import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/core/widgets/sync_status_pill_widget.dart';
import 'package:ner_landslideguard/features/weather_radar/domain/entities/weather_radar_entity.dart';
import 'package:ner_landslideguard/features/weather_radar/presentation/providers/weather_radar_provider.dart';
import 'package:ner_landslideguard/features/weather_radar/presentation/widgets/imd_radar_station_card.dart';
import 'package:ner_landslideguard/features/weather_radar/presentation/widgets/precipitation_bar_chart.dart';
import 'package:ner_landslideguard/features/weather_radar/presentation/widgets/soil_saturation_gauge.dart';

class WeatherRadarScreen extends ConsumerWidget {
  const WeatherRadarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherRadarStateProvider);
    final radar = weatherState.radarData;
    final selectedPoint = weatherState.selectedHourlyPoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weather Radar & Rainfall Timeline', style: AppTypography.heading3),
            Text(
              'IMD Doppler Radar & Geotechnical Infiltration Model',
              style: AppTypography.caption.copyWith(color: AppColors.accentLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Weather Telemetry',
            icon: const Icon(Icons.refresh, color: AppColors.accentLight),
            onPressed: () => ref.read(weatherRadarStateProvider.notifier).fetchWeatherRadar(weatherState.selectedDistrict),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(weatherRadarStateProvider.notifier).fetchWeatherRadar(weatherState.selectedDistrict);
          },
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Sync & Satellite Telemetry Pill
                const SyncStatusPillWidget(),
                const SizedBox(height: 12),

                // 2. District Selector Bar
                _buildDistrictSelector(context, ref, weatherState),
                const SizedBox(height: 16),

                if (weatherState.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (radar != null) ...[
                  // 3. IMD Radar Station & Telemetry Card
                  ImdRadarStationCard(radar: radar),
                  const SizedBox(height: 16),

                  // 4. Subsurface Soil Water Saturation Gauge
                  SoilSaturationGauge(saturationPct: radar.soilSaturationPct),
                  const SizedBox(height: 16),

                  // 5. 24h Precipitation Timeline Chart
                  PrecipitationBarChart(
                    timeline: radar.forecastTimeline,
                    selectedIndex: weatherState.selectedTimelineIndex,
                    onBarTapped: (index) {
                      ref.read(weatherRadarStateProvider.notifier).selectTimelineIndex(index);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 6. Selected Forecast Hour Detail Breakdown
                  if (selectedPoint != null) _buildSelectedForecastDetail(selectedPoint),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistrictSelector(BuildContext context, WidgetRef ref, WeatherRadarState state) {
    const districts = [
      'Tawang', 'Gangtok', 'Shillong', 'Aizawl',
      'Kohima', 'Imphal', 'Guwahati', 'Agartala'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: AppColors.accentLight, size: 18),
          const SizedBox(width: 8),
          Text('NER Sector:', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: districts.map((d) {
                  final isSelected = d.toLowerCase() == state.selectedDistrict.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(d, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      selected: isSelected,
                      selectedColor: AppColors.accent.withValues(alpha: 0.25),
                      backgroundColor: AppColors.surfaceLight,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.accentLight : AppColors.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.accentLight : AppColors.divider,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(weatherRadarStateProvider.notifier).fetchWeatherRadar(d);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedForecastDetail(HourlyPrecipitationEntity pt) {
    final riskColor = pt.riskLevel == 'CRITICAL'
        ? AppColors.riskCritical
        : (pt.riskLevel == 'HIGH'
            ? AppColors.riskHigh
            : (pt.riskLevel == 'MODERATE' ? AppColors.riskModerate : AppColors.riskLow));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: riskColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 18, color: AppColors.accentLight),
                  const SizedBox(width: 8),
                  Text('Forecast Window: ${pt.timeLabel}', style: AppTypography.heading3.copyWith(fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${pt.riskLevel} RISK',
                  style: TextStyle(color: riskColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rainfall Intensity', style: AppTypography.caption),
                    Text(
                      '${pt.rainfallMm} mm/hr',
                      style: AppTypography.heading3.copyWith(color: riskColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Precipitation Probability', style: AppTypography.caption),
                    Text(
                      '${pt.probabilityPct}% Chance',
                      style: AppTypography.heading3.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Geotechnical Advisory
          Text(
            pt.rainfallMm >= 20.0
                ? '⚠️ Torrential downpour threshold breached. Slope soil shear strength rapidly degrading. High probability of translational slide or debris channel surge.'
                : (pt.rainfallMm >= 10.0
                    ? '🌧️ Sustained heavy rain expected. Groundwater table rising. Saturated road shoulders require vigilant overwatch.'
                    : '⛅ Light precipitation. Hydrological stress below critical trigger limits.'),
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
