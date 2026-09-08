import '../../domain/entities/early_warning_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_remote_datasource.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource _remoteDataSource;

  AlertRepositoryImpl({AlertRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AlertRemoteDataSourceImpl();

  @override
  Future<List<EarlyWarningEntity>> getActiveWarnings({String? district}) {
    return _remoteDataSource.fetchActiveWarnings(district: district);
  }

  @override
  Future<EarlyWarningEntity> broadcastWarning({
    required String title,
    required String district,
    required String state,
    required String severity,
    required int riskScore,
    required double confidence,
    required int validUntilHours,
    required String advisory,
    required String evacuationRoute,
    required List<String> affectedSectors,
  }) {
    return _remoteDataSource.broadcastWarning(
      title: title,
      district: district,
      state: state,
      severity: severity,
      riskScore: riskScore,
      confidence: confidence,
      validUntilHours: validUntilHours,
      advisory: advisory,
      evacuationRoute: evacuationRoute,
      affectedSectors: affectedSectors,
    );
  }
}
