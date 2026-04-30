from sqlalchemy import Column,Integer,ForeignKey,DateTime,text

from app.db.database import Base


class Admin(Base):

    __tablename__="admins"


    admin_id=Column(

        Integer,

        primary_key=True,

        autoincrement=True

    )


    user_id=Column(

        Integer,

        ForeignKey("users.user_id"),

        unique=True

    )


    created_at=Column(

        DateTime,

        server_default=text("CURRENT_TIMESTAMP")

    )