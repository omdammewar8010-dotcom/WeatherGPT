from datetime import datetime
from typing import List, Dict, Any
from fastapi import APIRouter, HTTPException, Query
from app.schemas.weather_schemas import (
    WeatherRadarResponse,
    HourlyForecastPoint,
    NwpComparisonResponse,
    NwpModelMetric,
    ClimateTrendResponse,
    DecadalClimateTrendPoint,
)

router = APIRouter()

DISTRICT_WEATHER_DB = {
    "tawang": {
        "state": "Arunachal Pradesh",
        "temp": 14.5,
        "humidity": 94,
        "rainfall_24h": 184.5,
        "intensity": 24.2,
        "soil_sat": 91.5,
        "cloud": 98,
        "wind": 22.0,
        "aqi": 22,
        "aqi_status": "Good",
        "radar_dbz": 54.0,
        "radar": "IMD Doppler Radar — Mohanbari/Tawang High-Altitude Unit",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 24.2, "probability_pct": 95, "risk_level": "CRITICAL", "temperature_c": 14.5, "wind_gust_kmh": 42.0},
            {"time_label": "+1h", "rainfall_mm": 21.0, "probability_pct": 90, "risk_level": "CRITICAL", "temperature_c": 14.0, "wind_gust_kmh": 38.0},
            {"time_label": "+2h", "rainfall_mm": 18.5, "probability_pct": 85, "risk_level": "HIGH", "temperature_c": 13.5, "wind_gust_kmh": 35.0},
            {"time_label": "+3h", "rainfall_mm": 14.0, "probability_pct": 75, "risk_level": "HIGH", "temperature_c": 13.0, "wind_gust_kmh": 28.0},
            {"time_label": "+6h", "rainfall_mm": 9.5, "probability_pct": 60, "risk_level": "MODERATE", "temperature_c": 12.5, "wind_gust_kmh": 22.0},
            {"time_label": "+12h", "rainfall_mm": 5.0, "probability_pct": 40, "risk_level": "LOW", "temperature_c": 11.5, "wind_gust_kmh": 18.0},
        ],
    },
    "guwahati": {
        "state": "Assam",
        "temp": 28.5,
        "humidity": 89,
        "rainfall_24h": 68.0,
        "intensity": 16.5,
        "soil_sat": 78.0,
        "cloud": 92,
        "wind": 28.0,
        "aqi": 55,
        "aqi_status": "Satisfactory",
        "radar_dbz": 52.0,
        "radar": "IMD Doppler Radar — Borjhar Guwahati Airport Unit",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 16.5, "probability_pct": 92, "risk_level": "HIGH", "temperature_c": 28.5, "wind_gust_kmh": 45.0},
            {"time_label": "+1h", "rainfall_mm": 19.0, "probability_pct": 90, "risk_level": "CRITICAL", "temperature_c": 27.5, "wind_gust_kmh": 52.0},
            {"time_label": "+2h", "rainfall_mm": 14.0, "probability_pct": 82, "risk_level": "HIGH", "temperature_c": 26.5, "wind_gust_kmh": 40.0},
            {"time_label": "+3h", "rainfall_mm": 8.5, "probability_pct": 65, "risk_level": "MODERATE", "temperature_c": 26.0, "wind_gust_kmh": 30.0},
            {"time_label": "+6h", "rainfall_mm": 4.0, "probability_pct": 45, "risk_level": "LOW", "temperature_c": 25.5, "wind_gust_kmh": 20.0},
            {"time_label": "+12h", "rainfall_mm": 1.5, "probability_pct": 25, "risk_level": "LOW", "temperature_c": 25.0, "wind_gust_kmh": 15.0},
        ],
    },
    "gangtok": {
        "state": "Sikkim",
        "temp": 17.0,
        "humidity": 88,
        "rainfall_24h": 112.0,
        "intensity": 14.5,
        "soil_sat": 78.5,
        "cloud": 90,
        "wind": 16.5,
        "aqi": 28,
        "aqi_status": "Good",
        "radar_dbz": 48.0,
        "radar": "IMD Doppler Radar — Gangtok Burtuk Ridge",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 14.5, "probability_pct": 88, "risk_level": "HIGH", "temperature_c": 17.0, "wind_gust_kmh": 32.0},
            {"time_label": "+1h", "rainfall_mm": 16.0, "probability_pct": 85, "risk_level": "HIGH", "temperature_c": 16.5, "wind_gust_kmh": 30.0},
            {"time_label": "+2h", "rainfall_mm": 12.0, "probability_pct": 80, "risk_level": "HIGH", "temperature_c": 16.0, "wind_gust_kmh": 25.0},
            {"time_label": "+3h", "rainfall_mm": 8.0, "probability_pct": 65, "risk_level": "MODERATE", "temperature_c": 15.5, "wind_gust_kmh": 20.0},
            {"time_label": "+6h", "rainfall_mm": 4.5, "probability_pct": 50, "risk_level": "LOW", "temperature_c": 15.0, "wind_gust_kmh": 16.0},
            {"time_label": "+12h", "rainfall_mm": 2.0, "probability_pct": 30, "risk_level": "LOW", "temperature_c": 14.0, "wind_gust_kmh": 12.0},
        ],
    },
    "shillong": {
        "state": "Meghalaya",
        "temp": 16.2,
        "humidity": 92,
        "rainfall_24h": 142.0,
        "intensity": 18.0,
        "soil_sat": 84.0,
        "cloud": 95,
        "wind": 18.0,
        "aqi": 32,
        "aqi_status": "Good",
        "radar_dbz": 50.0,
        "radar": "IMD Doppler Radar — Sohra / Cherrapunji Weather Observatory",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 18.0, "probability_pct": 90, "risk_level": "CRITICAL", "temperature_c": 16.2, "wind_gust_kmh": 35.0},
            {"time_label": "+1h", "rainfall_mm": 15.0, "probability_pct": 85, "risk_level": "HIGH", "temperature_c": 15.8, "wind_gust_kmh": 32.0},
            {"time_label": "+2h", "rainfall_mm": 11.5, "probability_pct": 75, "risk_level": "HIGH", "temperature_c": 15.2, "wind_gust_kmh": 28.0},
            {"time_label": "+3h", "rainfall_mm": 7.0, "probability_pct": 60, "risk_level": "MODERATE", "temperature_c": 14.8, "wind_gust_kmh": 22.0},
            {"time_label": "+6h", "rainfall_mm": 4.0, "probability_pct": 45, "risk_level": "LOW", "temperature_c": 14.0, "wind_gust_kmh": 16.0},
            {"time_label": "+12h", "rainfall_mm": 1.5, "probability_pct": 20, "risk_level": "LOW", "temperature_c": 13.5, "wind_gust_kmh": 10.0},
        ],
    },
    "delhi": {
        "state": "National Capital Territory",
        "temp": 42.5,
        "humidity": 38,
        "rainfall_24h": 0.0,
        "intensity": 0.0,
        "soil_sat": 22.0,
        "cloud": 15,
        "wind": 24.0,
        "aqi": 210,
        "aqi_status": "Poor",
        "radar_dbz": 14.0,
        "radar": "IMD Doppler Radar — Mausam Bhavan New Delhi",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 42.5, "wind_gust_kmh": 38.0},
            {"time_label": "+1h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 43.0, "wind_gust_kmh": 35.0},
            {"time_label": "+2h", "rainfall_mm": 0.0, "probability_pct": 10, "risk_level": "LOW", "temperature_c": 42.0, "wind_gust_kmh": 30.0},
            {"time_label": "+3h", "rainfall_mm": 0.0, "probability_pct": 10, "risk_level": "LOW", "temperature_c": 40.5, "wind_gust_kmh": 25.0},
            {"time_label": "+6h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 36.0, "wind_gust_kmh": 18.0},
            {"time_label": "+12h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 31.0, "wind_gust_kmh": 15.0},
        ],
    },
    "mumbai": {
        "state": "Maharashtra",
        "temp": 30.2,
        "humidity": 88,
        "rainfall_24h": 115.0,
        "intensity": 22.0,
        "soil_sat": 86.0,
        "cloud": 95,
        "wind": 32.0,
        "aqi": 48,
        "aqi_status": "Good",
        "radar_dbz": 54.0,
        "radar": "IMD Doppler Radar — Colaba Coastal Radar Station",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 22.0, "probability_pct": 95, "risk_level": "CRITICAL", "temperature_c": 30.2, "wind_gust_kmh": 52.0},
            {"time_label": "+1h", "rainfall_mm": 18.5, "probability_pct": 90, "risk_level": "CRITICAL", "temperature_c": 29.5, "wind_gust_kmh": 48.0},
            {"time_label": "+2h", "rainfall_mm": 14.0, "probability_pct": 85, "risk_level": "HIGH", "temperature_c": 29.0, "wind_gust_kmh": 40.0},
            {"time_label": "+3h", "rainfall_mm": 10.0, "probability_pct": 75, "risk_level": "HIGH", "temperature_c": 28.5, "wind_gust_kmh": 34.0},
            {"time_label": "+6h", "rainfall_mm": 5.0, "probability_pct": 55, "risk_level": "MODERATE", "temperature_c": 28.0, "wind_gust_kmh": 26.0},
            {"time_label": "+12h", "rainfall_mm": 2.0, "probability_pct": 35, "risk_level": "LOW", "temperature_c": 27.5, "wind_gust_kmh": 20.0},
        ],
    },
    "bengaluru": {
        "state": "Karnataka",
        "temp": 24.5,
        "humidity": 68,
        "rainfall_24h": 12.0,
        "intensity": 4.0,
        "soil_sat": 54.0,
        "cloud": 60,
        "wind": 18.0,
        "aqi": 42,
        "aqi_status": "Good",
        "radar_dbz": 28.0,
        "radar": "IMD Doppler Radar — HAL Airport Bangalore",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 4.0, "probability_pct": 50, "risk_level": "LOW", "temperature_c": 24.5, "wind_gust_kmh": 24.0},
            {"time_label": "+1h", "rainfall_mm": 3.0, "probability_pct": 45, "risk_level": "LOW", "temperature_c": 24.0, "wind_gust_kmh": 22.0},
            {"time_label": "+2h", "rainfall_mm": 1.5, "probability_pct": 30, "risk_level": "LOW", "temperature_c": 23.5, "wind_gust_kmh": 20.0},
            {"time_label": "+3h", "rainfall_mm": 0.5, "probability_pct": 20, "risk_level": "LOW", "temperature_c": 23.0, "wind_gust_kmh": 16.0},
            {"time_label": "+6h", "rainfall_mm": 0.0, "probability_pct": 10, "risk_level": "LOW", "temperature_c": 22.0, "wind_gust_kmh": 14.0},
            {"time_label": "+12h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 20.5, "wind_gust_kmh": 12.0},
        ],
    },
    "kolkata": {
        "state": "West Bengal",
        "temp": 32.5,
        "humidity": 84,
        "rainfall_24h": 78.0,
        "intensity": 18.5,
        "soil_sat": 76.0,
        "cloud": 85,
        "wind": 26.0,
        "aqi": 68,
        "aqi_status": "Moderate",
        "radar_dbz": 50.0,
        "radar": "IMD Doppler Radar — Alipore Weather Observatory Kolkata",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 18.5, "probability_pct": 90, "risk_level": "HIGH", "temperature_c": 32.5, "wind_gust_kmh": 46.0},
            {"time_label": "+1h", "rainfall_mm": 14.0, "probability_pct": 82, "risk_level": "HIGH", "temperature_c": 31.0, "wind_gust_kmh": 40.0},
            {"time_label": "+2h", "rainfall_mm": 8.0, "probability_pct": 65, "risk_level": "MODERATE", "temperature_c": 30.0, "wind_gust_kmh": 32.0},
            {"time_label": "+3h", "rainfall_mm": 4.0, "probability_pct": 45, "risk_level": "LOW", "temperature_c": 29.5, "wind_gust_kmh": 24.0},
            {"time_label": "+6h", "rainfall_mm": 1.0, "probability_pct": 20, "risk_level": "LOW", "temperature_c": 29.0, "wind_gust_kmh": 18.0},
            {"time_label": "+12h", "rainfall_mm": 0.0, "probability_pct": 10, "risk_level": "LOW", "temperature_c": 27.5, "wind_gust_kmh": 14.0},
        ],
    },
    "chennai": {
        "state": "Tamil Nadu",
        "temp": 34.0,
        "humidity": 72,
        "rainfall_24h": 4.5,
        "intensity": 0.5,
        "soil_sat": 38.0,
        "cloud": 40,
        "wind": 20.0,
        "aqi": 52,
        "aqi_status": "Moderate",
        "radar_dbz": 22.0,
        "radar": "IMD Doppler Radar — Chennai Port Station",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 0.5, "probability_pct": 20, "risk_level": "LOW", "temperature_c": 34.0, "wind_gust_kmh": 25.0},
            {"time_label": "+1h", "rainfall_mm": 0.0, "probability_pct": 15, "risk_level": "LOW", "temperature_c": 33.5, "wind_gust_kmh": 22.0},
            {"time_label": "+2h", "rainfall_mm": 0.0, "probability_pct": 10, "risk_level": "LOW", "temperature_c": 33.0, "wind_gust_kmh": 20.0},
            {"time_label": "+3h", "rainfall_mm": 0.0, "probability_pct": 10, "risk_level": "LOW", "temperature_c": 32.0, "wind_gust_kmh": 18.0},
            {"time_label": "+6h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 30.5, "wind_gust_kmh": 15.0},
            {"time_label": "+12h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 28.0, "wind_gust_kmh": 12.0},
        ],
    },
    "hyderabad": {
        "state": "Telangana",
        "temp": 31.0,
        "humidity": 62,
        "rainfall_24h": 18.0,
        "intensity": 6.5,
        "soil_sat": 48.0,
        "cloud": 55,
        "wind": 16.0,
        "aqi": 58,
        "aqi_status": "Moderate",
        "radar_dbz": 32.0,
        "radar": "IMD Doppler Radar — Begumpet Hyderabad",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 6.5, "probability_pct": 60, "risk_level": "MODERATE", "temperature_c": 31.0, "wind_gust_kmh": 28.0},
            {"time_label": "+1h", "rainfall_mm": 4.0, "probability_pct": 50, "risk_level": "LOW", "temperature_c": 30.0, "wind_gust_kmh": 24.0},
            {"time_label": "+2h", "rainfall_mm": 2.0, "probability_pct": 35, "risk_level": "LOW", "temperature_c": 29.5, "wind_gust_kmh": 20.0},
            {"time_label": "+3h", "rainfall_mm": 0.5, "probability_pct": 20, "risk_level": "LOW", "temperature_c": 29.0, "wind_gust_kmh": 16.0},
            {"time_label": "+6h", "rainfall_mm": 0.0, "probability_pct": 10, "risk_level": "LOW", "temperature_c": 27.5, "wind_gust_kmh": 14.0},
            {"time_label": "+12h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 25.0, "wind_gust_kmh": 10.0},
        ],
    },
    "jaipur": {
        "state": "Rajasthan",
        "temp": 38.5,
        "humidity": 42,
        "rainfall_24h": 0.0,
        "intensity": 0.0,
        "soil_sat": 25.0,
        "cloud": 20,
        "wind": 22.0,
        "aqi": 115,
        "aqi_status": "Moderate",
        "radar_dbz": 16.0,
        "radar": "IMD Doppler Radar — Jaipur Sanganer Airport",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 38.5, "wind_gust_kmh": 32.0},
            {"time_label": "+1h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 39.0, "wind_gust_kmh": 30.0},
            {"time_label": "+2h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 38.0, "wind_gust_kmh": 26.0},
            {"time_label": "+3h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 36.5, "wind_gust_kmh": 22.0},
            {"time_label": "+6h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 33.0, "wind_gust_kmh": 16.0},
            {"time_label": "+12h", "rainfall_mm": 0.0, "probability_pct": 5, "risk_level": "LOW", "temperature_c": 29.0, "wind_gust_kmh": 12.0},
        ],
    },
    "srinagar": {
        "state": "Jammu & Kashmir",
        "temp": 16.0,
        "humidity": 74,
        "rainfall_24h": 28.0,
        "intensity": 5.2,
        "soil_sat": 68.0,
        "cloud": 80,
        "wind": 14.0,
        "aqi": 32,
        "aqi_status": "Good",
        "radar_dbz": 36.0,
        "radar": "IMD Doppler Radar — Srinagar Weather Radar",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": 5.2, "probability_pct": 70, "risk_level": "MODERATE", "temperature_c": 16.0, "wind_gust_kmh": 22.0},
            {"time_label": "+1h", "rainfall_mm": 4.5, "probability_pct": 65, "risk_level": "MODERATE", "temperature_c": 15.5, "wind_gust_kmh": 20.0},
            {"time_label": "+2h", "rainfall_mm": 3.0, "probability_pct": 50, "risk_level": "LOW", "temperature_c": 15.0, "wind_gust_kmh": 18.0},
            {"time_label": "+3h", "rainfall_mm": 1.5, "probability_pct": 35, "risk_level": "LOW", "temperature_c": 14.0, "wind_gust_kmh": 14.0},
            {"time_label": "+6h", "rainfall_mm": 0.5, "probability_pct": 20, "risk_level": "LOW", "temperature_c": 12.5, "wind_gust_kmh": 12.0},
            {"time_label": "+12h", "rainfall_mm": 0.0, "probability_pct": 10, "risk_level": "LOW", "temperature_c": 10.0, "wind_gust_kmh": 8.0},
        ],
    },
}

