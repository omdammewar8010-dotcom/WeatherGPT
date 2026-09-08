import os
import json
import joblib
import numpy as np
import pandas as pd
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error, classification_report, roc_auc_score
from dataset_generator import generate_ner_landslide_dataset
from train_models import LAYER1_FEATURES, LAYER2_FEATURES

def evaluate_models_report(models_dir: str = "models", data_dir: str = "data"):
    meta_path = os.path.join(models_dir, "model_meta.json")
    with open(meta_path, "r", encoding="utf-8") as f:
        meta = json.load(f)

    print("==================================================================")
    print("      NER-LandslideGuard Two-Layer ML Architecture Evaluation     ")
    print("==================================================================")
    print(f"Project: {meta['project']}")
    print(f"SIH Statement: {meta['sih_statement']} | Version: {meta['version']}")
    print(f"Total Training Samples: {meta['trained_samples']:,}")
    print("------------------------------------------------------------------")

    print("\n[+] LAYER 1: Static Susceptibility (Random Forest)")
    print(f"    - Model: {meta['layer1']['model_type']}")
    print(f"    - R2 Score: {meta['layer1']['r2_score']}")
    print(f"    - RMSE: {meta['layer1']['rmse']}")
    print(f"    - MAE: {meta['layer1']['mae']}")
    print("    - Top Feature Importances:")
    for feat, imp in meta['layer1']['feature_importance'].items():
        print(f"      * {feat:16s}: {imp * 100:5.2f}%")

    print("\n[+] LAYER 2: Dynamic Trigger Risk (Gradient Boosting)")
    print(f"    - Model: {meta['layer2']['model_type']}")
    print(f"    - R2 Score: {meta['layer2']['r2_score']}")
    print(f"    - RMSE: {meta['layer2']['rmse']}")
    print(f"    - MAE: {meta['layer2']['mae']}")
    print("    - Top Feature Importances:")
    for feat, imp in meta['layer2']['feature_importance'].items():
        print(f"      * {feat:18s}: {imp * 100:5.2f}%")

    print("\n[+] COMPOSITE HARMONIZATION:")
    print("    - Static Susceptibility Weight: 35%")
    print("    - Dynamic Trigger Weight:       65%")
    print("    - States Covered:               " + ", ".join(meta['ner_states_covered']))
    print("==================================================================")

if __name__ == "__main__":
    evaluate_models_report()
