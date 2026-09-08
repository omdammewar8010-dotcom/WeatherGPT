import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ner_landslideguard/features/weather_radar/domain/entities/weather_radar_entity.dart';
import 'package:ner_landslideguard/features/weather_radar/domain/repositories/weather_repository.dart';
import 'package:ner_landslideguard/features/weather_radar/presentation/providers/weather_radar_provider.dart';
import 'package:ner_landslideguard/features/weather_radar/presentation/screens/weather_radar_screen.dart';

class MockWeatherRepository implements WeatherRepository {
  String? queriedDistrict;

  @override
  Future<WeatherRadarEntity> getWeatherRadar(String district) async {
    queriedDistrict = district;
    return WeatherRadarEntity(
      district: district,
      state: 'Test Region',
      currentTempC: 15.0,
      humidityPct: 92,
      rainfallAccumulated24hMm: 165.0,
      rainfallIntensityMmHr: 22.5,
      soilSaturationPct: 88.0,
      cloudCoverPct: 95,
      windSpeedKmh: 20.0,
      imdRadarStation: 'IMD Doppler Radar — Test Station',
      lastUpdated: 'Test Telemetry',
      forecastTimeline: const [
        HourlyPrecipitationEntity(timeLabel: 'Now', rainfallMm: 22.5, probabilityPct: 95, riskLevel: 'CRITICAL'),
        HourlyPrecipitationEntity(timeLabel: '+1h', rainfallMm: 18.0, probabilityPct: 90, riskLevel: 'HIGH'),
        HourlyPrecipitationEntity(timeLabel: '+2h', rainfallMm: 12.0, probabilityPct: 80, riskLevel: 'HIGH'),
        HourlyPrecipitationEntity(timeLabel: '+3h', rainfallMm: 6.0, probabilityPct: 50, riskLevel: 'MODERATE'),
      ],
    );
  }
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 16: Weather Radar & Precipitation Timeline Tests', () {
    test('WeatherRadarEntity critical threshold heuristics', () {
      const entity = WeatherRadarEntity(
        district: 'Tawang',
        state: 'Arunachal Pradesh',
        currentTempC: 14.0,
        humidityPct: 95,
        rainfallAccumulated24hMm: 180.0,
        rainfallIntensityMmHr: 25.0,
        soilSaturationPct: 92.0,
        cloudCoverPct: 98,
        windSpeedKmh: 20.0,
        imdRadarStation: 'Doppler Unit',
        lastUpdated: 'Now',
        forecastTimeline: [
          HourlyPrecipitationEntity(timeLabel: 'Now', rainfallMm: 25.0, probabilityPct: 95, riskLevel: 'CRITICAL'),
        ],
      );

      expect(entity.isRainfallCritical, isTrue);
      expect(entity.isSoilSaturated, isTrue);
      expect(entity.maxTimelineRainfall, 25.0);
    });

    test('HourlyPrecipitationEntity serializes and parses correctly', () {
      final json = {
        'time_label': '+2h',
        'rainfall_mm': 18.5,
        'probability_pct': 85,
        'risk_level': 'HIGH',
      };

      final entity = HourlyPrecipitationEntity.fromJson(json);
      expect(entity.timeLabel, '+2h');
      expect(entity.rainfallMm, 18.5);
      expect(entity.probabilityPct, 85);
      expect(entity.riskLevel, 'HIGH');
    });

    test('WeatherRadarNotifier loads radar telemetry and switches districts', () async {
      final mockRepo = MockWeatherRepository();
      final notifier = WeatherRadarNotifier(mockRepo);

      // Initial load
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.state.radarData, isNotNull);
      expect(notifier.state.selectedDistrict, 'Tawang');
      expect(notifier.state.selectedTimelineIndex, 0);
      expect(notifier.state.selectedHourlyPoint?.rainfallMm, 22.5);

      // Select timeline point
      notifier.selectTimelineIndex(1);
      expect(notifier.state.selectedTimelineIndex, 1);
      expect(notifier.state.selectedHourlyPoint?.timeLabel, '+1h');

      // Switch district
      await notifier.fetchWeatherRadar('Gangtok');
      expect(notifier.state.selectedDistrict, 'Gangtok');
      expect(mockRepo.queriedDistrict, 'Gangtok');
    });

    testWidgets('WeatherRadarScreen renders radar card, saturation gauge, and precipitation chart',
        (WidgetTester tester) async {
      final mockRepo = MockWeatherRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: WeatherRadarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header and widgets
      expect(find.text('Weather Radar & Rainfall Timeline'), findsOneWidget);
      expect(find.text('Active Doppler Weather Radar'), findsOneWidget);
      expect(find.text('IMD Doppler Radar — Test Station'), findsOneWidget);
      expect(find.text('Subsurface Soil Water Saturation'), findsOneWidget);
      expect(find.text('24h IMD Precipitation Forecast Timeline'), findsOneWidget);
      expect(find.text('Forecast Window: Now'), findsOneWidget);
      expect(find.textContaining('CRITICAL RISK'), findsOneWidget);

      // Switch district via ChoiceChip
      await tester.tap(find.text('Gangtok'));
      await tester.pumpAndSettle();

      expect(mockRepo.queriedDistrict, 'Gangtok');
    });
  });
}