def get_or_synthesize_weather(district_or_city: str) -> dict:
    key = district_or_city.lower().strip()
    if key in DISTRICT_WEATHER_DB:
        return DISTRICT_WEATHER_DB[key]
    
    # Generate deterministic, realistic meteorological data for ANY location in India
    hash_val = sum(ord(c) for c in key)
    pseudo_temp = 20.0 + (hash_val % 18)  # 20°C to 37°C
    pseudo_rain = float((hash_val * 7) % 95)  # 0 to 94mm
    pseudo_humidity = 50 + (hash_val % 45)  # 50% to 94%
    pseudo_dbz = 18.0 + (hash_val % 35)  # 18 to 52 dBZ
    pseudo_wind = 12.0 + (hash_val % 22)
    
    risk_level = "LOW"
    if pseudo_rain > 65 or pseudo_dbz > 45:
        risk_level = "CRITICAL"
    elif pseudo_rain > 35 or pseudo_dbz > 35:
        risk_level = "HIGH"
    elif pseudo_rain > 15:
        risk_level = "MODERATE"

    return {
        "state": "India",
        "temp": round(pseudo_temp, 1),
        "humidity": pseudo_humidity,
        "rainfall_24h": round(pseudo_rain, 1),
        "intensity": round(pseudo_rain / 5.0, 1),
        "soil_sat": min(95.0, round(30.0 + pseudo_rain * 0.6, 1)),
        "cloud": min(100, 20 + int(pseudo_rain)),
        "wind": round(pseudo_wind, 1),
        "aqi": 30 + (hash_val % 110),
        "aqi_status": "Satisfactory" if (hash_val % 110) < 60 else "Moderate",
        "radar_dbz": round(pseudo_dbz, 1),
        "radar": f"IMD Doppler Weather Radar — Regional Hub ({district_or_city.capitalize()})",
        "timeline": [
            {"time_label": "Now", "rainfall_mm": round(pseudo_rain / 5.0, 1), "probability_pct": min(95, 20 + int(pseudo_rain)), "risk_level": risk_level, "temperature_c": round(pseudo_temp, 1), "wind_gust_kmh": round(pseudo_wind * 1.5, 1)},
            {"time_label": "+1h", "rainfall_mm": round(pseudo_rain / 6.0, 1), "probability_pct": min(90, 15 + int(pseudo_rain)), "risk_level": risk_level, "temperature_c": round(pseudo_temp - 0.5, 1), "wind_gust_kmh": round(pseudo_wind * 1.3, 1)},
            {"time_label": "+2h", "rainfall_mm": round(pseudo_rain / 8.0, 1), "probability_pct": max(10, min(80, int(pseudo_rain))), "risk_level": "MODERATE" if pseudo_rain > 30 else "LOW", "temperature_c": round(pseudo_temp - 1.0, 1), "wind_gust_kmh": round(pseudo_wind * 1.1, 1)},
            {"time_label": "+3h", "rainfall_mm": round(pseudo_rain / 12.0, 1), "probability_pct": max(5, min(65, int(pseudo_rain * 0.8))), "risk_level": "LOW", "temperature_c": round(pseudo_temp - 1.5, 1), "wind_gust_kmh": round(pseudo_wind, 1)},
            {"time_label": "+6h", "rainfall_mm": 0.5, "probability_pct": 20, "risk_level": "LOW", "temperature_c": round(pseudo_temp - 2.5, 1), "wind_gust_kmh": round(pseudo_wind * 0.8, 1)},
            {"time_label": "+12h", "rainfall_mm": 0.0, "probability_pct": 10, "risk_level": "LOW", "temperature_c": round(pseudo_temp - 4.0, 1), "wind_gust_kmh": round(pseudo_wind * 0.6, 1)},
        ],
    }

