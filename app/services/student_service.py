# app/services/student_service.py

from app.models.student import Student
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.course_prerequisite import CoursePrerequisite
from app.services.gpa_service import calculate_gpa
from fastapi import HTTPException


def get_student(current_user, db):
    return db.query(Student).filter(
        Student.user_id == current_user.user_id
    ).first()


def complete_student_profile(current_user, data, db):
    student = db.query(Student).filter(
        Student.user_id == current_user.user_id
    ).first()

    if not student:
        raise HTTPException(status_code=400, detail="Student not found")

    if not student.uni_id:
        student.uni_id = data.uni_id

    if data.department:
        student.department = data.department

    if data.level:
        student.level = data.level

    if data.phone:
        student.phone = data.phone

    db.commit()
    db.refresh(student)
    return student


def check_prerequisites(student_id, course_id, db):
    """
    Returns True only if every prerequisite course has been PASSED.
    A failed or registered enrollment does NOT satisfy a prerequisite.
    """
    prerequisites = db.query(CoursePrerequisite).filter(
        CoursePrerequisite.course_id == course_id
    ).all()

    if not prerequisites:
        return True

    for p in prerequisites:
        passed = db.query(Enrollment).filter(
            Enrollment.student_id == student_id,
            Enrollment.course_id  == p.prerequisite_id,
            Enrollment.status     == "passed",          # must be PASSED
        ).first()
        if not passed:
            return False

    return True


def enroll_course(current_user, data, db):
    student = get_student(current_user, db)

    course = db.query(Course).filter(
        Course.course_id == data.course_id
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    # ── Block only ACTIVE enrollments (pending or approved, not failed/rejected) ──
    # A student is allowed to re-enroll in a course they previously failed or
    # whose enrollment was rejected.
    active_enrollment = db.query(Enrollment).filter(
        Enrollment.student_id      == student.student_id,
        Enrollment.course_id       == data.course_id,
        Enrollment.status          == "registered",
        Enrollment.approval_status.in_(["pending", "approved"]),
    ).first()

    if active_enrollment:
        raise HTTPException(
            status_code=400,
            detail="Already enrolled or enrollment pending approval"
        )

    # ── Block if already passed ───────────────────────────────────────────────
    passed_enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == student.student_id,
        Enrollment.course_id  == data.course_id,
        Enrollment.status     == "passed",
    ).first()

    if passed_enrollment:
        raise HTTPException(
            status_code=400,
            detail="You have already passed this course"
        )

    # ── Check prerequisites ───────────────────────────────────────────────────
    if not check_prerequisites(student.student_id, data.course_id, db):
        raise HTTPException(
            status_code=403,
            detail="Prerequisite not completed — you must PASS all prerequisite courses first"
        )

    # ── Check capacity ────────────────────────────────────────────────────────
    current_count = db.query(Enrollment).filter(
        Enrollment.course_id       == data.course_id,
        Enrollment.approval_status == "approved",
    ).count()

    if current_count >= course.capacity:
        raise HTTPException(status_code=400, detail="Course is full")

    enrollment = Enrollment(
        student_id      = student.student_id,
        course_id       = data.course_id,
        advisor_id      = course.advisor_id,
        status          = "registered",
        approval_status = "pending",
    )
    db.add(enrollment)
    db.commit()
    db.refresh(enrollment)
    return enrollment


def get_my_enrollments(current_user, db):
    student = get_student(current_user, db)
    return db.query(Enrollment).filter(
        Enrollment.student_id == student.student_id
    ).all()


def get_my_approved_courses(current_user, db):
    student = get_student(current_user, db)
    return db.query(Enrollment).filter(
        Enrollment.student_id      == student.student_id,
        Enrollment.approval_status == "approved",
    ).all()


def student_dashboard(current_user, db):
    student = db.query(Student).filter(
        Student.user_id == current_user.user_id
    ).first()
    gpa_data = calculate_gpa(student.student_id, db)
    return {
        "current_gpa":       gpa_data["gpa"],
        "completed_credits": gpa_data["total_credits"],
    }


