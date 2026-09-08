import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ner_landslideguard/features/weather_radar/data/repositories/weather_repository_impl.dart';
import 'package:ner_landslideguard/features/weather_radar/domain/entities/weather_radar_entity.dart';
import 'package:ner_landslideguard/features/weather_radar/domain/repositories/weather_repository.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl();
});

class WeatherRadarState {
  final String selectedDistrict;
  final WeatherRadarEntity? radarData;
  final int selectedTimelineIndex;
  final bool isLoading;
  final String? errorMessage;

  const WeatherRadarState({
    this.selectedDistrict = 'Tawang',
    this.radarData,
    this.selectedTimelineIndex = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  HourlyPrecipitationEntity? get selectedHourlyPoint {
    if (radarData == null || radarData!.forecastTimeline.isEmpty) return null;
    if (selectedTimelineIndex >= 0 && selectedTimelineIndex < radarData!.forecastTimeline.length) {
      return radarData!.forecastTimeline[selectedTimelineIndex];
    }
    return radarData!.forecastTimeline.first;
  }

  WeatherRadarState copyWith({
    String? selectedDistrict,
    WeatherRadarEntity? radarData,
    int? selectedTimelineIndex,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WeatherRadarState(
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      radarData: radarData ?? this.radarData,
      selectedTimelineIndex: selectedTimelineIndex ?? this.selectedTimelineIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class WeatherRadarNotifier extends StateNotifier<WeatherRadarState> {
  final WeatherRepository _repository;

  WeatherRadarNotifier(this._repository) : super(const WeatherRadarState()) {
    fetchWeatherRadar('Tawang');
  }

  Future<void> fetchWeatherRadar(String district) async {
    state = state.copyWith(
      selectedDistrict: district,
      isLoading: true,
      errorMessage: null,
      selectedTimelineIndex: 0,
    );
    try {
      final radarData = await _repository.getWeatherRadar(district);
      state = state.copyWith(
        radarData: radarData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to retrieve radar telemetry: $e',
      );
    }
  }

  void selectTimelineIndex(int index) {
    if (state.radarData != null && index >= 0 && index < state.radarData!.forecastTimeline.length) {
      state = state.copyWith(selectedTimelineIndex: index);
    }
  }
}

final weatherRadarStateProvider =
    StateNotifierProvider<WeatherRadarNotifier, WeatherRadarState>((ref) {
  final repo = ref.watch(weatherRepositoryProvider);
  return WeatherRadarNotifier(repo);
});
