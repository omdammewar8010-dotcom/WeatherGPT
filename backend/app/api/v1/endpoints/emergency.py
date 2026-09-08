from typing import List
from fastapi import APIRouter
from app.schemas.emergency_schemas import (
    EvacuationShelter,
    SosTriagePriorityScore,
    SosTriageRequest,
)

router = APIRouter()

SHELTERS_DB: List[EvacuationShelter] = [
    EvacuationShelter(
        shelter_id="SHELTER-TAW-01",
        name="Tawang Government Higher Secondary School Complex",
        district="Tawang",
        state="Arunachal Pradesh",
        latitude=27.5890,
        longitude=91.8620,
        capacity_total=450,
        capacity_occupied=120,
        medical_facility=True,
        helipad_available=True,
        contact_officer="Col. Ranjit Singh (NDRF liaison)",
        contact_phone="+91 94360 12345",
    ),
    EvacuationShelter(
        shelter_id="SHELTER-GTK-02",
        name="Paljor Stadium Indoor Disaster Relief Camp",
        district="Gangtok",
        state="Sikkim",
        latitude=27.3325,
        longitude=88.6140,
        capacity_total=600,
        capacity_occupied=210,
        medical_facility=True,
        helipad_available=False,
        contact_officer="Dr. Pema Bhutia (Chief Medical Officer)",
        contact_phone="+91 94340 54321",
    ),
    EvacuationShelter(
        shelter_id="SHELTER-SHL-03",
        name="JN Stadium Emergency Evacuation Center",
        district="Shillong",
        state="Meghalaya",
        latitude=25.5788,
        longitude=91.8933,
        capacity_total=800,
        capacity_occupied=50,
        medical_facility=True,
        helipad_available=True,
        contact_officer="Capt. M. Sangma (SDMA)",
        contact_phone="+91 94361 98765",
    ),
]

@router.get("/shelters/{district}", response_model=List[EvacuationShelter], summary="Get Evacuation Shelters for District")
async def get_shelters_by_district(district: str):
    key = district.lower().strip()
    matches = [s for s in SHELTERS_DB if s.district.lower() == key]
    return matches if matches else SHELTERS_DB

@router.post("/prioritize", response_model=SosTriagePriorityScore, summary="Calculate Multi-Criteria SOS Triage Priority")
async def prioritize_emergency(req: SosTriageRequest):
    """
    Multi-Criteria Decision Analysis (MCDA) for Disaster Rescue Priority:
    Score = (Trapped * 25) + (CutOff * 25) + (Infra * 20) + (Vulnerable * 15) + (Severity * 15)
    """
    sev_weight = {"CRITICAL": 20.0, "HIGH": 15.0, "MODERATE": 8.0}.get(req.hazard_severity.upper(), 10.0)
    trapped_weight = min(req.trapped_persons_estimate * 5.0, 30.0)
    cutoff_weight = 25.0 if req.road_access_cut_off else 0.0
    infra_weight = 15.0 if req.critical_infrastructure_threat else 0.0
    vuln_weight = min(req.vulnerable_population_count * 3.0, 15.0)

    score = round(sev_weight + trapped_weight + cutoff_weight + infra_weight + vuln_weight, 1)
    score = min(100.0, score)

    urgency_factors = []
    if req.trapped_persons_estimate > 0:
        urgency_factors.append(f"{req.trapped_persons_estimate} citizens trapped under debris")
    if req.road_access_cut_off:
        urgency_factors.append("Road connection severed — requires aerial or ropeway approach")
    if req.critical_infrastructure_threat:
        urgency_factors.append("Threatening power grid/telecom tower infrastructure")
    if req.vulnerable_population_count > 0:
        urgency_factors.append(f"{req.vulnerable_population_count} elderly/infant dependents requiring immediate evacuation")

    if score >= 75:
        priority = "P1_IMMEDIATE_AIRLIFT"
        unit = "12th Battalion NDRF (Itanagar Air Base Quick Reaction Force)"
    elif score >= 50:
        priority = "P2_GROUND_RESCUE"
        unit = "SDRF Mountain Rescue Team & BRO Heavy Excavator Squad"
    else:
        priority = "P3_SUPPORT_MONITOR"
        unit = "District Civil Defense & Red Cross Volunteer Contingent"

    return SosTriagePriorityScore(
        incident_id=req.incident_id,
        triage_score=score,
        priority_level=priority,
        urgency_factors=urgency_factors,
        recommended_ndrf_unit=unit,
        nearest_shelter_id="SHELTER-TAW-01",
    )

