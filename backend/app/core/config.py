from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "NER-LandslideGuard Backend"
    VERSION: str = "1.0.0"
    SIH_STATEMENT: str = "SIH26001"
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["*"]
    
    # NER Focus Districts
    NER_DISTRICTS: List[str] = [
        "Tawang",
        "Gangtok",
        "Shillong",
        "Aizawl",
        "Kohima",
        "Imphal",
        "Guwahati",
        "Agartala",
    ]
    
    # ML Inference Thresholds
    CRITICAL_RISK_THRESHOLD: float = 75.0
    HIGH_RISK_THRESHOLD: float = 55.0
    MODERATE_RISK_THRESHOLD: float = 35.0

    model_config = SettingsConfigDict(case_sensitive=True, env_file=".env")

settings = Settings()
