import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert "Arunachal Pradesh" in data["active_ner_states"]

def test_get_district_risk_tawang():
    response = client.get("/api/v1/risk/Tawang")
    assert response.status_code == 200
    data = response.json()
    assert data["district"] == "Tawang"
    assert data["risk_level"] == "CRITICAL"
    assert data["composite_risk_score"] == 88
    assert len(data["shap_factors"]) > 0

def test_get_all_sectors():
    response = client.get("/api/v1/risk/all/sectors")
    assert response.status_code == 200
    data = response.json()
    assert data["total_count"] == 8

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
        "tilt_rate_deg_hr": 0.8,
        "seismic_acceleration_g": 0.05,
    }
    response = client.post("/api/v1/predictions/hybrid-infer", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["composite_risk_score"] >= 70
    assert data["risk_level"] in ["HIGH", "CRITICAL"]

def test_list_and_create_incident_reports():
    # 1. List
    list_res = client.get("/api/v1/reports")
    assert list_res.status_code == 200
    initial_count = len(list_res.json())

    # 2. Create
    new_report = {
        "reporter_id": "usr_test_01",
        "reporter_name": "Karmapa Rinpoche",
        "reporter_phone": "+91 98765 00000",
        "category": "rockfall",
        "severity": "HIGH",
        "latitude": 27.58,
        "longitude": 91.85,
        "state": "Arunachal Pradesh",
        "district": "Tawang",
        "landmark": "Near Monastery Bend",
        "description": "Boulders on downhill track.",
        "media_urls": [],
    }
    create_res = client.post("/api/v1/reports", json=new_report)
    assert create_res.status_code == 200
    created = create_res.json()
    assert created["id"].startswith("LR-2026-")

    # 3. Update status
    patch_res = client.patch(f"/api/v1/reports/{created['id']}/status", json={
        "status": "VERIFIED",
        "verified_by": "Inspector Pemba",
        "resolution_notes": "Assessed by quick response team",
    })
    assert patch_res.status_code == 200
    assert patch_res.json()["status"] == "VERIFIED"

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

def test_road_status():
    response = client.get("/api/v1/roads/status")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 3

def test_emergency_triage_prioritization():
    payload = {
        "incident_id": "INC-TEST-01",
        "district": "Tawang",
        "hazard_severity": "CRITICAL",
        "trapped_persons_estimate": 4,
        "critical_infrastructure_threat": True,
        "road_access_cut_off": True,
        "vulnerable_population_count": 2,
    }
    response = client.post("/api/v1/emergency/prioritize", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["priority_level"] == "P1_IMMEDIATE_AIRLIFT"
    assert data["triage_score"] >= 80
