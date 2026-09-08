import os
import pytest
from inference_engine import TwoLayerLandslideInferenceEngine

def test_ml_engine_loaded():
    engine = TwoLayerLandslideInferenceEngine()
    assert engine.is_loaded is True
    assert engine.model1 is not None
    assert engine.model2 is not None

def test_ml_engine_critical_prediction():
    engine = TwoLayerLandslideInferenceEngine()
    result = engine.predict(
        district="Tawang",
        state="Arunachal Pradesh",
        slope_angle=48.0,
        elevation_m=3048.0,
        soil_type=2,  # Fragile Schist
        fault_dist_km=1.2,
        rainfall_24h_mm=175.0,
        rainfall_72h_mm=260.0,
        soil_sat_pct=92.0,
        pwp_kpa=140.0,
        tilt_rate_deg_day=1.5,
        pga_seismic_g=0.08,
    )

    assert result["district"] == "Tawang"
    assert result["composite_risk_score"] >= 70
    assert result["risk_level"] in ["HIGH", "CRITICAL"]
    assert len(result["shap_factors"]) == 4
    assert len(result["plain_language_reasons"]) > 0

def test_ml_engine_low_risk_prediction():
    engine = TwoLayerLandslideInferenceEngine()
    result = engine.predict(
        district="Agartala",
        state="Tripura",
        slope_angle=12.0,
        elevation_m=120.0,
        soil_type=1,  # Stable alluvium
        fault_dist_km=25.0,
        rainfall_24h_mm=5.0,
        rainfall_72h_mm=10.0,
        soil_sat_pct=20.0,
        pwp_kpa=15.0,
        tilt_rate_deg_day=0.0,
        pga_seismic_g=0.0,
    )

    assert result["composite_risk_score"] <= 35
    assert result["risk_level"] in ["LOW", "MODERATE"]
