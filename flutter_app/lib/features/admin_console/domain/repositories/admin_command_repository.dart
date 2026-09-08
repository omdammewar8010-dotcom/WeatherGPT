import 'package:ner_landslideguard/features/admin_console/domain/entities/regional_analytics_entity.dart';

abstract class AdminCommandRepository {
  Future<RegionalCommandMetricsEntity> getRegionalCommandMetrics();
  Future<void> dispatchEmergencyBroadcast({
    required String targetState,
    required String targetDistrict,
    required String alertTitle,
    required String severity,
    required String advisoryMessage,
    required bool activateSiren,
    required bool sendSmsFallback,
  });
}
