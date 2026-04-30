from sqlalchemy.orm import Session
from fastapi import HTTPException
from datetime import datetime, timedelta
import secrets

from app.models.user import User
from app.models.student import Student
from app.models.advisor import Advisor
from app.models.admin import Admin

from app.schemas.auth_schema import RegisterRequest

from app.core.security import hash_password
from app.core.security import verify_password
from app.core.security import create_access_token

from app.services.notification_service import create_notification


def register_user(data: RegisterRequest, db: Session):

    # Minimum password length
    if len(data.password) < 8:
        raise HTTPException(
            status_code=400,
            detail="Password must be at least 8 characters"
        )

    code = data.code.lower().strip()

    existing = db.query(User).filter(
        User.email == data.email
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Email already registered"
        )

    role_map = {
        "st": "student",
        "ad": "admin",
        "do": "advisor"
    }

    if code not in role_map:
        raise HTTPException(
            status_code=400,
            detail="Invalid approval code"
        )

    role = role_map[code]

    is_active = False

    if role == "admin":
        admin_count = db.query(User).filter(
            User.role == "admin"
        ).count()

        if admin_count == 0:
            is_active = True

    hashed = hash_password(data.password)

    # FIX: removed code=code — User model has no such column
    new_user = User(
        full_name=data.full_name,
        email=data.email,
        password=hashed,
        role=role,
        is_active=is_active
    )

    db.add(new_user)
    db.flush()

    # Student profile
    if role == "student":
        student = Student(
            user_id=new_user.user_id,
            gpa=0
        )
        db.add(student)

    # Advisor profile
    if role == "advisor":
        advisor = Advisor(
            user_id=new_user.user_id
        )
        db.add(advisor)

    # Admin profile
    if role == "admin":
        admin = Admin(
            user_id=new_user.user_id
        )
        db.add(admin)

    db.commit()
    db.refresh(new_user)

    return new_user


def login_user(data, db):

    user = db.query(User).filter(
        User.email == data.email
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    if not verify_password(data.password, user.password):
        raise HTTPException(
            status_code=401,
            detail="Incorrect password"
        )

    if not user.is_active:
        raise HTTPException(
            status_code=403,
            detail="Account waiting admin approval"
        )

    token = create_access_token({
        "user_id": user.user_id,
        "role": user.role
    })

    return {
        "access_token": token,
        "token_type": "bearer",
        "role": user.role,
        "user_id": user.user_id
    }


# Forgot password
def forgot_password(data, db):

    user = db.query(User).filter(
        User.email == data.email
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    token = secrets.token_urlsafe(32)

    expire_time = datetime.utcnow() + timedelta(minutes=15)

    user.reset_token = token
    user.reset_expires = expire_time

    db.commit()

    return {
        "message": "Reset token generated",
        "token": token
    }


# Reset password
def reset_password(data, db):

    user = db.query(User).filter(
        User.reset_token == data.token
    ).first()

    if not user:
        raise HTTPException(
            status_code=400,
            detail="Invalid token"
        )

    if user.reset_expires < datetime.utcnow():
        raise HTTPException(
            status_code=400,
            detail="Token expired"
        )

    # Minimum password length
    if len(data.new_password) < 8:
        raise HTTPException(
            status_code=400,
            detail="Password must be at least 8 characters"
        )

    user.password = hash_password(data.new_password)
    user.reset_token = None
    user.reset_expires = None

    db.commit()

    # Password reset notification
    create_notification(
        user.user_id,
        "Password Reset",
        "Your password was successfully changed",
        db
    )

    return {
        "message": "Password updated"
    }
