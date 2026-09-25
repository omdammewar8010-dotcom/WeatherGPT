from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

class WeatherGPTQueryRequest(BaseModel):
    query: str = Field(..., description="Natural language meteorological query from user")
    language: str = Field("en", description="Target language code: en, hi, bn, as, ta, te, mr, gu")
    location: Optional[str] = Field(None, description="Target district or city name (e.g. Guwahati, Delhi)")
    latitude: Optional[float] = Field(None, description="User latitude for localized weather")
    longitude: Optional[float] = Field(None, description="User longitude for localized weather")
    sector_context: Optional[str] = Field("general", description="User persona: general, farmer, aviation, marine, disaster_manager")

class SectorAdvisoryPayload(BaseModel):
    sector: str
    headline: str
    key_points: List[str]
    caution_level: str  # NORMAL, CAUTION, DANGER

class WeatherGPTQueryResponse(BaseModel):
    query: str
    answer: str
    detected_intent: str  # FORECAST, ALERT, AGROMET, AVIATION, MARINE, CLIMATE, EXTREME_RISK
    language: str
    location: str
    state: str
    current_temp_c: float
    rainfall_24h_mm: float
    weather_condition: str
    alert_severity: str  # GREEN, YELLOW, ORANGE, RED
    nwp_summary: str
    sector_advisory: Optional[SectorAdvisoryPayload] = None
    voice_transcript: Optional[str] = None
    suggested_followups: List[str] = []
    confidence_score: float = 0.96

class VoiceTranscribeRequest(BaseModel):
    audio_base64: Optional[str] = None
    sample_text_simulated: Optional[str] = None
    language: str = "en"

class VoiceTranscribeResponse(BaseModel):
    transcribed_text: str
    language: str
    confidence: float = 0.95

class QuickPrompt(BaseModel):
    category: str
    title: str
    prompt: str
    language: str = "en"
