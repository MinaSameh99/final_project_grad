from sqlalchemy import Column,Integer,ForeignKey,DateTime,Enum, String

from sqlalchemy.sql import func

from app.db.database import Base


class Enrollment(Base):

    __tablename__="enrollments"


    enrollment_id = Column(
        Integer,
        primary_key=True,
        index=True
    )


    student_id = Column(
        Integer,
        ForeignKey("students.student_id")
    )


    course_id = Column(
        Integer,
        ForeignKey("courses.course_id")
    )


    advisor_id = Column(
        Integer,
        ForeignKey("advisors.advisor_id")
    )


    enrollment_date = Column(
        DateTime,
        server_default=func.now()
    )


    status = Column(
        Enum('registered','passed','failed'),
        default="registered"
    )


    approval_status = Column(
        Enum('pending','approved','rejected'),
        default="pending"
    )

    grade = Column(
    String(2),
    nullable=True
)