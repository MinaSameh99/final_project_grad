from fastapi import APIRouter,Depends

from sqlalchemy.orm import Session

from app.core.dependencies import get_db

from app.core.dependencies import get_current_student , get_current_user

from app.schemas.student_schema import StudentProfileUpdate

from app.schemas.enrollment_schema import EnrollmentCreate

from app.services.student_service import complete_student_profile

from app.services.student_service import enroll_course

from app.services.student_service import get_my_enrollments

from app.services.student_service import get_my_approved_courses

from app.services.student_service import get_student

from app.services.gpa_service import calculate_gpa

from app.services.student_service import student_dashboard

from app.services.student_service import eligible_courses

from app.services.student_service import get_courses_overview          # NEW


from app.models.student import Student

router = APIRouter(

    prefix="/student",

    tags=["Student"]

)



@router.post("/complete-profile")

def complete_profile(

    data:StudentProfileUpdate,

    db:Session=Depends(get_db),

    current_student=Depends(get_current_student)

):

    student = complete_student_profile(

        current_student,

        data,

        db

    )


    return{

        "message":"Profile completed"

    }




@router.post("/enroll-course")

def enroll(

    data:EnrollmentCreate,

    db:Session=Depends(get_db),

    current_student=Depends(get_current_student)

):

    enrollment=enroll_course(

        current_student,

        data,

        db

    )


    return{

        "message":"Enrollment request sent",

        "enrollment_id":enrollment.enrollment_id

    }




@router.get("/my-enrollments")

def my_enrollments(

    db:Session=Depends(get_db),

    current_student=Depends(get_current_student)

):

    enrollments=get_my_enrollments(

        current_student,

        db

    )


    result=[]


    for e in enrollments:

        result.append({

            "enrollment_id":e.enrollment_id,

            "course_id":e.course_id,

            "status":e.status,

            "approval":e.approval_status

        })


    return result




@router.get("/my-courses")

def my_courses(

    db:Session=Depends(get_db),

    current_student=Depends(get_current_student)

):

    courses=get_my_approved_courses(

        current_student,

        db

    )


    result=[]


    for c in courses:

        result.append({

            "course_id":c.course_id,

            "status":c.status

        })


    return result




@router.get("/profile")

def my_profile(

    db:Session=Depends(get_db),

    current_student=Depends(get_current_student)

):

    student=get_student(

        current_student,

        db

    )


    return{

        "student_id":student.student_id,

        "university_id":student.uni_id,

        "department":student.department,

        "level":student.level,

        "phone":student.phone,

        "gpa":student.gpa

    }


@router.get("/transcript")

def transcript(

    db:Session=Depends(get_db),

    current_user=Depends(get_current_user)

):

    student=db.query(

        Student

    ).filter(

        Student.user_id==current_user.user_id

    ).first()


    result=calculate_gpa(

        student.student_id,

        db

    )


    return result




@router.get("/dashboard")

def dashboard(

    db:Session=Depends(get_db),

    current_user=Depends(get_current_user)

):

    return student_dashboard(

        current_user,

        db

    )


@router.get("/eligible-courses")

def get_eligible(

    db:Session=Depends(get_db),

    current_user=Depends(get_current_user)

):

    return eligible_courses(

        current_user,

        db

    )


@router.get("/courses-overview")
def courses_overview(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """Returns both eligible and locked courses for the logged-in student."""
    return get_courses_overview(current_user, db)