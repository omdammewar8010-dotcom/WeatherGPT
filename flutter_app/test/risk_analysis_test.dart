import 'package:flutter_test/flutter_test.dart';
import 'package:ner_landslideguard/features/risk_analysis/data/models/risk_analysis_model.dart';

void main() {
  group('AI Risk Explainability & SHAP Unit Tests', () {
    test('sampleTawangExplainability contains Two-Layer scores and SHAP factors', () {
      final analysis = RiskAnalysisModel.sampleTawangExplainability;
      expect(analysis.finalRiskScore, 87);
      expect(analysis.riskTier, 'CRITICAL');
      expect(analysis.staticVulnerabilityScore, 82);
      expect(analysis.dynamicTriggerRiskScore, 89);
      expect(analysis.confidencePercent, 91);
      expect(analysis.dataQuality, 'EXCELLENT');

      // Verify SHAP factor weights
      expect(analysis.factorContributions.length, 6);
      expect(analysis.factorContributions.first.featureName, 'Recent 24-Hour Rainfall');
      expect(analysis.factorContributions.first.importanceScore, 92.0);

      // Verify plain language drivers
      expect(analysis.primaryDrivers.length, 4);
    });

    test('RiskAnalysisModel parses JSON correctly', () {
      final json = {
        'location_id': 'test_loc',
        'location_name': 'Test Corridor',
        'district': 'Tawang',
        'state': 'Arunachal Pradesh',
        'final_risk_score': 87,
        'risk_level': 'CRITICAL',
        'confidence_percent': 91,
        'data_quality': 'GOOD',
        'static_vulnerability': 80,
        'dynamic_trigger_risk': 88,
        'exposure_score': 72,
        'factor_contributions': [
          {
            'feature_name': '24h Rain',
            'importance_score': 90.0,
            'actual_value': '140 mm',
            'description': 'Heavy rainfall',
          }
        ],
        'primary_drivers': ['Heavy rain detected'],
        'model_name': 'XGBoost + RF Hybrid',
      };

      final model = RiskAnalysisModel.fromJson(json);
      expect(model.finalRiskScore, 87);
      expect(model.factorContributions.first.featureName, '24h Rain');
      expect(model.primaryDrivers.first, 'Heavy rain detected');
    });
  });
}
