import '../../../../core/storage/local_storage_service.dart';
import '../models/incident_report_model.dart';

abstract class ReportLocalDataSource {
  Future<void> queueOfflineReport(IncidentReportModel report);
  Future<List<IncidentReportModel>> getQueuedReports();
  Future<void> clearQueuedReport(String reportId);
}

class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  final LocalStorageService localStorageService;

  ReportLocalDataSourceImpl(this.localStorageService);

  @override
  Future<void> queueOfflineReport(IncidentReportModel report) async {
    final list = localStorageService.getOfflineReports();
    list.add(report.toJson());
    await localStorageService.saveOfflineReports(list);
  }

  @override
  Future<List<IncidentReportModel>> getQueuedReports() async {
    final list = localStorageService.getOfflineReports();
    return list.map((json) => IncidentReportModel.fromJson(json)).toList();
  }

  @override
  Future<void> clearQueuedReport(String reportId) async {
    final list = localStorageService.getOfflineReports();
    list.removeWhere((r) => r['id'] == reportId);
    await localStorageService.saveOfflineReports(list);
  }
}
