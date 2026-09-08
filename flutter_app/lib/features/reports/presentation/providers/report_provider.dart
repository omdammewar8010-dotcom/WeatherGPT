import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/report_local_datasource.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/incident_report_entity.dart';
import '../../domain/repositories/report_repository.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final reportLocalDataSourceProvider = Provider<ReportLocalDataSource>((ref) {
  return ReportLocalDataSourceImpl(ref.watch(localStorageServiceProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(
    remoteDataSource: ref.watch(reportRemoteDataSourceProvider),
    localDataSource: ref.watch(reportLocalDataSourceProvider),
  );
});

class ReportState {
  final List<IncidentReportEntity> reports;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final int pendingSyncCount;

  const ReportState({
    this.reports = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.pendingSyncCount = 0,
  });

  ReportState copyWith({
    List<IncidentReportEntity>? reports,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    int? pendingSyncCount,
  }) {
    return ReportState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportRepository _repository;

  ReportNotifier(this._repository) : super(const ReportState()) {
    loadReports();
  }

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getMyReports();
      final pending = list.where((r) => r.isOfflinePending).length;
      state = state.copyWith(
        reports: list,
        pendingSyncCount: pending,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load reports: $e',
      );
    }
  }

  Future<IncidentReportEntity?> submitNewReport(IncidentReportEntity report) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final created = await _repository.submitReport(report);
      final updatedList = [created, ...state.reports];
      final pending = updatedList.where((r) => r.isOfflinePending).length;
      state = state.copyWith(
        reports: updatedList,
        pendingSyncCount: pending,
        isSubmitting: false,
      );
      return created;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Submission failed: $e',
      );
      return null;
    }
  }

  Future<int> triggerSync() async {
    final count = await _repository.syncOfflineReports();
    await loadReports();
    return count;
  }
}

final reportStateProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.watch(reportRepositoryProvider));
});