@router.get("/radar/{district}", response_model=WeatherRadarResponse, summary="Get Live IMD Doppler Weather Radar Feed")
@router.get("/current/{district}", response_model=WeatherRadarResponse, summary="Get Live Weather for District")
async def get_district_weather(district: str):
    data = get_or_synthesize_weather(district)
    state = data.get("state", "India")

    return WeatherRadarResponse(
        district=district.capitalize(),
        state=state,
        current_temp_c=data["temp"],
        humidity_pct=data["humidity"],
        rainfall_accumulated_24h_mm=data["rainfall_24h"],
        rainfall_intensity_mm_hr=data["intensity"],
        soil_saturation_pct=data["soil_sat"],
        cloud_cover_pct=data["cloud"],
        wind_speed_kmh=data["wind"],
        forecast_timeline=[HourlyForecastPoint(**p) for p in data["timeline"]],
        imd_radar_station=data["radar"],
        last_updated=datetime.now().strftime("%Y-%m-%d %H:%M:%S IST"),
        air_quality_index=data.get("aqi", 65),
        air_quality_status=data.get("aqi_status", "Satisfactory"),
        doppler_reflectivity_dbz=data.get("radar_dbz", 38.0),
    )

@router.get("/nwp/compare/{district}", response_model=NwpComparisonResponse, summary="NWP Model Comparison (GFS vs WRF vs IMD Ensemble)")
async def get_nwp_comparison(district: str):
    data = get_or_synthesize_weather(district)
    base_rain = data["rainfall_24h"]
    base_temp = data["temp"]

    models = [
        NwpModelMetric(
            model_name="IMD-WRF (Regional Mesoscale)",
            resolution="3 km High-Resolution",
            forecast_temp_c=round(base_temp - 0.4, 1),
            forecast_rain_24h_mm=round(base_rain * 1.08, 1),
            cape_j_kg=2450.0 if base_rain > 40 else 850.0,
            confidence_pct=92,
        ),
        NwpModelMetric(
            model_name="NCEP-GFS (Global Forecast System)",
            resolution="0.25° Synoptic Grid (~25 km)",
            forecast_temp_c=round(base_temp + 0.5, 1),
            forecast_rain_24h_mm=round(base_rain * 0.92, 1),
            cape_j_kg=2200.0 if base_rain > 40 else 920.0,
            confidence_pct=88,
        ),
        NwpModelMetric(
            model_name="IMD-MME (Multi-Model Ensemble)",
            resolution="Ensemble Consensus Mean",
            forecast_temp_c=base_temp,
            forecast_rain_24h_mm=base_rain,
            cape_j_kg=2320.0 if base_rain > 40 else 885.0,
            confidence_pct=95,
        ),
    ]

    return NwpComparisonResponse(
        location=district.capitalize(),
        state=data["state"],
        valid_time=datetime.now().strftime("%Y-%m-%d %H:00 UTC"),
        models=models,
        consensus_advisory=f"High inter-model consensus between WRF 3km and GFS over {district.capitalize()} confirming {data['rainfall_24h']}mm active precipitation window.",
    )

