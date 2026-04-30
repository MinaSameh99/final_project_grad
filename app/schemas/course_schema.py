from pydantic import BaseModel


class CourseCreate(BaseModel):

    course_name:str

    course_code:str

    credit_hours:int

    department:str

    level:int

    semester:str

    year:int

    advisor_id : int

    capacity:int