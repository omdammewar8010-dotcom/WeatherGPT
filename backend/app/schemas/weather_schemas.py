from typing import List, Optional
from pydantic import BaseModel

class HourlyForecastPoint(BaseModel):
    time_label: str
    rainfall_mm: float
    probability_pct: int
    risk_level: str

class WeatherRadarResponse(BaseModel):
    district: str
    state: str
    current_temp_c: float
    humidity_pct: int
    rainfall_accumulated_24h_mm: float
    rainfall_intensity_mm_hr: float
    soil_saturation_pct: float
    cloud_cover_pct: int
    wind_speed_kmh: float
    forecast_timeline: List[HourlyForecastPoint]
    imd_radar_station: str
    last_updated: str
