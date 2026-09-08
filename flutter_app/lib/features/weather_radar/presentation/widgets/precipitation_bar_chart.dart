import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/features/weather_radar/domain/entities/weather_radar_entity.dart';

class PrecipitationBarChart extends StatelessWidget {
  final List<HourlyPrecipitationEntity> timeline;
  final int selectedIndex;
  final ValueChanged<int> onBarTapped;

  const PrecipitationBarChart({
    super.key,
    required this.timeline,
    required this.selectedIndex,
    required this.onBarTapped,
  });

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.riskCritical;
      case 'HIGH':
        return AppColors.riskHigh;
      case 'MODERATE':
        return AppColors.riskModerate;
      case 'LOW':
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) {
      return const SizedBox(height: 180, child: Center(child: Text('No timeline data available')));
    }

    double maxY = 30.0;
    for (final pt in timeline) {
      if (pt.rainfallMm > maxY) maxY = pt.rainfallMm + 5.0;
    }

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
                child: Text('24h IMD Precipitation Forecast Timeline', style: AppTypography.heading3.copyWith(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.riskCritical.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Trigger Threshold: 20mm/hr',
                  style: TextStyle(color: AppColors.riskCritical, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a forecast hour to inspect estimated soil pore-pressure & slope stability',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (response != null &&
                        response.spot != null &&
                        event is FlTapUpEvent) {
                      final index = response.spot!.touchedBarGroupIndex;
                      if (index >= 0 && index < timeline.length) {
                        onBarTapped(index);
                      }
                    }
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceLight,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final pt = timeline[group.x.toInt()];
                      return BarTooltipItem(
                        '${pt.timeLabel}\n${pt.rainfallMm} mm/hr\n${pt.probabilityPct}% prob',
                        TextStyle(
                          color: _getRiskColor(pt.riskLevel),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value % 10 == 0) {
                          return Text('${value.toInt()}mm', style: AppTypography.caption.copyWith(fontSize: 9));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < timeline.length) {
                          final isSel = index == selectedIndex;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              timeline[index].timeLabel,
                              style: TextStyle(
                                color: isSel ? AppColors.accentLight : AppColors.textSecondary,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    if (value == 20) {
                      return FlLine(
                        color: AppColors.riskCritical.withValues(alpha: 0.6),
                        strokeWidth: 1.5,
                        dashArray: [5, 5],
                      );
                    }
                    return FlLine(
                      color: AppColors.divider.withValues(alpha: 0.5),
                      strokeWidth: 0.8,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: timeline.asMap().entries.map((entry) {
                  final index = entry.key;
                  final pt = entry.value;
                  final isSelected = index == selectedIndex;
                  final color = _getRiskColor(pt.riskLevel);

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: pt.rainfallMm,
                        color: color,
                        width: isSelected ? 18 : 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        borderSide: isSelected
                            ? const BorderSide(color: Colors.white, width: 2)
                            : BorderSide.none,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
