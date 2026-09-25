from fastapi import APIRouter
from app.api.v1.endpoints import (
    weathergpt,
    weather,
    alerts,
    risk,
    predictions,
    reports,
    roads,
    emergency,
)

api_router = APIRouter()

# Primary WeatherGPT Conversational Intelligence
api_router.include_router(weathergpt.router, prefix="/weathergpt", tags=["WeatherGPT Conversational AI & Sector Advisories"])

# Meteorological Services & Radar
api_router.include_router(weather.router, prefix="/weather", tags=["IMD Weather, NWP Models & Doppler Radar"])
api_router.include_router(alerts.router, prefix="/alerts", tags=["IMD Early Warnings & CAP Bulletins"])
api_router.include_router(risk.router, prefix="/risk", tags=["Extreme Weather Risk & Vulnerability Index"])
api_router.include_router(predictions.router, prefix="/predictions", tags=["Two-Layer NWP AI Predictions"])

# Supporting Field & Citizen Services
api_router.include_router(reports.router, prefix="/reports", tags=["Citizen Weather & Ground Reports"])
api_router.include_router(roads.router, prefix="/roads", tags=["Corridor & Transport Lifelines"])
api_router.include_router(emergency.router, prefix="/emergency", tags=["Emergency Triage & Relief Centers"])
