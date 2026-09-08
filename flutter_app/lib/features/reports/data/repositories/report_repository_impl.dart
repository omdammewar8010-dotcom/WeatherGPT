import '../../domain/entities/incident_report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_datasource.dart';
import '../datasources/report_remote_datasource.dart';
import '../models/incident_report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  final ReportLocalDataSource localDataSource;

  ReportRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<IncidentReportEntity> submitReport(IncidentReportEntity report) async {
    final model = IncidentReportModel(
      id: report.id,
      reporterId: report.reporterId,
      reporterName: report.reporterName,
      reporterPhone: report.reporterPhone,
      category: report.category,
      severity: report.severity,
      latitude: report.latitude,
      longitude: report.longitude,
      state: report.state,
      district: report.district,
      landmark: report.landmark,
      description: report.description,
      mediaUrls: report.mediaUrls,
      status: report.isOfflinePending ? 'PENDING_SYNC' : 'UNDER_REVIEW',
      isOfflinePending: report.isOfflinePending,
      aiAnalysis: report.aiAnalysis,
      createdAt: report.createdAt,
    );

    if (report.isOfflinePending) {
      await localDataSource.queueOfflineReport(model);
      return model;
    }

    try {
      return await remoteDataSource.submitReport(model.toJson());
    } catch (_) {
      // Network failed during submission -> automatically queue offline
      await localDataSource.queueOfflineReport(model);
      return model;
    }
  }

  @override
  Future<List<IncidentReportEntity>> getMyReports() async {
    final remote = await remoteDataSource.getReports();
    final queued = await localDataSource.getQueuedReports();
    return [...queued, ...remote];
  }

  @override
  Future<List<IncidentReportEntity>> getDistrictReports(String district) async {
    final list = await getMyReports();
    return list.where((r) => r.district.toLowerCase() == district.toLowerCase()).toList();
  }

  @override
  Future<int> syncOfflineReports() async {
    final queued = await localDataSource.getQueuedReports();
    int syncedCount = 0;
    for (final report in queued) {
      try {
        await remoteDataSource.submitReport(report.toJson());
        await localDataSource.clearQueuedReport(report.id);
        syncedCount++;
      } catch (_) {
        break; // Stop if connectivity dropped
      }
    }
    return syncedCount;
  }
}
