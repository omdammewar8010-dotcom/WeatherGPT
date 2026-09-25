from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "WeatherGPT Meteorological & Climate AI Backend"
    VERSION: str = "2.0.0"
    SIH_STATEMENT: str = "SIH26068"
    ORGANIZATION: str = "Ministry of Earth Sciences (MoES) / India Meteorological Department (IMD)"
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["*"]
    
    # Major Indian Regional Meteorological Centers (RMC) & Synoptic Hubs
    INDIAN_WEATHER_HUBS: List[str] = [
        "Guwahati",
        "Kolkata",
        "New Delhi",
        "Mumbai",
        "Chennai",
        "Nagpur",
        "Bengaluru",
        "Shillong",
        "Tawang",
        "Srinagar",
    ]
    # Backward compatibility alias
    NER_DISTRICTS: List[str] = INDIAN_WEATHER_HUBS
    
    # Supported Indian Languages for WeatherGPT
    SUPPORTED_LANGUAGES: List[str] = [
        "en",  # English
        "hi",  # Hindi
        "bn",  # Bengali
        "as",  # Assamese
        "ta",  # Tamil
        "te",  # Telugu
        "mr",  # Marathi
        "gu",  # Gujarati
    ]

    # Extreme Weather ML Thresholds
    CRITICAL_RISK_THRESHOLD: float = 75.0
    HIGH_RISK_THRESHOLD: float = 55.0
    MODERATE_RISK_THRESHOLD: float = 35.0

    model_config = SettingsConfigDict(case_sensitive=True, env_file=".env", extra="allow")

settings = Settings()
