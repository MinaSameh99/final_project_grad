from pydantic import BaseModel


class NotificationResponse(BaseModel):

    id:int

    title:str

    message:str

    is_read:bool

    type:str

    class Config:

        from_attributes=True