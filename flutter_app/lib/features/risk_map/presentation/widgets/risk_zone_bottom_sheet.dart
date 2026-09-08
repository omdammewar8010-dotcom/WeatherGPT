import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../domain/entities/gis_feature_entity.dart';

class RiskZoneBottomSheet extends StatelessWidget {
  final GisFeatureEntity feature;
  final VoidCallback onDismiss;
  final VoidCallback? onDetailedAnalysis;

  const RiskZoneBottomSheet({
    super.key,
    required this.feature,
    required this.onDismiss,
    this.onDetailedAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = AppColors.getRiskColor(feature.riskScore);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: AppTypography.heading2.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature.subtitle,
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              RiskBadge(score: feature.riskScore),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),

          // Environmental Metrics Grid (if available)
          if (feature.rainfall24h != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFact('Rainfall 24h', '${feature.rainfall24h!.toStringAsFixed(0)} mm', Icons.water_drop_outlined),
                _buildFact('Soil Moisture', '${feature.soilMoisture?.toStringAsFixed(0) ?? "88"}%', Icons.grain_outlined),
                _buildFact('Slope Angle', '${feature.slopeDegrees?.toStringAsFixed(0) ?? "38"}°', Icons.terrain_outlined),
                _buildFact('Forecast', '+${feature.forecast24h?.toStringAsFixed(0) ?? "80"} mm', Icons.cloud_outlined),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // Status & Historical info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.traffic_rounded,
                      size: 16,
                      color: feature.riskScore >= 80 ? AppColors.riskCritical : AppColors.accentLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Road Status: ${feature.roadStatus ?? "Clear & Passable"}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (feature.historicalEventsCount != null) ...[
                  Text(
                    'History: ${feature.historicalEventsCount} events',
                    style: AppTypography.bodySmall.copyWith(fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismiss,
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onDetailedAnalysis,
                  style: ElevatedButton.styleFrom(backgroundColor: riskColor),
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label: const Text('View Full Analysis'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFact(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.heading3.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 1),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 9, color: AppColors.textMuted)),
      ],
    );
  }
}
