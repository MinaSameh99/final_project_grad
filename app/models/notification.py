from sqlalchemy import Column,Integer,String,Text,Boolean,ForeignKey,DateTime

from sqlalchemy.sql import func

from app.db.database import Base


class Notification(Base):

    __tablename__="notifications"


    id=Column(

        Integer,

        primary_key=True

    )


    user_id=Column(

        Integer,

        ForeignKey("users.user_id")

    )


    title=Column(

        String(100)

    )


    message=Column(

        Text
    )


    is_read=Column(

        Boolean,

        default=False

    )


    created_at=Column(

        DateTime,

        server_default=func.now()

    )


    type=Column(

        String(50),

        default="system"

    )