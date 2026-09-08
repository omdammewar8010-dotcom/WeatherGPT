import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class RiskBadge extends StatelessWidget {
  final int? score;
  final String? level;
  final bool isCompact;

  const RiskBadge({
    super.key,
    this.score,
    this.level,
    this.isCompact = false,
  }) : assert(score != null || level != null, 'Either score or level must be provided');

  @override
  Widget build(BuildContext context) {
    final effectiveLevel = level ?? AppColors.getRiskLabel(score!);
    final effectiveColor = score != null
        ? AppColors.getRiskColor(score!)
        : _getColorFromLevel(effectiveLevel);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 10,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isCompact ? 4 : 6),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? 5 : 7,
            height: isCompact ? 5 : 7,
            decoration: BoxDecoration(
              color: effectiveColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isCompact ? 4 : 6),
          Text(
            score != null ? '$effectiveLevel ($score)' : effectiveLevel,
            style: AppTypography.caption.copyWith(
              color: effectiveColor,
              fontSize: isCompact ? 9 : 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromLevel(String lvl) {
    switch (lvl.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.riskCritical;
      case 'HIGH':
        return AppColors.riskHigh;
      case 'MODERATE':
        return AppColors.riskModerate;
      case 'LOW':
      default:
        return AppColors.riskLow;
    }
  }
}
