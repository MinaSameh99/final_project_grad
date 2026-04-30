from app.models.notification import Notification



def create_notification(

    user_id,

    title,

    message,

    db,

    type="system"

):

    notification=Notification(

        user_id=user_id,

        title=title,

        message=message,

        type=type

    )


    db.add(notification)

    db.commit()




def get_user_notifications(

    user_id,

    db

):

    notifications=db.query(

        Notification

    ).filter(

        Notification.user_id==user_id

    ).order_by(

        Notification.created_at.desc()

    ).all()


    return notifications




def mark_as_read(

    notification_id,

    db

):

    notification=db.query(

        Notification

    ).filter(

        Notification.id==notification_id

    ).first()


    if notification:

        notification.is_read=True

        db.commit()


    return True