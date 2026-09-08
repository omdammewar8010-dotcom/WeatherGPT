from datetime import datetime
from typing import List
from fastapi import APIRouter
from app.schemas.road_schemas import RoadCorridorStatus, RoadBlockageReportCreate

router = APIRouter()

ROADS_DB: List[RoadCorridorStatus] = [
    RoadCorridorStatus(
        corridor_id="ROAD-NH13-01",
        highway_name="NH-13 (Trans-Arunachal Highway)",
        section="Sela Pass to Tawang KM 44",
        district="Tawang",
        state="Arunachal Pradesh",
        status="TOTAL_BLOCKAGE",
        blockage_cause="Debris Avalanche & Large Granite Boulders",
        clearing_progress_pct=35,
        estimated_reopening_hours=14,
        alternate_detour="Dirang - Lumla Old Military Track (4x4 only)",
        last_reported="15 mins ago",
    ),
    RoadCorridorStatus(
        corridor_id="ROAD-NH10-02",
        highway_name="NH-10 (Siliguri - Gangtok Highway)",
        section="29th Mile Seti Jhora",
        district="Gangtok",
        state="Sikkim",
        status="PARTIALLY_BLOCKED",
        blockage_cause="Mudslide and water logging on single lane",
        clearing_progress_pct=70,
        estimated_reopening_hours=4,
        alternate_detour="Melli - Jorethang - Namchi - Singtam route",
        last_reported="30 mins ago",
    ),
    RoadCorridorStatus(
        corridor_id="ROAD-NH29-03",
        highway_name="NH-29 (Dimapur - Kohima Highway)",
        section="Phesama Sinking Zone KM 18",
        district="Kohima",
        state="Nagaland",
        status="VULNERABLE",
        blockage_cause="Active road bed subsidence & pavement fissures",
        clearing_progress_pct=85,
        estimated_reopening_hours=2,
        alternate_detour="Jotsoma bypass corridor",
        last_reported="1 hour ago",
    ),
]

@router.get("/status", response_model=List[RoadCorridorStatus], summary="Get Live Road Overwatch & Highway Status")
async def get_road_status():
    return ROADS_DB

@router.post("/blockage-report", response_model=RoadCorridorStatus, summary="Report New Road Blockage Incident")
async def report_road_blockage(report_in: RoadBlockageReportCreate):
    new_id = f"ROAD-BLOCK-{len(ROADS_DB) + 1:02d}"
    new_corridor = RoadCorridorStatus(
        corridor_id=new_id,
        highway_name=report_in.highway_name,
        section=report_in.section,
        district=report_in.district,
        state=report_in.state,
        status=report_in.status,
        blockage_cause=report_in.blockage_cause,
        clearing_progress_pct=0,
        estimated_reopening_hours=12,
        alternate_detour=report_in.alternate_detour,
        last_reported="Just now",
    )
    ROADS_DB.insert(0, new_corridor)
    return new_corridor

HISTORICAL_LANDSLIDES_DB: List[dict] = [
    {
        "event_id": "GSI-HIST-2024-01",
        "location_name": "Sela Pass North Zig-Zag Slope",
        "district": "Tawang",
        "state": "Arunachal Pradesh",
        "year": 2024,
        "month": "July",
        "trigger_mechanism": "Monsoon Cloudburst (280mm / 48h)",
        "debris_volume_m3": 45000,
        "fatalities_count": 0,
        "highway_severed": "NH-13 Trans-Arunachal Highway",
        "restoration_days": 8,
        "geotechnical_summary": "Pore-water pressure built up rapidly in highly jointed granite gneiss bedrock causing planar failure.",
    },
    {
        "event_id": "GSI-HIST-2023-04",
        "location_name": "29th Mile Seti Jhora Scour",
        "district": "Gangtok",
        "state": "Sikkim",
        "year": 2023,
        "month": "October",
        "trigger_mechanism": "GLOF Surge & Teesta River Toe Erosion",
        "debris_volume_m3": 38000,
        "fatalities_count": 3,
        "highway_severed": "NH-10 Siliguri-Gangtok Lifeline",
        "restoration_days": 14,
        "geotechnical_summary": "Hydrodynamic toe erosion washed away retaining crib walls, undermining the slope toe.",
    },
    {
        "event_id": "GSI-HIST-2022-09",
        "location_name": "Tupul Railway Construction Site",
        "district": "Noney",
        "state": "Manipur",
        "year": 2022,
        "month": "June",
        "trigger_mechanism": "Continuous Monsoon Rains & Slope Toe Excavation",
        "debris_volume_m3": 85000,
        "fatalities_count": 58,
        "highway_severed": "Imphal-Jiribam Rail & NH-37 Corridor",
        "restoration_days": 28,
        "geotechnical_summary": "Deep-seated rotational slip failure in Disang shale formation aggravated by drainage disruption.",
    },
    {
        "event_id": "GSI-HIST-2020-02",
        "location_name": "Phesama Sinking Zone",
        "district": "Kohima",
        "state": "Nagaland",
        "year": 2020,
        "month": "August",
        "trigger_mechanism": "Subsurface Seepage & Infiltration Surcharge",
        "debris_volume_m3": 22000,
        "fatalities_count": 0,
        "highway_severed": "NH-29 Dimapur-Kohima Highway",
        "restoration_days": 6,
        "geotechnical_summary": "Expansive clayey gouge in sandstone contact zone underwent cyclic creeping subsidence.",
    },
    {
        "event_id": "GSI-HIST-2018-05",
        "location_name": "Laipuitlang Hillside Slope",
        "district": "Aizawl",
        "state": "Mizoram",
        "year": 2018,
        "month": "September",
        "trigger_mechanism": "Urban Surcharge & Unengineered Bench Cutting",
        "debris_volume_m3": 16000,
        "fatalities_count": 17,
        "highway_severed": "Aizawl Urban Arterial Road",
        "restoration_days": 4,
        "geotechnical_summary": "Multi-storey building loading over steep siltstone dip slope exceeded critical safety factor (FoS < 0.85).",
    },
]

@router.get("/historical", response_model=List[dict], summary="Get GSI Historical Landslide Event Catalog")
async def get_historical_landslides(year: int = None, state: str = None):
    res = HISTORICAL_LANDSLIDES_DB
    if year:
        res = [e for e in res if e["year"] == year]
    if state:
        res = [e for e in res if e["state"].lower() == state.lower()]
    return res
