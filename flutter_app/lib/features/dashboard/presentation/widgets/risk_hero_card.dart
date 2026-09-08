import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/risk_score_dial.dart';
import '../../domain/entities/risk_profile_entity.dart';

class RiskHeroCard extends StatelessWidget {
  final RiskProfileEntity profile;
  final VoidCallback? onExplainRisk;

  const RiskHeroCard({
    super.key,
    required this.profile,
    this.onExplainRisk,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = AppColors.getRiskColor(profile.riskScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: riskColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: riskColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CURRENT AREA RISK',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  'CONFIDENCE ${profile.predictionConfidencePercent}%',
                  style: AppTypography.caption.copyWith(
                    fontSize: 9,
                    color: AppColors.accentLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Central Animated Risk Dial Gauge
          RiskScoreDial(
            score: profile.riskScore,
            size: 190,
            subtitle: profile.locationName,
          ),
          const SizedBox(height: 14),

          Text(
            'Updated ${profile.lastUpdatedTime}',
            style: AppTypography.bodySmall.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // 4 Environmental Quick Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Rainfall 24h', '${profile.rainfall24h.toStringAsFixed(0)} mm', Icons.water_drop_outlined),
              _buildMetric('Soil Saturation', '${profile.soilMoisturePercent.toStringAsFixed(0)}%', Icons.grain_outlined),
              _buildMetric('Slope Angle', '${profile.slopeDegrees.toStringAsFixed(0)}°', Icons.terrain_outlined),
              _buildMetric('Forecast 24h', '+${profile.forecast24h.toStringAsFixed(0)} mm', Icons.cloud_outlined),
            ],
          ),

          if (onExplainRisk != null) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: onExplainRisk,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.analytics_outlined, size: 16, color: AppColors.accentLight),
                    const SizedBox(width: 6),
                    Text(
                      'View AI Factor Explainability',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.accentLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.accentLight),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.heading3.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 9,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
