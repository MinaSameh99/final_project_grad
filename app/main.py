from fastapi import FastAPI
from app.db.database import engine
from app.api.auth_router import router as auth_router
from app.api import admin_router
from app.api import student_router
from app.api import advisor_router
from app.api.notification_router import router as notification_router
from app.api.student_router import router as student_router


app = FastAPI()

@app.get("/")
def root():
    return {"message": "SAMS API running"}

app.include_router(auth_router)
app.include_router(admin_router.router)
app.include_router(advisor_router.router)
app.include_router(student_router)
app.include_router(notification_router)