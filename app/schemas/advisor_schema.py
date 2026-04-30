from pydantic import BaseModel


class AdvisorProfileResponse(BaseModel):

    advisor_id:int

    advisor_name:str

    department:str

    phone:str

    courses:list[str]


class AdvisorProfileUpdate(BaseModel):

    phone: str
    department: str