import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/gis_feature_model.dart';

abstract class RiskMapRemoteDataSource {
  Future<List<GisFeatureModel>> getGisFeatures();
}

class RiskMapRemoteDataSourceImpl implements RiskMapRemoteDataSource {
  final ApiClient apiClient;

  RiskMapRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<GisFeatureModel>> getGisFeatures() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.riskZones);
      if (response.data is Map<String, dynamic> && response.data['features'] != null) {
        final list = response.data['features'] as List<dynamic>;
        return list.map((e) => GisFeatureModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return GisFeatureModel.sampleNerGisFeatures;
    } catch (_) {
      return GisFeatureModel.sampleNerGisFeatures;
    }
  }
}
