import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class LocationHeader extends StatelessWidget {
  final String stateName;
  final String districtName;
  final String? village;
  final String lastUpdated;
  final VoidCallback? onChangeLocation;

  const LocationHeader({
    super.key,
    required this.stateName,
    required this.districtName,
    this.village,
    required this.lastUpdated,
    this.onChangeLocation,
  });

  @override
  Widget build(BuildContext context) {
    final locationString = village != null
        ? '$village, $districtName, $stateName'
        : '$districtName, $stateName';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              size: 18,
              color: AppColors.accentLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationString,
                  style: AppTypography.heading3.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.riskLow,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live Sensor Feed • $lastUpdated',
                      style: AppTypography.bodySmall.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onChangeLocation != null) ...[
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.textSecondary, size: 20),
              onPressed: onChangeLocation,
              tooltip: 'Switch District',
            ),
          ],
        ],
      ),
    );
  }
}