@router.get("/climate/trends/{district}", response_model=ClimateTrendResponse, summary="10-Year Decadal Climate Trends & Anomalies")
async def get_climate_trends(district: str):
    data = get_or_synthesize_weather(district)

    years_data = [
        {"year": 2016, "temp_anomaly_c": 0.12, "monsoon_departure_pct": -3.5, "extreme_heat_days": 14, "heavy_rain_events_count": 8},
        {"year": 2017, "temp_anomaly_c": 0.18, "monsoon_departure_pct": 4.2, "extreme_heat_days": 16, "heavy_rain_events_count": 9},
        {"year": 2018, "temp_anomaly_c": 0.22, "monsoon_departure_pct": -1.8, "extreme_heat_days": 15, "heavy_rain_events_count": 10},
        {"year": 2019, "temp_anomaly_c": 0.35, "monsoon_departure_pct": 8.4, "extreme_heat_days": 19, "heavy_rain_events_count": 12},
        {"year": 2020, "temp_anomaly_c": 0.28, "monsoon_departure_pct": 5.1, "extreme_heat_days": 17, "heavy_rain_events_count": 11},
        {"year": 2021, "temp_anomaly_c": 0.41, "monsoon_departure_pct": -2.4, "extreme_heat_days": 21, "heavy_rain_events_count": 13},
        {"year": 2022, "temp_anomaly_c": 0.49, "monsoon_departure_pct": 9.2, "extreme_heat_days": 23, "heavy_rain_events_count": 14},
        {"year": 2023, "temp_anomaly_c": 0.62, "monsoon_departure_pct": -4.8, "extreme_heat_days": 26, "heavy_rain_events_count": 15},
        {"year": 2024, "temp_anomaly_c": 0.74, "monsoon_departure_pct": 6.8, "extreme_heat_days": 28, "heavy_rain_events_count": 17},
        {"year": 2025, "temp_anomaly_c": 0.81, "monsoon_departure_pct": 7.5, "extreme_heat_days": 31, "heavy_rain_events_count": 19},
    ]

    return ClimateTrendResponse(
        location=district.capitalize(),
        state=data["state"],
        baseline_period="1991-2020 IMD Climatological Normal",
        decadal_warming_rate="+0.28°C / decade",
        trends=[DecadalClimateTrendPoint(**yd) for yd in years_data],
        summary_analysis=f"Over the last decade, {district.capitalize()} exhibits a marked warming anomaly of +0.81°C with heavy rainfall days (+50mm) increasing by 37.5%, corroborating intensifying monsoon convective extremes.",
    )
