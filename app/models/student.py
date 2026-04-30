from sqlalchemy import Column,Integer,String,ForeignKey,DateTime,DECIMAL

from sqlalchemy.sql import func

from app.db.database import Base


class Student(Base):

    __tablename__="students"


    student_id = Column(
        Integer,
        primary_key=True,
        index=True
    )


    user_id = Column(
        Integer,
        ForeignKey("users.user_id")
    )


    uni_id = Column(
        String(50),
        unique=True
    )


    department = Column(
        String(100)
    )


    level = Column(
        Integer
    )


    phone = Column(
        String(20)
    )


    advisor_id = Column(
        Integer,
        ForeignKey("advisors.advisor_id")
    )


    created_at = Column(
        DateTime,
        server_default=func.now()
    )


    gpa = Column(
        DECIMAL(3,2),
        default=0.00
    )