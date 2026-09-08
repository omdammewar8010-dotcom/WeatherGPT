import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/risk_profile_model.dart';

abstract class DashboardRemoteDataSource {
  Future<RiskProfileModel> getRiskProfile(String districtName);
  Future<List<RiskProfileModel>> getAllRiskProfiles();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl(this.apiClient);

  @override
  Future<RiskProfileModel> getRiskProfile(String districtName) async {
    try {
      final response = await apiClient.dio.get('${ApiEndpoints.riskLocation}/$districtName');
      return RiskProfileModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      // Return realistic local profile for NER state/district
      return RiskProfileModel.nerDistrictProfiles[districtName] ??
          RiskProfileModel.nerDistrictProfiles['Tawang']!;
    }
  }

  @override
  Future<List<RiskProfileModel>> getAllRiskProfiles() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.riskZones);
      final list = response.data['zones'] as List<dynamic>;
      return list.map((e) => RiskProfileModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return RiskProfileModel.nerDistrictProfiles.values.toList();
    }
  }
}
