import '../../domain/entities/risk_profile_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<RiskProfileEntity> getDistrictRiskProfile(String districtName) async {
    return await remoteDataSource.getRiskProfile(districtName);
  }

  @override
  Future<List<RiskProfileEntity>> getAllNerRiskProfiles() async {
    return await remoteDataSource.getAllRiskProfiles();
  }
}
