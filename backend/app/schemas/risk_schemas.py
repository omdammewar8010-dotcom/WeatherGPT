from typing import Dict, List, Optional
from pydantic import BaseModel, Field

class ShapFeatureFactor(BaseModel):
    feature_name: str
    feature_key: str
    impact_score: float = Field(..., description="+ for increases risk, - for decreases")
    raw_value: float
    unit: str
    percentage: float

class Layer1Susceptibility(BaseModel):
    score: float
    confidence: float
    model_name: str = "NWP-Synoptic-RF"
    primary_factors: List[str]

class Layer2DynamicTrigger(BaseModel):
    score: float
    confidence: float
    model_name: str = "Mesoscale-Nowcast-GB"
    primary_factors: List[str]

class LiveSensorMetrics(BaseModel):
    rainfall_24h_mm: float
    rainfall_intensity_mm_hr: float
    soil_moisture_kpa: float
    slope_tilt_degrees: float = 0.0
    pore_water_pressure_kpa: float = 0.0
    ground_vibration_mm_s: float = 0.0
    cape_j_kg: Optional[float] = 1650.0
    radar_reflectivity_dbz: Optional[float] = 38.0
    wind_gust_kmh: Optional[float] = 45.0

class DistrictRiskResponse(BaseModel):
    district: str
    state: str
    composite_risk_score: int
    risk_level: str  # "LOW", "MODERATE", "HIGH", "CRITICAL"
    confidence_score: float
    timestamp: str
    sensor_metrics: LiveSensorMetrics
    layer1_static: Layer1Susceptibility
    layer2_dynamic: Layer2DynamicTrigger
    shap_factors: List[ShapFeatureFactor]
    plain_language_reasons: List[str]
    recommended_action: str
    hazard_type: Optional[str] = "THUNDERSTORM_LIGHTNING"

class NwpInferenceRequest(BaseModel):
    district: str
    state: str
    cape_j_kg: float = Field(1850.0, description="Convective Available Potential Energy")
    lifted_index: float = Field(-3.5, description="Lifted Index (°C)")
    precipitable_water_mm: float = Field(52.0, description="Precipitable Water (mm)")
    wind_shear_0_6km_kts: float = Field(32.0, description="Bulk Wind Shear (kts)")
    radar_reflectivity_dbz: float = Field(46.0, description="Doppler Radar (dBZ)")
    rainfall_3h_accum_mm: float = Field(65.0, description="3h Rainfall Accumulation (mm)")
    cloud_top_temp_c: float = Field(-58.0, description="INSAT-3D Cloud Top Temp (°C)")
    pressure_trend_3h_hpa: float = Field(-2.8, description="3h Pressure Tendency (hPa)")
    wind_gust_kmh: float = Field(58.0, description="Wind Gust (km/h)")
    surface_temp_c: float = Field(31.5, description="Surface Temperature (°C)")

class HybridInferenceRequest(BaseModel):
    district: str
    state: str
    slope_angle: float = 30.0
    soil_type_code: int = Field(1, description="1: Clay loam, 2: Schist/Colluvium, 3: Silt")
    elevation_meters: float = 500.0
    distance_to_fault_km: float = 10.0
    rainfall_24h_mm: float = 45.0
    rainfall_72h_mm: float = 80.0
    soil_saturation_pct: float = 60.0
    tilt_rate_deg_hr: float = 0.0
    seismic_acceleration_g: float = 0.0
