from app.models.enrollment import Enrollment

from app.models.course import Course


GRADE_POINTS={

"A":4.0,

"A-":3.7,

"B+":3.3,

"B":3.0,

"B-":2.7,

"C+":2.3,

"C":2.0,

"C-":1.7,

"D":1.0,

"F":0.0

}


def calculate_gpa(

    student_id,

    db

):

    enrollments=db.query(

        Enrollment

    ).filter(

        Enrollment.student_id==student_id,

        Enrollment.status=="passed"

    ).all()


    total_points=0

    total_credits=0


    transcript=[]


    for e in enrollments:

        course=db.query(

            Course

        ).filter(

            Course.course_id==e.course_id

        ).first()


        if not course:

            continue


        if not e.grade:

            continue


        grade_value=GRADE_POINTS.get(

            e.grade,

            0

        )


        course_points=grade_value * course.credit_hours


        total_points+=course_points

        total_credits+=course.credit_hours


        transcript.append({

            "course_id":course.course_id,

            "credits":course.credit_hours,

            "grade":e.grade,

            "points":course_points

        })


    if total_credits==0:

        gpa=0

    else:

        gpa=total_points/total_credits


    return{

        "gpa":round(gpa,2),

        "total_points":total_points,

        "total_credits":total_credits,

        "courses":transcript

    }