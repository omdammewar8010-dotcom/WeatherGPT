import '../entities/risk_analysis_entity.dart';

abstract class RiskAnalysisRepository {
  Future<RiskAnalysisEntity> getExplainability(String locationId);
}
