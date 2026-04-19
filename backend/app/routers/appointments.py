from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from ..database import get_db
from ..auth_utils import get_current_patient_id
from .. import models

router = APIRouter(prefix="/appointments", tags=["appointments"])


class AppointmentIn(BaseModel):
    doctor_id: int
    date: str
    time_slot: str | None = None


class AppointmentOut(BaseModel):
    id: int
    patient_id: int
    doctor_id: int
    date: str
    time_slot: str | None
    status: str

    class Config:
        from_attributes = True


@router.post("", response_model=AppointmentOut)
def book(
    body: AppointmentIn,
    db: Session = Depends(get_db),
    current_id: int = Depends(get_current_patient_id),
):
    if not db.query(models.Doctor).filter(models.Doctor.id == body.doctor_id).first():
        raise HTTPException(status_code=404, detail="Doctor not found")
    clash = (
        db.query(models.Appointment)
        .filter(
            models.Appointment.doctor_id == body.doctor_id,
            models.Appointment.date == body.date,
            models.Appointment.time_slot == body.time_slot,
            models.Appointment.status == "booked",
        )
        .first()
    )
    if clash:
        raise HTTPException(status_code=409, detail="Slot already booked")
    appt = models.Appointment(
        patient_id=current_id,
        doctor_id=body.doctor_id,
        date=body.date,
        time_slot=body.time_slot,
    )
    db.add(appt)
    db.commit()
    db.refresh(appt)
    return appt


@router.get("/{patient_id}", response_model=list[AppointmentOut])
def list_for_patient(
    patient_id: int,
    db: Session = Depends(get_db),
    current_id: int = Depends(get_current_patient_id),
):
    if patient_id != current_id:
        raise HTTPException(status_code=403, detail="Forbidden")
    return (
        db.query(models.Appointment)
        .filter(models.Appointment.patient_id == patient_id)
        .order_by(models.Appointment.date.asc())
        .all()
    )


@router.delete("/{appointment_id}")
def cancel(
    appointment_id: int,
    db: Session = Depends(get_db),
    current_id: int = Depends(get_current_patient_id),
):
    appt = db.query(models.Appointment).filter(models.Appointment.id == appointment_id).first()
    if not appt:
        raise HTTPException(status_code=404, detail="Appointment not found")
    if appt.patient_id != current_id:
        raise HTTPException(status_code=403, detail="Forbidden")
    appt.status = "cancelled"
    db.commit()
    return {"ok": True, "id": appointment_id, "status": "cancelled"}
