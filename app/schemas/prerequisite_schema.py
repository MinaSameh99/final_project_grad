from pydantic import BaseModel


class PrerequisiteCreate(BaseModel):

    course_id:int

    prerequisite_id:int



class PrerequisiteResponse(BaseModel):

    id:int

    course_id:int

    prerequisite_id:int

    class Config:

        from_attributes=True