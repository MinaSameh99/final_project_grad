from fastapi import APIRouter,Depends

from sqlalchemy.orm import Session

from app.core.dependencies import get_db

from app.core.dependencies import get_current_user

from app.services.notification_service import get_user_notifications

from app.services.notification_service import mark_as_read


router=APIRouter(

    prefix="/notifications",

    tags=["Notifications"]

)



@router.get("/my")

def my_notifications(

    db:Session=Depends(get_db),

    current_user=Depends(get_current_user)

):

    notifications=get_user_notifications(

        current_user.user_id,

        db

    )


    result=[]


    for n in notifications:

        result.append({

            "id":n.id,

            "title":n.title,

            "message":n.message,

            "read":n.is_read,

            "type":n.type

        })


    return result




@router.post("/read/{notification_id}")

def read_notification(

    notification_id:int,

    db:Session=Depends(get_db),

    current_user=Depends(get_current_user)

):

    mark_as_read(

        notification_id,

        db

    )


    return{

        "message":"Notification marked as read"

    }