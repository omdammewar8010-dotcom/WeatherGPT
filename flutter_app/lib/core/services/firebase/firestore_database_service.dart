import 'dart:async';
import '../../../features/reports/data/models/incident_report_model.dart';
import '../../../features/reports/domain/entities/incident_report_entity.dart';
import '../../../features/risk_map/data/models/gis_feature_model.dart';
import '../../../features/risk_map/domain/entities/gis_feature_entity.dart';

abstract class FirestoreDatabaseService {
  // Incident Reports
  Future<void> saveIncidentReport(IncidentReportEntity report);
  Future<IncidentReportEntity?> getIncidentReport(String reportId);
  Stream<List<IncidentReportEntity>> streamIncidentReports({String? district});
  Future<void> updateIncidentReportStatus({
    required String reportId,
    required String newStatus,
    required String verifiedBy,
    String? resolutionNotes,
  });

  // Early Warnings & Alerts
  Stream<List<Map<String, dynamic>>> streamActiveWarnings({String? district});
  Future<void> broadcastEarlyWarning(Map<String, dynamic> warningData);

  // IoT Sensor Telemetry
  Stream<List<GisFeatureEntity>> streamIotSensors({String? district});

  // Risk Assessments
  Future<Map<String, dynamic>?> getLatestDistrictRisk(String district);
  Future<void> saveDistrictRisk(String district, Map<String, dynamic> riskData);

  // Audit Logs
  Future<void> logAuditAction({
    required String userId,
    required String action,
    required Map<String, dynamic> details,
  });
}

class FirestoreDatabaseServiceImpl implements FirestoreDatabaseService {
  final List<IncidentReportModel> _reportsCache = List.from(IncidentReportModel.sampleReports);
  final List<Map<String, dynamic>> _warningsCache = [
    {
      'id': 'WARN-2026-089',
      'title': 'High Landslide Risk — Sela Pass Corridor',
      'district': 'Tawang',
      'state': 'Arunachal Pradesh',
      'severity': 'CRITICAL',
      'risk_score': 88,
      'confidence': 0.94,
      'valid_until': DateTime.now().add(const Duration(hours: 18)).toIso8601String(),
      'advisory': 'NH-13 traffic suspended. Residents in Lumla and Jang sectors urged to evacuate to designated relief camps.',
      'evacuation_route': 'NH-13 South diversion towards Dirang',
      'created_at': DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
    },
    {
      'id': 'WARN-2026-090',
      'title': 'Slope Instability Advisory — East Sikkim',
      'district': 'Gangtok',
      'state': 'Sikkim',
      'severity': 'HIGH',
      'risk_score': 74,
      'confidence': 0.89,
      'valid_until': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      'advisory': 'Continuous heavy rain triggered rockfall along Gangtok-Nathula highway. Heavy commercial transit prohibited.',
      'evacuation_route': 'Burtuk bypass to Ranipool shelter',
      'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
  ];

  final _reportsController = StreamController<List<IncidentReportEntity>>.broadcast();
  final _warningsController = StreamController<List<Map<String, dynamic>>>.broadcast();

  FirestoreDatabaseServiceImpl() {
    _reportsController.add(List.unmodifiable(_reportsCache));
    _warningsController.add(List.unmodifiable(_warningsCache));
  }

  @override
  Future<void> saveIncidentReport(IncidentReportEntity report) async {
    final model = IncidentReportModel(
      id: report.id,
      reporterId: report.reporterId,
      reporterName: report.reporterName,
      reporterPhone: report.reporterPhone,
      category: report.category,
      severity: report.severity,
      latitude: report.latitude,
      longitude: report.longitude,
      state: report.state,
      district: report.district,
      landmark: report.landmark,
      description: report.description,
      mediaUrls: report.mediaUrls,
      status: report.status,
      isOfflinePending: false,
      aiAnalysis: report.aiAnalysis,
      createdAt: report.createdAt,
    );

    final existingIndex = _reportsCache.indexWhere((r) => r.id == report.id);
    if (existingIndex >= 0) {
      _reportsCache[existingIndex] = model;
    } else {
      _reportsCache.insert(0, model);
    }
    _reportsController.add(List.unmodifiable(_reportsCache));
  }

  @override
  Future<IncidentReportEntity?> getIncidentReport(String reportId) async {
    try {
      return _reportsCache.firstWhere((r) => r.id == reportId);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<IncidentReportEntity>> streamIncidentReports({String? district}) {
    if (district == null) {
      return _reportsController.stream;
    }
    return _reportsController.stream.map(
      (reports) => reports.where((r) => r.district.toLowerCase() == district.toLowerCase()).toList(),
    );
  }

  @override
  Future<void> updateIncidentReportStatus({
    required String reportId,
    required String newStatus,
    required String verifiedBy,
    String? resolutionNotes,
  }) async {
    final index = _reportsCache.indexWhere((r) => r.id == reportId);
    if (index >= 0) {
      final current = _reportsCache[index];
      final updated = IncidentReportModel(
        id: current.id,
        reporterId: current.reporterId,
        reporterName: current.reporterName,
        reporterPhone: current.reporterPhone,
        category: current.category,
        severity: current.severity,
        latitude: current.latitude,
        longitude: current.longitude,
        state: current.state,
        district: current.district,
        landmark: current.landmark,
        description: resolutionNotes != null ? '${current.description}\n[Note by $verifiedBy]: $resolutionNotes' : current.description,
        mediaUrls: current.mediaUrls,
        status: newStatus,
        isOfflinePending: false,
        aiAnalysis: current.aiAnalysis,
        createdAt: current.createdAt,
      );
      _reportsCache[index] = updated;
      _reportsController.add(List.unmodifiable(_reportsCache));
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamActiveWarnings({String? district}) {
    if (district == null) {
      return _warningsController.stream;
    }
    return _warningsController.stream.map(
      (warnings) => warnings.where((w) => w['district'].toString().toLowerCase() == district.toLowerCase()).toList(),
    );
  }

  @override
  Future<void> broadcastEarlyWarning(Map<String, dynamic> warningData) async {
    _warningsCache.insert(0, warningData);
    _warningsController.add(List.unmodifiable(_warningsCache));
  }

  @override
  Stream<List<GisFeatureEntity>> streamIotSensors({String? district}) {
    final sensors = GisFeatureModel.sampleNerGisFeatures
        .where((f) => f.layerType == GisLayerType.sensor)
        .toList();
    if (district == null) {
      return Stream.value(sensors);
    }
    return Stream.value(
      sensors.where((s) => s.subtitle.toLowerCase().contains(district.toLowerCase())).toList(),
    );
  }

  @override
  Future<Map<String, dynamic>?> getLatestDistrictRisk(String district) async {
    return {
      'district': district,
      'risk_score': 84.5,
      'risk_level': 'HIGH',
      'confidence': 0.93,
      'factors': {
        'slope_gradient_deg': 42.5,
        'rainfall_accumulated_mm': 168.0,
        'soil_moisture_kpa': 48.0,
        'geology_type': 'Fragile Schist / Colluvium',
      },
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<void> saveDistrictRisk(String district, Map<String, dynamic> riskData) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> logAuditAction({
    required String userId,
    required String action,
    required Map<String, dynamic> details,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  void dispose() {
    _reportsController.close();
    _warningsController.close();
  }
}
