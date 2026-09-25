from datetime import datetime, timedelta
from typing import List
from fastapi import APIRouter
from app.schemas.alert_schemas import EarlyWarningCreate, EarlyWarningResponse

router = APIRouter()

EARLY_WARNINGS_DB: List[EarlyWarningResponse] = [
    EarlyWarningResponse(
        id="IMD-WARN-2026-101",
        title="IMD RED ALERT: Flash Flood & Cloudburst Hazard over Kameng Basin",
        district="Tawang",
        state="Arunachal Pradesh",
        severity="CRITICAL",
        risk_score=92,
        confidence=0.96,
        valid_until=(datetime.now() + timedelta(hours=18)).strftime("%Y-%m-%d %H:%M IST"),
        advisory="IMD Doppler radar indicates extreme convective cell with core reflectivity > 54 dBZ. High risk of localized cloudburst and sudden river discharge surge. Stay away from natural drains and low-lying riverbanks.",
        evacuation_route="Higher elevation shelters via Dirang - Tawang Monastery Ridge route",
        affected_sectors=["Lumla Valley", "Jang", "Sela Base", "Tawang Town"],
        created_at=datetime.now().strftime("%Y-%m-%d %H:%M IST"),
        is_active=True,
    ),
    EarlyWarningResponse(
        id="IMD-WARN-2026-102",
        title="IMD ORANGE WARNING: Severe Thunderstorm & Squall Activity (45-60 km/h)",
        district="Guwahati",
        state="Assam",
        severity="HIGH",
        risk_score=78,
        confidence=0.91,
        valid_until=(datetime.now() + timedelta(hours=24)).strftime("%Y-%m-%d %H:%M IST"),
        advisory="Mesoscale squall line traversing Brahmaputra valley. Frequent cloud-to-ground lightning and wind gusts up to 60 km/h expected. Secure loose tin roofs and halt inland boat movements.",
        evacuation_route="Designated flood relief centers at Pandu and Khanapara Indoor Stadium",
        affected_sectors=["Kamrup Metro", "Pandu Ghat", "Borjhar", "Dispur"],
        created_at=datetime.now().strftime("%Y-%m-%d %H:%M IST"),
        is_active=True,
    ),
    EarlyWarningResponse(
        id="IMD-WARN-2026-103",
        title="IMD ORANGE WARNING: Severe Heatwave & Sunstroke Advisory (Max Temp > 43°C)",
        district="Delhi",
        state="National Capital Territory",
        severity="HIGH",
        risk_score=75,
        confidence=0.93,
        valid_until=(datetime.now() + timedelta(hours=36)).strftime("%Y-%m-%d %H:%M IST"),
        advisory="Severe heatwave conditions with maximum temperatures reaching 43-44°C. High vulnerability for infants, elderly, and outdoor laborers. Drink adequate water and avoid direct exposure between 11:30 and 15:30.",
        evacuation_route="Air-cooled public transit hubs and designated municipal hydration points",
        affected_sectors=["Central Delhi", "Najafgarh", "Ayanagar", "Palam"],
        created_at=datetime.now().strftime("%Y-%m-%d %H:%M IST"),
        is_active=True,
    ),
]

@router.get("/active", response_model=List[EarlyWarningResponse], summary="List Active IMD Weather Warning Bulletins")
async def list_active_warnings():
    return EARLY_WARNINGS_DB

@router.post("/broadcast", response_model=EarlyWarningResponse, summary="Broadcast Official IMD Early Warning Advisory")
async def broadcast_warning(warning_in: EarlyWarningCreate):
    new_id = f"IMD-WARN-2026-{len(EARLY_WARNINGS_DB) + 101:03d}"
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