ACTIVE_EMERGENCIES_DB: List[dict] = [
    {
        "sos_id": "SOS-2026-081",
        "reporter_name": "Tenzing Dorjee",
        "reporter_phone": "+91 94360 88211",
        "district": "Tawang",
        "state": "Arunachal Pradesh",
        "latitude": 27.5890,
        "longitude": 91.8620,
        "trapped_count": 4,
        "medical_emergency": True,
        "road_cut_off": True,
        "vulnerable_dependents": 2,
        "notes": "Debris broke through ground floor. Elder patient on oxygen support.",
        "status": "DISPATCHED",
        "triage_score": 92.0,
        "priority_level": "P1_IMMEDIATE_AIRLIFT",
        "dispatched_unit": "12th Battalion NDRF Airborne Team",
        "timestamp": "2026-09-06T19:40:00Z",
    },
    {
        "sos_id": "SOS-2026-079",
        "reporter_name": "Deepak Chettri",
        "reporter_phone": "+91 94340 11928",
        "district": "Gangtok",
        "state": "Sikkim",
        "latitude": 27.3325,
        "longitude": 88.6140,
        "trapped_count": 1,
        "medical_emergency": False,
        "road_cut_off": True,
        "vulnerable_dependents": 1,
        "notes": "Culvert collapse blocked private vehicle with 3 occupants.",
        "status": "RESCUE_IN_PROGRESS",
        "triage_score": 68.0,
        "priority_level": "P2_GROUND_RESCUE",
        "dispatched_unit": "SDRF Mountain Rescue Team",
        "timestamp": "2026-09-06T18:15:00Z",
    },
    {
        "sos_id": "SOS-2026-074",
        "reporter_name": "Lalrinawma",
        "reporter_phone": "+91 98623 44551",
        "district": "Aizawl",
        "state": "Mizoram",
        "latitude": 23.7271,
        "longitude": 92.7176,
        "trapped_count": 0,
        "medical_emergency": False,
        "road_cut_off": False,
        "vulnerable_dependents": 0,
        "notes": "Slope retaining wall showing progressive tensile fissures.",
        "status": "PENDING",
        "triage_score": 42.0,
        "priority_level": "P3_SUPPORT_MONITOR",
        "dispatched_unit": "Civil Defense Volunteer Unit",
        "timestamp": "2026-09-06T17:00:00Z",
    },
]

@router.get("/active", response_model=List[dict], summary="Get Active Emergency Triage Incidents")
async def get_active_emergencies():
    return ACTIVE_EMERGENCIES_DB

@router.post("/sos", summary="Submit Citizen SOS Distress Signal")
async def submit_sos_distress(data: dict):
    trapped = int(data.get("trapped_count", 0))
    med = bool(data.get("medical_emergency", False))
    cutoff = bool(data.get("road_cut_off", False))
    vuln = int(data.get("vulnerable_dependents", 0))

    score = 30.0 + (trapped * 10.0) + (25.0 if med else 0.0) + (20.0 if cutoff else 0.0) + (vuln * 5.0)
    score = min(100.0, score)

    if score >= 75:
        p_level = "P1_IMMEDIATE_AIRLIFT"
        unit = "12th Battalion NDRF Airborne Team"
    elif score >= 50:
        p_level = "P2_GROUND_RESCUE"
        unit = "SDRF Mountain Rescue Team"
    else:
        p_level = "P3_SUPPORT_MONITOR"
        unit = "District Civil Defense Unit"

    sos_entry = {
        "sos_id": f"SOS-2026-{len(ACTIVE_EMERGENCIES_DB) + 101}",
        "reporter_name": data.get("reporter_name", "Anonymous Citizen"),
        "reporter_phone": data.get("reporter_phone", "+91 99999 99999"),
        "district": data.get("district", "Tawang"),
        "state": data.get("state", "Arunachal Pradesh"),
        "latitude": float(data.get("latitude", 27.589)),
        "longitude": float(data.get("longitude", 91.862)),
        "trapped_count": trapped,
        "medical_emergency": med,
        "road_cut_off": cutoff,
        "vulnerable_dependents": vuln,
        "notes": data.get("notes", "Emergency SOS via Citizen App"),
        "status": "DISPATCHED",
        "triage_score": score,
        "priority_level": p_level,
        "dispatched_unit": unit,
        "timestamp": "2026-09-06T21:20:00Z",
    }
    ACTIVE_EMERGENCIES_DB.insert(0, sos_entry)
    return sos_entry
