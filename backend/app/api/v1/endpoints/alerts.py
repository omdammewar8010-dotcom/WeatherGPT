from datetime import datetime, timedelta
from typing import List
from fastapi import APIRouter
from app.schemas.alert_schemas import EarlyWarningCreate, EarlyWarningResponse

router = APIRouter()

EARLY_WARNINGS_DB: List[EarlyWarningResponse] = [
    EarlyWarningResponse(
        id="WARN-2026-089",
        title="CRITICAL RED ALERT: Sela Pass - Lumla Road Debris Avalanche",
        district="Tawang",
        state="Arunachal Pradesh",
        severity="CRITICAL",
        risk_score=88,
        confidence=0.94,
        valid_until=(datetime.now() + timedelta(hours=18)).strftime("%Y-%m-%d %H:%M IST"),
        advisory="NH-13 traffic suspended immediately. Active mudflow risk along KM 42 to 48. Residents in Lumla downstream valley instructed to relocate to Tawang Higher Secondary School shelter.",
        evacuation_route="NH-13 South diversion via Dirang Valley bypass",
        affected_sectors=["Lumla", "Jang", "Sela Pass", "Tawang Monastery Ridge"],
        created_at=datetime.now().strftime("%Y-%m-%d %H:%M IST"),
        is_active=True,
    ),
    EarlyWarningResponse(
        id="WARN-2026-090",
        title="ORANGE WARNING: Gangtok - Nathula Highway Rockfall Risk",
        district="Gangtok",
        state="Sikkim",
        severity="HIGH",
        risk_score=74,
        confidence=0.89,
        valid_until=(datetime.now() + timedelta(hours=24)).strftime("%Y-%m-%d %H:%M IST"),
        advisory="Continuous torrential showers triggered surface fissuring along Burtuk corridor. Heavy vehicles prohibited; light vehicles with escort only.",
        evacuation_route="Burtuk bypass to Ranipool Indoor Stadium shelter",
        affected_sectors=["Burtuk", "Tadong", "Ranipool", "3rd Mile Ridge"],
        created_at=datetime.now().strftime("%Y-%m-%d %H:%M IST"),
        is_active=True,
    ),
]

@router.get("/active", response_model=List[EarlyWarningResponse], summary="List Active Early Warning Bulletins")
async def list_active_warnings():
    return EARLY_WARNINGS_DB

@router.post("/broadcast", response_model=EarlyWarningResponse, summary="Broadcast Early Warning Advisory")
async def broadcast_warning(warning_in: EarlyWarningCreate):
    new_id = f"WARN-2026-{len(EARLY_WARNINGS_DB) + 100:03d}"
    valid_dt = datetime.now() + timedelta(hours=warning_in.valid_until_hours)
    
    new_warning = EarlyWarningResponse(
        id=new_id,
        title=warning_in.title,
        district=warning_in.district,
        state=warning_in.state,
        severity=warning_in.severity,
        risk_score=warning_in.risk_score,
        confidence=warning_in.confidence,
        valid_until=valid_dt.strftime("%Y-%m-%d %H:%M IST"),
        advisory=warning_in.advisory,
        evacuation_route=warning_in.evacuation_route,
        affected_sectors=warning_in.affected_sectors,
        created_at=datetime.now().strftime("%Y-%m-%d %H:%M IST"),
        is_active=True,
    )
    EARLY_WARNINGS_DB.insert(0, new_warning)
    return new_warning
