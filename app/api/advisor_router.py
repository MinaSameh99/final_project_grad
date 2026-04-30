from fastapi import APIRouter,Depends

from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user , get_current_advisor

from app.core.dependencies import get_db

from app.services.advisor_service import create_lecture

from app.services.advisor_service import get_my_lectures

from app.schemas.lecture_schema import LectureCreate

from app.schemas.grade_schema import GradeAssign

from app.services.advisor_service import assign_grade

from app.services.advisor_service import get_my_students

from app.services.advisor_service import get_advisor_profile

from app.services.advisor_service import complete_advisor_profile   # NEW

from app.schemas.advisor_schema import AdvisorProfileUpdate          # NEW

from app.models.user import User


router = APIRouter(

    prefix="/advisor",

    tags=["Advisor"]

)


@router.post("/create-lecture")

def create_new_lecture(

    data:LectureCreate,

    db:Session = Depends(get_db),

    current_advisor = Depends(get_current_advisor)

):

    lecture = create_lecture(

        current_advisor,

        data,

        db

    )

    return {

        "message":"Lecture created successfully",

        "lecture_id":lecture.lecture_id

    }

@router.get("/my-lectures")

def my_lectures(

    db:Session = Depends(get_db),

    current_user = Depends(get_current_user)

):

    lectures = get_my_lectures(

        current_user,

        db

    )

    result=[]

    for l in lectures:

        result.append({

            "lecture_id":l.lecture_id,

            "course_id":l.course_id,

            "title":l.title,

            "description":l.description,

            "room":l.room,

            "lecture_datetime":l.lecture_datetime

        })

    return result


@router.post("/assign-grade")

def assign_student_grade(

    data:GradeAssign,

    db:Session=Depends(get_db),

    current_user=Depends(get_current_user)

):

    enrollment=assign_grade(

        current_user,

        data,

        db

    )


    return{

        "message":"Grade assigned",

        "student":enrollment.student_id,

        "grade":enrollment.grade,

        "status":enrollment.status

    }


@router.get("/my-students")

def my_students(

    db:Session=Depends(get_db),

    current_user=Depends(get_current_user)

):

    return get_my_students(

        current_user,

        db

    )


@router.get(

"/profile"

)

def advisor_profile(

    current_user:User=Depends(get_current_user),

    db:Session=Depends(get_db)

):

    return get_advisor_profile(

        current_user,

        db

    )


# ── NEW endpoint ─────────────────────────────────────────────────────────────
@router.post("/complete-profile")
def complete_profile(
    data: AdvisorProfileUpdate,
    db: Session = Depends(get_db),
    current_advisor=Depends(get_current_advisor),
):
    advisor = complete_advisor_profile(current_advisor, data, db)
    return {
        "message":    "Profile completed",
        "advisor_id": advisor.advisor_id,
    }