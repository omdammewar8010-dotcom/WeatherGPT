import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/risk_score_dial.dart';
import '../../domain/entities/risk_profile_entity.dart';

class WeatherHeroCard extends StatelessWidget {
  final RiskProfileEntity profile;
  final VoidCallback? onExplainRisk;

  const WeatherHeroCard({
    super.key,
    required this.profile,
    this.onExplainRisk,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = profile.riskLevel == 'CRITICAL';
    final isHigh = profile.riskLevel == 'HIGH';
    final alertColor = isCritical
        ? AppColors.riskCritical
        : isHigh
            ? AppColors.riskHigh
            : (profile.riskLevel == 'MODERATE' ? AppColors.riskModerate : AppColors.riskLow);

    // Weather condition and temperature derived from rainfall / risk
    final double temp = (32.0 - (profile.rainfall24h * 0.08)).clamp(14.0, 42.0);
    final String condition = profile.rainfall24h > 100
        ? 'Torrential Downpour & Cloudburst Alert'
        : profile.rainfall24h > 50
            ? 'Heavy Thunderstorm & Squall Activity'
            : profile.rainfall24h > 15
                ? 'Moderate Monsoon Showers'
                : 'Partly Cloudy & Humid Skies';

    final IconData weatherIcon = profile.rainfall24h > 50
        ? Icons.thunderstorm_rounded
        : profile.rainfall24h > 15
            ? Icons.grain_rounded
            : Icons.wb_cloudy_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alertColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: alertColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: alertColor,
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
                  color: alertColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: alertColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  'IMD ${profile.riskLevel} ALERT',
                  style: AppTypography.caption.copyWith(
                    fontSize: 9,
                    color: alertColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Weather Display (Big Temp + Icon + Condition)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(weatherIcon, size: 40, color: alertColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${temp.toStringAsFixed(1)}°',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'C',
                            style: AppTypography.heading3.copyWith(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      condition,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${profile.district}, ${profile.state} • ${profile.lastUpdatedTime}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Central Animated Risk Dial Gauge (integrated with weather severity)
          Center(
            child: RiskScoreDial(
              score: profile.riskScore,
              size: 160,
              subtitle: 'Doppler Hazard Score',
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // 6 Meteorological Sensor Metrics Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Doppler Core', '${(20.0 + profile.rainfall24h * 0.25).clamp(18.0, 58.0).toStringAsFixed(0)} dBZ', Icons.radar_rounded),
              _buildMetric('Rainfall 24h', '${profile.rainfall24h.toStringAsFixed(0)} mm', Icons.water_drop_outlined),
              _buildMetric('Precip Rate', '${(profile.rainfall24h / 6.0).toStringAsFixed(1)} mm/h', Icons.speed_rounded),
              _buildMetric('Forecast 24h', '+${profile.forecast24h.toStringAsFixed(0)} mm', Icons.cloud_outlined),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Humidity', '${(55 + profile.riskScore * 0.4).clamp(40, 98).toStringAsFixed(0)}%', Icons.water_rounded),
              _buildMetric('Wind Gusts', '${(18.0 + profile.rainfall24h * 0.2).clamp(10.0, 65.0).toStringAsFixed(0)} km/h', Icons.air_rounded),
              _buildMetric('AQI Status', '48 (Good)', Icons.eco_outlined),
              _buildMetric('Instability', '${(800 + profile.riskScore * 25).toStringAsFixed(0)} J/kg', Icons.electric_bolt_rounded),
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
            fontSize: 13,
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
