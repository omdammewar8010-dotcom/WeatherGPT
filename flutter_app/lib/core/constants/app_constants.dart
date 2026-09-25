class AppConstants {
  // Brand & Government Disclaimers
  static const String appTitle = 'WeatherGPT';
  static const String appTagline = 'Conversational Weather & Climate Intelligence (MoES / IMD)';
  static const String sihStatement = 'SIH26068: Conversational AI for Weather Forecasting, Alerts, and Climate Information';
  static const String scientificDisclaimer =
      'Scientific Disclaimer: WeatherGPT synthesizes meteorological intelligence using IMD Doppler radar nowcasting, numerical weather prediction (NWP GFS & WRF), and climate trends. Predictions are decision-support insights and must be used alongside official alerts from India Meteorological Department (IMD) and disaster management authorities (NDMA/SDMA).';

  // 8 North Eastern States of India
  static const List<String> nerStates = [
    'Arunachal Pradesh',
    'Assam',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Sikkim',
    'Tripura',
  ];

  // User Roles
  static const String roleCitizen = 'citizen';
  static const String roleFieldOfficer = 'field_officer';
  static const String roleAuthorityAdmin = 'authority_admin';

  // Storage Keys
  static const String keyUserRole = 'user_role';
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyDemoMode = 'is_demo_mode';
  static const String keyLocale = 'selected_locale';
  static const String keyOfflineQueue = 'offline_reports_queue';
  static const String keyCachedRisk = 'cached_risk_zones';
}
