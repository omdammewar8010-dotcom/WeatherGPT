class HourlyPrecipitationEntity {
  final String timeLabel;
  final double rainfallMm;
  final int probabilityPct;
  final String riskLevel; // "CRITICAL", "HIGH", "MODERATE", "LOW"

  const HourlyPrecipitationEntity({
    required this.timeLabel,
    required this.rainfallMm,
    required this.probabilityPct,
    required this.riskLevel,
  });

  factory HourlyPrecipitationEntity.fromJson(Map<String, dynamic> json) {
    return HourlyPrecipitationEntity(
      timeLabel: json['time_label'] ?? 'Now',
      rainfallMm: (json['rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      probabilityPct: (json['probability_pct'] as num?)?.toInt() ?? 0,
      riskLevel: json['risk_level'] ?? 'LOW',
    );
  }

  Map<String, dynamic> toJson() => {
        'time_label': timeLabel,
        'rainfall_mm': rainfallMm,
        'probability_pct': probabilityPct,
        'risk_level': riskLevel,
      };
}

class WeatherRadarEntity {
  final String district;
  final String state;
  final double currentTempC;
  final int humidityPct;
  final double rainfallAccumulated24hMm;
  final double rainfallIntensityMmHr;
  final double soilSaturationPct;
  final int cloudCoverPct;
  final double windSpeedKmh;
  final List<HourlyPrecipitationEntity> forecastTimeline;
  final String imdRadarStation;
  final String lastUpdated;

  const WeatherRadarEntity({
    required this.district,
    required this.state,
    required this.currentTempC,
    required this.humidityPct,
    required this.rainfallAccumulated24hMm,
    required this.rainfallIntensityMmHr,
    required this.soilSaturationPct,
    required this.cloudCoverPct,
    required this.windSpeedKmh,
    required this.forecastTimeline,
    required this.imdRadarStation,
    required this.lastUpdated,
  });

  bool get isRainfallCritical => rainfallAccumulated24hMm >= 150.0 || rainfallIntensityMmHr >= 20.0;
  bool get isSoilSaturated => soilSaturationPct >= 85.0;

  double get maxTimelineRainfall {
    if (forecastTimeline.isEmpty) return 30.0;
    double maxVal = 0.0;
    for (final item in forecastTimeline) {
      if (item.rainfallMm > maxVal) maxVal = item.rainfallMm;
    }
    return maxVal > 0 ? maxVal : 30.0;
  }

  factory WeatherRadarEntity.fromJson(Map<String, dynamic> json) {
    final timelineRaw = json['forecast_timeline'] as List? ?? [];
    return WeatherRadarEntity(
      district: json['district'] ?? 'Tawang',
      state: json['state'] ?? 'Arunachal Pradesh',
      currentTempC: (json['current_temp_c'] as num?)?.toDouble() ?? 15.0,
      humidityPct: (json['humidity_pct'] as num?)?.toInt() ?? 80,
      rainfallAccumulated24hMm:
          (json['rainfall_accumulated_24h_mm'] as num?)?.toDouble() ?? 0.0,
      rainfallIntensityMmHr:
          (json['rainfall_intensity_mm_hr'] as num?)?.toDouble() ?? 0.0,
      soilSaturationPct:
          (json['soil_saturation_pct'] as num?)?.toDouble() ?? 50.0,
      cloudCoverPct: (json['cloud_cover_pct'] as num?)?.toInt() ?? 50,
      windSpeedKmh: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 10.0,
      forecastTimeline: timelineRaw
          .map((item) => HourlyPrecipitationEntity.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      imdRadarStation: json['imd_radar_station'] ?? 'IMD Doppler Radar Unit',
      lastUpdated: json['last_updated'] ?? 'Live Telemetry',
    );
  }
}
