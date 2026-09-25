from typing import List, Optional
from pydantic import BaseModel, Field

class HourlyForecastPoint(BaseModel):
    time_label: str
    rainfall_mm: float
    probability_pct: int
    risk_level: str
    temperature_c: Optional[float] = None
    wind_gust_kmh: Optional[float] = None

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
    air_quality_index: Optional[int] = Field(68, description="AQI (0-500 scale)")
    air_quality_status: Optional[str] = Field("Satisfactory", description="Good, Satisfactory, Moderate, Poor")
    doppler_reflectivity_dbz: Optional[float] = Field(38.5, description="Max reflectivity dBZ")

class NwpModelMetric(BaseModel):
    model_name: str  # GFS 0.25°, WRF 3km, IMD Multi-Model Ensemble
    resolution: str
    forecast_temp_c: float
    forecast_rain_24h_mm: float
    cape_j_kg: float
    confidence_pct: int

class NwpComparisonResponse(BaseModel):
    location: str
    state: str
    valid_time: str
    models: List[NwpModelMetric]
    consensus_advisory: str

class DecadalClimateTrendPoint(BaseModel):
    year: int
    temp_anomaly_c: float  # Deviation from normal
    monsoon_departure_pct: float  # + or - percentage
    extreme_heat_days: int
    heavy_rain_events_count: int

class ClimateTrendResponse(BaseModel):
    location: str
    state: str
    baseline_period: str = "1991-2020 IMD Climatological Normal"
    decadal_warming_rate: str = "+0.28°C / decade"
    trends: List[DecadalClimateTrendPoint]
    summary_analysis: str
