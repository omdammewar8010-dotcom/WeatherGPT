import 'package:flutter_test/flutter_test.dart';
import 'package:ner_landslideguard/features/risk_map/data/models/gis_feature_model.dart';
import 'package:ner_landslideguard/features/risk_map/domain/entities/gis_feature_entity.dart';

void main() {
  group('GIS Risk Map Unit Tests', () {
    test('sampleNerGisFeatures loads polygons, incidents, sensors, and infrastructure', () {
      final features = GisFeatureModel.sampleNerGisFeatures;
      expect(features.isNotEmpty, isTrue);

      final riskZones = features.where((f) => f.layerType == GisLayerType.riskZone).toList();
      expect(riskZones.isNotEmpty, isTrue);
      expect(riskZones.first.polygonPoints, isNotNull);
      expect(riskZones.first.polygonPoints!.length, greaterThanOrEqualTo(3));

      final sensors = features.where((f) => f.layerType == GisLayerType.sensor).toList();
      expect(sensors.isNotEmpty, isTrue);

      final incidents = features.where((f) => f.layerType == GisLayerType.incident).toList();
      expect(incidents.isNotEmpty, isTrue);

      final roads = features.where((f) => f.layerType == GisLayerType.road).toList();
      expect(roads.isNotEmpty, isTrue);
    });

    test('GisFeatureModel parses layer types correctly', () {
      final jsonZone = {
        'id': 'test_01',
        'title': 'Test Zone',
        'layer_type': 'risk_zone',
        'latitude': 27.5,
        'longitude': 91.8,
        'risk_score': 85,
        'risk_level': 'CRITICAL',
      };
      final model = GisFeatureModel.fromJson(jsonZone);
      expect(model.layerType, GisLayerType.riskZone);
      expect(model.riskScore, 85);
      expect(model.riskLevel, 'CRITICAL');
    });
  });
}
