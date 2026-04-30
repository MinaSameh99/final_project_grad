from pydantic import BaseModel, EmailStr


class RegisterRequest(BaseModel):

    full_name: str

    email: EmailStr

    password: str

    code: str


class LoginRequest(BaseModel):

    email: EmailStr

    password: str


class TokenResponse(BaseModel):

    access_token: str

    token_type: str

    role: str

    user_id: int