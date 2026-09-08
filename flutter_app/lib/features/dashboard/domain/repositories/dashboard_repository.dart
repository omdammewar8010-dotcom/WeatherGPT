import '../entities/risk_profile_entity.dart';

abstract class DashboardRepository {
  Future<RiskProfileEntity> getDistrictRiskProfile(String districtName);
  Future<List<RiskProfileEntity>> getAllNerRiskProfiles();
}
