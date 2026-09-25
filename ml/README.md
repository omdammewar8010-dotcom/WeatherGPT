# ⛈️ WeatherGPT AI & Meteorological Nowcasting Subsystem
> **Ministry of Earth Sciences (MoES) & India Meteorological Department (IMD)** — *SIH26068*

## Overview
This subsystem implements the **Two-Layer NWP & Mesoscale Weather Intelligence Engine**:
1. **Layer 1 (NWP Synoptic Instability & Climatology)**: `RandomForestRegressor` ($R^2 = 0.9501$, $\text{RMSE} = 2.93$) trained on downscaled GFS (0.25°) and WRF (3km) numerical model tensors:
   - Convective Available Potential Energy (CAPE, J/kg)
   - Lifted Index (°C)
   - Precipitable Water (mm)
   - Deep Layer Bulk Wind Shear 0–6km (knots)
   - 850 hPa Relative Humidity (%)
   - Climatological Temperature Anomaly (°C)
2. **Layer 2 (Dynamic Mesoscale Trigger & IMD Doppler Radar)**: `GradientBoostingRegressor` ($R^2 = 0.9765$, $\text{RMSE} = 2.32$) trained on live radar nowcasting and satellite telemetry:
   - IMD Doppler Radar Reflectivity (dBZ)
   - Rain Rate (mm/hr)
   - 3-Hour Rapid Precipitation Accumulation (mm)
   - INSAT-3D Cloud Top Brightness Temperature (°C)
   - 3-Hour Barometric Pressure Tendency (hPa/3h)
   - Surface Wind Gusts (km/h)
3. **Composite Scoring & TreeSHAP Explainability**:
   $$\text{Composite Extreme Weather Risk} = 0.30 \times \text{Layer 1} + 0.70 \times \text{Layer 2}$$
   Linear weighting combined with TreeSHAP factor decomposition delivers transparent, plain-language meteorological explanations and color-coded IMD hazard warnings.

## Running Tests & Training
```bash
# Retrain models
py ml/train_models.py

# Run unit tests
py -m pytest ml/test_ml.py
```
