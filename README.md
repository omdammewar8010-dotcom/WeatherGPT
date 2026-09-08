# 🌄 NER-LandslideGuard
> **AI-Based Early Warning and Landslide Risk Monitoring System in the North Eastern Region of India**  
> *Predict. Warn. Respond. Protect.* (SIH26001)

---

## 📌 Executive Summary

**NER-LandslideGuard** is a production-grade, full-stack disaster management and AI-powered hazard monitoring platform built specifically for the fragile mountainous terrains of the 8 North Eastern Region (NER) states of India (*Arunachal Pradesh, Sikkim, Mizoram, Nagaland, Meghalaya, Manipur, Assam, and Tripura*).

The system addresses the chronic threat of monsoon-triggered landslides, debris flows, and highway lifelines severance through:
1. **Two-Layer Hybrid ML Hazard Inference Engine** (Layer 1 Static Susceptibility Random Forest + Layer 2 Dynamic Trigger Gradient Boosting + TreeSHAP explainability).
2. **Offline-First Resilient Architecture** with local queueing, exponential backoff, and conflict resolution over fragile mountain cellular networks.
3. **Multi-Criteria Decision Analysis (MCDA) Triage & Citizen SOS** prioritizing rescue airlifts and ground task forces.
4. **Live Highway Overwatch** monitoring critical corridors (NH-13, NH-10, NH-29, NH-54) with Border Roads Organisation (BRO) clearance telemetry.
5. **GSI Historical Landslide Event Catalog** and IMD Doppler Weather Radar timeline forecast.

---

## 🏛️ System Architecture

```
                                  [ Citizen Mobile App / Flutter 3.38+ ]
                                                    │
                 ┌──────────────────────────────────┴──────────────────────────────────┐
                 ▼                                                                     ▼
     [ Cloud Online Mode ]                                                   [ Offline Resilient Mode ]
     • REST / WebSocket Telemetry                                            • Local SQLite / SharedPreferences
     • Firebase Firestore & Storage                                          • SyncQueueManager Engine
     • FCM Push Bulletins & Sirens                                           • ConflictResolver (LWW)
                 │                                                                     │
                 ▼                                                                     │
     [ FastAPI Backend Microservices ] ◄───────────────────────────────────────────────┘
     • /api/v1/risk (Hazard Scoring)
     • /api/v1/predictions (SHAP attribution)
     • /api/v1/emergency (MCDA triage)
     • /api/v1/weather (Doppler timeline)
     • /api/v1/roads (Highway lifelines)
                 │
                 ▼
     [ Two-Layer ML Inference Engine ]
     • Layer 1: Static Susceptibility (Random Forest, R² = 0.9434)
     • Layer 2: Dynamic Triggering (Gradient Boosting, R² = 0.9912)
     • TreeSHAP Factor Attribution & Plain-Language Explanations
```

---

## 🚀 Key Functional Modules (18-Phase Implementation)

| Phase | Module | Key Capabilities |
|---|---|---|
| **01-03** | **Core Foundation & RBAC** | Monorepo structure, dark glassmorphic design system, role-based access (Citizen, Field Officer, Disaster Authority). |
| **04-06** | **Citizen Dashboard & Explainable AI** | Composite Risk Score Gauge (0-100), GSI/IMD telemetry, Two-Layer SHAP feature attribution bar cards, plain-language hazard drivers. |
| **07-08** | **Vision Incident Reporting & Firebase** | 6-step geo-tagged camera reporting, offline queueing, Firestore security rules (`firestore.rules`), storage rules. |
| **09-10** | **FastAPI Backend & Hybrid ML Engine** | REST API endpoints, 7,500 synthetic NER geotechnical dataset, serialized `.joblib` pipelines, SHAP explainers. |
| **11-12** | **Alert Center & Offline Sync Engine** | Audio siren simulator, Red/Orange/Yellow alert feeds, evacuation routes, background exponential backoff sync engine with jitter. |
| **13-14** | **Field Inspection & Command Center** | Geotechnical crack geometry recorder, 8-state regional hazard matrix, macro KPI grid, cell-broadcast emergency transmitter. |
| **15-17** | **MCDA Triage, Weather Radar & Overwatch** | Pulsing SOS beacon, MCDA air/ground triage queue, 24h precipitation timeline (`fl_chart`), soil saturation gauges, highway clearance lifelines. |
| **18** | **System Hardening & Evaluation Ready** | Full-stack automated test verification, launch automation scripts, and documentation. |

---

## 🤖 Machine Learning Model Architecture

### Two-Layer Hybrid Formulation:
$$\text{Composite Risk} = 0.35 \times \text{Susceptibility}_{\text{Layer 1}} + 0.65 \times \text{Dynamic Trigger}_{\text{Layer 2}}$$

1. **Layer 1: Static Terrain Susceptibility Model (Random Forest)**
   - *Features*: Slope angle (°), Soil type code, Elevation (m), Distance to active fault line (km).
   - *Performance*: $R^2 = 0.9434$, $\text{RMSE} = 3.65$.
2. **Layer 2: Dynamic Meteorological & Geotechnical Trigger Model (Gradient Boosting)**
   - *Features*: 24h rainfall (mm), 72h antecedent rainfall (mm), Soil water saturation (%), Tilt rate (°/hr), Peak ground acceleration (g).
   - *Performance*: $R^2 = 0.9912$, $\text{RMSE} = 1.34$.
3. **Tree-Based SHAP Explainability Engine**
   - Translates high-dimensional vector weights into human-understandable hazard factors (e.g. *"72h Rainfall Accumulation contributed +28.4 points"*).

---

## ⚡ Quick Start & Execution Guide

### Prerequisites
- **Python 3.10+** (FastAPI, Scikit-Learn, Joblib, SHAP, Pytest)
- **Flutter 3.24+ / Dart 3.5+**

### 1-Click Launch (Windows)
Double-click `start_all.bat` in the root directory:
```cmd
start_all.bat
```

### Manual Service Launch

#### 1. Start FastAPI Backend:
```bash
cd backend
py -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
- Interactive Swagger UI: `http://127.0.0.1:8000/docs`
- Health Endpoint: `http://127.0.0.1:8000/health`

#### 2. Start Flutter Web/Desktop/Mobile:
```bash
cd flutter_app
flutter run -d chrome
```

---

## 🧪 Verification & Test Suite Summary

- **Flutter Test Suite**: `flutter test`
  - **54 / 54 Unit & Widget Tests Passing (100% Green)**
  - `flutter analyze`: **0 issues found**
- **Backend Test Suite**: `pytest`
  - **9 / 9 REST API Tests Passing**
- **ML Engine Test Suite**: `pytest ml/test_ml.py`
  - **3 / 3 Pipeline & Inference Tests Passing**

---

## 📜 Problem Statement Alignment (SIH26001)

- **Target Geographic Sectors**: Sela Pass & Lumla (Arunachal Pradesh), Seti Jhora (Sikkim), Laipuitlang (Mizoram), Phesama (Nagaland), Cherrapunji/Sohra (Meghalaya), Tupul/Noney (Manipur), Dima Hasao (Assam), Jampui Hills (Tripura).
- **Stakeholders**: Citizens, Field Geotechnical Officers, District Disaster Management Authorities (DDMA), State Disaster Management Authorities (SDMA), Border Roads Organisation (BRO), National Disaster Response Force (NDRF).

*Built with ❤️ for Indian North Eastern Mountain Safety.*
