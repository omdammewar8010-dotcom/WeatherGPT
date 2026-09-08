import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/risk_analysis_entity.dart';

class TwoLayerModelCard extends StatelessWidget {
  final RiskAnalysisEntity analysis;

  const TwoLayerModelCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TWO-LAYER HYBRID AI ARCHITECTURE', style: AppTypography.caption),
              Text(
                'Harmonized Index',
                style: AppTypography.caption.copyWith(color: AppColors.accentLight),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Layer 1: Static Susceptibility
          _buildLayerRow(
            layerNumber: 'LAYER 1',
            title: 'Static Terrain Susceptibility',
            score: analysis.staticVulnerabilityScore,
            color: AppColors.accentLight,
            description: 'Elevation, Slope Gradient, Aspect, Soil Lithology, GSI Historical Catalog',
            algorithm: 'Random Forest (Static Propensity)',
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Layer 2: Dynamic Trigger Hazard
          _buildLayerRow(
            layerNumber: 'LAYER 2',
            title: 'Dynamic Trigger Risk',
            score: analysis.dynamicTriggerRiskScore,
            color: AppColors.riskCritical,
            description: '1h-7d Precipitation Accumulation, 24h IMD Forecast, Soil Pore Moisture Saturation',
            algorithm: 'XGBoost Regressor (Dynamic Trigger)',
          ),
          const SizedBox(height: 14),

          // Harmonization formula breakdown banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.functions_rounded, size: 18, color: AppColors.accentLight),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hazard = (0.35 × Static) + (0.65 × Dynamic) × Exposure [Normalized 0–100]',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerRow({
    required String layerNumber,
    required String title,
    required int score,
    required Color color,
    required String description,
    required String algorithm,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    layerNumber,
                    style: AppTypography.caption.copyWith(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(title, style: AppTypography.heading3.copyWith(fontSize: 13)),
              ],
            ),
            Text(
              '$score / 100',
              style: AppTypography.heading3.copyWith(color: color, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(description, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          'Model: $algorithm',
          style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
