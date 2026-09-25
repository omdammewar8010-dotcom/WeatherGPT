import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/location_header.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../authentication/presentation/providers/auth_provider.dart';
import '../../authentication/presentation/widgets/demo_user_selector_dialog.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/active_warning_card.dart';
import 'widgets/climate_trend_card.dart';
import 'widgets/district_picker_dialog.dart';
import 'widgets/nowcasting_timeline_card.dart';
import 'widgets/nwp_consensus_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/sector_advisories_carousel.dart';
import 'widgets/weather_hero_card.dart';
import 'widgets/weathergpt_copilot_card.dart';

class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final dashboardState = ref.watch(dashboardStateProvider);
    final profile = dashboardState.riskProfile;
    final user = authState.user;

    final displayName = user?.fullName.split(' ').first ?? 'Citizen';
    final currentDistrict = profile?.district ?? dashboardState.selectedDistrict;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        elevation: 6,
        icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Ask WeatherGPT',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3, color: Colors.white),
        ),
        onPressed: () => context.pushNamed(RouteNames.weathergptChat),
      ),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.cloud_sync_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('WeatherGPT', style: AppTypography.heading3.copyWith(fontSize: 15)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 0.6),
                      ),
                      child: const Text('MoES / IMD', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.accentLight)),
                    ),
                  ],
                ),
                Text(
                  'Good day, $displayName 👋',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // WeatherGPT Chat Shortcut
          IconButton(
            tooltip: 'Open WeatherGPT Chatbot',
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.accentLight),
            onPressed: () => context.pushNamed(RouteNames.weathergptChat),
          ),
          // Quick Switch Role Button for Hackathon Judges
          IconButton(
            tooltip: 'Switch Demo Profile',
            icon: const Icon(Icons.switch_account_rounded, color: AppColors.accentLight),
            onPressed: () => DemoUserSelectorDialog.show(context),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.goNamed(RouteNames.auth);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(dashboardStateProvider.notifier).refresh(),
          backgroundColor: AppColors.surface,
          color: AppColors.accent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offline status indicator
                OfflineBanner(
                  isOffline: dashboardState.isOffline,
                  pendingSyncCount: 0,
                ),
                const SizedBox(height: 6),

                // Pan-India Location header with 1-tap district switcher
                LocationHeader(
                  stateName: profile?.state ?? 'National Capital Region',
                  districtName: currentDistrict,
                  village: profile?.locationName,
                  lastUpdated: profile?.lastUpdatedTime ?? 'Live',
                  onChangeLocation: () => DistrictPickerDialog.show(context),
                ),
                const SizedBox(height: 14),

                // 1. Live Weather Hero Card (Temperature, Weather Condition, IMD Alert Badge & 6 Met Sensors)
                if (dashboardState.isLoading || profile == null) ...[
                  const ShimmerSkeleton(width: double.infinity, height: 320, borderRadius: 16),
                ] else ...[
                  WeatherHeroCard(
                    profile: profile,
                    onExplainRisk: () => context.pushNamed(
                      RouteNames.riskAnalysis,
                      queryParameters: {'location_id': profile.locationId},
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // 2. WeatherGPT Conversational Voice & Text Copilot
                WeatherGptCopilotCard(currentDistrict: currentDistrict),
                const SizedBox(height: 16),

                // 3. Doppler Radar Nowcasting (<3h timeline with hourly forecast & dBZ reflectivity)
                if (profile != null) ...[
                  NowcastingTimelineCard(
                    district: currentDistrict,
                    rainfall24h: profile.rainfall24h,
                    riskLevel: profile.riskLevel,
                    onViewFullRadar: () => context.pushNamed(RouteNames.weather),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. IMD Severe Weather Warning Card
                if (profile != null) ...[
                  ActiveWarningCard(
                    advisoryText: profile.activeAdvisory,
                    riskLevel: profile.riskLevel,
                    onViewDetails: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('IMD Standard Advisory: Monitor localized Doppler radar & de-silt storm drains.'),
                          backgroundColor: AppColors.surfaceLight,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. NWP Multi-Model Consensus (NOAA GFS vs NCAR WRF vs IMD MME)
                if (profile != null) ...[
                  NwpConsensusCard(
                    currentRainfall: profile.rainfall24h,
                    district: currentDistrict,
                  ),
                  const SizedBox(height: 16),
                ],

                // 6. Sector Decision Advisories Carousel (Agromet, Aviation, Marine, Smart City)
                SectorAdvisoriesCarousel(
                  onOpenAdvisories: () => context.pushNamed(RouteNames.sectorAdvisories),
                ),
                const SizedBox(height: 16),

                // 7. Decadal Climate Trends & Monsoon Anomaly
                const ClimateTrendCard(),
                const SizedBox(height: 16),

                // 8. 4 Operational Quick Action Cards
                QuickActionsGrid(
                  onOpenMap: () => context.pushNamed(RouteNames.riskMap),
                  onReportIncident: () => context.pushNamed(RouteNames.reportIncident),
                  onWeather: () => context.pushNamed(RouteNames.weather),
                  onEmergency: () => context.pushNamed(RouteNames.emergency),
                  onRoads: () => context.pushNamed(RouteNames.sectorAdvisories),
                  onAlerts: () => context.pushNamed(RouteNames.alertCenter),
                ),
                const SizedBox(height: 24),

                // Scientific IMD / MoES Disclaimer Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.accentLight),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Powered by Ministry of Earth Sciences (MoES) & India Meteorological Department (IMD). Built for SIH26068 (WeatherGPT) with Doppler Radar Nowcasting, NWP GFS/WRF Ensembles, and Multilingual Conversational Intelligence.',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
