from fastapi import FastAPI
from app.database import Base, engine
from app import models
from app.routers import doctors, health, auth, appointments, reminders

Base.metadata.create_all(bind=engine)

app = FastAPI()
app.include_router(auth.router)
app.include_router(doctors.router)
app.include_router(health.router)
app.include_router(appointments.router)
app.include_router(reminders.router)


@app.get("/ping")
def ping():
    return {"status": "ok"}
