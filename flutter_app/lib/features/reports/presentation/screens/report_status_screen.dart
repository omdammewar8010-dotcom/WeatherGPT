import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/incident_card.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../providers/report_provider.dart';

class ReportStatusScreen extends ConsumerWidget {
  const ReportStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportStateProvider);
    final reports = reportState.reports;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Incident Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(reportStateProvider.notifier).loadReports(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.riskCritical,
        icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
        label: const Text('Report New Hazard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => context.pushNamed(RouteNames.reportIncident),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Offline sync banner if pending reports exist
            if (reportState.pendingSyncCount > 0)
              OfflineBanner(
                isOffline: false,
                pendingSyncCount: reportState.pendingSyncCount,
                onForceSync: () async {
                  final synced = await ref.read(reportStateProvider.notifier).triggerSync();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully synced $synced pending reports to cloud.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),

            Expanded(
              child: reports.isEmpty
                  ? EmptyStateView(
                      icon: Icons.assignment_outlined,
                      title: 'No Incident Reports Yet',
                      message: 'Submit landslide, crack, or blockage reports to help protect your community.',
                      actionLabel: 'Report First Incident',
                      onAction: () => context.pushNamed(RouteNames.reportIncident),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return IncidentCard(
                          reportId: report.id,
                          category: report.category.displayName,
                          severity: report.severity,
                          location: '${report.landmark ?? "Road Section"}, ${report.district}',
                          status: report.status,
                          timeAgo: report.createdAt,
                          isOfflinePending: report.isOfflinePending,
                          onTap: () {
                            _showReportDetails(context, report);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetails(BuildContext context, dynamic report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(report.id, style: AppTypography.heading3.copyWith(color: AppColors.accentLight)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report.status,
                    style: AppTypography.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(report.category.displayName, style: AppTypography.heading2),
            const SizedBox(height: 4),
            Text('📍 ${report.landmark ?? report.district}', style: AppTypography.bodySmall),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text('Description:', style: AppTypography.caption),
            const SizedBox(height: 4),
            Text(report.description, style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            if (report.aiAnalysis != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppColors.accentLight),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Vision: ${report.aiAnalysis.summary}',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
