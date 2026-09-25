class EnvConfig {
  static const String appName = 'WeatherGPT';
  static const String appVersion = '2.0.0';
  static const String appTagline = 'Conversational Weather & Climate Intelligence (MoES / IMD)';
  static const String sihStatement = 'SIH26068';
  
  // Base URLs - default points to local FastAPI backend; can be configured at runtime
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1', // Android Emulator fallback
  );

  static const String apiBaseUrlWeb = String.fromEnvironment(
    'API_BASE_URL_WEB',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  static const bool isDemoModeDefault = true;
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}
