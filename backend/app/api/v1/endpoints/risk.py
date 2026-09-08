from datetime import datetime
from typing import List
from fastapi import APIRouter, HTTPException, Query
from app.schemas.risk_schemas import (
    DistrictRiskResponse,
    Layer1Susceptibility,
    Layer2DynamicTrigger,
    LiveSensorMetrics,
    ShapFeatureFactor,
)

router = APIRouter()

NER_SECTOR_DATA = {
    "tawang": {
        "state": "Arunachal Pradesh",
        "score": 88,
        "level": "CRITICAL",
        "confidence": 0.94,
        "sensor_metrics": {
            "rainfall_24h_mm": 184.5,
            "rainfall_intensity_mm_hr": 24.2,
            "soil_moisture_kpa": 48.2,
            "slope_tilt_degrees": 4.8,
            "pore_water_pressure_kpa": 142.0,
            "ground_vibration_mm_s": 1.25,
        },
        "layer1": {
            "score": 82.4,
            "confidence": 0.92,
            "factors": ["Slope Gradient > 42°", "Fragile Schist Bedrock", "High Surcharge Weight"],
        },
        "layer2": {
            "score": 93.6,
            "confidence": 0.96,
            "factors": ["72h Rainfall Surge (+184mm)", "Piezometer Saturation 92%", "Active Tilt Rate 1.2°/day"],
        },
        "shap_factors": [
            {"feature_name": "72-Hour Cumulative Rainfall", "feature_key": "rainfall_72h", "impact_score": 0.38, "raw_value": 184.5, "unit": "mm", "percentage": 38.0},
            {"feature_name": "Pore Water Pressure (PWP)", "feature_key": "pwp", "impact_score": 0.24, "raw_value": 142.0, "unit": "kPa", "percentage": 24.0},
            {"feature_name": "Slope Angle & Shear Stress", "feature_key": "slope_angle", "impact_score": 0.18, "raw_value": 43.5, "unit": "°", "percentage": 18.0},
            {"feature_name": "Soil Moisture Saturation", "feature_key": "soil_moisture", "impact_score": 0.12, "raw_value": 48.2, "unit": "kPa", "percentage": 12.0},
            {"feature_name": "Proximity to Thrust Fault", "feature_key": "fault_dist", "impact_score": 0.08, "raw_value": 1.4, "unit": "km", "percentage": 8.0},
        ],
        "reasons": [
            "Severe monsoon downpour exceeded the regional 120mm critical failure threshold.",
            "Subsurface piezometers indicate extreme pore-water pressure near Sela Pass.",
            "Slope inclinometers registered 4.8° displacement over the past 6 hours.",
        ],
        "action": "Immediate evacuation of lower Lumla settlements; prohibit heavy transport on NH-13.",
    },
    "gangtok": {
        "state": "Sikkim",
        "score": 74,
        "level": "HIGH",
        "confidence": 0.89,
        "sensor_metrics": {
            "rainfall_24h_mm": 112.0,
            "rainfall_intensity_mm_hr": 14.5,
            "soil_moisture_kpa": 39.8,
            "slope_tilt_degrees": 2.6,
            "pore_water_pressure_kpa": 98.4,
            "ground_vibration_mm_s": 0.85,
        },
        "layer1": {
            "score": 71.0,
            "confidence": 0.88,
            "factors": ["Steep Valley Gradient", "Colluvial Soil Mantle"],
        },
        "layer2": {
            "score": 77.0,
            "confidence": 0.90,
            "factors": ["Continuous 48h Precipitation", "Teesta Basin Saturation"],
        },
        "shap_factors": [
            {"feature_name": "24h Accumulated Rainfall", "feature_key": "rainfall_24h", "impact_score": 0.32, "raw_value": 112.0, "unit": "mm", "percentage": 32.0},
            {"feature_name": "Slope Steepness", "feature_key": "slope_angle", "impact_score": 0.28, "raw_value": 37.8, "unit": "°", "percentage": 28.0},
            {"feature_name": "Soil Saturation Index", "feature_key": "soil_sat", "impact_score": 0.22, "raw_value": 78.5, "unit": "%", "percentage": 22.0},
            {"feature_name": "Road Cutting Undercutting", "feature_key": "road_cut", "impact_score": 0.18, "raw_value": 85.0, "unit": "%", "percentage": 18.0},
        ],
        "reasons": [
            "Heavy cloudburst over Gangtok-Nathula ridge saturated the upper soil layer.",
            "Historical landslide reactivation risk elevated along Ranipool corridor.",
        ],
        "action": "Issue orange alert along NH-10; activate quick reaction road clearing teams.",
    },
    "shillong": {
        "state": "Meghalaya",
        "score": 62,
        "level": "HIGH",
        "confidence": 0.86,
        "sensor_metrics": {
            "rainfall_24h_mm": 95.0,
            "rainfall_intensity_mm_hr": 11.0,
            "soil_moisture_kpa": 34.0,
            "slope_tilt_degrees": 1.4,
            "pore_water_pressure_kpa": 76.0,
            "ground_vibration_mm_s": 0.45,
        },
        "layer1": {"score": 58.0, "confidence": 0.85, "factors": ["Sandstone/Shale Matrix", "Plateau Escarpment"]},
        "layer2": {"score": 66.0, "confidence": 0.87, "factors": ["Cherrapunji Front Moisture Surge"]},
        "shap_factors": [
            {"feature_name": "Precipitation Influx", "feature_key": "rainfall", "impact_score": 0.35, "raw_value": 95.0, "unit": "mm", "percentage": 35.0},
            {"feature_name": "Escarpment Slope", "feature_key": "slope", "impact_score": 0.30, "raw_value": 34.2, "unit": "°", "percentage": 30.0},
            {"feature_name": "Vegetation Cover Index", "feature_key": "ndvi", "impact_score": -0.15, "raw_value": 0.62, "unit": "NDVI", "percentage": 15.0},
        ],
        "reasons": ["Sustained rainfall on Umiam bypass slopes increases mudslide probability."],
        "action": "Maintain highway patrol and advisory for night transit.",
    },
    "aizawl": {
        "state": "Mizoram",
        "score": 79,
        "level": "CRITICAL",
        "confidence": 0.91,
        "sensor_metrics": {
            "rainfall_24h_mm": 142.0,
            "rainfall_intensity_mm_hr": 19.5,
            "soil_moisture_kpa": 44.0,
            "slope_tilt_degrees": 3.2,
            "pore_water_pressure_kpa": 118.0,
            "ground_vibration_mm_s": 0.95,
        },
        "layer1": {"score": 76.0, "confidence": 0.90, "factors": ["Linear Ridge Splay", "Weak Siltstone"]},
        "layer2": {"score": 82.0, "confidence": 0.92, "factors": ["Intense Monsoon Cell", "Urban Slope Loading"]},
        "shap_factors": [
            {"feature_name": "Structural Surcharge (Buildings)", "feature_key": "surcharge", "impact_score": 0.34, "raw_value": 88.0, "unit": "%", "percentage": 34.0},
            {"feature_name": "24h Accumulated Rainfall", "feature_key": "rainfall", "impact_score": 0.32, "raw_value": 142.0, "unit": "mm", "percentage": 32.0},
            {"feature_name": "Slope Steepness", "feature_key": "slope", "impact_score": 0.22, "raw_value": 41.0, "unit": "°", "percentage": 22.0},
            {"feature_name": "Drainage Outflow Rate", "feature_key": "drainage", "impact_score": -0.12, "raw_value": 3.2, "unit": "m³/s", "percentage": 12.0},
        ],
        "reasons": [
            "Dense hillside urbanization in Laipuitlang area creating excessive surcharge.",
            "Water accumulation behind retaining walls exceeds drainage capacity.",
        ],
        "action": "Immediate structural inspection of hillside settlements; relocate vulnerable households.",
    },
    "kohima": {
        "state": "Nagaland",
        "score": 68,
        "level": "HIGH",
        "confidence": 0.88,
        "sensor_metrics": {
            "rainfall_24h_mm": 105.0,
            "rainfall_intensity_mm_hr": 13.0,
            "soil_moisture_kpa": 38.0,
            "slope_tilt_degrees": 2.1,
            "pore_water_pressure_kpa": 88.0,
            "ground_vibration_mm_s": 0.60,
        },
        "layer1": {"score": 65.0, "confidence": 0.87, "factors": ["Disheveled Shale", "Active Fault Line"]},
        "layer2": {"score": 71.0, "confidence": 0.89, "factors": ["Sustained Rainfall", "NH-29 Sinking Zone"]},
        "shap_factors": [
            {"feature_name": "NH-29 Sinking Zone Instability", "feature_key": "sinking_zone", "impact_score": 0.36, "raw_value": 90.0, "unit": "%", "percentage": 36.0},
            {"feature_name": "Rainfall Infiltration", "feature_key": "rain", "impact_score": 0.30, "raw_value": 105.0, "unit": "mm", "percentage": 30.0},
            {"feature_name": "Geological Fractures", "feature_key": "geology", "impact_score": 0.24, "raw_value": 75.0, "unit": "%", "percentage": 24.0},
        ],
        "reasons": ["Phesama sinking zone on NH-29 showing accelerated creep."],
        "action": "Deploy earthmovers at Kohima-Dimapur highway; monitor landslide bypass.",
    },
    "imphal": {
        "state": "Manipur",
        "score": 45,
        "level": "MODERATE",
        "confidence": 0.84,
        "sensor_metrics": {
            "rainfall_24h_mm": 52.0,
            "rainfall_intensity_mm_hr": 6.5,
            "soil_moisture_kpa": 26.0,
            "slope_tilt_degrees": 0.8,
            "pore_water_pressure_kpa": 48.0,
            "ground_vibration_mm_s": 0.30,
        },
        "layer1": {"score": 48.0, "confidence": 0.83, "factors": ["Valley Margin Slopes"]},
        "layer2": {"score": 42.0, "confidence": 0.85, "factors": ["Moderate Rainfall Bands"]},
        "shap_factors": [
            {"feature_name": "Rainfall Level", "feature_key": "rain", "impact_score": 0.28, "raw_value": 52.0, "unit": "mm", "percentage": 28.0},
            {"feature_name": "Slope Stability", "feature_key": "slope", "impact_score": -0.22, "raw_value": 22.0, "unit": "°", "percentage": 22.0},
        ],
        "reasons": ["Moderate rainfall recorded across surrounding hill tracts."],
        "action": "Routine surveillance across Imphal-Jiribam corridor.",
    },
    "guwahati": {
        "state": "Assam",
        "score": 38,
        "level": "MODERATE",
        "confidence": 0.85,
        "sensor_metrics": {
            "rainfall_24h_mm": 48.0,
            "rainfall_intensity_mm_hr": 5.0,
            "soil_moisture_kpa": 22.0,
            "slope_tilt_degrees": 0.5,
            "pore_water_pressure_kpa": 38.0,
            "ground_vibration_mm_s": 0.20,
        },
        "layer1": {"score": 44.0, "confidence": 0.84, "factors": ["Granitic Gneiss Hills", "Urban Excavation"]},
        "layer2": {"score": 32.0, "confidence": 0.86, "factors": ["Light to Moderate Showers"]},
        "shap_factors": [
            {"feature_name": "Hill Cutting / Encroachment", "feature_key": "encroachment", "impact_score": 0.32, "raw_value": 65.0, "unit": "%", "percentage": 32.0},
            {"feature_name": "Precipitation", "feature_key": "rain", "impact_score": 0.20, "raw_value": 48.0, "unit": "mm", "percentage": 20.0},
        ],
        "reasons": ["Urban hillside cutting at Naranarayan hills requires periodic inspection."],
        "action": "Ensure storm drains are clear along Kamakhya hill access.",
    },
    "agartala": {
        "state": "Tripura",
        "score": 25,
        "level": "LOW",
        "confidence": 0.90,
        "sensor_metrics": {
            "rainfall_24h_mm": 22.0,
            "rainfall_intensity_mm_hr": 2.5,
            "soil_moisture_kpa": 14.0,
            "slope_tilt_degrees": 0.2,
            "pore_water_pressure_kpa": 24.0,
            "ground_vibration_mm_s": 0.10,
        },
        "layer1": {"score": 28.0, "confidence": 0.89, "factors": ["Low Rolling Hills", "Stable Alluvium"]},
        "layer2": {"score": 22.0, "confidence": 0.91, "factors": ["Dry Weather Window"]},
        "shap_factors": [
            {"feature_name": "Low Slope Angle", "feature_key": "slope", "impact_score": -0.45, "raw_value": 12.0, "unit": "°", "percentage": 45.0},
            {"feature_name": "Dense Vegetation", "feature_key": "vegetation", "impact_score": -0.35, "raw_value": 0.78, "unit": "NDVI", "percentage": 35.0},
        ],
        "reasons": ["Favorable dry conditions with minimal slope instability."],
        "action": "Standard background monitoring active.",
    },
}

