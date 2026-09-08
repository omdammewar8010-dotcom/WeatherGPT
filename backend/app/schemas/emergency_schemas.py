from typing import List, Optional
from pydantic import BaseModel

class EvacuationShelter(BaseModel):
    shelter_id: str
    name: str
    district: str
    state: str
    latitude: float
    longitude: float
    capacity_total: int
    capacity_occupied: int
    medical_facility: bool
    helipad_available: bool
    contact_officer: str
    contact_phone: str

class SosTriageRequest(BaseModel):
    incident_id: str
    district: str
    hazard_severity: str  # "CRITICAL", "HIGH", "MODERATE"
    trapped_persons_estimate: int
    critical_infrastructure_threat: bool
    road_access_cut_off: bool
    vulnerable_population_count: int  # elderly, children

class SosTriagePriorityScore(BaseModel):
    incident_id: str
    triage_score: float  # 0 to 100
    priority_level: str  # "P1_IMMEDIATE_AIRLIFT", "P2_GROUND_RESCUE", "P3_SUPPORT_MONITOR"
    urgency_factors: List[str]
    recommended_ndrf_unit: str
    nearest_shelter_id: str

class EmergencySosSubmission(BaseModel):
    reporter_name: str
    reporter_phone: str
    district: str
    state: str
    latitude: float
    longitude: float
    trapped_count: int = 0
    medical_emergency: bool = False
    road_cut_off: bool = False
    vulnerable_dependents: int = 0
    notes: Optional[str] = None

class ActiveEmergencyIncident(BaseModel):
    sos_id: str
    reporter_name: str
    reporter_phone: str
    district: str
    state: str
    latitude: float
    longitude: float
    trapped_count: int
    medical_emergency: bool
    road_cut_off: bool
    vulnerable_dependents: int
    notes: Optional[str] = None
    status: str  # "DISPATCHED", "PENDING", "RESCUE_IN_PROGRESS", "RESOLVED"
    triage_score: float
    priority_level: str  # "P1_IMMEDIATE_AIRLIFT", "P2_GROUND_RESCUE", "P3_SUPPORT_MONITOR"
    dispatched_unit: str
    timestamp: str
