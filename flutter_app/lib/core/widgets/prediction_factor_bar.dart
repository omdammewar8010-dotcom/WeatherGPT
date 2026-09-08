import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PredictionFactorBar extends StatelessWidget {
  final String title;
  final double percentage; // 0.0 to 100.0
  final String? valueDisplay;
  final Color? barColor;
  final IconData? icon;

  const PredictionFactorBar({
    super.key,
    required this.title,
    required this.percentage,
    this.valueDisplay,
    this.barColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percentage.clamp(0.0, 100.0);
    final effectiveColor = barColor ??
        (clampedPercent >= 80
            ? AppColors.riskCritical
            : clampedPercent >= 60
                ? AppColors.riskHigh
                : clampedPercent >= 30
                    ? AppColors.riskModerate
                    : AppColors.riskLow);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                valueDisplay ?? '${clampedPercent.toStringAsFixed(0)}%',
                style: AppTypography.caption.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress Track
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fillWidth = constraints.maxWidth * (clampedPercent / 100.0);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    width: fillWidth,
                    height: 8,
                    decoration: BoxDecoration(
                      color: effectiveColor,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: effectiveColor.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
