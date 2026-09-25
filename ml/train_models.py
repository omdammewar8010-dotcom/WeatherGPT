import os
import json
import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
from dataset_generator import generate_weathergpt_dataset

LAYER1_FEATURES = [
    "cape_j_kg",
    "lifted_index",
    "precipitable_water_mm",
    "wind_shear_0_6km_kts",
    "rh_850hpa_pct",
    "temp_anomaly_c",
]

LAYER2_FEATURES = [
    "radar_reflectivity_dbz",
    "rain_rate_mm_hr",
    "rainfall_3h_accum_mm",
    "cloud_top_temp_c",
    "pressure_trend_3h_hpa",
    "wind_gust_kmh",
]

def train_and_export_models(output_dir: str = "models", data_dir: str = "data"):
    # Ensure relative paths work whether executed from root or ml/
    base_dir = os.path.dirname(__file__) if os.path.dirname(__file__) else "."
    abs_output_dir = os.path.join(base_dir, output_dir)
    abs_data_dir = os.path.join(base_dir, data_dir)

    os.makedirs(abs_output_dir, exist_ok=True)
    os.makedirs(abs_data_dir, exist_ok=True)

    print("[1/5] Generating WeatherGPT NWP & Doppler meteorological training dataset...")
    df = generate_weathergpt_dataset(num_samples=7500, random_seed=42)
    csv_path = os.path.join(abs_data_dir, "weathergpt_meteorological_dataset.csv")
    df.to_csv(csv_path, index=False)
    print(f"   -> Dataset saved to {csv_path} ({len(df)} records)")

    # -------------------------------------------------------------------------
    # LAYER 1: NWP Synoptic Climatology & Instability Model (Random Forest)
    # -------------------------------------------------------------------------
    print("[2/5] Training Layer 1 (NWP Synoptic Instability Random Forest)...")
    X1 = df[LAYER1_FEATURES]
    y1 = df["layer1_synoptic_instability"]

    X1_train, X1_test, y1_train, y1_test = train_test_split(X1, y1, test_size=0.2, random_state=42)

    scaler1 = StandardScaler()
    X1_train_scaled = scaler1.fit_transform(X1_train)
    X1_test_scaled = scaler1.transform(X1_test)

    model1 = RandomForestRegressor(
        n_estimators=130,
        max_depth=12,
        min_samples_split=4,
        random_state=42,
        n_jobs=-1,
    )
    model1.fit(X1_train_scaled, y1_train)

    y1_pred = model1.predict(X1_test_scaled)
    r2_1 = r2_score(y1_test, y1_pred)
    rmse_1 = np.sqrt(mean_squared_error(y1_test, y1_pred))
    mae_1 = mean_absolute_error(y1_test, y1_pred)
    print(f"   -> Layer 1 Performance: R2 = {r2_1:.4f} | RMSE = {rmse_1:.2f} | MAE = {mae_1:.2f}")

    # -------------------------------------------------------------------------
    # LAYER 2: Mesoscale Dynamic Trigger Model (Gradient Boosting / XGBoost)
    # -------------------------------------------------------------------------
    print("[3/5] Training Layer 2 (Mesoscale Dynamic Trigger Gradient Boosting)...")
    X2 = df[LAYER2_FEATURES]
    y2 = df["layer2_mesoscale_trigger"]

    X2_train, X2_test, y2_train, y2_test = train_test_split(X2, y2, test_size=0.2, random_state=42)

    scaler2 = StandardScaler()
    X2_train_scaled = scaler2.fit_transform(X2_train)
    X2_test_scaled = scaler2.transform(X2_test)

    model2 = GradientBoostingRegressor(
        n_estimators=150,
        learning_rate=0.08,
        max_depth=6,
        random_state=42,
    )
    model2.fit(X2_train_scaled, y2_train)

    y2_pred = model2.predict(X2_test_scaled)
    r2_2 = r2_score(y2_test, y2_pred)
    rmse_2 = np.sqrt(mean_squared_error(y2_test, y2_pred))
    mae_2 = mean_absolute_error(y2_test, y2_pred)
    print(f"   -> Layer 2 Performance: R2 = {r2_2:.4f} | RMSE = {rmse_2:.2f} | MAE = {mae_2:.2f}")

    # -------------------------------------------------------------------------
    # FEATURE IMPORTANCE & SHAP REFERENCE VALUES
    # -------------------------------------------------------------------------
    print("[4/5] Computing meteorological feature importance & SHAP baselines...")
    f1_importance = dict(zip(LAYER1_FEATURES, [float(v) for v in model1.feature_importances_]))
    f2_importance = dict(zip(LAYER2_FEATURES, [float(v) for v in model2.feature_importances_]))

    layer1_base_value = float(np.mean(y1_train))
    layer2_base_value = float(np.mean(y2_train))

    metadata = {
        "project": "WeatherGPT Two-Layer NWP & Mesoscale AI Hazard Engine",
        "sih_statement": "SIH26068",
        "organization": "Ministry of Earth Sciences (MoES) / India Meteorological Department (IMD)",
        "version": "2.0.0",
        "trained_samples": len(df),
        "layer1": {
            "model_name": "NWP-Synoptic-RF",
            "model_type": "RandomForestRegressor(n_estimators=130, max_depth=12)",
            "features": LAYER1_FEATURES,
            "r2_score": round(float(r2_1), 4),
            "rmse": round(float(rmse_1), 3),
            "mae": round(float(mae_1), 3),
            "base_value": round(layer1_base_value, 2),
            "feature_importance": f1_importance,
        },
        "layer2": {
            "model_name": "Mesoscale-Nowcast-GB",
            "model_type": "GradientBoostingRegressor(n_estimators=150, max_depth=6)",
            "features": LAYER2_FEATURES,
            "r2_score": round(float(r2_2), 4),
            "rmse": round(float(rmse_2), 3),
            "mae": round(float(mae_2), 3),
            "base_value": round(layer2_base_value, 2),
            "feature_importance": f2_importance,
        },
        "composite_weights": {
            "layer1_synoptic": 0.30,
            "layer2_mesoscale": 0.70,
        },
        "target_hazards": [
            "CLOUDBURST_FLASHFLOOD",
            "THUNDERSTORM_LIGHTNING",
            "HEATWAVE_SEVERE",
            "SQUALL_SEVERE_GALE",
            "HEAVY_RAINFALL_FLOOD",
        ],
    }

    # -------------------------------------------------------------------------
    # SERIALIZATION TO JOBLIB & JSON
    # -------------------------------------------------------------------------
    print("[5/5] Serializing model weights and artifacts to disk...")
    # New specific names
    joblib.dump(model1, os.path.join(abs_output_dir, "layer1_nwp_rf.joblib"))
    joblib.dump(scaler1, os.path.join(abs_output_dir, "scaler1.joblib"))

    joblib.dump(model2, os.path.join(abs_output_dir, "layer2_mesoscale_gb.joblib"))
    joblib.dump(scaler2, os.path.join(abs_output_dir, "scaler2.joblib"))

    # Also keep compatibility filenames so existing pipelines load gracefully
    joblib.dump(model1, os.path.join(abs_output_dir, "layer1_susceptibility_rf.joblib"))
    joblib.dump(model2, os.path.join(abs_output_dir, "layer2_dynamic_gb.joblib"))

    meta_path = os.path.join(abs_output_dir, "model_meta.json")
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)

    print(f"[OK] All WeatherGPT models trained and saved to '{abs_output_dir}/' successfully!")
    return metadata

if __name__ == "__main__":
    train_and_export_models()
