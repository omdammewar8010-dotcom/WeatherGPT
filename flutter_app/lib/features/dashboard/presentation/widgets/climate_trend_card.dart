import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ClimateTrendCard extends StatelessWidget {
  const ClimateTrendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.riskModerate.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.public_rounded, color: AppColors.riskModerate, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Decadal Climate Trends', style: AppTypography.heading3.copyWith(fontSize: 14)),
                      Text(
                        'IMD National Climate Centre (NCC) Baseline',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '10-YEAR ERA5 / IMD',
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Metric Tiles
          Row(
            children: [
              _buildTrendMetric(
                label: 'Decadal Warming',
                value: '+0.28°C',
                trend: 'per decade',
                color: AppColors.riskHigh,
                icon: Icons.thermostat_rounded,
              ),
              const SizedBox(width: 8),
              _buildTrendMetric(
                label: 'Monsoon Anomaly',
                value: '+18.4%',
                trend: 'above 50yr LPA',
                color: AppColors.accentLight,
                icon: Icons.water_drop_rounded,
              ),
              const SizedBox(width: 8),
              _buildTrendMetric(
                label: 'Extreme Events',
                value: '+24.1%',
                trend: 'frequency rise',
                color: AppColors.riskCritical,
                icon: Icons.thunderstorm_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            'Climate Insight: Elevated sea surface temperatures in the North Indian Ocean contribute to enhanced moisture flux and localized convective cloudburst events during summer monsoon.',
            style: AppTypography.caption.copyWith(fontSize: 10.5, color: AppColors.textSecondary, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendMetric({
    required String label,
    required String value,
    required String trend,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 9.5, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              trend,
              style: const TextStyle(fontSize: 8, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
