import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/risk_analysis_model.dart';

abstract class RiskAnalysisRemoteDataSource {
  Future<RiskAnalysisModel> getExplainability(String locationId);
}

class RiskAnalysisRemoteDataSourceImpl implements RiskAnalysisRemoteDataSource {
  final ApiClient apiClient;

  RiskAnalysisRemoteDataSourceImpl(this.apiClient);

  @override
  Future<RiskAnalysisModel> getExplainability(String locationId) async {
    try {
      final response = await apiClient.dio.get('${ApiEndpoints.predictExplain}/$locationId');
      return RiskAnalysisModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return RiskAnalysisModel.sampleTawangExplainability;
    }
  }
}
