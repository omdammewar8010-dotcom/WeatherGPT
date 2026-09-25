from datetime import datetime
from fastapi import APIRouter
from app.schemas.risk_schemas import (
    HybridInferenceRequest,
    NwpInferenceRequest,
    DistrictRiskResponse,
    Layer1Susceptibility,
    Layer2DynamicTrigger,
    LiveSensorMetrics,
    ShapFeatureFactor,
)
from app.services.ml_service import MLHazardPredictionService

router = APIRouter()

@router.post("/nwp-infer", response_model=DistrictRiskResponse, summary="Perform WeatherGPT Two-Layer NWP & Doppler Inference")
async def run_nwp_inference(req: NwpInferenceRequest):
    """
    WeatherGPT Two-Layer Meteorological Inference Engine:
    - Layer 1 (NWP Synoptic Instability): Random Forest trained on CAPE, Lifted Index, Pw, Shear, RH 850.
    - Layer 2 (Mesoscale Trigger): Gradient Boosting trained on Doppler Reflectivity, Rain Rate, 3h Accumulation.
    - TreeSHAP Factor Decomposition: Translates tensor contributions to human-understandable percentages.
    """
    res = MLHazardPredictionService.infer_weather_hazard(
        district=req.district,
        state=req.state,
        cape_j_kg=req.cape_j_kg,
        lifted_index=req.lifted_index,
        precipitable_water_mm=req.precipitable_water_mm,
        wind_shear_0_6km_kts=req.wind_shear_0_6km_kts,
        radar_reflectivity_dbz=req.radar_reflectivity_dbz,
        rainfall_3h_accum_mm=req.rainfall_3h_accum_mm,
        cloud_top_temp_c=req.cloud_top_temp_c,
        pressure_trend_3h_hpa=req.pressure_trend_3h_hpa,
        wind_gust_kmh=req.wind_gust_kmh,
        surface_temp_c=req.surface_temp_c,
    )

    return DistrictRiskResponse(
        district=res["district"],
        state=res["state"],
        composite_risk_score=res["composite_risk_score"],
        risk_level=res["risk_level"],
        confidence_score=res["confidence_score"],
        timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S IST"),
        sensor_metrics=LiveSensorMetrics(
            rainfall_24h_mm=req.rainfall_3h_accum_mm * 1.5,
            rainfall_intensity_mm_hr=round(req.rainfall_3h_accum_mm / 3.0, 1),
            soil_moisture_kpa=round(req.precipitable_water_mm * 0.8, 1),
            cape_j_kg=req.cape_j_kg,
            radar_reflectivity_dbz=req.radar_reflectivity_dbz,
            wind_gust_kmh=req.wind_gust_kmh,
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
        hazard_type=res.get("hazard_type", "THUNDERSTORM_LIGHTNING"),
    )

@router.post("/hybrid-infer", response_model=DistrictRiskResponse, summary="Perform Hybrid Inference (Legacy Compatible)")
async def run_hybrid_inference(req: HybridInferenceRequest):
    res = MLHazardPredictionService.infer_hazard(
        district=req.district,
        state=req.state,
        rainfall_24h_mm=req.rainfall_24h_mm,
        rainfall_72h_mm=req.rainfall_72h_mm,
        soil_sat_pct=req.soil_saturation_pct,
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
        hazard_type=res.get("hazard_type", "THUNDERSTORM_LIGHTNING"),
    )
