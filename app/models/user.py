from sqlalchemy import Column, Integer, String, DateTime, Boolean, TIMESTAMP
from sqlalchemy.sql import func
from app.db.database import Base
from sqlalchemy.orm import relationship


class User(Base):

    __tablename__ = "users"

    user_id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    full_name = Column(String(100))

    email = Column(
        String(100),
        unique=True,
        index=True
    )

    password = Column(String(255))

    role = Column(String(20))

    is_active = Column(
        Boolean,
        default=False
    )

    created_at = Column(
        TIMESTAMP,
        server_default=func.now()
    )

    reset_token = Column(
        String(255),
        nullable=True
    )

    reset_expires = Column(
        DateTime,
        nullable=True
    )
