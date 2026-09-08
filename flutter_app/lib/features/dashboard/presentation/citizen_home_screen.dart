import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
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
import 'widgets/district_picker_dialog.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/risk_hero_card.dart';

class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final dashboardState = ref.watch(dashboardStateProvider);
    final profile = dashboardState.riskProfile;
    final user = authState.user;

    final displayName = user?.fullName.split(' ').first ?? 'Citizen';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.landscape_rounded, size: 20, color: AppColors.accentLight),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NER-LandslideGuard', style: AppTypography.heading3.copyWith(fontSize: 15)),
                Text(
                  'Good day, $displayName 👋',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
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

                // Location header with 1-tap district switcher
                LocationHeader(
                  stateName: profile?.state ?? 'Arunachal Pradesh',
                  districtName: profile?.district ?? dashboardState.selectedDistrict,
                  village: profile?.locationName,
                  lastUpdated: profile?.lastUpdatedTime ?? 'Live',
                  onChangeLocation: () => DistrictPickerDialog.show(context),
                ),
                const SizedBox(height: 16),

                // Main Risk Hero Gauge Card
                if (dashboardState.isLoading || profile == null) ...[
                  const ShimmerSkeleton(width: double.infinity, height: 320, borderRadius: 16),
                ] else ...[
                  RiskHeroCard(
                    profile: profile,
                    onExplainRisk: () => context.pushNamed(
                      RouteNames.riskAnalysis,
                      queryParameters: {'location_id': profile.locationId},
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Active Warning Banner
                if (profile != null) ...[
                  ActiveWarningCard(
                    advisoryText: profile.activeAdvisory,
                    riskLevel: profile.riskLevel,
                    onViewDetails: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Standard operating protocol: Avoid steep slopes & unpaved mountain roads.'),
                          backgroundColor: AppColors.surfaceLight,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // 4 Operational Quick Action Cards
                QuickActionsGrid(
                  onOpenMap: () => context.pushNamed(RouteNames.riskMap),
                  onReportIncident: () => context.pushNamed(RouteNames.reportIncident),
                  onWeather: () => context.pushNamed(RouteNames.weather),
                  onEmergency: () => context.pushNamed(RouteNames.emergency),
                  onRoads: () => context.pushNamed(RouteNames.roads),
                  onAlerts: () => context.pushNamed(RouteNames.alertCenter),
                ),
                const SizedBox(height: 24),

                // Scientific Disclaimer Box
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
                      const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppConstants.scientificDisclaimer,
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
