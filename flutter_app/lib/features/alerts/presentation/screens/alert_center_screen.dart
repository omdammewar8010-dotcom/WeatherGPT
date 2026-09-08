import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../domain/entities/early_warning_entity.dart';
import '../providers/alert_provider.dart';

class AlertCenterScreen extends ConsumerWidget {
  const AlertCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertState = ref.watch(alertStateProvider);
    final warnings = alertState.filteredWarnings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Emergency Alert Center',
          style: AppTypography.heading2,
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Warnings',
            icon: const Icon(Icons.refresh, color: AppColors.accentLight),
            onPressed: () => ref.read(alertStateProvider.notifier).loadWarnings(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(alertStateProvider.notifier).loadWarnings();
        },
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Critical Siren / Emergency Status Banner
              _buildSirenStatusBanner(context, ref, alertState),
              const SizedBox(height: 16),

              // 2. Urgency Filter Tabs
              _buildFilterChips(ref, alertState),
              const SizedBox(height: 16),

              // 3. Bulletins Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Early Warnings (${warnings.length})',
                    style: AppTypography.heading3,
                  ),
                  Text(
                    'NDMA / GSI Verified',
                    style: AppTypography.caption.copyWith(color: AppColors.accentLight),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Warning Cards List or Empty State
              if (warnings.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: EmptyStateView(
                    icon: Icons.check_circle_outline,
                    title: 'No Active Warnings',
                    message: 'All slopes in this sector are currently within safe baseline parameters.',
                  ),
                )
              else
                ...warnings.map((warning) => _buildWarningCard(context, ref, warning)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSirenStatusBanner(BuildContext context, WidgetRef ref, AlertState state) {
    final isSirenOn = state.isSirenPlaying;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSirenOn
            ? AppColors.riskCritical.withValues(alpha: 0.15)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSirenOn ? AppColors.riskCritical : AppColors.divider,
          width: isSirenOn ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSirenOn
                      ? AppColors.riskCritical
                      : AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSirenOn ? Icons.volume_up_rounded : Icons.notifications_active_rounded,
                  color: isSirenOn ? Colors.white : AppColors.accentLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSirenOn
                          ? 'EMERGENCY SIREN ACTIVE'
                          : 'Early Warning Broadcast Hub',
                      style: AppTypography.heading3.copyWith(
                        color: isSirenOn ? AppColors.riskCritical : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSirenOn
                          ? 'High-pitch auditory siren test in progress...'
                          : '${state.criticalCount} Red Alert(s) active in North East Region',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => ref.read(alertStateProvider.notifier).toggleSiren(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSirenOn ? AppColors.riskCritical : AppColors.surfaceLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isSirenOn ? 'MUTE' : 'TEST SIREN',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, AlertState state) {
    final filters = [
      {'key': 'ALL', 'label': 'All (${state.warnings.length})'},
      {'key': 'CRITICAL', 'label': '🔴 Red (${state.criticalCount})'},
      {'key': 'HIGH', 'label': '🟠 Orange (${state.highCount})'},
      {'key': 'MODERATE', 'label': '🟡 Yellow (${state.moderateCount})'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = state.selectedSeverityFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                f['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.accent,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.accent : AppColors.divider,
              ),
              onSelected: (_) {
                ref.read(alertStateProvider.notifier).setSeverityFilter(f['key']!);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context, WidgetRef ref, EarlyWarningEntity warning) {
    Color severityColor;
    String badgeText;
    switch (warning.severity.toUpperCase()) {
      case 'CRITICAL':
        severityColor = AppColors.riskCritical;
        badgeText = 'RED ALERT';
        break;
      case 'HIGH':
        severityColor = AppColors.riskHigh;
        badgeText = 'ORANGE WARNING';
        break;
      case 'MODERATE':
      default:
        severityColor = AppColors.riskModerate;
        badgeText = 'YELLOW ADVISORY';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: severityColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Sector, Badge & Timestamp
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${warning.district}, ${warning.state}',
                  style: AppTypography.caption,
                ),
                const Spacer(),
                Text(
                  warning.createdAt,
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              warning.title,
              style: AppTypography.heading3,
            ),
            const SizedBox(height: 6),

            // Validity Countdown Tag
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: AppColors.riskHigh),
                const SizedBox(width: 4),
                Text(
                  warning.validUntil,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.riskHigh,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.analytics_outlined, size: 14, color: AppColors.accentLight),
                const SizedBox(width: 4),
                Text(
                  'AI Risk Score: ${warning.riskScore}/100',
                  style: AppTypography.caption.copyWith(color: AppColors.accentLight),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Advisory Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning.advisory,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Affected Sectors Chips
            if (warning.affectedSectors.isNotEmpty) ...[
              Text(
                'AFFECTED SECTORS & VILLAGES:',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: warning.affectedSectors.map((sector) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      sector,
                      style: AppTypography.caption,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Evacuation Corridor Banner
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.riskLow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.riskLow.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alt_route_rounded, color: AppColors.riskLow, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Designated Evacuation Corridor',
                          style: TextStyle(
                            color: AppColors.riskLow,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          warning.evacuationRoute,
                          style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons: Navigate Route on Map & Share
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('View on Map', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      context.pushNamed(RouteNames.riskMap);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Broadcast Alert', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: severityColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Dispatched early warning advisory for ${warning.district}'),
                          backgroundColor: severityColor,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
