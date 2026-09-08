import 'package:ner_landslideguard/core/network/api_client.dart';
import 'package:ner_landslideguard/core/services/sync/sync_queue_manager.dart';
import 'package:ner_landslideguard/features/field_officer/domain/entities/geotechnical_inspection_entity.dart';
import 'package:ner_landslideguard/features/field_officer/domain/repositories/field_officer_repository.dart';
import 'package:ner_landslideguard/features/reports/data/models/incident_report_model.dart';
import 'package:ner_landslideguard/features/reports/domain/entities/incident_report_entity.dart';

class FieldOfficerRepositoryImpl implements FieldOfficerRepository {
  final ApiClient _apiClient;
  final SyncQueueManager _syncQueue;

  FieldOfficerRepositoryImpl({
    ApiClient? apiClient,
    SyncQueueManager? syncQueue,
  })  : _apiClient = apiClient ?? ApiClient(),
        _syncQueue = syncQueue ?? SyncQueueManagerImpl();

  @override
  Future<List<IncidentReportEntity>> getAssignedIncidents({String? district}) async {
    try {
      final response = await _apiClient.dio.get('/reports', queryParameters: {
        if (district != null) 'district': district,
      });
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => IncidentReportModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }
    return IncidentReportModel.sampleReports;
  }

  @override
  Future<void> submitInspection(GeotechnicalInspectionEntity inspection) async {
    // 1. Queue for offline synchronization
    await _syncQueue.enqueue(
      SyncQueueItem(
        id: inspection.inspectionId,
        type: SyncItemType.fieldInspection,
        payload: inspection.toJson(),
        createdAt: DateTime.now(),
      ),
    );

    // 2. Try remote patch to update incident status
    try {
      await _apiClient.dio.patch(
        '/reports/${inspection.reportId}/status',
        data: {
          'status': inspection.verificationStatus,
          'verified_by': '${inspection.inspectorName} (${inspection.inspectorBadge})',
          'resolution_notes': '${inspection.recommendedAction}: ${inspection.officerNotes}',
        },
      );
    } catch (_) {
      // Handled by background sync engine
    }
  }
}
