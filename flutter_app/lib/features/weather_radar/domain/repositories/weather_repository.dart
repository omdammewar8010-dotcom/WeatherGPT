import 'package:ner_landslideguard/features/weather_radar/domain/entities/weather_radar_entity.dart';

abstract class WeatherRepository {
  Future<WeatherRadarEntity> getWeatherRadar(String district);
}
