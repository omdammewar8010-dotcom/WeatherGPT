import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/risk_map_remote_datasource.dart';
import '../../data/repositories/risk_map_repository_impl.dart';
import '../../domain/entities/gis_feature_entity.dart';
import '../../domain/repositories/risk_map_repository.dart';

final riskMapRemoteDataSourceProvider = Provider<RiskMapRemoteDataSource>((ref) {
  return RiskMapRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final riskMapRepositoryProvider = Provider<RiskMapRepository>((ref) {
  return RiskMapRepositoryImpl(ref.watch(riskMapRemoteDataSourceProvider));
});

class RiskMapState {
  final List<GisFeatureEntity> allFeatures;
  final Set<GisLayerType> activeLayers;
  final GisFeatureEntity? selectedFeature;
  final bool isLoading;
  final String? errorMessage;

  const RiskMapState({
    this.allFeatures = const [],
    this.activeLayers = const {
      GisLayerType.riskZone,
      GisLayerType.incident,
      GisLayerType.road,
      GisLayerType.sensor,
      GisLayerType.infrastructure,
    },
    this.selectedFeature,
    this.isLoading = false,
    this.errorMessage,
  });

  List<GisFeatureEntity> get filteredFeatures {
    return allFeatures.where((f) => activeLayers.contains(f.layerType)).toList();
  }

  RiskMapState copyWith({
    List<GisFeatureEntity>? allFeatures,
    Set<GisLayerType>? activeLayers,
    GisFeatureEntity? selectedFeature,
    bool clearSelected = false,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RiskMapState(
      allFeatures: allFeatures ?? this.allFeatures,
      activeLayers: activeLayers ?? this.activeLayers,
      selectedFeature: clearSelected ? null : (selectedFeature ?? this.selectedFeature),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RiskMapNotifier extends StateNotifier<RiskMapState> {
  final RiskMapRepository _repository;

  RiskMapNotifier(this._repository) : super(const RiskMapState()) {
    loadGisLayers();
  }

  Future<void> loadGisLayers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final features = await _repository.getGisFeatures();
      state = state.copyWith(
        allFeatures: features,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load GIS map layers: $e',
      );
    }
  }

  void toggleLayer(GisLayerType layer) {
    final current = Set<GisLayerType>.from(state.activeLayers);
    if (current.contains(layer)) {
      if (current.length > 1) {
        current.remove(layer);
      }
    } else {
      current.add(layer);
    }
    state = state.copyWith(activeLayers: current);
  }

  void selectFeature(GisFeatureEntity? feature) {
    state = state.copyWith(selectedFeature: feature, clearSelected: feature == null);
  }
}

final riskMapStateProvider = StateNotifierProvider<RiskMapNotifier, RiskMapState>((ref) {
  return RiskMapNotifier(ref.watch(riskMapRepositoryProvider));
});
