class RiskProfileEntity {
  final String locationId;
  final String locationName;
  final String district;
  final String state;
  final double latitude;
  final double longitude;
  final int riskScore; // 0 to 100
  final String riskLevel; // "LOW", "MODERATE", "HIGH", "CRITICAL"
  final int staticVulnerability; // 0 to 100
  final int dynamicTriggerRisk; // 0 to 100
  final int exposureScore; // 0 to 100
  final double rainfall1h; // mm
  final double rainfall24h; // mm
  final double rainfall7d; // mm
  final double forecast24h; // mm
  final double soilMoisturePercent; // %
  final double slopeDegrees; // deg
  final double elevationMeters; // m
  final int historicalLandslideCount;
  final int predictionConfidencePercent;
  final String dataQuality; // "EXCELLENT", "GOOD", "DEGRADED", "SIMULATED"
  final String activeAdvisory;
  final String lastUpdatedTime;
  final bool isDemoData;

  const RiskProfileEntity({
    required this.locationId,
    required this.locationName,
    required this.district,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.riskScore,
    required this.riskLevel,
    required this.staticVulnerability,
    required this.dynamicTriggerRisk,
    required this.exposureScore,
    required this.rainfall1h,
    required this.rainfall24h,
    required this.rainfall7d,
    required this.forecast24h,
    required this.soilMoisturePercent,
    required this.slopeDegrees,
    required this.elevationMeters,
    required this.historicalLandslideCount,
    required this.predictionConfidencePercent,
    required this.dataQuality,
    required this.activeAdvisory,
    required this.lastUpdatedTime,
    this.isDemoData = true,
  });

  bool get isCritical => riskScore >= 80;
  bool get isHigh => riskScore >= 60 && riskScore < 80;
  bool get isModerate => riskScore >= 30 && riskScore < 60;
  bool get isLow => riskScore < 30;
}
