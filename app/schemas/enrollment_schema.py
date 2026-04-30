from pydantic import BaseModel


class EnrollmentCreate(BaseModel):

    course_id:int



class EnrollmentResponse(BaseModel):

    enrollment_id:int

    course_id:int

    status:str

    approval_status:str

    class Config:

        from_attributes=True