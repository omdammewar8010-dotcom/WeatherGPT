import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'risk_badge.dart';

class AlertCard extends StatelessWidget {
  final String title;
  final String location;
  final String description;
  final String timeAgo;
  final String severity; // "CRITICAL", "HIGH", "MODERATE", "ADVISORY"
  final VoidCallback? onTap;
  final bool isDismissible;

  const AlertCard({
    super.key,
    required this.title,
    required this.location,
    required this.description,
    required this.timeAgo,
    required this.severity,
    this.onTap,
    this.isDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getColor(severity);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: severityColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: severityColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RiskBadge(level: severity, isCompact: true),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.accentLight),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accentLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTypography.bodyMedium.copyWith(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (onTap != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Advisory & Actions',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.accentLight),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColor(String sev) {
    switch (sev.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.riskCritical;
      case 'HIGH':
        return AppColors.riskHigh;
      case 'MODERATE':
        return AppColors.riskModerate;
      default:
        return AppColors.accent;
    }
  }
}
