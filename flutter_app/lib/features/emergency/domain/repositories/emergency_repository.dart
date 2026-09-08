import 'package:ner_landslideguard/features/emergency/domain/entities/emergency_sos_entity.dart';

abstract class EmergencyRepository {
  Future<EmergencySosEntity> triggerSos(EmergencySosEntity entity);
  Future<List<EmergencySosEntity>> getActiveEmergencies();
  Future<List<EvacuationShelterEntity>> getNearbyShelters(String district);
  Future<void> updateEmergencyStatus(String sosId, String status);
}
