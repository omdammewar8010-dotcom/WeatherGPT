import os
import numpy as np
import pandas as pd

def generate_ner_landslide_dataset(num_samples: int = 5000, random_seed: int = 42) -> pd.DataFrame:
    """
    Generate realistic synthetic geological, topographical, and hydrometeorological
    data tailored for the 8 North Eastern Region (NER) states of India.
    """
    np.random.seed(random_seed)

    ner_states = [
        "Arunachal Pradesh", "Sikkim", "Meghalaya", "Mizoram",
        "Nagaland", "Manipur", "Assam", "Tripura"
    ]
    state_probs = [0.22, 0.20, 0.16, 0.14, 0.12, 0.08, 0.05, 0.03]

    states = np.random.choice(ner_states, size=num_samples, p=state_probs)

    # 1. Static Geological & Morphological Features
    # Slope Angle in degrees (higher in Arunachal/Sikkim)
    slope_angles = np.zeros(num_samples)
    elevations = np.zeros(num_samples)
    for i, state in enumerate(states):
        if state in ["Arunachal Pradesh", "Sikkim"]:
            slope_angles[i] = np.random.normal(38.0, 8.5)
            elevations[i] = np.random.uniform(1500, 4200)
        elif state in ["Meghalaya", "Mizoram", "Nagaland"]:
            slope_angles[i] = np.random.normal(32.0, 7.0)
            elevations[i] = np.random.uniform(800, 2200)
        else:
            slope_angles[i] = np.random.normal(20.0, 6.0)
            elevations[i] = np.random.uniform(100, 1000)

    slope_angles = np.clip(slope_angles, 5.0, 68.0)
    elevations = np.clip(elevations, 50.0, 4800.0)

    # Soil type: 1 = Clay loam/alluvium (stable), 2 = Schist/Colluvium (fragile), 3 = Siltstone/Shale (moderate)
    soil_types = np.random.choice([1, 2, 3], size=num_samples, p=[0.25, 0.45, 0.30])

    # Distance to active tectonic fault (km)
    fault_distances = np.random.exponential(scale=4.5, size=num_samples)
    fault_distances = np.clip(fault_distances, 0.1, 30.0)

    # Normalized Difference Vegetation Index (NDVI: -0.1 to 0.9)
    ndvi = np.random.beta(a=6, b=2, size=num_samples) * 0.85

    # Road cutting / human surcharge index (0 to 100)
    road_cutting_index = np.random.uniform(0.0, 100.0, size=num_samples)

    # 2. Dynamic Hydrometeorological Features
    # 24h Rainfall (mm)
    rainfall_24h = np.random.exponential(scale=45.0, size=num_samples)
    # Monsoon surge simulation for top 20%
    heavy_rain_idx = np.random.choice(num_samples, size=int(num_samples * 0.2), replace=False)
    rainfall_24h[heavy_rain_idx] += np.random.uniform(60.0, 160.0, size=len(heavy_rain_idx))
    rainfall_24h = np.clip(rainfall_24h, 0.0, 280.0)

    # 72h Antecedent Rainfall (mm)
    rainfall_72h = rainfall_24h * np.random.uniform(1.4, 2.8, size=num_samples)

    # Soil moisture saturation percentage (0 to 100%)
    soil_saturation = np.clip((rainfall_72h / 250.0) * 80.0 + np.random.normal(20.0, 10.0, size=num_samples), 5.0, 99.0)

    # Pore water pressure in kPa
    pore_water_pressure = soil_saturation * np.random.uniform(1.2, 1.8, size=num_samples)

    # Inclinometer tilt rate (degrees / day)
    tilt_rate = np.where(soil_saturation > 80, np.random.exponential(scale=0.8, size=num_samples), np.random.exponential(scale=0.05, size=num_samples))
    tilt_rate = np.clip(tilt_rate, 0.0, 8.0)

    # Peak ground acceleration (g)
    pga_seismic = np.random.exponential(scale=0.02, size=num_samples)
    pga_seismic = np.clip(pga_seismic, 0.0, 0.45)

    # 3. Ground Truth Susceptibility (Layer 1 Target: 0-100)
    layer1_ground_truth = (
        (slope_angles / 60.0) * 45.0 +
        (soil_types == 2) * 25.0 +
        (soil_types == 3) * 15.0 +
        np.maximum(0, (10.0 - fault_distances) / 10.0) * 15.0 +
        (1.0 - ndvi) * 10.0 +
        (road_cutting_index / 100.0) * 10.0 +
        np.random.normal(0, 3.0, size=num_samples)
    )
    layer1_ground_truth = np.clip(layer1_ground_truth, 0.0, 100.0)

    # 4. Ground Truth Dynamic Trigger Hazard Score (Layer 2 Target: 0-100)
    layer2_ground_truth = (
        np.minimum(rainfall_24h / 180.0, 1.0) * 35.0 +
        np.minimum(rainfall_72h / 320.0, 1.0) * 25.0 +
        (soil_saturation / 100.0) * 20.0 +
        np.minimum(pore_water_pressure / 150.0, 1.0) * 10.0 +
        np.minimum(tilt_rate / 3.0, 1.0) * 10.0 +
        (pga_seismic / 0.3) * 10.0 +
        np.random.normal(0, 2.5, size=num_samples)
    )
    layer2_ground_truth = np.clip(layer2_ground_truth, 0.0, 100.0)

    # Binary Failure Event (1 = Landslide Event, 0 = Stable)
    composite_hazard = 0.35 * layer1_ground_truth + 0.65 * layer2_ground_truth
    failure_probability = 1.0 / (1.0 + np.exp(-(composite_hazard - 58.0) / 8.0))
    landslide_occurred = (np.random.uniform(0, 1, size=num_samples) < failure_probability).astype(int)

    df = pd.DataFrame({
        "state": states,
        "slope_angle": np.round(slope_angles, 2),
        "elevation_m": np.round(elevations, 1),
        "soil_type": soil_types,
        "fault_dist_km": np.round(fault_distances, 2),
        "ndvi": np.round(ndvi, 3),
        "road_cut_idx": np.round(road_cutting_index, 1),
        "rainfall_24h_mm": np.round(rainfall_24h, 1),
        "rainfall_72h_mm": np.round(rainfall_72h, 1),
        "soil_sat_pct": np.round(soil_saturation, 1),
        "pwp_kpa": np.round(pore_water_pressure, 1),
        "tilt_rate_deg_day": np.round(tilt_rate, 3),
        "pga_seismic_g": np.round(pga_seismic, 3),
        "layer1_susceptibility": np.round(layer1_ground_truth, 1),
        "layer2_dynamic_trigger": np.round(layer2_ground_truth, 1),
        "composite_risk_score": np.round(composite_hazard, 1),
        "landslide_event": landslide_occurred,
    })

    return df

if __name__ == "__main__":
    os.makedirs("data", exist_ok=True)
    dataset = generate_ner_landslide_dataset(num_samples=6000)
    csv_path = os.path.join("data", "ner_landslide_dataset.csv")
    dataset.to_csv(csv_path, index=False)
    print(f"✅ Generated {len(dataset)} NER samples saved to {csv_path}")
    print(dataset.head())
