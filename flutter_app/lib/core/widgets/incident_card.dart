import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'risk_badge.dart';

class IncidentCard extends StatelessWidget {
  final String reportId;
  final String category;
  final String severity;
  final String location;
  final String status;
  final String timeAgo;
  final String? imageUrl;
  final bool isOfflinePending;
  final VoidCallback? onTap;

  const IncidentCard({
    super.key,
    required this.reportId,
    required this.category,
    required this.severity,
    required this.location,
    required this.status,
    required this.timeAgo,
    this.imageUrl,
    this.isOfflinePending = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOfflinePending
                ? AppColors.warning.withValues(alpha: 0.5)
                : AppColors.surfaceBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media thumbnail or category icon placeholder
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Icon(
                Icons.landscape_rounded,
                color: AppColors.textSecondary,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            // Incident details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reportId,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RiskBadge(level: severity, isCompact: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: AppTypography.heading3.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(status, isOfflinePending),
                      Text(
                        timeAgo,
                        style: AppTypography.bodySmall.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String st, bool isPending) {
    if (isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 10, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              'PENDING SYNC',
              style: AppTypography.caption.copyWith(
                color: AppColors.warning,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    Color color;
    switch (st.toUpperCase()) {
      case 'VERIFIED':
        color = AppColors.success;
        break;
      case 'UNDER_REVIEW':
        color = AppColors.warning;
        break;
      case 'ACTION_INITIATED':
        color = AppColors.accentLight;
        break;
      case 'RESOLVED':
        color = AppColors.textMuted;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        st.replaceAll('_', ' '),
        style: AppTypography.caption.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
