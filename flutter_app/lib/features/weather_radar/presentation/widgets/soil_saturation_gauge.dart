import 'package:flutter/material.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';

class SoilSaturationGauge extends StatelessWidget {
  final double saturationPct;

  const SoilSaturationGauge({super.key, required this.saturationPct});

  Color get _gaugeColor {
    if (saturationPct >= 85.0) return AppColors.riskCritical;
    if (saturationPct >= 70.0) return AppColors.riskHigh;
    if (saturationPct >= 50.0) return AppColors.riskModerate;
    return AppColors.riskLow;
  }

  String get _statusLabel {
    if (saturationPct >= 85.0) return 'CRITICAL FLASH RUNOFF RISK';
    if (saturationPct >= 70.0) return 'HIGH SURFACE SATURATION';
    if (saturationPct >= 50.0) return 'OPTIMAL SOWING MOISTURE';
    return 'SAFE SOIL MOISTURE';
  }

  @override
  Widget build(BuildContext context) {
    final color = _gaugeColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Subsurface Soil Water Saturation', style: AppTypography.heading3.copyWith(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // Circular Gauge
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: (saturationPct / 100.0).clamp(0.0, 1.0),
                      strokeWidth: 8,
                      backgroundColor: AppColors.surfaceLight,
                      color: color,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${saturationPct.toInt()}%',
                          style: AppTypography.heading3.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text('SAT', style: AppTypography.caption.copyWith(fontSize: 8, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Detail points
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hydrometeorological Infiltration & Runoff',
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      saturationPct >= 85.0
                          ? 'Soil catchment capacity depleted. Continuous rainfall will generate immediate surface runoff and urban inundation.'
                          : 'Catchment absorption capacity optimal for kharif sowing and aquifer recharge.',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.water_drop_rounded, size: 14, color: AppColors.accentLight),
                        const SizedBox(width: 4),
                        Text('Catchment Flash Inundation Threshold: 85.0%', style: AppTypography.caption.copyWith(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
