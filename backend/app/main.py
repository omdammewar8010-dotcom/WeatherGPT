from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.api import api_router

app = FastAPI(
    title="WeatherGPT AI Platform API",
    description="Conversational AI for Weather Forecasting, Alerts, and Climate Information — Ministry of Earth Sciences (MoES) & India Meteorological Department (IMD) [SIH26068]",
    version=settings.VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Attach V1 API Router
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/health", tags=["System"])
async def health_check():
    return {
        "status": "online",
        "service": settings.PROJECT_NAME,
        "organization": settings.ORGANIZATION,
        "version": settings.VERSION,
        "sih_statement": settings.SIH_STATEMENT,
        "supported_languages": settings.SUPPORTED_LANGUAGES,
        "weather_hubs": settings.INDIAN_WEATHER_HUBS,
        "key_capabilities": [
            "Natural Language Forecasting (WeatherGPT)",
            "NWP GFS & WRF Numerical Model Assimilation",
            "IMD Doppler Radar Nowcasting (< 3 Hours)",
            "Extreme Weather Early Warning Dissemination",
            "Multilingual Support for 8 Indian Languages",
            "Agromet, Aviation, Marine & Climate Advisories",
            "Voice-Enabled Query Processing for Rural Accessibility",
        ],
        "endpoints": [
            f"{settings.API_V1_STR}/weathergpt/chat",
            f"{settings.API_V1_STR}/weathergpt/voice-transcribe",
            f"{settings.API_V1_STR}/weathergpt/quick-prompts",
            f"{settings.API_V1_STR}/weather/radar/{{district}}",
            f"{settings.API_V1_STR}/weather/nwp/compare/{{district}}",
            f"{settings.API_V1_STR}/weather/climate/trends/{{district}}",
            f"{settings.API_V1_STR}/alerts/active",
            f"{settings.API_V1_STR}/predictions/nwp-infer",
            f"{settings.API_V1_STR}/risk/{{district}}",
            f"{settings.API_V1_STR}/reports",
        ],
    }
