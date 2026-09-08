from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.api import api_router

app = FastAPI(
    title="NER-LandslideGuard API",
    description="AI-Based Early Warning and Landslide Risk Monitoring System in North Eastern Region of India (SIH26001)",
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
        "version": settings.VERSION,
        "sih_statement": settings.SIH_STATEMENT,
        "active_ner_states": [
            "Arunachal Pradesh",
            "Assam",
            "Manipur",
            "Meghalaya",
            "Mizoram",
            "Nagaland",
            "Sikkim",
            "Tripura",
        ],
        "endpoints": [
            f"{settings.API_V1_STR}/risk/{{district}}",
            f"{settings.API_V1_STR}/predictions/hybrid-infer",
            f"{settings.API_V1_STR}/reports",
            f"{settings.API_V1_STR}/weather/radar/{{district}}",
            f"{settings.API_V1_STR}/alerts/active",
            f"{settings.API_V1_STR}/roads/status",
            f"{settings.API_V1_STR}/emergency/prioritize",
        ],
    }
