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
            description: 'Pore water pressure exceeds critical shear resistance threshold.',
          ),
          FactorContribution(
            featureName: 'Terrain Slope Gradient',
            importanceScore: 79.0,
            actualValueFormatted: '39.0°',
            description: 'Steep escarpment with high gravitational shear stress.',
          ),
          FactorContribution(
            featureName: '7-Day Antecedent Rainfall',
            importanceScore: 77.0,
            actualValueFormatted: '380 mm',
            description: 'Persistent 7-day cumulative rainfall saturated sub-surface rock joints.',
          ),
          FactorContribution(
            featureName: 'Historical Landslide Frequency',
            importanceScore: 71.0,
            actualValueFormatted: '17 past events',
            description: 'High repeat failure susceptibility mapped in GSI inventory.',
          ),
          FactorContribution(
            featureName: 'Vegetation Canopy (NDVI)',
            importanceScore: 52.0,
            actualValueFormatted: '0.38 NDVI',
            description: 'Moderate canopy cover offers insufficient root anchoring on steep cut slopes.',
          ),
        ],
        primaryDrivers: [
          'Extreme recent rainfall (142 mm in 24 hours)',
          'High soil moisture saturation (91.2% pore water pressure)',
          'Steep terrain slope angle (39.0° gravitational vector)',
          'High historical landslide frequency (17 mapped GSI events)',
        ],
        modelName: 'XGBoost Dynamic + Random Forest Static Hybrid',
        evaluatedAt: 'Live (Synchronized)',
      );
}
