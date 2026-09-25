import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert "WeatherGPT" in data["service"]
    assert data["sih_statement"] == "SIH26068"
    assert "Guwahati" in data["weather_hubs"]

def test_weathergpt_chat_forecast():
    payload = {
        "query": "Will it rain heavily in Guwahati tomorrow?",
        "language": "en",
        "location": "Guwahati",
    }
    response = client.post("/api/v1/weathergpt/chat", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "Guwahati" in data["location"]
    assert data["detected_intent"] == "FORECAST"
    assert len(data["answer"]) > 10
    assert data["confidence_score"] > 0.9

def test_weathergpt_chat_agromet_hindi():
    payload = {
        "query": "Kisan ke liye dhan ki fasal ki salah dijiye",
        "language": "hi",
        "location": "Guwahati",
        "sector_context": "farmer",
    }
    response = client.post("/api/v1/weathergpt/chat", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["detected_intent"] == "AGROMET"
    assert data["sector_advisory"] is not None
    assert "paddy" in data["sector_advisory"]["key_points"][0].lower() or "sal" in data["sector_advisory"]["key_points"][0].lower()

def test_weathergpt_quick_prompts():
    response = client.get("/api/v1/weathergpt/quick-prompts")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 5

def test_nwp_comparison():
    response = client.get("/api/v1/weather/nwp/compare/Guwahati")
    assert response.status_code == 200
    data = response.json()
    assert data["location"] == "Guwahati"
    assert len(data["models"]) >= 3
    assert any("WRF" in m["model_name"] for m in data["models"])
    assert any("GFS" in m["model_name"] for m in data["models"])

def test_climate_trends():
    response = client.get("/api/v1/weather/climate/trends/Delhi")
    assert response.status_code == 200
    data = response.json()
    assert len(data["trends"]) >= 5
    assert "+0.28" in data["decadal_warming_rate"]

def test_get_district_risk_tawang():
    response = client.get("/api/v1/risk/Tawang")
    assert response.status_code == 200
    data = response.json()
    assert data["district"] == "Tawang"
    assert data["risk_level"] == "CRITICAL"
    assert len(data["shap_factors"]) > 0

def test_hybrid_inference():
    payload = {
        "district": "Tawang",
        "state": "Arunachal Pradesh",
        "slope_angle": 45.0,
        "soil_type_code": 2,
        "elevation_meters": 3048.0,
        "distance_to_fault_km": 1.2,
        "rainfall_24h_mm": 160.0,
        "rainfall_72h_mm": 240.0,
        "soil_saturation_pct": 88.0,
    }
    response = client.post("/api/v1/predictions/hybrid-infer", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["composite_risk_score"] >= 60

def test_weather_radar():
    response = client.get("/api/v1/weather/radar/Gangtok")
    assert response.status_code == 200
    data = response.json()
    assert data["district"] == "Gangtok"
    assert len(data["forecast_timeline"]) > 0

def test_active_alerts():
    response = client.get("/api/v1/alerts/active")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 2
