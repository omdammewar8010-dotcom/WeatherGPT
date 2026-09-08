import '../entities/early_warning_entity.dart';

abstract class AlertRepository {
  Future<List<EarlyWarningEntity>> getActiveWarnings({String? district});
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
  });
}
