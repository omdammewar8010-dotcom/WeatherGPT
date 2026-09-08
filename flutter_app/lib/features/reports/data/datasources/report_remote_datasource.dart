import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/incident_report_model.dart';

abstract class ReportRemoteDataSource {
  Future<IncidentReportModel> submitReport(Map<String, dynamic> payload);
  Future<List<IncidentReportModel>> getReports();
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSourceImpl(this.apiClient);

  @override
  Future<IncidentReportModel> submitReport(Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.reports,
        data: payload,
      );
      return IncidentReportModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      // Simulate successful local intake if backend is not yet running
      return IncidentReportModel.fromJson(payload);
    }
  }

  @override
  Future<List<IncidentReportModel>> getReports() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.reports);
      final list = response.data['reports'] as List<dynamic>;
      return list.map((e) => IncidentReportModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return IncidentReportModel.sampleReports;
    }
  }
}
