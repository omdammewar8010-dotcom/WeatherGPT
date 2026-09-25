import os
import pytest
from inference_engine import WeatherGPTInferenceEngine, TwoLayerLandslideInferenceEngine

def test_ml_engine_loaded():
    engine = WeatherGPTInferenceEngine()
    assert engine.is_loaded is True
    assert engine.model1 is not None
    assert engine.model2 is not None

def test_weathergpt_extreme_nowcast_prediction():
    engine = WeatherGPTInferenceEngine()
    result = engine.predict_weather_hazard(
        district="Guwahati",
        state="Assam",
        cape_j_kg=2850.0,
        lifted_index=-5.2,
        precipitable_water_mm=68.0,
        wind_shear_0_6km_kts=42.0,
        rh_850hpa_pct=92.0,
        temp_anomaly_c=2.1,
        radar_reflectivity_dbz=54.0,
        rain_rate_mm_hr=45.0,
        rainfall_3h_accum_mm=95.0,
        cloud_top_temp_c=-68.0,
        pressure_trend_3h_hpa=-4.2,
        wind_gust_kmh=82.0,
        surface_temp_c=33.0,
    )

    assert result["district"] == "Guwahati"
    assert result["composite_risk_score"] >= 65
    assert result["risk_level"] in ["HIGH", "CRITICAL"]
    assert len(result["shap_factors"]) == 4
    assert len(result["plain_language_reasons"]) > 0
    assert "IMD" in result["recommended_action"]

def test_weathergpt_stable_weather_prediction():
    engine = WeatherGPTInferenceEngine()
    result = engine.predict_weather_hazard(
        district="Bengaluru",
        state="Karnataka",
        cape_j_kg=400.0,
        lifted_index=4.0,
        precipitable_water_mm=22.0,
        wind_shear_0_6km_kts=12.0,
        rh_850hpa_pct=45.0,
        temp_anomaly_c=0.2,
        radar_reflectivity_dbz=12.0,
        rain_rate_mm_hr=0.0,
        rainfall_3h_accum_mm=0.0,
        cloud_top_temp_c=-10.0,
        pressure_trend_3h_hpa=0.2,
        wind_gust_kmh=15.0,
        surface_temp_c=26.0,
    )

    assert result["composite_risk_score"] <= 40
    assert result["risk_level"] in ["LOW", "MODERATE"]

def test_legacy_landslide_compatibility():
    engine = TwoLayerLandslideInferenceEngine()
    result = engine.predict(
        district="Tawang",
        state="Arunachal Pradesh",
        slope_angle=48.0,
        elevation_m=3048.0,
        soil_type=2,
        fault_dist_km=1.2,
        rainfall_24h_mm=175.0,
        rainfall_72h_mm=260.0,
        soil_sat_pct=92.0,
    )
    assert result["composite_risk_score"] >= 60
