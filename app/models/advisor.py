from sqlalchemy import Column, Integer, String, ForeignKey, TIMESTAMP
from sqlalchemy.sql import func
from app.db.database import Base


class Advisor(Base):

    __tablename__ = "advisors"

    advisor_id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    user_id = Column(
        Integer,
        ForeignKey("users.user_id"),
        unique=True
    )

    department = Column(String(100))

    phone = Column(String(20))

    created_at = Column(
        TIMESTAMP,
        server_default=func.now()
    )
