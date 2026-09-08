/// Firestore Collection Constants & Path Definitions for NER-LandslideGuard
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String incidentReports = 'incident_reports';
  static const String riskAssessments = 'risk_assessments';
  static const String earlyWarnings = 'early_warnings';
  static const String iotSensors = 'iot_sensors';
  static const String roadStatus = 'road_status';
  static const String evacuationShelters = 'evacuation_shelters';
  static const String systemAuditLogs = 'system_audit_logs';

  // Sub-collection helpers
  static String userNotifications(String userId) => '$users/$userId/notifications';
  static String reportAuditTrail(String reportId) => '$incidentReports/$reportId/audit_trail';
  static String sensorTelemetryHistory(String sensorId) => '$iotSensors/$sensorId/telemetry_history';
}

/// Firebase Cloud Storage Paths
class FirebaseStoragePaths {
  FirebaseStoragePaths._();

  static String incidentPhoto(String reportId, String filename) =>
      'incident_media/$reportId/$filename';
  static String incidentThumbnail(String reportId, String filename) =>
      'incident_media/$reportId/thumbnails/$filename';
  static String shelterMap(String district) =>
      'gis_assets/shelters/${district.toLowerCase()}_shelters.geojson';
  static String hazardPolygon(String sectorId) =>
      'gis_assets/hazard_zones/$sectorId.geojson';
}

/// Notification Topics for FCM
class FcmTopics {
  FcmTopics._();

  static const String globalEmergencyAlerts = 'ner_emergency_alerts_global';
  static const String criticalWarnings = 'ner_alerts_critical';
  static const String fieldOfficers = 'ner_field_officers';
  static const String authorityAdmins = 'ner_authority_admins';

  static String districtTopic(String districtName) =>
      'district_${districtName.toLowerCase().replaceAll(' ', '_')}';
  static String stateTopic(String stateName) =>
      'state_${stateName.toLowerCase().replaceAll(' ', '_')}';
}
