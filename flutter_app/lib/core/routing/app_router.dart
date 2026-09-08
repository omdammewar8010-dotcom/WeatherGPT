import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/alerts/presentation/screens/alert_center_screen.dart';
import '../../features/admin_console/presentation/admin_command_center_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/citizen_home_screen.dart';
import '../../features/emergency/presentation/screens/emergency_screen.dart';
import '../../features/field_officer/presentation/officer_dashboard_screen.dart';
import '../../features/onboarding_splash/presentation/splash_screen.dart';
import '../../features/reports/presentation/screens/report_incident_screen.dart';
import '../../features/reports/presentation/screens/report_status_screen.dart';
import '../../features/risk_analysis/presentation/screens/risk_analysis_screen.dart';
import '../../features/risk_map/presentation/screens/risk_map_screen.dart';
import '../../features/roads_overwatch/presentation/screens/road_overwatch_screen.dart';
import '../../features/weather_radar/presentation/screens/weather_radar_screen.dart';
import '../widgets/design_system_preview_screen.dart';
import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      name: RouteNames.auth,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/citizen',
      name: RouteNames.citizenHome,
      builder: (context, state) => const CitizenHomeScreen(),
    ),
    GoRoute(
      path: '/risk-map',
      name: RouteNames.riskMap,
      builder: (context, state) => const RiskMapScreen(),
    ),
    GoRoute(
      path: '/risk-analysis',
      name: RouteNames.riskAnalysis,
      builder: (context, state) {
        final locId = state.uri.queryParameters['location_id'];
        return RiskAnalysisScreen(locationId: locId);
      },
    ),
    GoRoute(
      path: '/weather',
      name: RouteNames.weather,
      builder: (context, state) => const WeatherRadarScreen(),
    ),
    GoRoute(
      path: '/report-incident',
      name: RouteNames.reportIncident,
      builder: (context, state) => const ReportIncidentScreen(),
    ),
    GoRoute(
      path: '/report-status',
      name: RouteNames.reportStatus,
      builder: (context, state) => const ReportStatusScreen(),
    ),
    GoRoute(
      path: '/alerts',
      name: RouteNames.alertCenter,
      builder: (context, state) => const AlertCenterScreen(),
    ),
    GoRoute(
      path: '/emergency',
      name: RouteNames.emergency,
      builder: (context, state) => const EmergencyScreen(),
    ),
    GoRoute(
      path: '/roads',
      name: RouteNames.roads,
      builder: (context, state) => const RoadOverwatchScreen(),
    ),
    GoRoute(
      path: '/history',
      name: RouteNames.history,
      builder: (context, state) => const RoadOverwatchScreen(),
    ),
    GoRoute(
      path: '/officer',
      name: RouteNames.officerDashboard,
      builder: (context, state) => const OfficerDashboardScreen(),
    ),
    GoRoute(
      path: '/admin',
      name: RouteNames.adminCommandCenter,
      builder: (context, state) => const AdminCommandCenterScreen(),
    ),
    GoRoute(
      path: '/design-preview',
      name: RouteNames.designPreview,
      builder: (context, state) => const DesignSystemPreviewScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
