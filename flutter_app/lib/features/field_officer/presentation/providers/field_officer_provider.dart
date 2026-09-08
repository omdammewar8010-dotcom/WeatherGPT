import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ner_landslideguard/features/field_officer/data/repositories/field_officer_repository_impl.dart';
import 'package:ner_landslideguard/features/field_officer/domain/entities/geotechnical_inspection_entity.dart';
import 'package:ner_landslideguard/features/field_officer/domain/repositories/field_officer_repository.dart';
import 'package:ner_landslideguard/features/reports/domain/entities/incident_report_entity.dart';

final fieldOfficerRepositoryProvider = Provider<FieldOfficerRepository>((ref) {
  return FieldOfficerRepositoryImpl();
});

class FieldOfficerState {
  final List<IncidentReportEntity> assignedIncidents;
  final IncidentReportEntity? activeInspectionIncident;
  final bool isLoading;
  final String selectedStatusFilter; // "ALL", "SUBMITTED", "UNDER_REVIEW", "VERIFIED", "RESOLVED"
  final String? errorMessage;
  final bool isSubmitting;

  const FieldOfficerState({
    this.assignedIncidents = const [],
    this.activeInspectionIncident,
    this.isLoading = false,
    this.selectedStatusFilter = 'ALL',
    this.errorMessage,
    this.isSubmitting = false,
  });

  List<IncidentReportEntity> get filteredIncidents {
    if (selectedStatusFilter == 'ALL') {
      return assignedIncidents;
    }
    return assignedIncidents
        .where((i) => i.status.toUpperCase() == selectedStatusFilter.toUpperCase())
        .toList();
  }

  int get pendingCount => assignedIncidents
      .where((i) => i.status == 'SUBMITTED' || i.status == 'UNDER_REVIEW')
      .length;
  int get verifiedCount =>
      assignedIncidents.where((i) => i.status == 'VERIFIED').length;
  int get resolvedCount =>
      assignedIncidents.where((i) => i.status == 'RESOLVED').length;

  FieldOfficerState copyWith({
    List<IncidentReportEntity>? assignedIncidents,
    IncidentReportEntity? activeInspectionIncident,
    bool? isLoading,
    String? selectedStatusFilter,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return FieldOfficerState(
      assignedIncidents: assignedIncidents ?? this.assignedIncidents,
      activeInspectionIncident: activeInspectionIncident ?? this.activeInspectionIncident,
      isLoading: isLoading ?? this.isLoading,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class FieldOfficerNotifier extends StateNotifier<FieldOfficerState> {
  final FieldOfficerRepository _repository;

  FieldOfficerNotifier(this._repository) : super(const FieldOfficerState()) {
    loadAssignedIncidents();
  }

  Future<void> loadAssignedIncidents({String? district}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getAssignedIncidents(district: district);
      state = state.copyWith(assignedIncidents: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load assigned incidents: $e',
      );
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedStatusFilter: filter);
  }

  void setActiveInspection(IncidentReportEntity incident) {
    state = state.copyWith(activeInspectionIncident: incident);
  }

  Future<bool> submitGeotechnicalInspection(GeotechnicalInspectionEntity inspection) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.submitInspection(inspection);
      
      // Update local status in state
      final updated = state.assignedIncidents.map((inc) {
        if (inc.id == inspection.reportId) {
          return IncidentReportEntity(
            id: inc.id,
            reporterId: inc.reporterId,
            reporterName: inc.reporterName,
            reporterPhone: inc.reporterPhone,
            category: inc.category,
            severity: inc.severity,
            latitude: inc.latitude,
            longitude: inc.longitude,
            state: inc.state,
            district: inc.district,
            landmark: inc.landmark,
            description: inc.description,
            mediaUrls: inc.mediaUrls,
            status: inspection.verificationStatus,
            isOfflinePending: false,
            aiAnalysis: inc.aiAnalysis,
            createdAt: inc.createdAt,
          );
        }
        return inc;
      }).toList();

      state = state.copyWith(
        assignedIncidents: updated,
        isSubmitting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit inspection: $e',
      );
      return false;
    }
  }
}

final fieldOfficerStateProvider =
    StateNotifierProvider<FieldOfficerNotifier, FieldOfficerState>((ref) {
  final repo = ref.watch(fieldOfficerRepositoryProvider);
  return FieldOfficerNotifier(repo);
});
