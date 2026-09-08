class FactorContribution {
  final String featureName;
  final double importanceScore; // 0.0 to 100.0
  final String actualValueFormatted;
  final String impactDirection; // "INCREASING_RISK" or "DECREASING_RISK"
  final String description;

  const FactorContribution({
    required this.featureName,
    required this.importanceScore,
    required this.actualValueFormatted,
    this.impactDirection = 'INCREASING_RISK',
    required this.description,
  });
}

class RiskAnalysisEntity {
  final String locationId;
  final String locationName;
  final String district;
  final String state;
  final int finalRiskScore; // 0 - 100
  final String riskTier; // "CRITICAL", "HIGH", "MODERATE", "LOW"
  final int confidencePercent;
  final String dataQuality; // "EXCELLENT", "GOOD", "DEGRADED"
  final int staticVulnerabilityScore; // Layer 1 (0-100)
  final int dynamicTriggerRiskScore; // Layer 2 (0-100)
  final int exposureScore; // (0-100)
  final List<FactorContribution> factorContributions;
  final List<String> primaryDrivers;
  final String modelName;
  final String evaluatedAt;

  const RiskAnalysisEntity({
    required this.locationId,
    required this.locationName,
    required this.district,
    required this.state,
    required this.finalRiskScore,
    required this.riskTier,
    required this.confidencePercent,
    required this.dataQuality,
    required this.staticVulnerabilityScore,
    required this.dynamicTriggerRiskScore,
    required this.exposureScore,
    required this.factorContributions,
    required this.primaryDrivers,
    required this.modelName,
    required this.evaluatedAt,
  });
}
