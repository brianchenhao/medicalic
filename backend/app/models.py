from sqlalchemy import Column, Integer, String, Float, ForeignKey, TIMESTAMP
from sqlalchemy.sql import func
from .database import Base


class Patient(Base):
    __tablename__ = "patients"
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    avatar_url = Column(String)
    location = Column(String)
    created_at = Column(TIMESTAMP, server_default=func.current_timestamp())


class Doctor(Base):
    __tablename__ = "doctors"
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False)
    specialty = Column(String, nullable=False)
    category = Column(String, nullable=False)
    experience_years = Column(Integer)
    rating = Column(Float, default=0.0)
    review_count = Column(Integer, default=0)
    patient_count = Column(Integer, default=0)
    location = Column(String)
    avatar_url = Column(String)


class HealthMetric(Base):
    __tablename__ = "health_metrics"
    id = Column(Integer, primary_key=True, autoincrement=True)
    patient_id = Column(Integer, ForeignKey("patients.id"), nullable=False)
    metric_type = Column(String, nullable=False)
    value = Column(Float, nullable=False)
    unit = Column(String, nullable=False)
    recorded_at = Column(TIMESTAMP, server_default=func.current_timestamp())


class Appointment(Base):
    __tablename__ = "appointments"
    id = Column(Integer, primary_key=True, autoincrement=True)
    patient_id = Column(Integer, ForeignKey("patients.id"), nullable=False)
    doctor_id = Column(Integer, ForeignKey("doctors.id"), nullable=False)
    date = Column(String, nullable=False)
    time_slot = Column(String)
    status = Column(String, default="booked")
    created_at = Column(TIMESTAMP, server_default=func.current_timestamp())


class Reminder(Base):
    __tablename__ = "reminders"
    id = Column(Integer, primary_key=True, autoincrement=True)
    patient_id = Column(Integer, ForeignKey("patients.id"), nullable=False)
    appointment_id = Column(Integer, ForeignKey("appointments.id"))
    title = Column(String, nullable=False)
    remind_at = Column(TIMESTAMP, nullable=False)
    seen = Column(Integer, default=0)
