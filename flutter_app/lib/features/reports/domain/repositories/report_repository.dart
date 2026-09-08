import '../entities/incident_report_entity.dart';

abstract class ReportRepository {
  Future<IncidentReportEntity> submitReport(IncidentReportEntity report);
  Future<List<IncidentReportEntity>> getMyReports();
  Future<List<IncidentReportEntity>> getDistrictReports(String district);
  Future<int> syncOfflineReports();
}
