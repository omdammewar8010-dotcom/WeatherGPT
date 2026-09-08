import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ner_landslideguard/features/admin_console/data/repositories/admin_command_repository_impl.dart';
import 'package:ner_landslideguard/features/admin_console/domain/entities/regional_analytics_entity.dart';
import 'package:ner_landslideguard/features/admin_console/domain/repositories/admin_command_repository.dart';

final adminCommandRepositoryProvider = Provider<AdminCommandRepository>((ref) {
  return AdminCommandRepositoryImpl();
});

class AdminCommandState {
  final RegionalCommandMetricsEntity? metrics;
  final bool isLoading;
  final String? errorMessage;
  final String selectedStateFilter; // "ALL" or specific state
  final bool isBroadcasting;

  const AdminCommandState({
    this.metrics,
    this.isLoading = false,
    this.errorMessage,
    this.selectedStateFilter = 'ALL',
    this.isBroadcasting = false,
  });

  List<StateRiskOverviewEntity> get filteredStates {
    if (metrics == null) return [];
    if (selectedStateFilter == 'ALL') return metrics!.statesOverview;
    return metrics!.statesOverview
        .where((s) => s.stateName.toLowerCase() == selectedStateFilter.toLowerCase())
        .toList();
  }

  AdminCommandState copyWith({
    RegionalCommandMetricsEntity? metrics,
    bool? isLoading,
    String? errorMessage,
    String? selectedStateFilter,
    bool? isBroadcasting,
  }) {
    return AdminCommandState(
      metrics: metrics ?? this.metrics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedStateFilter: selectedStateFilter ?? this.selectedStateFilter,
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
    );
  }
}

class AdminCommandNotifier extends StateNotifier<AdminCommandState> {
  final AdminCommandRepository _repository;

  AdminCommandNotifier(this._repository) : super(const AdminCommandState()) {
    loadRegionalMetrics();
  }

  Future<void> loadRegionalMetrics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final metrics = await _repository.getRegionalCommandMetrics();
      state = state.copyWith(metrics: metrics, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load regional command metrics: $e',
      );
    }
  }

  void setStateFilter(String stateName) {
    state = state.copyWith(selectedStateFilter: stateName);
  }

  Future<bool> broadcastEmergencyRedAlert({
    required String targetState,
    required String targetDistrict,
    required String alertTitle,
    required String severity,
    required String advisoryMessage,
    required bool activateSiren,
    required bool sendSmsFallback,
  }) async {
    state = state.copyWith(isBroadcasting: true, errorMessage: null);
    try {
      await _repository.dispatchEmergencyBroadcast(
        targetState: targetState,
        targetDistrict: targetDistrict,
        alertTitle: alertTitle,
        severity: severity,
        advisoryMessage: advisoryMessage,
        activateSiren: activateSiren,
        sendSmsFallback: sendSmsFallback,
      );
      state = state.copyWith(isBroadcasting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isBroadcasting: false,
        errorMessage: 'Emergency broadcast failed: $e',
      );
      return false;
    }
  }
}

final adminCommandStateProvider =
    StateNotifierProvider<AdminCommandNotifier, AdminCommandState>((ref) {
  final repo = ref.watch(adminCommandRepositoryProvider);
  return AdminCommandNotifier(repo);
});
