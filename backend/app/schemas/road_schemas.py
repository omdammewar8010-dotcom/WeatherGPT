from typing import List, Optional
from pydantic import BaseModel

class RoadCorridorStatus(BaseModel):
    corridor_id: str
    highway_name: str
    section: str
    district: str
    state: str
    status: str  # "CLEAR", "VULNERABLE", "PARTIALLY_BLOCKED", "TOTAL_BLOCKAGE"
    blockage_cause: Optional[str] = None
    clearing_progress_pct: int
    estimated_reopening_hours: Optional[int] = None
    alternate_detour: Optional[str] = None
    last_reported: str

class RoadBlockageReportCreate(BaseModel):
    highway_name: str
    section: str
    district: str
    state: str
    status: str
    blockage_cause: str
    alternate_detour: Optional[str] = None
    reported_by: str

class HistoricalLandslideEvent(BaseModel):
    event_id: str
    location_name: str
    district: str
    state: str
    year: int
    month: str
    trigger_mechanism: str  # "Monsoon Cloudburst", "Seismic Fault Rupture", "Unplanned Hillside Cutting"
    debris_volume_m3: int
    fatalities_count: int
    highway_severed: str
    restoration_days: int
    geotechnical_summary: str
