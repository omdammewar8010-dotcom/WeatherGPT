from datetime import datetime
from fastapi import APIRouter
from app.schemas.risk_schemas import (
    HybridInferenceRequest,
    DistrictRiskResponse,
    Layer1Susceptibility,
    Layer2DynamicTrigger,
    LiveSensorMetrics,
    ShapFeatureFactor,
)
from app.services.ml_service import MLHazardPredictionService

router = APIRouter()

@router.post("/hybrid-infer", response_model=DistrictRiskResponse, summary="Perform Two-Layer Hybrid ML Inference")
async def run_hybrid_inference(req: HybridInferenceRequest):
    """
    Two-Layer Inference Engine:
    - Layer 1 (Static Susceptibility): Trained Random Forest on Slope Angle, Soil Type, Elevation, Fault Proximity.
    - Layer 2 (Dynamic Trigger): Trained Gradient Boosting on 24h & 72h Rainfall, Soil Saturation, PWP, Tilt Rate, Seismic G.
    - SHAP Feature Attribution: Tree-based feature decomposition with percentage impact scores.
    """
    res = MLHazardPredictionService.infer_hazard(
        district=req.district,
        state=req.state,
        slope_angle=req.slope_angle,
        elevation_m=req.elevation_meters,
        soil_type=req.soil_type_code,
        fault_dist_km=req.distance_to_fault_km,
        rainfall_24h_mm=req.rainfall_24h_mm,
        rainfall_72h_mm=req.rainfall_72h_mm,
        soil_sat_pct=req.soil_saturation_pct,
        tilt_rate_deg_day=req.tilt_rate_deg_hr * 24.0,
        pga_seismic_g=req.seismic_acceleration_g,
    )

    return DistrictRiskResponse(
        district=res["district"],
        state=res["state"],
        composite_risk_score=res["composite_risk_score"],
        risk_level=res["risk_level"],
        confidence_score=res["confidence_score"],
        timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S IST"),
        sensor_metrics=LiveSensorMetrics(
            rainfall_24h_mm=req.rainfall_24h_mm,
            rainfall_intensity_mm_hr=round(req.rainfall_24h_mm / 12.0, 1),
            soil_moisture_kpa=round(req.soil_saturation_pct * 0.6, 1),
            slope_tilt_degrees=round(req.tilt_rate_deg_hr * 4.0, 2),
            pore_water_pressure_kpa=round(req.soil_saturation_pct * 1.5, 1),
            ground_vibration_mm_s=round(req.seismic_acceleration_g * 9.8, 2),
        ),
        layer1_static=Layer1Susceptibility(
            score=res["layer1_static"]["score"],
            confidence=res["layer1_static"]["confidence"],
            model_name=res["layer1_static"]["model_name"],
            primary_factors=res["layer1_static"]["primary_factors"],
        ),
        layer2_dynamic=Layer2DynamicTrigger(
            score=res["layer2_dynamic"]["score"],
            confidence=res["layer2_dynamic"]["confidence"],
            model_name=res["layer2_dynamic"]["model_name"],
            primary_factors=res["layer2_dynamic"]["primary_factors"],
        ),
        shap_factors=[ShapFeatureFactor(**sf) for sf in res["shap_factors"]],
        plain_language_reasons=res["plain_language_reasons"],
        recommended_action=res["recommended_action"],
    )
