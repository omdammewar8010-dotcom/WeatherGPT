import '../../domain/entities/risk_analysis_entity.dart';
import '../../domain/repositories/risk_analysis_repository.dart';
import '../datasources/risk_analysis_remote_datasource.dart';

class RiskAnalysisRepositoryImpl implements RiskAnalysisRepository {
  final RiskAnalysisRemoteDataSource remoteDataSource;

  RiskAnalysisRepositoryImpl(this.remoteDataSource);

  @override
  Future<RiskAnalysisEntity> getExplainability(String locationId) async {
    return await remoteDataSource.getExplainability(locationId);
  }
}
