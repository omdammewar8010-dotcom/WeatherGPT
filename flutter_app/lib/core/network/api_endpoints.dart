class ApiEndpoints {
  // WeatherGPT Conversational Intelligence
  static const String weathergptChat = '/weathergpt/chat';
  static const String weathergptVoiceTranscribe = '/weathergpt/voice-transcribe';
  static const String weathergptQuickPrompts = '/weathergpt/quick-prompts';

  // Weather, NWP & Climate Trends
  static const String weatherRadar = '/weather/radar'; // + /{district}
  static const String weatherNwpCompare = '/weather/nwp/compare'; // + /{district}
  static const String weatherClimateTrends = '/weather/climate/trends'; // + /{district}
  static const String weatherLocation = '/weather'; // + /{location_id}
  static const String sensorsTelemetry = '/sensors/telemetry';

  // Alerts & Warnings
  static const String alerts = '/alerts';
  static const String alertsActive = '/alerts/active';
  static const String alertsBroadcast = '/alerts/broadcast';

  // Risk & Predictions
  static const String riskZones = '/risk/zones';
  static const String riskLocation = '/risk'; // + /{location_id}
  static const String riskPredict = '/risk/predict';
  static const String predictionsNwpInfer = '/predictions/nwp-infer';
  static const String predictionsHybridInfer = '/predictions/hybrid-infer';
  static const String predictExplain = '/predictions/explain';

  // Auth
  static const String authVerify = '/auth/verify-token';
  static const String authLogin = '/auth/login';

  // Reports
  static const String reports = '/reports';
  static const String reportStatus = '/reports'; // + /{report_id}/status

  // Emergency & Lifelines
  static const String emergencyPriorities = '/emergency/priorities';
  static const String emergencySafeRoutes = '/emergency/safe-routes';
  static const String roads = '/roads';
  static const String history = '/history';
}