def eligible_courses(current_user, db):
    """Simple list — only used by the old endpoint, kept for compatibility."""
    student = db.query(Student).filter(
        Student.user_id == current_user.user_id
    ).first()

    passed_rows = db.query(Enrollment.course_id).filter(
        Enrollment.student_id == student.student_id,
        Enrollment.status     == "passed",
    ).all()
    passed_ids = {r[0] for r in passed_rows}

    courses = db.query(Course).all()
    result  = []

    for course in courses:
        if course.course_id in passed_ids:
            continue
        prereqs    = db.query(CoursePrerequisite).filter(
            CoursePrerequisite.course_id == course.course_id
        ).all()
        prereq_ids = [p.prerequisite_id for p in prereqs]
        if not set(prereq_ids).issubset(passed_ids):
            continue
        result.append({
            "course_id":   course.course_id,
            "course_name": course.course_name,
            "credits":     course.credit_hours,
        })

    return result


def get_courses_overview(current_user, db):
    """
    Returns eligible and locked courses for the home screen.

    Rules:
    ──────
    SKIP a course entirely when the student:
      • has PASSED it  (status="passed")
      • has an ACTIVE enrollment in it:
            status="registered" AND approval_status IN ("pending","approved")

    SHOW a course (eligible OR locked) when the student:
      • has no enrollment at all
      • has a FAILED enrollment  (status="failed")  → can re-enroll
      • has a REJECTED enrollment (approval_status="rejected") → can re-enroll

    ELIGIBLE  = all prerequisite courses have status="passed"
    LOCKED    = at least one prerequisite course does NOT have status="passed"
                (failed ≠ passed, so failing a prereq keeps the dependent locked)
    """
    student = db.query(Student).filter(
        Student.user_id == current_user.user_id
    ).first()

    if not student:
        return {"eligible": [], "locked": []}

    # ── Passed course IDs (prerequisites are checked against this set) ────────
    passed_rows = db.query(Enrollment.course_id).filter(
        Enrollment.student_id == student.student_id,
        Enrollment.status     == "passed",
    ).all()
    passed_ids = {r[0] for r in passed_rows}

    # ── Active enrollment IDs (pending or approved, not finished yet) ─────────
    # These are courses the student is currently enrolled in and we should hide.
    active_rows = db.query(Enrollment.course_id).filter(
        Enrollment.student_id      == student.student_id,
        Enrollment.status          == "registered",
        Enrollment.approval_status.in_(["pending", "approved"]),
    ).all()
    active_ids = {r[0] for r in active_rows}

    all_courses = db.query(Course).all()
    eligible    = []
    locked      = []

    for course in all_courses:
        cid = course.course_id

        # Skip already-passed courses
        if cid in passed_ids:
            continue

        # Skip courses the student is currently registered in (pending/approved)
        if cid in active_ids:
            continue

        # Determine prerequisite satisfaction
        prereqs    = db.query(CoursePrerequisite).filter(
            CoursePrerequisite.course_id == cid
        ).all()
        prereq_ids = [p.prerequisite_id for p in prereqs]

        # Missing = prereqs that are NOT in the passed set
        # A FAILED prereq is missing because failed ≠ passed
        missing_ids = [pid for pid in prereq_ids if pid not in passed_ids]

        base = {
            "course_id":   cid,
            "course_name": course.course_name,
            "credits":     course.credit_hours,
            "department":  course.department or "",
            "level":       course.level,
        }

        if not missing_ids:
            eligible.append(base)
        else:
            # Resolve missing prerequisite names for the UI
            missing_names = []
            for pid in missing_ids:
                pc = db.query(Course).filter(Course.course_id == pid).first()
                if pc:
                    missing_names.append(pc.course_name)
            locked.append({**base, "missing_prerequisites": missing_names})

    return {"eligible": eligible, "locked": locked}