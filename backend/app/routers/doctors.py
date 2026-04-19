from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from .. import models

router = APIRouter(prefix="/doctors", tags=["doctors"])


@router.get("")
def list_doctors(category: str | None = None, db: Session = Depends(get_db)):
    q = db.query(models.Doctor)
    if category:
        q = q.filter(models.Doctor.category == category)
    return q.all()


@router.get("/{doctor_id}")
def get_doctor(doctor_id: int, db: Session = Depends(get_db)):
    doc = db.query(models.Doctor).filter(models.Doctor.id == doctor_id).first()
    if not doc:
        raise HTTPException(status_code=404, detail="Doctor not found")
    return doc
