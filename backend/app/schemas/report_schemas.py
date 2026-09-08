from typing import List, Optional
from pydantic import BaseModel, Field

class AiVisionScreeningSchema(BaseModel):
    crack_detected: bool
    debris_detected: bool
    road_obstruction: bool
    confidence_score: float
    summary: str

class IncidentReportCreate(BaseModel):
    reporter_id: str
    reporter_name: str
    reporter_phone: str
    category: str
    severity: str
    latitude: float
    longitude: float
    state: str
    district: str
    landmark: Optional[str] = None
    description: str
    media_urls: List[str] = []
    ai_analysis: Optional[AiVisionScreeningSchema] = None

class IncidentReportStatusUpdate(BaseModel):
    status: str
    verified_by: str
    resolution_notes: Optional[str] = None

class IncidentReportResponse(BaseModel):
    id: str
    reporter_id: str
    reporter_name: str
    reporter_phone: str
    category: str
    severity: str
    latitude: float
    longitude: float
    state: str
    district: str
    landmark: Optional[str] = None
    description: str
    media_urls: List[str]
    status: str
    ai_analysis: Optional[AiVisionScreeningSchema] = None
    created_at: str
    verified_by: Optional[str] = None
    resolved_at: Optional[str] = None
    resolution_notes: Optional[str] = None
