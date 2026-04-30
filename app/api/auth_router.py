from fastapi import APIRouter ,Depends

from app.core.dependencies import get_db

from sqlalchemy.orm import Session

from app.schemas.auth_schema import RegisterRequest

from app.schemas.auth_schema import LoginRequest

from app.schemas.password_schema import ForgotPasswordRequest

from app.schemas.password_schema import ResetPasswordRequest

from app.services.auth_service import forgot_password

from app.services.auth_service import reset_password 

from app.services.auth_service import register_user

from app.services.auth_service import login_user

from app.db.database import SessionLocal 


router = APIRouter(

    prefix="/auth",

    tags=["Authentication"]

)


@router.post("/register")

def register(data: RegisterRequest):

    db = SessionLocal()

    user = register_user(

        data,

        db

    )

    return {

        "message":"User registered successfully",

        "user_id":user.user_id,

        "role":user.role,

        "is_active":user.is_active

    }


@router.post("/login")

def login(data: LoginRequest):

    db = SessionLocal()

    result = login_user(

        data,

        db

    )

    return result



@router.post("/forgot-password")

def forgot_password_endpoint(

    data:ForgotPasswordRequest,

    db:Session=Depends(get_db)

):

    return forgot_password(

        data,

        db

    )



@router.post("/reset-password")

def reset_password_endpoint(

    data:ResetPasswordRequest,

    db:Session=Depends(get_db)

):

    return reset_password(

        data,

        db

    )