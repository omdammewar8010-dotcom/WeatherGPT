class AppConstants {
  // Brand & Government Disclaimers
  static const String appTitle = 'NER-LandslideGuard';
  static const String appTagline = 'Predict. Warn. Respond. Protect.';
  static const String sihStatement = 'SIH26001: AI-Based Early Warning & Landslide Risk Monitoring';
  static const String scientificDisclaimer =
      'Scientific Disclaimer: The system estimates landslide risk using real-time and historical multi-source indicators. Predictions are decision-support insights and must be used alongside official alerts from local disaster management authorities (NDMA/SDMA).';

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
