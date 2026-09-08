import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/sync_status_pill_widget.dart';
import '../../authentication/presentation/providers/auth_provider.dart';
import '../../reports/domain/entities/incident_report_entity.dart';
import 'providers/field_officer_provider.dart';
import 'screens/officer_inspection_screen.dart';

class OfficerDashboardScreen extends ConsumerWidget {
  const OfficerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officerState = ref.watch(fieldOfficerStateProvider);
    final currentUser = ref.watch(currentUserProvider);
    final incidents = officerState.filteredIncidents;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Field Officer Console', style: AppTypography.heading3),
            Text(
              '${currentUser?.fullName ?? "Inspector Pemba"} • Sector: ${currentUser?.district ?? "Tawang"}',
              style: AppTypography.caption.copyWith(color: AppColors.accentLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Queue',
            icon: const Icon(Icons.refresh, color: AppColors.accentLight),
            onPressed: () => ref.read(fieldOfficerStateProvider.notifier).loadAssignedIncidents(),
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
            await ref.read(fieldOfficerStateProvider.notifier).loadAssignedIncidents();
          },
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Offline Sync Status Pill
                const SyncStatusPillWidget(),
                const SizedBox(height: 12),

                // 2. Metrics Summary Grid
                _buildMetricsGrid(officerState),
                const SizedBox(height: 16),

                // 3. Status Filter Tabs
                _buildStatusFilters(ref, officerState),
                const SizedBox(height: 16),

                // 4. Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Assigned Geotechnical Incidents (${incidents.length})',
                      style: AppTypography.heading3,
                    ),
                    Text(
                      'Proximity Sorted',
                      style: AppTypography.caption.copyWith(color: AppColors.accentLight),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 5. Incident Cards List or Empty State
                if (incidents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: EmptyStateView(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'No Incidents Pending',
                      message: 'No assigned geotechnical inspection tasks match the selected filter.',
                    ),
                  )
                else
                  ...incidents.map((inc) => _buildIncidentCard(context, ref, inc)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(FieldOfficerState state) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Pending Verification',
            value: '${state.pendingCount}',
            color: AppColors.riskHigh,
            icon: Icons.pending_actions_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Field Verified',
            value: '${state.verifiedCount}',
            color: AppColors.riskLow,
            icon: Icons.verified_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Resolved Cases',
            value: '${state.resolvedCount}',
            color: AppColors.accentLight,
            icon: Icons.task_alt_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              Icon(icon, size: 18, color: color),
              Text(
                value,
                style: AppTypography.heading2.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildStatusFilters(WidgetRef ref, FieldOfficerState state) {
    final filters = [
      {'key': 'ALL', 'label': 'All (${state.assignedIncidents.length})'},
      {'key': 'SUBMITTED', 'label': 'Pending (${state.pendingCount})'},
      {'key': 'VERIFIED', 'label': 'Verified (${state.verifiedCount})'},
      {'key': 'RESOLVED', 'label': 'Resolved (${state.resolvedCount})'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = state.selectedStatusFilter == f['key'];
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
                ref.read(fieldOfficerStateProvider.notifier).setFilter(f['key']!);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIncidentCard(BuildContext context, WidgetRef ref, IncidentReportEntity incident) {
    Color sevColor;
    switch (incident.severity.toUpperCase()) {
      case 'CRITICAL':
        sevColor = AppColors.riskCritical;
        break;
      case 'HIGH':
        sevColor = AppColors.riskHigh;
        break;
      case 'MODERATE':
      default:
        sevColor = AppColors.riskModerate;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: sevColor.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(incident.id, style: AppTypography.caption.copyWith(color: AppColors.accentLight)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  incident.severity,
                  style: TextStyle(color: sevColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location & Type
          Text(
            '${incident.district} — ${incident.landmark ?? "Road Sector"}',
            style: AppTypography.heading3,
          ),
          const SizedBox(height: 4),
          Text(
            'Category: ${incident.category.displayName} • Reported ${incident.createdAt}',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 8),

          // Citizen Description Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              incident.description,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.rate_review_rounded, size: 16),
                  label: Text(
                    incident.status == 'VERIFIED' ? 'Update Inspection' : 'Start Field Inspection',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ref.read(fieldOfficerStateProvider.notifier).setActiveInspection(incident);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OfficerInspectionScreen(incident: incident),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
