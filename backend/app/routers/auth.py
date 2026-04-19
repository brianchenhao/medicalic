from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
from ..database import get_db
from .. import models
from ..auth_utils import hash_password, verify_password, create_access_token

router = APIRouter(prefix="/auth", tags=["auth"])


class RegisterIn(BaseModel):
    name: str
    email: EmailStr
    password: str


class LoginIn(BaseModel):
    email: EmailStr
    password: str


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    patient_id: int


@router.post("/register", response_model=TokenOut)
def register(body: RegisterIn, db: Session = Depends(get_db)):
    existing = db.query(models.Patient).filter(models.Patient.email == body.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    patient = models.Patient(
        name=body.name,
        email=body.email,
        password_hash=hash_password(body.password),
    )
    db.add(patient)
    db.commit()
    db.refresh(patient)
    return TokenOut(access_token=create_access_token(str(patient.id)), patient_id=patient.id)


@router.post("/login", response_model=TokenOut)
def login(body: LoginIn, db: Session = Depends(get_db)):
    patient = db.query(models.Patient).filter(models.Patient.email == body.email).first()
    if not patient or not verify_password(body.password, patient.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return TokenOut(access_token=create_access_token(str(patient.id)), patient_id=patient.id)
