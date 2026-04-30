from app.models.course_prerequisite import CoursePrerequisite
from app.models.course import Course
from fastapi import HTTPException


def add_prerequisite(data, db):

    course = db.query(Course).filter(
        Course.course_id == data.course_id
    ).first()

    if not course:
        raise HTTPException(
            status_code=404,  # FIX: was bare Exception() with no status code
            detail="Course not found"
        )

    prerequisite = db.query(Course).filter(
        Course.course_id == data.prerequisite_id
    ).first()

    if not prerequisite:
        raise HTTPException(
            status_code=404,  # FIX: was 400
            detail="Prerequisite course not found"
        )

    existing = db.query(CoursePrerequisite).filter(
        CoursePrerequisite.course_id == data.course_id,
        CoursePrerequisite.prerequisite_id == data.prerequisite_id
    ).first()

    if existing:
        raise HTTPException(
            status_code=409,  # FIX: was 401 — 409 Conflict is correct for duplicates
            detail="Prerequisite already exists"
        )

    prereq = CoursePrerequisite(
        course_id=data.course_id,
        prerequisite_id=data.prerequisite_id
    )

    db.add(prereq)
    db.commit()
    db.refresh(prereq)

    return prereq


def get_prerequisites(course_id, db):

    prereqs = db.query(CoursePrerequisite).filter(
        CoursePrerequisite.course_id == course_id
    ).all()

    return prereqs


def delete_prerequisite(prereq_id, db):

    prereq = db.query(CoursePrerequisite).filter(
        CoursePrerequisite.id == prereq_id
    ).first()

    if not prereq:
        raise HTTPException(
            status_code=404,  # FIX: was 402
            detail="Prerequisite not found"
        )

    db.delete(prereq)
    db.commit()

    return True
