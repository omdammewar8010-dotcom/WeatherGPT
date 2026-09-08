import 'package:flutter/material.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/features/weather_radar/domain/entities/weather_radar_entity.dart';

class ImdRadarStationCard extends StatelessWidget {
  final WeatherRadarEntity radar;

  const ImdRadarStationCard({super.key, required this.radar});

  @override
  Widget build(BuildContext context) {
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
            children: [
              const Icon(Icons.radar_rounded, color: AppColors.accentLight, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Doppler Weather Radar', style: AppTypography.heading3.copyWith(fontSize: 14)),
                    Text(radar.imdRadarStation, style: AppTypography.caption.copyWith(color: AppColors.accentLight)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.riskLow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.sensors_rounded, color: AppColors.riskLow, size: 12),
                    SizedBox(width: 4),
                    Text('BEAM ONLINE', style: TextStyle(color: AppColors.riskLow, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4-Card Weather Metric Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.thermostat_rounded,
                  label: 'Temperature',
                  value: '${radar.currentTempC}°C',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.water_drop_rounded,
                  label: 'Humidity',
                  value: '${radar.humidityPct}%',
                  color: AppColors.accentLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.cloud_rounded,
                  label: 'Cloud Cover',
                  value: '${radar.cloudCoverPct}%',
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.air_rounded,
                  label: 'Wind Speed',
                  value: '${radar.windSpeedKmh} km/h',
                  color: AppColors.riskModerate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Total 24h Rainfall Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.grain_rounded, size: 16, color: AppColors.accentLight),
                    const SizedBox(width: 8),
                    Text('24h Accumulated Rainfall:', style: AppTypography.bodySmall),
                  ],
                ),
                Text(
                  '${radar.rainfallAccumulated24hMm} mm',
                  style: AppTypography.bodySmall.copyWith(
                    color: radar.rainfallAccumulated24hMm >= 150.0 ? AppColors.riskCritical : AppColors.riskHigh,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
          Text(label, style: AppTypography.caption.copyWith(fontSize: 8, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
