from fastapi import APIRouter
from app.api.v1.endpoints import (
    risk,
    predictions,
    reports,
    weather,
    alerts,
    roads,
    emergency,
)

api_router = APIRouter()

api_router.include_router(risk.router, prefix="/risk", tags=["Risk Analysis & Monitoring"])
api_router.include_router(predictions.router, prefix="/predictions", tags=["Two-Layer AI Predictions"])
api_router.include_router(reports.router, prefix="/reports", tags=["Citizen Incident Reports"])
api_router.include_router(weather.router, prefix="/weather", tags=["IMD Weather & Precipitation Radar"])
api_router.include_router(alerts.router, prefix="/alerts", tags=["Early Warnings & Advisories"])
api_router.include_router(roads.router, prefix="/roads", tags=["Highway & Corridor Overwatch"])
api_router.include_router(emergency.router, prefix="/emergency", tags=["Emergency Triage & Evacuation"])
