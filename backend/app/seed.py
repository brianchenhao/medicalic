from .database import SessionLocal, Base, engine
from . import models
from .auth_utils import hash_password

Base.metadata.create_all(bind=engine)


def seed():
    db = SessionLocal()
    try:
        if db.query(models.Patient).count() == 0:
            db.add(models.Patient(
                name="Jane Doe",
                email="jane@example.com",
                password_hash=hash_password("demo1234"),
                avatar_url="https://i.pravatar.cc/150?img=47",
                location="San Francisco, CA",
            ))

        if db.query(models.Doctor).count() == 0:
            db.add_all([
                models.Doctor(
                    name="Dr. Alex Morgan",
                    specialty="Psychology Specialist",
                    category="Doctors",
                    experience_years=8,
                    rating=4.8,
                    review_count=120,
                    patient_count=340,
                    location="San Francisco, CA",
                    avatar_url="https://i.pravatar.cc/150?img=12",
                ),
                models.Doctor(
                    name="Dr. Priya Patel",
                    specialty="Thermologist",
                    category="Therm",
                    experience_years=6,
                    rating=4.6,
                    review_count=84,
                    patient_count=210,
                    location="Oakland, CA",
                    avatar_url="https://i.pravatar.cc/150?img=32",
                ),
                models.Doctor(
                    name="Dr. Marcus Lee",
                    specialty="EHR Consultant",
                    category="EHR",
                    experience_years=10,
                    rating=4.9,
                    review_count=201,
                    patient_count=540,
                    location="Palo Alto, CA",
                    avatar_url="https://i.pravatar.cc/150?img=14",
                ),
            ])

        if db.query(models.HealthMetric).count() == 0:
            glucose_vals = [150.2, 158.7, 162.4, 170.1, 165.5, 172.9, 168.93]
            heart_vals = [22.1, 23.0, 21.8, 24.5, 23.7, 25.0, 24.32]
            chol_vals = [180.0, 182.5, 179.3, 185.0, 183.2, 181.7, 184.4]
            for v in glucose_vals:
                db.add(models.HealthMetric(patient_id=1, metric_type="glucose", value=v, unit="mg/dL"))
            for v in heart_vals:
                db.add(models.HealthMetric(patient_id=1, metric_type="heart_rate", value=v, unit="Bpm"))
            for v in chol_vals:
                db.add(models.HealthMetric(patient_id=1, metric_type="cholesterol", value=v, unit="%"))

        db.commit()
        print("Seed complete.")
    finally:
        db.close()


if __name__ == "__main__":
    seed()
