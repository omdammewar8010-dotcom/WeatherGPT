import '../entities/gis_feature_entity.dart';

abstract class RiskMapRepository {
  Future<List<GisFeatureEntity>> getGisFeatures();
  Future<GisFeatureEntity> getFeatureDetails(String featureId);
}
