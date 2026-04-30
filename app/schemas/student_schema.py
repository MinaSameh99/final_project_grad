from pydantic import BaseModel


class StudentProfileUpdate(BaseModel):

    uni_id:str

    department:str

    level:int

    phone:str



class StudentResponse(BaseModel):

    student_id:int

    uni_id:str

    department:str

    level:int

    phone:str

    gpa:float

    class Config:

        from_attributes=True