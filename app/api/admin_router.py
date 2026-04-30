# app/api/admin_router.py

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_admin, get_db
from app.schemas.course_schema import CourseCreate
from app.schemas.prerequisite_schema import PrerequisiteCreate
from app.schemas.admin_schema import EnrollmentApproval

from app.services.admin_service import (
    get_pending_users,
    approve_user,
    create_course,
    get_all_courses,
    delete_course,
    get_all_advisors,
    get_pending_enrollments,
    approve_enrollment,
    reject_enrollment,
)
from app.services.prerequisite_service import (
    add_prerequisite,
    get_prerequisites,
    delete_prerequisite,
)

router = APIRouter(prefix="/admin", tags=["Admin"])


# ── Users ─────────────────────────────────────────────────────────────────────

@router.get("/pending-users")
def pending_users(
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    users = get_pending_users(db)
    return [
        {
            "user_id": u.user_id,
            "name":    u.full_name,
            "email":   u.email,
            "role":    u.role,
        }
        for u in users
    ]


@router.put("/approve/{user_id}")
def approve(
    user_id: int,
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    user = approve_user(user_id, db)
    return {"message": "User approved", "user_id": user.user_id}


# ── Advisors list ─────────────────────────────────────────────────────────────

@router.get("/advisors")
def list_advisors(
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    """Returns all active advisors — used to populate the advisor dropdown."""
    return get_all_advisors(db)


# ── Courses ───────────────────────────────────────────────────────────────────

@router.get("/courses")
def list_courses(
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    return get_all_courses(db)


@router.post("/create-course")
def create_new_course(
    data: CourseCreate,
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    course = create_course(data, db)
    return {
        "message":     "Course created",
        "course_id":   course.course_id,
        "course_name": course.course_name,
    }


@router.delete("/courses/{course_id}")
def remove_course(
    course_id: int,
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    delete_course(course_id, db)
    return {"message": "Course deleted"}


# ── Prerequisites ─────────────────────────────────────────────────────────────

@router.post("/add-prerequisite")
def add_prerequisite_endpoint(
    data: PrerequisiteCreate,
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    prereq = add_prerequisite(data, db)
    return {"message": "Prerequisite added", "id": prereq.id}


@router.get("/course-prerequisites/{course_id}")
def course_prerequisites(
    course_id: int,
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    prereqs = get_prerequisites(course_id, db)
    return [
        {
            "id":              p.id,
            "course_id":       p.course_id,
            "prerequisite_id": p.prerequisite_id,
        }
        for p in prereqs
    ]


@router.delete("/delete-prerequisite/{prereq_id}")
def delete_prereq(
    prereq_id: int,
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    delete_prerequisite(prereq_id, db)
    return {"message": "Prerequisite deleted"}


# ── Enrollments ───────────────────────────────────────────────────────────────

@router.get("/pending-enrollments")
def pending_enrollments(
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    enrollments = get_pending_enrollments(db)
    return [
        {
            "enrollment_id": e.enrollment_id,
            "student_id":    e.student_id,
            "course_id":     e.course_id,
            "status":        e.approval_status,
        }
        for e in enrollments
    ]


@router.post("/approve-enrollment")
def approve_enroll(
    data: EnrollmentApproval,
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    enrollment = approve_enrollment(data.enrollment_id, db)
    return {
        "message":       "Enrollment approved",
        "enrollment_id": enrollment.enrollment_id,
    }


@router.post("/reject-enrollment")
def reject_enroll(
    data: EnrollmentApproval,
    db: Session = Depends(get_db),
    admin       = Depends(get_current_admin),
):
    reject_enrollment(data.enrollment_id, db)
    return {"message": "Enrollment rejected"}