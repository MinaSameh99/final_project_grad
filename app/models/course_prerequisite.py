from sqlalchemy import Column,Integer,ForeignKey

from app.db.database import Base


class CoursePrerequisite(Base):

    __tablename__="course_prerequisites"


    id = Column(
        Integer,
        primary_key=True
    )


    course_id = Column(
        Integer,
        ForeignKey("courses.course_id")
    )


    prerequisite_id = Column(
        Integer,
        ForeignKey("courses.course_id")
    )