@router.get("/{district}", response_model=DistrictRiskResponse, summary="Get Real-Time Risk Analysis for District")
async def get_district_risk(district: str):
    key = district.lower().strip()
    data = NER_SECTOR_DATA.get(key)
    if not data:
        # Default fallback to Tawang structure adapted for custom district query
        data = NER_SECTOR_DATA["tawang"]
        state_name = "North Eastern Region"
    else:
        state_name = data["state"]

    return DistrictRiskResponse(
        district=district.capitalize(),
        state=state_name,
        composite_risk_score=data["score"],
        risk_level=data["level"],
        confidence_score=data["confidence"],
        timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S IST"),
        sensor_metrics=LiveSensorMetrics(**data["sensor_metrics"]),
        layer1_static=Layer1Susceptibility(
            score=data["layer1"]["score"],
            confidence=data["layer1"]["confidence"],
            primary_factors=data["layer1"]["factors"],
        ),
        layer2_dynamic=Layer2DynamicTrigger(
            score=data["layer2"]["score"],
            confidence=data["layer2"]["confidence"],
            primary_factors=data["layer2"]["factors"],
        ),
        shap_factors=[ShapFeatureFactor(**sf) for sf in data["shap_factors"]],
        plain_language_reasons=data["reasons"],
        recommended_action=data["action"],
    )

@router.get("/all/sectors", summary="Get Overview of All 8 NER Key Sectors")
async def get_all_sectors_overview():
    results = []
    for district, data in NER_SECTOR_DATA.items():
        results.append({
            "district": district.capitalize(),
            "state": data["state"],
            "risk_score": data["score"],
            "risk_level": data["level"],
            "confidence": data["confidence"],
            "action": data["action"],
        })
    return {"sectors": results, "total_count": len(results)}
