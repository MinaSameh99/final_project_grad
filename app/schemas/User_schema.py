from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):

    full_name: str

    email: EmailStr

    password: str

    approval_code: str


class UserLogin(BaseModel):

    email: EmailStr

    password: str



from datetime import datetime
from typing import Optional

class UserResponse(BaseModel):

    user_id: int

    full_name: str

    email: EmailStr

    role: str

    phone : str

    is_active: bool

    created_at: Optional[datetime]

    class Config:

        from_attributes = True