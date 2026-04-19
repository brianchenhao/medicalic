from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from .. import models

router = APIRouter(prefix="/health", tags=["health"])


@router.get("/{patient_id}")
def get_health(patient_id: int, db: Session = Depends(get_db)):
    rows = (
        db.query(models.HealthMetric)
        .filter(models.HealthMetric.patient_id == patient_id)
        .order_by(models.HealthMetric.recorded_at.desc())
        .all()
    )
    latest: dict[str, dict] = {}
    for r in rows:
        if r.metric_type not in latest:
            latest[r.metric_type] = {
                "value": r.value,
                "unit": r.unit,
                "recorded_at": r.recorded_at,
            }
    return {"patient_id": patient_id, "metrics": latest}
