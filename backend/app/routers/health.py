from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..auth_utils import get_current_patient_id
from .. import models

router = APIRouter(prefix="/health", tags=["health"])


@router.get("/{patient_id}")
def get_health(
    patient_id: int,
    db: Session = Depends(get_db),
    current_id: int = Depends(get_current_patient_id),
):
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


@router.get("/{patient_id}/chart")
def get_chart(
    patient_id: int,
    metric_type: str = "glucose",
    db: Session = Depends(get_db),
    current_id: int = Depends(get_current_patient_id),
):
    rows = (
        db.query(models.HealthMetric)
        .filter(
            models.HealthMetric.patient_id == patient_id,
            models.HealthMetric.metric_type == metric_type,
        )
        .order_by(models.HealthMetric.recorded_at.desc())
        .limit(7)
        .all()
    )
    rows = list(reversed(rows))
    return {
        "patient_id": patient_id,
        "metric_type": metric_type,
        "values": [r.value for r in rows],
        "unit": rows[0].unit if rows else None,
        "recorded_at": [r.recorded_at for r in rows],
    }
