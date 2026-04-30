from sqlalchemy.orm import Session
from fastapi import HTTPException

from app.models.user import User
from app.models.advisor import Advisor
from app.models.lecture import Lecture
from app.models.student import Student
from app.models.enrollment import Enrollment
from app.models.course import Course
from app.services.notification_service import create_notification


def create_lecture(user: User, data, db: Session):

    if user.role != "advisor":
        raise HTTPException(
            status_code=403,
            detail="Only advisors allowed"
        )

    advisor = db.query(Advisor).filter(
        Advisor.user_id == user.user_id
    ).first()

    if not advisor:
        raise HTTPException(
            status_code=404,
            detail="Advisor profile not found"
        )

    lecture = Lecture(
        advisor_id=advisor.advisor_id,
        course_id=data.course_id,
        title=data.title,
        description=data.description,
        room=data.room,
        lecture_datetime=data.lecture_datetime
    )

    db.add(lecture)
    db.flush()

    # Find students enrolled in this course
    enrollments = db.query(Enrollment).filter(
        Enrollment.course_id == lecture.course_id,
        Enrollment.approval_status == "approved"
    ).all()

    # FIX: both the student query and notification call are now
    # inside the for loop so every student gets notified
    for enrollment in enrollments:

        student = db.query(Student).filter(
            Student.student_id == enrollment.student_id
        ).first()

        if student:
            create_notification(
                student.user_id,
                "New Lecture Available",
                f"New lecture posted: {lecture.title}",
                db,
                "lecture"
            )

    # FIX: commit once after the loop, not inside it
    db.commit()

    return lecture


def get_my_lectures(user: User, db: Session):

    advisor = db.query(Advisor).filter(
        Advisor.user_id == user.user_id
    ).first()

    lectures = db.query(Lecture).filter(
        Lecture.advisor_id == advisor.advisor_id
    ).all()

    return lectures


def assign_grade(current_user, data, db):

    advisor = db.query(Advisor).filter(
        Advisor.user_id == current_user.user_id
    ).first()

    if not advisor:
        raise HTTPException(
            status_code=400,  # FIX: was 400
            detail="Advisor not found"
        )

    enrollment = db.query(Enrollment).filter(
        Enrollment.enrollment_id == data.enrollment_id
    ).first()

    if not enrollment:
        raise HTTPException(
            status_code=404,  # FIX: was 401
            detail="Enrollment not found"
        )

    if enrollment.advisor_id != advisor.advisor_id:
        raise HTTPException(
            status_code=403,
            detail="Not your student"
        )

    if enrollment.approval_status != "approved":
        raise HTTPException(
            status_code=400,
            detail="Student not approved"
        )

    enrollment.grade = data.grade

    if data.grade == "F":
        enrollment.status = "failed"
    else:
        enrollment.status = "passed"

    db.commit()
    db.refresh(enrollment)

    return enrollment


def get_my_students(current_user, db):

    advisor = db.query(Advisor).filter(
        Advisor.user_id == current_user.user_id
    ).first()

    enrollments = db.query(Enrollment).filter(
        Enrollment.advisor_id == advisor.advisor_id,
        Enrollment.approval_status == "approved"
    ).all()

    result = []

    for e in enrollments:

        student = db.query(Student).filter(
            Student.student_id == e.student_id
        ).first()

        course = db.query(Course).filter(
            Course.course_id == e.course_id
        ).first()

        # Get full name from the users table
        student_user = None
        if student:
            student_user = db.query(User).filter(
                User.user_id == student.user_id
            ).first()

        result.append({
            "enrollment_id": e.enrollment_id,
            "student_id":    student.student_id if student else 0,
            "student_name":  student_user.full_name if student_user else "Unknown",
            "uni_id":        student.uni_id if student else "",
            "course":        course.course_name if course else f"Course #{e.course_id}",
            "grade":         e.grade,
            "status":        e.status,
        })

    return result


def get_advisor_profile(current_user, db):

    advisor = db.query(Advisor).filter(
        Advisor.user_id == current_user.user_id
    ).first()

    if not advisor:
        raise HTTPException(
            status_code=404,
            detail="Advisor not found"
        )

    user = db.query(User).filter(
        User.user_id == advisor.user_id).first()

    courses = db.query(Course).filter(
        Course.advisor_id == advisor.advisor_id).all()

    course_names = []

    for course in courses:
        course_names.append(course.course_name)

    return {
        "advisor_id": advisor.advisor_id,
        "advisor_name": user.full_name,
        "department": advisor.department,
        "phone": advisor.phone,
        "courses":      [c.course_name for c in courses],
    }


# ── NEW: called by POST /advisor/complete-profile ────────────────────────────
def complete_advisor_profile(current_user, data, db):

    advisor = db.query(Advisor).filter(
        Advisor.user_id == current_user.user_id
    ).first()

    if not advisor:
        raise HTTPException(status_code=404, detail="Advisor not found")

    advisor.phone      = data.phone
    advisor.department = data.department

    db.commit()
    db.refresh(advisor)
    return advisor