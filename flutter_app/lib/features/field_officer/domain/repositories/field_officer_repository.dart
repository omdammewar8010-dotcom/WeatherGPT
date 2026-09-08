import 'package:ner_landslideguard/features/field_officer/domain/entities/geotechnical_inspection_entity.dart';
import 'package:ner_landslideguard/features/reports/domain/entities/incident_report_entity.dart';

abstract class FieldOfficerRepository {
  Future<List<IncidentReportEntity>> getAssignedIncidents({String? district});
  Future<void> submitInspection(GeotechnicalInspectionEntity inspection);
}
