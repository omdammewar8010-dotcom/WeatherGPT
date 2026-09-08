# 🌄 NER-LandslideGuard — ML Inference & Training Pipeline

## Overview
This subsystem implements the Two-Layer Landslide Hazard Engine:
1. **Layer 1 (Static Susceptibility)**: Random Forest Classifier trained on Digital Elevation Models (DEM), Slope Gradient, Aspect, Lithology, and Historical Landslides.
2. **Layer 2 (Dynamic Trigger Risk)**: XGBoost Regressor trained on Antecedent Rainfall (1h, 3h, 6h, 24h, 3d, 7d), 24h Forecast Precipitation, and Soil Moisture Saturation.
3. **Risk Harmonization & Explainability**: Linear weighting combined with TreeExplainer (SHAP) for transparent, plain-language decision support.
