import os
import numpy as np
import pandas as pd

def generate_weathergpt_dataset(num_samples: int = 7500, random_seed: int = 42) -> pd.DataFrame:
    """
    Generate realistic synthetic meteorological, NWP (GFS/WRF), and IMD Doppler radar datasets
    tailored for Indian meteorological sub-divisions and extreme weather classification.
    Supports: Thunderstorm/Cloudburst, Severe Heatwave, Heavy Rainfall/Flash Flood, Squall.
    """
    np.random.seed(random_seed)

    indian_regions = [
        "Northeast (Guwahati / Tawang / Shillong)",
        "East (Kolkata / Bhubaneswar / Patna)",
        "North (Delhi / Dehradun / Srinagar)",
        "Central (Nagpur / Bhopal / Raipur)",
        "West (Mumbai / Ahmedabad / Jaipur)",
        "South (Chennai / Bengaluru / Hyderabad / Kochi)"
    ]
    region_probs = [0.20, 0.18, 0.18, 0.14, 0.15, 0.15]
    regions = np.random.choice(indian_regions, size=num_samples, p=region_probs)

    # -------------------------------------------------------------------------
    # 1. LAYER 1: NWP Synoptic Grid Features (GFS 0.25° / WRF 3km downscaling)
    # -------------------------------------------------------------------------
    # CAPE: Convective Available Potential Energy (J/kg)
    cape = np.random.gamma(shape=2.5, scale=600.0, size=num_samples)
    cape = np.clip(cape, 50.0, 4800.0)

    # Lifted Index (°C) - negative values denote severe atmospheric instability
    lifted_index = 6.0 - (cape / 500.0) + np.random.normal(0, 1.2, size=num_samples)
    lifted_index = np.clip(lifted_index, -11.0, 8.0)

    # Precipitable Water (mm) in tropospheric column
    precipitable_water = np.random.normal(42.0, 14.0, size=num_samples)
    precipitable_water = np.clip(precipitable_water, 12.0, 85.0)

    # Deep Layer Bulk Wind Shear 0-6 km (knots)
    wind_shear_0_6km = np.random.gamma(shape=3.0, scale=8.0, size=num_samples)
    wind_shear_0_6km = np.clip(wind_shear_0_6km, 5.0, 65.0)

    # Relative Humidity at 850 hPa (%)
    rh_850hpa = np.random.beta(a=4.5, b=2.0, size=num_samples) * 100.0
    rh_850hpa = np.clip(rh_850hpa, 20.0, 100.0)

    # Temperature Anomaly (°C from 30-year climatological normal)
    temp_anomaly = np.random.normal(0.5, 2.2, size=num_samples)
    temp_anomaly = np.clip(temp_anomaly, -5.0, 8.5)

    # -------------------------------------------------------------------------
    # 2. LAYER 2: Mesoscale Nowcasting & IMD Doppler Radar Trigger Features
    # -------------------------------------------------------------------------
    # IMD Doppler Radar Reflectivity (dBZ) (higher = intense hydrometeors/hail)
    radar_reflectivity = np.where(
        cape > 2200,
        np.random.normal(48.0, 9.0, size=num_samples),
        np.random.normal(24.0, 11.0, size=num_samples)
    )
    radar_reflectivity = np.clip(radar_reflectivity, 0.0, 68.0)

    # Rain Rate (mm/hr)
    rain_rate = np.where(
        radar_reflectivity > 45,
        np.random.exponential(scale=28.0, size=num_samples) + 15.0,
        np.random.exponential(scale=4.0, size=num_samples)
    )
    rain_rate = np.clip(rain_rate, 0.0, 140.0)

    # 3-Hour Rapid Precipitation Accumulation (mm)
    rainfall_3h = rain_rate * np.random.uniform(1.2, 2.6, size=num_samples)
    rainfall_3h = np.clip(rainfall_3h, 0.0, 240.0)

    # Cloud Top Temperature (°C) from INSAT-3D IR channel (-80°C = deep convective overshoot)
    cloud_top_temp = np.where(
        cape > 2000,
        np.random.normal(-62.0, 12.0, size=num_samples),
        np.random.normal(-15.0, 18.0, size=num_samples)
    )
    cloud_top_temp = np.clip(cloud_top_temp, -88.0, 18.0)

    # Surface Pressure Tendency (hPa/3h) (rapid drop precedes squalls/cyclones)
    pressure_trend_3h = np.random.normal(-0.4, 2.1, size=num_samples)
    pressure_trend_3h = np.clip(pressure_trend_3h, -14.0, 4.5)

    # Surface Wind Gusts (km/h)
    wind_gust = np.where(
        wind_shear_0_6km > 35,
        np.random.gamma(shape=3.5, scale=16.0, size=num_samples),
        np.random.gamma(shape=2.5, scale=10.0, size=num_samples)
    )
    wind_gust = np.clip(wind_gust, 10.0, 155.0)

    # Ambient Surface Temperature (°C)
    surface_temp = np.random.normal(29.0, 6.5, size=num_samples) + temp_anomaly
    surface_temp = np.clip(surface_temp, 4.0, 49.5)

    # -------------------------------------------------------------------------
    # 3. Ground Truth Layer 1: NWP Atmospheric Instability Index (0 - 100)
    # -------------------------------------------------------------------------
    layer1_instability = (
        (cape / 4000.0) * 40.0 +
        np.maximum(0.0, (-lifted_index + 6.0) / 14.0) * 20.0 +
        (precipitable_water / 75.0) * 15.0 +
        (wind_shear_0_6km / 60.0) * 15.0 +
        (rh_850hpa / 100.0) * 10.0 +
        np.random.normal(0, 2.5, size=num_samples)
    )
    layer1_instability = np.clip(layer1_instability, 2.0, 99.0)

    # -------------------------------------------------------------------------
    # 4. Ground Truth Layer 2: Dynamic Mesoscale Trigger Score (0 - 100)
    # -------------------------------------------------------------------------
    layer2_trigger = (
        (radar_reflectivity / 65.0) * 35.0 +
        np.minimum(rainfall_3h / 120.0, 1.0) * 25.0 +
        np.maximum(0.0, (-cloud_top_temp) / 80.0) * 15.0 +
        np.maximum(0.0, (-pressure_trend_3h) / 10.0) * 15.0 +
        (wind_gust / 130.0) * 10.0 +
        np.random.normal(0, 2.0, size=num_samples)
    )
    layer2_trigger = np.clip(layer2_trigger, 2.0, 99.0)

    # -------------------------------------------------------------------------
    # 5. Composite Extreme Weather Risk Score (0 - 100)
    # -------------------------------------------------------------------------
    composite_risk = 0.30 * layer1_instability + 0.70 * layer2_trigger
    composite_risk = np.clip(composite_risk, 1.0, 99.0)

    # Extreme Hazard Classification
    hazard_types = []
    for i in range(num_samples):
        if surface_temp[i] >= 42.0 and temp_anomaly[i] >= 4.5:
            hazard_types.append("HEATWAVE_SEVERE")
        elif radar_reflectivity[i] >= 50.0 and rainfall_3h[i] >= 80.0:
            hazard_types.append("CLOUDBURST_FLASHFLOOD")
        elif wind_gust[i] >= 75.0 and pressure_trend_3h[i] <= -4.0:
            hazard_types.append("SQUALL_SEVERE_GALE")
        elif composite_risk[i] >= 65.0:
            hazard_types.append("THUNDERSTORM_LIGHTNING")
        elif composite_risk[i] >= 40.0:
            hazard_types.append("MODERATE_RAIN_SHOWERS")
        else:
            hazard_types.append("NORMAL_STABLE")

    df = pd.DataFrame({
        "region": regions,
        # Layer 1 Features (NWP Synoptic)
        "cape_j_kg": np.round(cape, 1),
        "lifted_index": np.round(lifted_index, 2),
        "precipitable_water_mm": np.round(precipitable_water, 1),
        "wind_shear_0_6km_kts": np.round(wind_shear_0_6km, 1),
        "rh_850hpa_pct": np.round(rh_850hpa, 1),
        "temp_anomaly_c": np.round(temp_anomaly, 2),
        # Layer 2 Features (Doppler / Mesoscale)
        "radar_reflectivity_dbz": np.round(radar_reflectivity, 1),
        "rain_rate_mm_hr": np.round(rain_rate, 1),
        "rainfall_3h_accum_mm": np.round(rainfall_3h, 1),
        "cloud_top_temp_c": np.round(cloud_top_temp, 1),
        "pressure_trend_3h_hpa": np.round(pressure_trend_3h, 2),
        "wind_gust_kmh": np.round(wind_gust, 1),
        "surface_temp_c": np.round(surface_temp, 1),
        # Target variables
        "layer1_synoptic_instability": np.round(layer1_instability, 1),
        "layer2_mesoscale_trigger": np.round(layer2_trigger, 1),
        "composite_risk_score": np.round(composite_risk, 1),
        "hazard_type": hazard_types,
    })

    return df

if __name__ == "__main__":
    os.makedirs("data", exist_ok=True)
    df = generate_weathergpt_dataset(num_samples=7500)
    csv_path = os.path.join("data", "weathergpt_meteorological_dataset.csv")
    df.to_csv(csv_path, index=False)
    print(f"[OK] Generated {len(df)} WeatherGPT meteorological samples saved to {csv_path}")
    print(df[["region", "cape_j_kg", "radar_reflectivity_dbz", "composite_risk_score", "hazard_type"]].head())
