from pydantic import BaseModel , validator


class GradeAssign(BaseModel):
    
    
    enrollment_id:int

    grade:str