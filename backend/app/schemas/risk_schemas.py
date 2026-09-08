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
    model_name: str = "RandomForest-StaticGeo"
    primary_factors: List[str]

class Layer2DynamicTrigger(BaseModel):
    score: float
    confidence: float
    model_name: str = "XGBoost-HydroMeteo"
    primary_factors: List[str]

class LiveSensorMetrics(BaseModel):
    rainfall_24h_mm: float
    rainfall_intensity_mm_hr: float
    soil_moisture_kpa: float
    slope_tilt_degrees: float
    pore_water_pressure_kpa: float
    ground_vibration_mm_s: float

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

class HybridInferenceRequest(BaseModel):
    district: str
    state: str
    slope_angle: float
    soil_type_code: int = Field(1, description="1: Clay loam, 2: Schist/Colluvium, 3: Silt")
    elevation_meters: float
    distance_to_fault_km: float
    rainfall_24h_mm: float
    rainfall_72h_mm: float
    soil_saturation_pct: float
    tilt_rate_deg_hr: float = 0.0
    seismic_acceleration_g: float = 0.0
