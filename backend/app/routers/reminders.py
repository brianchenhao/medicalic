from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from ..database import get_db
from ..auth_utils import get_current_patient_id
from .. import models

router = APIRouter(prefix="/reminders", tags=["reminders"])


class ReminderIn(BaseModel):
    title: str
    remind_at: datetime
    appointment_id: int | None = None


class ReminderOut(BaseModel):
    id: int
    patient_id: int
    appointment_id: int | None
    title: str
    remind_at: datetime
    seen: int

    class Config:
        from_attributes = True


@router.post("", response_model=ReminderOut)
def create(
    body: ReminderIn,
    db: Session = Depends(get_db),
    current_id: int = Depends(get_current_patient_id),
):
    if body.appointment_id is not None:
        appt = (
            db.query(models.Appointment)
            .filter(models.Appointment.id == body.appointment_id)
            .first()
        )
        if not appt or appt.patient_id != current_id:
            raise HTTPException(status_code=404, detail="Appointment not found")
    rem = models.Reminder(
        patient_id=current_id,
        appointment_id=body.appointment_id,
        title=body.title,
        remind_at=body.remind_at,
    )
    db.add(rem)
    db.commit()
    db.refresh(rem)
    return rem


@router.get("/{patient_id}", response_model=list[ReminderOut])
def list_for_patient(
    patient_id: int,
    db: Session = Depends(get_db),
    current_id: int = Depends(get_current_patient_id),
):
    if patient_id != current_id:
        raise HTTPException(status_code=403, detail="Forbidden")
    return (
        db.query(models.Reminder)
        .filter(models.Reminder.patient_id == patient_id)
        .order_by(models.Reminder.remind_at.asc())
        .all()
    )
