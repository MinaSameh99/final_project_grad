from pydantic import BaseModel


class ApproveUserRequest(BaseModel):

    user_id:int


class UserResponse(BaseModel):

    user_id:int

    full_name:str

    email:str

    role:str

    is_active:bool



class EnrollmentApproval(BaseModel):

    enrollment_id:int