from sqlalchemy import Column,Integer,ForeignKey,TIMESTAMP,DateTime,String,Text
from sqlalchemy.sql import func

from app.db.database import Base


class Lecture(Base):

    __tablename__="lectures"

    lecture_id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    advisor_id = Column(
        Integer,
        ForeignKey("advisors.advisor_id")
    )

    course_id = Column(
        Integer,
        ForeignKey("courses.course_id")
    )

    title = Column(
        String(255)
    )

    description = Column(
        Text
    )

    room = Column(
        String(50)
    )

    lecture_datetime = Column(
        DateTime
    )

    created_at = Column(
        TIMESTAMP,
        server_default=func.now()
    )