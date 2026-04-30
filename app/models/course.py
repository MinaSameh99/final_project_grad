from sqlalchemy import Column,Integer,String,ForeignKey

from app.db.database import Base


class Course(Base):

    __tablename__="courses"


    course_id = Column(

        Integer,

        primary_key=True,

        index=True

    )


    course_name = Column(

        String(100)

    )


    course_code = Column(

        String(50),

        unique=True

    )


    credit_hours = Column(

        Integer

    )


    department = Column(

        String(100)

    )


    level = Column(

        Integer

    )


    semester = Column(

        String(20)

    )


    year = Column(

        Integer

    )


    advisor_id = Column(

        Integer,

        ForeignKey("advisors.advisor_id")

    )


    capacity = Column(

        Integer,

        default=50

    )