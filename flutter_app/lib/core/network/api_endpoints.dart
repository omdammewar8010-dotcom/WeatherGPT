class ApiEndpoints {
  // Auth
  static const String authVerify = '/auth/verify-token';
  static const String authLogin = '/auth/login';

  // Risk & Predictions
  static const String riskZones = '/risk/zones';
  static const String riskLocation = '/risk'; // + /{location_id}
  static const String riskPredict = '/risk/predict';
  static const String predictExplain = '/predictions/explain'; // + /{location_id}

  // Weather & Sensors
  static const String weatherLocation = '/weather'; // + /{location_id}
  static const String sensorsTelemetry = '/sensors/telemetry';

  // Reports
  static const String reports = '/reports';
  static const String reportStatus = '/reports'; // + /{report_id}/status

  // Alerts
  static const String alerts = '/alerts';
  static const String alertsBroadcast = '/alerts/broadcast';

  // Emergency & Roads
  static const String emergencyPriorities = '/emergency/priorities';
  static const String emergencySafeRoutes = '/emergency/safe-routes';
  static const String roads = '/roads';
  static const String history = '/history';

  // Analytics
  static const String analyticsNerSummary = '/analytics/ner-summary';
}
