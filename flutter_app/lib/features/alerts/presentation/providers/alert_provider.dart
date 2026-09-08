import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/early_warning_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../data/repositories/alert_repository_impl.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepositoryImpl();
});

class AlertState {
  final List<EarlyWarningEntity> warnings;
  final bool isLoading;
  final String selectedSeverityFilter; // "ALL", "CRITICAL", "HIGH", "MODERATE"
  final bool isSirenPlaying;
  final String? errorMessage;

  const AlertState({
    this.warnings = const [],
    this.isLoading = false,
    this.selectedSeverityFilter = 'ALL',
    this.isSirenPlaying = false,
    this.errorMessage,
  });

  List<EarlyWarningEntity> get filteredWarnings {
    if (selectedSeverityFilter == 'ALL') {
      return warnings;
    }
    return warnings
        .where((w) => w.severity.toUpperCase() == selectedSeverityFilter.toUpperCase())
        .toList();
  }

  int get criticalCount =>
      warnings.where((w) => w.severity.toUpperCase() == 'CRITICAL').length;
  int get highCount =>
      warnings.where((w) => w.severity.toUpperCase() == 'HIGH').length;
  int get moderateCount =>
      warnings.where((w) => w.severity.toUpperCase() == 'MODERATE').length;

  AlertState copyWith({
    List<EarlyWarningEntity>? warnings,
    bool? isLoading,
    String? selectedSeverityFilter,
    bool? isSirenPlaying,
    String? errorMessage,
  }) {
    return AlertState(
      warnings: warnings ?? this.warnings,
      isLoading: isLoading ?? this.isLoading,
      selectedSeverityFilter: selectedSeverityFilter ?? this.selectedSeverityFilter,
      isSirenPlaying: isSirenPlaying ?? this.isSirenPlaying,
      errorMessage: errorMessage,
    );
  }
}

class AlertNotifier extends StateNotifier<AlertState> {
  final AlertRepository _repository;

  AlertNotifier(this._repository) : super(const AlertState()) {
    loadWarnings();
  }

  Future<void> loadWarnings({String? district}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getActiveWarnings(district: district);
      state = state.copyWith(warnings: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load warnings: $e',
      );
    }
  }

  void setSeverityFilter(String severity) {
    state = state.copyWith(selectedSeverityFilter: severity);
  }

  void markAsRead(String warningId) {
    final updated = state.warnings.map((w) {
      if (w.id == warningId) {
        return w.copyWith(isRead: true);
      }
      return w;
    }).toList();
    state = state.copyWith(warnings: updated);
  }

  void toggleSiren() {
    state = state.copyWith(isSirenPlaying: !state.isSirenPlaying);
  }

  Future<void> broadcastWarning({
    required String title,
    required String district,
    required String stateName,
    required String severity,
    required int riskScore,
    required double confidence,
    required int validUntilHours,
    required String advisory,
    required String evacuationRoute,
    required List<String> affectedSectors,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final created = await _repository.broadcastWarning(
        title: title,
        district: district,
        state: stateName,
        severity: severity,
        riskScore: riskScore,
        confidence: confidence,
        validUntilHours: validUntilHours,
        advisory: advisory,
        evacuationRoute: evacuationRoute,
        affectedSectors: affectedSectors,
      );
      state = state.copyWith(
        warnings: [created, ...state.warnings],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to broadcast warning: $e',
      );
    }
  }
}

final alertStateProvider = StateNotifierProvider<AlertNotifier, AlertState>((ref) {
  final repo = ref.watch(alertRepositoryProvider);
  final notifier = AlertNotifier(repo);

  ref.listen<DashboardState>(dashboardStateProvider, (prev, next) {
    if (prev?.selectedDistrict != next.selectedDistrict) {
      notifier.loadWarnings(district: next.selectedDistrict);
    }
  });

  return notifier;
});
