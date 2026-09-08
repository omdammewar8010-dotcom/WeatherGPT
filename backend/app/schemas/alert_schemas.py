from typing import List, Optional
from pydantic import BaseModel

class EarlyWarningCreate(BaseModel):
    title: str
    district: str
    state: str
    severity: str  # "CRITICAL", "HIGH", "MODERATE", "ADVISORY"
    risk_score: int
    confidence: float
    valid_until_hours: int = 24
    advisory: str
    evacuation_route: str
    affected_sectors: List[str] = []

class EarlyWarningResponse(BaseModel):
    id: str
    title: str
    district: str
    state: str
    severity: str
    risk_score: int
    confidence: float
    valid_until: str
    advisory: str
    evacuation_route: str
    affected_sectors: List[str]
    created_at: str
    is_active: bool = True
