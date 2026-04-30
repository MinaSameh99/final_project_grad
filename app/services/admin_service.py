# app/services/admin_service.py

from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.user import User
from app.models.course import Course
from app.models.advisor import Advisor
from app.models.student import Student
from app.models.enrollment import Enrollment
from app.services.notification_service import create_notification


# ── Pending users ─────────────────────────────────────────────────────────────

def get_pending_users(db: Session):
    return db.query(User).filter(User.is_active == False).all()


def approve_user(user_id: int, db: Session):
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_active = True
    db.commit()
    return user


# ── Courses ───────────────────────────────────────────────────────────────────

def create_course(data, db):
    advisor = db.query(Advisor).filter(
        Advisor.advisor_id == data.advisor_id
    ).first()
    if not advisor:
        raise HTTPException(status_code=400, detail="Advisor not found")

    # Check for duplicate course code
    existing = db.query(Course).filter(
        Course.course_code == data.course_code
    ).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"Course code '{data.course_code}' is already used"
        )

    course = Course(
        course_name  = data.course_name,
        course_code  = data.course_code,
        credit_hours = data.credit_hours,
        department   = data.department,
        level        = data.level,
        semester     = data.semester,
        year         = data.year,
        advisor_id   = data.advisor_id,
        capacity     = data.capacity,
    )
    db.add(course)
    db.commit()
    db.refresh(course)
    return course


def get_all_courses(db: Session):
    """Returns all courses with their advisor's name."""
    courses = db.query(Course).all()
    result  = []

    for c in courses:
        advisor_name = ""
        if c.advisor_id:
            advisor = db.query(Advisor).filter(
                Advisor.advisor_id == c.advisor_id
            ).first()
            if advisor:
                user = db.query(User).filter(
                    User.user_id == advisor.user_id
                ).first()
                if user:
                    advisor_name = user.full_name

        result.append({
            "course_id":    c.course_id,
            "course_name":  c.course_name,
            "course_code":  c.course_code,
            "credit_hours": c.credit_hours,
            "department":   c.department or "",
            "level":        c.level,
            "semester":     c.semester or "",
            "year":         c.year,
            "advisor_id":   c.advisor_id,
            "advisor_name": advisor_name,
            "capacity":     c.capacity,
        })

    return result


def delete_course(course_id: int, db: Session):
    course = db.query(Course).filter(Course.course_id == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    # Block deletion if students are enrolled
    enrolled_count = db.query(Enrollment).filter(
        Enrollment.course_id       == course_id,
        Enrollment.approval_status == "approved",
    ).count()
    if enrolled_count > 0:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot delete: {enrolled_count} student(s) are enrolled"
        )

    db.delete(course)
    db.commit()
    return True


# ── Advisors list (for course creation dropdown) ──────────────────────────────

def get_all_advisors(db: Session):
    """Returns all active advisors with their names — used by create-course form."""
    advisors = db.query(Advisor).all()
    result   = []

    for a in advisors:
        user = db.query(User).filter(
            User.user_id   == a.user_id,
            User.is_active == True,
        ).first()
        if user:
            result.append({
                "advisor_id": a.advisor_id,
                "name":       user.full_name,
                "department": a.department or "",
            })

    return result


# ── Enrollments ───────────────────────────────────────────────────────────────

def get_pending_enrollments(db):
    return db.query(Enrollment).filter(
        Enrollment.approval_status == "pending"
    ).all()


def approve_enrollment(enrollment_id, db):
    enrollment = db.query(Enrollment).filter(
        Enrollment.enrollment_id == enrollment_id
    ).first()
    if not enrollment:
        raise HTTPException(status_code=404, detail="Enrollment not found")

    enrollment.approval_status = "approved"

    student = db.query(Student).filter(
        Student.student_id == enrollment.student_id
    ).first()
    if student:
        create_notification(
            student.user_id,
            "Enrollment Approved",
            "Your enrollment request has been approved",
            db,
            "enrollment",
        )

    db.commit()
    db.refresh(enrollment)
    return enrollment


def reject_enrollment(enrollment_id, db):
    enrollment = db.query(Enrollment).filter(
        Enrollment.enrollment_id == enrollment_id
    ).first()
    if not enrollment:
        raise HTTPException(status_code=404, detail="Enrollment not found")

    enrollment.approval_status = "rejected"

    student = db.query(Student).filter(
        Student.student_id == enrollment.student_id
    ).first()
    if student:
        create_notification(
            student.user_id,
            "Enrollment Rejected",
            "Your enrollment request was rejected",
            db,
            "enrollment",
        )

    db.commit()
    return True