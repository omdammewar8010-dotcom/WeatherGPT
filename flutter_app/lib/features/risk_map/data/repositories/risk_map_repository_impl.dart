import '../../domain/entities/gis_feature_entity.dart';
import '../../domain/repositories/risk_map_repository.dart';
import '../datasources/risk_map_remote_datasource.dart';

class RiskMapRepositoryImpl implements RiskMapRepository {
  final RiskMapRemoteDataSource remoteDataSource;

  RiskMapRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<GisFeatureEntity>> getGisFeatures() async {
    return await remoteDataSource.getGisFeatures();
  }

  @override
  Future<GisFeatureEntity> getFeatureDetails(String featureId) async {
    final list = await remoteDataSource.getGisFeatures();
    return list.firstWhere(
      (f) => f.id == featureId,
      orElse: () => list.first,
    );
  }
}
