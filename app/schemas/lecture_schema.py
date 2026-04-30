from pydantic import BaseModel
from datetime import datetime


class LectureCreate(BaseModel):

    course_id:int

    title:str

    description:str

    room:str

    lecture_datetime:datetime