import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ner_landslideguard/core/routing/route_names.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/core/widgets/sync_status_pill_widget.dart';
import 'package:ner_landslideguard/features/admin_console/domain/entities/regional_analytics_entity.dart';
import 'package:ner_landslideguard/features/admin_console/presentation/providers/admin_command_provider.dart';
import 'package:ner_landslideguard/features/admin_console/presentation/widgets/emergency_broadcast_dialog.dart';

class AdminCommandCenterScreen extends ConsumerWidget {
  const AdminCommandCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminCommandStateProvider);
    final metrics = adminState.metrics;
    final states = adminState.filteredStates;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Disaster Authority Command Center', style: AppTypography.heading3),
            Text(
              'NDMA / SDMA 8-State North Eastern Regional Overwatch',
              style: AppTypography.caption.copyWith(color: AppColors.accentLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Broadcast Emergency Alert',
            icon: const Icon(Icons.broadcast_on_personal_rounded, color: AppColors.riskCritical),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const EmergencyBroadcastDialog(),
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh Regional Telemetry',
            icon: const Icon(Icons.refresh, color: AppColors.accentLight),
            onPressed: () => ref.read(adminCommandStateProvider.notifier).loadRegionalMetrics(),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () {
              try {
                context.goNamed(RouteNames.auth);
              } catch (_) {}
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(adminCommandStateProvider.notifier).loadRegionalMetrics();
          },
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Sync & Satellite Telemetry Pill
                const SyncStatusPillWidget(),
                const SizedBox(height: 10),

                // 2. Macro KPI Metrics Grid
                if (metrics != null) _buildMacroKpiGrid(metrics),
                const SizedBox(height: 20),

                // 3. Quick Action Bar
                _buildQuickActionBar(context),
                const SizedBox(height: 20),

                // 4. 8-State Regional Landslide Hazard Matrix
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('8-State Regional Hazard Matrix', style: AppTypography.heading3),
                    Text('Live GSI/IMD Telemetry', style: AppTypography.caption.copyWith(color: AppColors.accentLight)),
                  ],
                ),
                const SizedBox(height: 12),

                ...states.map((state) => _buildStateRiskCard(context, state)),
                const SizedBox(height: 24),

                // 5. Evacuation Shelters & Relief Camp Overwatch
                if (metrics != null) _buildShelterOverwatchPanel(metrics),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroKpiGrid(RegionalCommandMetricsEntity m) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiTile(
                title: 'Hazard Sectors Monitored',
                value: '${m.totalMonitoredZones}',
                subtitle: '${m.activeSensorsTotal} Active IoT Sensors',
                color: AppColors.accentLight,
                icon: Icons.shield_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiTile(
                title: 'Critical Red Warnings',
                value: '${m.activeCriticalAlerts}',
                subtitle: '${m.activeOrangeWarnings} Orange Advisories',
                color: AppColors.riskCritical,
                icon: Icons.warning_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildKpiTile(
                title: 'Blocked Highway Corridors',
                value: '${m.blockedHighwaysTotal}',
                subtitle: 'NH-13, NH-10, NH-29',
                color: AppColors.riskHigh,
                icon: Icons.traffic_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiTile(
                title: 'Shelter Bed Occupancy',
                value: '${m.occupiedShelterBeds}/${m.totalShelterCapacity}',
                subtitle: '${(m.shelterOccupancyRate * 100).toInt()}% Capacity Used',
                color: AppColors.riskLow,
                icon: Icons.night_shelter_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: color),
              Text(
                value,
                style: AppTypography.heading2.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: AppTypography.caption.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildQuickActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.broadcast_on_personal_rounded, size: 16),
              label: const Text('DISPATCH RED ALERT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.riskCritical,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const EmergencyBroadcastDialog(),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.map_rounded, size: 16),
              label: const Text('GIS COMMAND MAP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.divider),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                context.pushNamed(RouteNames.riskMap);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateRiskCard(BuildContext context, StateRiskOverviewEntity s) {
    final riskColor = AppColors.getRiskColor(s.compositeRiskScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(s.stateName, style: AppTypography.heading3),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${s.severity} • ${s.compositeRiskScore}/100',
                  style: TextStyle(color: riskColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Key Threat: ${s.primaryThreatCorridor}', style: AppTypography.bodySmall),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sensors: ${s.activeSensorsCount}', style: AppTypography.caption),
              Text('Road Blocks: ${s.blockedRoadsCount}', style: AppTypography.caption),
              Text('Relief Camps: ${s.evacuationSheltersCount}', style: AppTypography.caption),
              Text('NDRF Units: ${s.ndrfUnitsDeployed}', style: AppTypography.caption.copyWith(color: AppColors.accentLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShelterOverwatchPanel(RegionalCommandMetricsEntity m) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.night_shelter_rounded, color: AppColors.riskLow, size: 22),
              const SizedBox(width: 8),
              Text('Evacuation Relief Staging Facilities', style: AppTypography.heading3),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Live telemetry of designated shelters, medical personnel, and air rescue helipads.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: m.shelterOccupancyRate,
              backgroundColor: AppColors.surfaceLight,
              color: AppColors.riskLow,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Occupied: ${m.occupiedShelterBeds} Citizens', style: AppTypography.caption),
              Text('Available Capacity: ${m.totalShelterCapacity - m.occupiedShelterBeds} Beds', style: AppTypography.caption.copyWith(color: AppColors.riskLow)),
            ],
          ),
        ],
      ),
    );
  }
}
