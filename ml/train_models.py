import os
import json
import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
from dataset_generator import generate_ner_landslide_dataset

LAYER1_FEATURES = ["slope_angle", "elevation_m", "soil_type", "fault_dist_km", "ndvi", "road_cut_idx"]
LAYER2_FEATURES = ["rainfall_24h_mm", "rainfall_72h_mm", "soil_sat_pct", "pwp_kpa", "tilt_rate_deg_day", "pga_seismic_g"]

def train_and_export_models(output_dir: str = "models", data_dir: str = "data"):
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(data_dir, exist_ok=True)

    print("[1/5] Generating North Eastern Region synthetic training dataset...")
    df = generate_ner_landslide_dataset(num_samples=7500, random_seed=42)
    csv_path = os.path.join(data_dir, "ner_landslide_dataset.csv")
    df.to_csv(csv_path, index=False)
    print(f"   -> Dataset saved to {csv_path} ({len(df)} records)")

    # -------------------------------------------------------------------------
    # LAYER 1: Static Susceptibility Model (Random Forest)
    # -------------------------------------------------------------------------
    print("[2/5] Training Layer 1 (Static Susceptibility Random Forest)...")
    X1 = df[LAYER1_FEATURES]
    y1 = df["layer1_susceptibility"]

    X1_train, X1_test, y1_train, y1_test = train_test_split(X1, y1, test_size=0.2, random_state=42)

    scaler1 = StandardScaler()
    X1_train_scaled = scaler1.fit_transform(X1_train)
    X1_test_scaled = scaler1.transform(X1_test)

    model1 = RandomForestRegressor(
        n_estimators=120,
        max_depth=12,
        min_samples_split=4,
        random_state=42,
        n_jobs=-1
    )
    model1.fit(X1_train_scaled, y1_train)

    y1_pred = model1.predict(X1_test_scaled)
    r2_1 = r2_score(y1_test, y1_pred)
    rmse_1 = np.sqrt(mean_squared_error(y1_test, y1_pred))
    mae_1 = mean_absolute_error(y1_test, y1_pred)
    print(f"   -> Layer 1 Performance: R2 = {r2_1:.4f} | RMSE = {rmse_1:.2f} | MAE = {mae_1:.2f}")

    # -------------------------------------------------------------------------
    # LAYER 2: Dynamic Trigger Hazard Model (Gradient Boosting / Random Forest)
    # -------------------------------------------------------------------------
    print("[3/5] Training Layer 2 (Dynamic Trigger Gradient Boosting)...")
    X2 = df[LAYER2_FEATURES]
    y2 = df["layer2_dynamic_trigger"]

    X2_train, X2_test, y2_train, y2_test = train_test_split(X2, y2, test_size=0.2, random_state=42)

    scaler2 = StandardScaler()
    X2_train_scaled = scaler2.fit_transform(X2_train)
    X2_test_scaled = scaler2.transform(X2_test)

    model2 = GradientBoostingRegressor(
        n_estimators=140,
        learning_rate=0.08,
        max_depth=6,
        random_state=42
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
    print("[4/5] Computing feature importance weights & SHAP baselines...")
    f1_importance = dict(zip(LAYER1_FEATURES, [float(v) for v in model1.feature_importances_]))
    f2_importance = dict(zip(LAYER2_FEATURES, [float(v) for v in model2.feature_importances_]))

    layer1_base_value = float(np.mean(y1_train))
    layer2_base_value = float(np.mean(y2_train))

    metadata = {
        "project": "NER-LandslideGuard Two-Layer Hybrid ML Engine",
        "sih_statement": "SIH26001",
        "version": "1.0.0",
        "trained_samples": len(df),
        "layer1": {
            "model_type": "RandomForestRegressor(n_estimators=120, max_depth=12)",
            "features": LAYER1_FEATURES,
            "r2_score": round(float(r2_1), 4),
            "rmse": round(float(rmse_1), 3),
            "mae": round(float(mae_1), 3),
            "base_value": round(layer1_base_value, 2),
            "feature_importance": f1_importance,
        },
        "layer2": {
            "model_type": "GradientBoostingRegressor(n_estimators=140, max_depth=6)",
            "features": LAYER2_FEATURES,
            "r2_score": round(float(r2_2), 4),
            "rmse": round(float(rmse_2), 3),
            "mae": round(float(mae_2), 3),
            "base_value": round(layer2_base_value, 2),
            "feature_importance": f2_importance,
        },
        "composite_weights": {
            "layer1_static": 0.35,
            "layer2_dynamic": 0.65,
        },
        "ner_states_covered": [
            "Arunachal Pradesh", "Sikkim", "Meghalaya", "Mizoram",
            "Nagaland", "Manipur", "Assam", "Tripura"
        ]
    }

    # -------------------------------------------------------------------------
    # SERIALIZATION TO JOBLIB & JSON
    # -------------------------------------------------------------------------
    print("[5/5] Serializing model weights and artifacts to disk...")
    joblib.dump(model1, os.path.join(output_dir, "layer1_susceptibility_rf.joblib"))
    joblib.dump(scaler1, os.path.join(output_dir, "scaler1.joblib"))

    joblib.dump(model2, os.path.join(output_dir, "layer2_dynamic_gb.joblib"))
    joblib.dump(scaler2, os.path.join(output_dir, "scaler2.joblib"))

    meta_path = os.path.join(output_dir, "model_meta.json")
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)

    print(f"All models trained and saved to '{output_dir}/' successfully!")
    return metadata

if __name__ == "__main__":
    train_and_export_models()
