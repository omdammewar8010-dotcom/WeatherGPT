class GeotechnicalInspectionEntity {
  final String inspectionId;
  final String reportId;
  final String inspectorId;
  final String inspectorName;
  final String inspectorBadge;
  final double crackLengthMeters;
  final double crackDepthCm;
  final double slopeTiltMeasuredDeg;
  final bool seepageVisible;
  final bool retainingWallDeformation;
  final bool vegetationDisturbance;
  final double soilMoistureDirectReading;
  final String geologicalFormationObserved;
  final String recommendedAction; // "DEPLOY_EXCAVATOR", "EVACUATE_IMMEDIATELY", "INSTALL_WIRE_MESH", "MONITOR_HOURLY", "CLOSE_ROAD"
  final String officerNotes;
  final String verificationStatus; // "VERIFIED", "FALSE_ALARM", "ESCALATED_CRITICAL", "RESOLVED"
  final DateTime inspectedAt;

  const GeotechnicalInspectionEntity({
    required this.inspectionId,
    required this.reportId,
    required this.inspectorId,
    required this.inspectorName,
    required this.inspectorBadge,
    required this.crackLengthMeters,
    required this.crackDepthCm,
    required this.slopeTiltMeasuredDeg,
    required this.seepageVisible,
    required this.retainingWallDeformation,
    required this.vegetationDisturbance,
    required this.soilMoistureDirectReading,
    required this.geologicalFormationObserved,
    required this.recommendedAction,
    required this.officerNotes,
    required this.verificationStatus,
    required this.inspectedAt,
  });

  Map<String, dynamic> toJson() => {
        'inspection_id': inspectionId,
        'report_id': reportId,
        'inspector_id': inspectorId,
        'inspector_name': inspectorName,
        'inspector_badge': inspectorBadge,
        'crack_length_meters': crackLengthMeters,
        'crack_depth_cm': crackDepthCm,
        'slope_tilt_measured_deg': slopeTiltMeasuredDeg,
        'seepage_visible': seepageVisible,
        'retaining_wall_deformation': retainingWallDeformation,
        'vegetation_disturbance': vegetationDisturbance,
        'soil_moisture_direct_reading': soilMoistureDirectReading,
        'geological_formation_observed': geologicalFormationObserved,
        'recommended_action': recommendedAction,
        'officer_notes': officerNotes,
        'verification_status': verificationStatus,
        'inspected_at': inspectedAt.toIso8601String(),
      };
}
