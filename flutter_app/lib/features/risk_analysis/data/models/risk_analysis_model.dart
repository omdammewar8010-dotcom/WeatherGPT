import '../../domain/entities/risk_analysis_entity.dart';

class RiskAnalysisModel extends RiskAnalysisEntity {
  const RiskAnalysisModel({
    required super.locationId,
    required super.locationName,
    required super.district,
    required super.state,
    required super.finalRiskScore,
    required super.riskTier,
    required super.confidencePercent,
    required super.dataQuality,
    required super.staticVulnerabilityScore,
    required super.dynamicTriggerRiskScore,
    required super.exposureScore,
    required super.factorContributions,
    required super.primaryDrivers,
    required super.modelName,
    required super.evaluatedAt,
  });

  factory RiskAnalysisModel.fromJson(Map<String, dynamic> json) {
    final factors = (json['factor_contributions'] as List<dynamic>?)?.map((f) {
          final item = f as Map<String, dynamic>;
          return FactorContribution(
            featureName: item['feature_name'] as String? ?? '',
            importanceScore: (item['importance_score'] as num?)?.toDouble() ?? 50.0,
            actualValueFormatted: item['actual_value'] as String? ?? '',
            impactDirection: item['impact_direction'] as String? ?? 'INCREASING_RISK',
            description: item['description'] as String? ?? '',
          );
        }).toList() ??
        [];

    final drivers = (json['primary_drivers'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return RiskAnalysisModel(
      locationId: json['location_id'] as String? ?? 'tawang_001',
      locationName: json['location_name'] as String? ?? 'Tawang Sector 4',
      district: json['district'] as String? ?? 'Tawang',
      state: json['state'] as String? ?? 'Arunachal Pradesh',
      finalRiskScore: (json['final_risk_score'] as num?)?.toInt() ?? 87,
      riskTier: json['risk_level'] as String? ?? 'CRITICAL',
      confidencePercent: (json['confidence_percent'] as num?)?.toInt() ?? 91,
      dataQuality: json['data_quality'] as String? ?? 'EXCELLENT',
      staticVulnerabilityScore: (json['static_vulnerability'] as num?)?.toInt() ?? 82,
      dynamicTriggerRiskScore: (json['dynamic_trigger_risk'] as num?)?.toInt() ?? 89,
      exposureScore: (json['exposure_score'] as num?)?.toInt() ?? 74,
      factorContributions: factors,
      primaryDrivers: drivers,
      modelName: json['model_name'] as String? ?? 'XGBoost v2.1 + RF Hybrid Ensembled',
      evaluatedAt: json['evaluated_at'] as String? ?? 'Just now',
    );
  }

  // Pre-configured explainability profile for Tawang / NER sectors
  static RiskAnalysisModel get sampleTawangExplainability => const RiskAnalysisModel(
        locationId: 'ner_ar_tawang_001',
        locationName: 'Tawang - Lumla Slope Corridor',
        district: 'Tawang',
        state: 'Arunachal Pradesh',
        finalRiskScore: 87,
        riskTier: 'CRITICAL',
        confidencePercent: 91,
        dataQuality: 'EXCELLENT',
        staticVulnerabilityScore: 82,
        dynamicTriggerRiskScore: 89,
        exposureScore: 74,
        factorContributions: [
          FactorContribution(
            featureName: 'Recent 24-Hour Rainfall',
            importanceScore: 92.0,
            actualValueFormatted: '142 mm',
            description: 'Extreme heavy precipitation exceeding 98th percentile for monsoon season.',
          ),
          FactorContribution(
            featureName: 'Soil Moisture Saturation',
            importanceScore: 86.0,
            actualValueFormatted: '91.2%',
            description: 'Catchment saturation exceeds absorption capacity triggering rapid surface runoff.',
          ),
          FactorContribution(
            featureName: 'Doppler Radar Reflectivity',
            importanceScore: 79.0,
            actualValueFormatted: '52.4 dBZ',
            description: 'High-intensity convective cloudburst cell detected by IMD Doppler radar.',
          ),
          FactorContribution(
            featureName: '7-Day Cumulative Rainfall',
            importanceScore: 77.0,
            actualValueFormatted: '380 mm',
            description: 'Persistent 7-day cumulative rainfall exceeding seasonal monsoon normals by +68%.',
          ),
          FactorContribution(
            featureName: 'Atmospheric Instability (CAPE)',
            importanceScore: 71.0,
            actualValueFormatted: '2,840 J/kg',
            description: 'Extreme convective available potential energy driving severe squall storms.',
          ),
          FactorContribution(
            featureName: 'Wind Gust Velocity',
            importanceScore: 52.0,
            actualValueFormatted: '68 km/h',
            description: 'Strong squall front associated with passing mesoscale convective system.',
          ),
        ],
        primaryDrivers: [
          'Extreme recent rainfall (142 mm in 24 hours, cloudburst intensity)',
          'High soil moisture saturation (91.2% runoff & urban inundation risk)',
          'Intense Doppler radar reflectivity (52.4 dBZ convective storm core)',
          'Extreme atmospheric instability (2,840 J/kg CAPE squall trigger)',
        ],
        modelName: 'IMD NWP Ensemble + XGBoost Nowcasting Engine',
        evaluatedAt: 'Live (Synchronized)',
      );
}
