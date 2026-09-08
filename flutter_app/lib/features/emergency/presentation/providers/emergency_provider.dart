import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ner_landslideguard/features/emergency/data/repositories/emergency_repository_impl.dart';
import 'package:ner_landslideguard/features/emergency/domain/entities/emergency_sos_entity.dart';
import 'package:ner_landslideguard/features/emergency/domain/repositories/emergency_repository.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  return EmergencyRepositoryImpl();
});

class EmergencyState {
  final List<EmergencySosEntity> emergencies;
  final List<EvacuationShelterEntity> shelters;
  final EmergencySosEntity? activeUserSos;
  final String selectedPriorityFilter; // "ALL", "P1", "P2", "P3"
  final bool isLoading;
  final bool isSubmittingSos;
  final String? errorMessage;
  final String currentDistrict;

  const EmergencyState({
    this.emergencies = const [],
    this.shelters = const [],
    this.activeUserSos,
    this.selectedPriorityFilter = 'ALL',
    this.isLoading = false,
    this.isSubmittingSos = false,
    this.errorMessage,
    this.currentDistrict = 'Tawang',
  });

  List<EmergencySosEntity> get sortedAndFilteredEmergencies {
    var list = [...emergencies];
    list.sort((a, b) => b.triageScore.compareTo(a.triageScore));
    if (selectedPriorityFilter == 'ALL') return list;
    return list.where((e) => e.priorityLevel.startsWith(selectedPriorityFilter)).toList();
  }

  int get p1Count => emergencies.where((e) => e.priorityLevel.startsWith('P1')).length;
  int get p2Count => emergencies.where((e) => e.priorityLevel.startsWith('P2')).length;
  int get p3Count => emergencies.where((e) => e.priorityLevel.startsWith('P3')).length;

  EmergencyState copyWith({
    List<EmergencySosEntity>? emergencies,
    List<EvacuationShelterEntity>? shelters,
    EmergencySosEntity? activeUserSos,
    String? selectedPriorityFilter,
    bool? isLoading,
    bool? isSubmittingSos,
    String? errorMessage,
    String? currentDistrict,
  }) {
    return EmergencyState(
      emergencies: emergencies ?? this.emergencies,
      shelters: shelters ?? this.shelters,
      activeUserSos: activeUserSos ?? this.activeUserSos,
      selectedPriorityFilter: selectedPriorityFilter ?? this.selectedPriorityFilter,
      isLoading: isLoading ?? this.isLoading,
      isSubmittingSos: isSubmittingSos ?? this.isSubmittingSos,
      errorMessage: errorMessage,
      currentDistrict: currentDistrict ?? this.currentDistrict,
    );
  }
}

class EmergencyNotifier extends StateNotifier<EmergencyState> {
  final EmergencyRepository _repository;

  EmergencyNotifier(this._repository) : super(const EmergencyState()) {
    loadEmergencyData();
  }

  Future<void> loadEmergencyData({String? district}) async {
    final dist = district ?? state.currentDistrict;
    state = state.copyWith(isLoading: true, errorMessage: null, currentDistrict: dist);
    try {
      final emergencies = await _repository.getActiveEmergencies();
      final shelters = await _repository.getNearbyShelters(dist);
      state = state.copyWith(
        emergencies: emergencies,
        shelters: shelters,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load emergency triage data: $e',
      );
    }
  }

  void setPriorityFilter(String filter) {
    state = state.copyWith(selectedPriorityFilter: filter);
  }

  Future<EmergencySosEntity?> submitCitizenSos({
    required String reporterName,
    required String reporterPhone,
    required String district,
    required String stateName,
    required double latitude,
    required double longitude,
    required int trappedCount,
    required bool medicalEmergency,
    required bool roadCutOff,
    required int vulnerableDependents,
    required String notes,
  }) async {
    state = state.copyWith(isSubmittingSos: true, errorMessage: null);
    try {
      final calculatedScore = EmergencyMcdaCalculator.computeScore(
        trappedCount: trappedCount,
        medicalEmergency: medicalEmergency,
        roadCutOff: roadCutOff,
        vulnerableDependents: vulnerableDependents,
      );
      final pLevel = EmergencyMcdaCalculator.getPriorityLevel(calculatedScore);
      final unit = EmergencyMcdaCalculator.getRecommendedUnit(pLevel);

      final sosEntity = EmergencySosEntity(
        id: 'SOS-PENDING',
        reporterName: reporterName,
        reporterPhone: reporterPhone,
        district: district,
        state: stateName,
        latitude: latitude,
        longitude: longitude,
        trappedCount: trappedCount,
        medicalEmergency: medicalEmergency,
        roadCutOff: roadCutOff,
        vulnerableDependents: vulnerableDependents,
        notes: notes,
        status: 'DISPATCHED',
        triageScore: calculatedScore,
        priorityLevel: pLevel,
        dispatchedUnit: unit,
        timestamp: DateTime.now().toIso8601String(),
      );

      final result = await _repository.triggerSos(sosEntity);
      state = state.copyWith(
        isSubmittingSos: false,
        activeUserSos: result,
        emergencies: [result, ...state.emergencies],
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isSubmittingSos: false,
        errorMessage: 'Emergency SOS signal transmission failed: $e',
      );
      return null;
    }
  }

  void updateIncidentStatus(String sosId, String newStatus) {
    final updatedList = state.emergencies.map((e) {
      if (e.id == sosId) {
        return e.copyWith(status: newStatus);
      }
      return e;
    }).toList();

    EmergencySosEntity? activeUser = state.activeUserSos;
    if (activeUser != null && activeUser.id == sosId) {
      activeUser = activeUser.copyWith(status: newStatus);
    }

    state = state.copyWith(emergencies: updatedList, activeUserSos: activeUser);
    _repository.updateEmergencyStatus(sosId, newStatus);
  }

  void clearUserSos() {
    state = state.copyWith(activeUserSos: null);
  }
}

final emergencyStateProvider =
    StateNotifierProvider<EmergencyNotifier, EmergencyState>((ref) {
  final repo = ref.watch(emergencyRepositoryProvider);
  return EmergencyNotifier(repo);
});
