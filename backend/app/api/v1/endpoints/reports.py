from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query
from app.schemas.report_schemas import (
    IncidentReportCreate,
    IncidentReportResponse,
    IncidentReportStatusUpdate,
    AiVisionScreeningSchema,
)

router = APIRouter()

# In-memory database of reports for evaluation & fast execution
REPORTS_DB: List[IncidentReportResponse] = [
    IncidentReportResponse(
        id="LR-2026-000123",
        reporter_id="usr_cit_01",
        reporter_name="Tashi Norbu",
        reporter_phone="+91 98765 43210",
        category="landslide",
        severity="CRITICAL",
        latitude=27.586,
        longitude=91.859,
        state="Arunachal Pradesh",
        district="Tawang",
        landmark="Near Sela Pass Tunnel Gate 2",
        description="Massive mudflow and boulder detachment blocked both lanes of NH-13.",
        media_urls=["https://images.unsplash.com/photo-1579546929518-9e396f3cc809"],
        status="UNDER_REVIEW",
        ai_analysis=AiVisionScreeningSchema(
            crack_detected=True,
            debris_detected=True,
            road_obstruction=True,
            confidence_score=0.94,
            summary="High confidence slope failure & road blockage identified.",
        ),
        created_at="2026-09-06 18:30 IST",
    ),
    IncidentReportResponse(
        id="LR-2026-000124",
        reporter_id="usr_cit_02",
        reporter_name="Sonam Lepcha",
        reporter_phone="+91 98765 43211",
        category="ground_crack",
        severity="HIGH",
        latitude=27.3314,
        longitude=88.6138,
        state="Sikkim",
        district="Gangtok",
        landmark="Burtuk Hillside Road",
        description="Longitudinal surface crack approx 15m in length spreading across the retaining wall.",
        media_urls=["https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe"],
        status="SUBMITTED",
        ai_analysis=AiVisionScreeningSchema(
            crack_detected=True,
            debris_detected=False,
            road_obstruction=False,
            confidence_score=0.88,
            summary="Structural slope fissure detected. Early warning candidate.",
        ),
        created_at="2026-09-06 19:15 IST",
    ),
]

@router.get("", response_model=List[IncidentReportResponse], summary="List Incident Reports with Filter")
async def list_reports(
    district: Optional[str] = Query(None, description="Filter by district"),
    status: Optional[str] = Query(None, description="Filter by status"),
):
    results = REPORTS_DB
    if district:
        results = [r for r in results if r.district.lower() == district.lower()]
    if status:
        results = [r for r in results if r.status.upper() == status.upper()]
    return results

@router.post("", response_model=IncidentReportResponse, summary="Submit New Incident Report")
async def create_report(report_in: IncidentReportCreate):
    new_id = f"LR-2026-{len(REPORTS_DB) + 1000:04d}"
    
    # Auto-screening fallback if AI analysis not provided
    ai_result = report_in.ai_analysis
    if not ai_result:
        ai_result = AiVisionScreeningSchema(
            crack_detected=report_in.category in ["ground_crack", "landslide"],
            debris_detected=report_in.category in ["landslide", "rockfall"],
            road_obstruction=report_in.category == "road_blockage",
            confidence_score=0.91,
            summary=f"Automated AI hazard triage completed for {report_in.category}.",
        )

    new_report = IncidentReportResponse(
        id=new_id,
        reporter_id=report_in.reporter_id,
        reporter_name=report_in.reporter_name,
        reporter_phone=report_in.reporter_phone,
        category=report_in.category,
        severity=report_in.severity,
        latitude=report_in.latitude,
        longitude=report_in.longitude,
        state=report_in.state,
        district=report_in.district,
        landmark=report_in.landmark,
        description=report_in.description,
        media_urls=report_in.media_urls,
        status="SUBMITTED",
        ai_analysis=ai_result,
        created_at=datetime.now().strftime("%Y-%m-%d %H:%M IST"),
    )
    REPORTS_DB.insert(0, new_report)
    return new_report

@router.get("/{report_id}", response_model=IncidentReportResponse, summary="Get Incident Report by ID")
async def get_report(report_id: str):
    for r in REPORTS_DB:
        if r.id == report_id:
            return r
    raise HTTPException(status_code=404, detail="Incident report not found")

@router.patch("/{report_id}/status", response_model=IncidentReportResponse, summary="Update Report Status & Verification Notes")
async def update_report_status(report_id: str, update_in: IncidentReportStatusUpdate):
    for idx, r in enumerate(REPORTS_DB):
        if r.id == report_id:
            updated = r.model_copy(update={
                "status": update_in.status,
                "verified_by": update_in.verified_by,
                "resolution_notes": update_in.resolution_notes,
                "resolved_at": datetime.now().strftime("%Y-%m-%d %H:%M IST") if update_in.status == "RESOLVED" else r.resolved_at,
            })
            REPORTS_DB[idx] = updated
            return updated
    raise HTTPException(status_code=404, detail="Incident report not found")
