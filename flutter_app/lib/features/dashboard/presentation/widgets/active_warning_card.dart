import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/risk_badge.dart';

class ActiveWarningCard extends StatelessWidget {
  final String advisoryText;
  final String riskLevel;
  final VoidCallback? onViewDetails;

  const ActiveWarningCard({
    super.key,
    required this.advisoryText,
    required this.riskLevel,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = riskLevel.toUpperCase() == 'CRITICAL';
    final isHigh = riskLevel.toUpperCase() == 'HIGH';
    final cardColor = isCritical
        ? AppColors.riskCritical
        : isHigh
            ? AppColors.riskHigh
            : AppColors.riskModerate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.06),
            blurRadius: 12,
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
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: cardColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ACTIVE LANDSLIDE WARNING',
                    style: AppTypography.caption.copyWith(
                      color: cardColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              RiskBadge(level: riskLevel, isCompact: true),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            advisoryText,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
              fontSize: 13,
            ),
          ),
          if (onViewDetails != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onViewDetails,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.accentLight),
                label: Text(
                  'Advisory Protocols',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accentLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
