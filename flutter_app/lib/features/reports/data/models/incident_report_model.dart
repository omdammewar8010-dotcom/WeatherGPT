import '../../domain/entities/incident_report_entity.dart';

class IncidentReportModel extends IncidentReportEntity {
  const IncidentReportModel({
    required super.id,
    required super.reporterId,
    required super.reporterName,
    required super.reporterPhone,
    required super.category,
    required super.severity,
    required super.latitude,
    required super.longitude,
    required super.state,
    required super.district,
    super.landmark,
    required super.description,
    required super.mediaUrls,
    required super.status,
    super.isOfflinePending = false,
    super.aiAnalysis,
    required super.createdAt,
  });

  factory IncidentReportModel.fromJson(Map<String, dynamic> json) {
    AiImageAnalysisResult? analysis;
    if (json['ai_image_analysis'] != null) {
      final a = json['ai_image_analysis'] as Map<String, dynamic>;
      analysis = AiImageAnalysisResult(
        crackDetected: a['crack_detected'] as bool? ?? false,
        debrisDetected: a['debris_detected'] as bool? ?? false,
        roadObstructionDetected: a['road_obstruction'] as bool? ?? false,
        confidenceScore: (a['confidence_score'] as num?)?.toDouble() ?? 0.91,
        summary: a['summary'] as String? ?? 'Computer Vision hazard screening completed.',
      );
    }

    return IncidentReportModel(
      id: json['id'] as String? ?? 'LR-2026-000123',
      reporterId: json['reporter_id'] as String? ?? 'usr_demo',
      reporterName: json['reporter_name'] as String? ?? 'Citizen Reporter',
      reporterPhone: json['reporter_phone'] as String? ?? '+91 98765 43210',
      category: ReportCategory.fromString(json['category'] as String?),
      severity: json['severity'] as String? ?? 'HIGH',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 27.586,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 91.859,
      state: json['state'] as String? ?? 'Arunachal Pradesh',
      district: json['district'] as String? ?? 'Tawang',
      landmark: json['landmark'] as String?,
      description: json['description'] as String? ?? '',
      mediaUrls: (json['media_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] as String? ?? 'UNDER_REVIEW',
      isOfflinePending: json['is_offline_pending'] as bool? ?? false,
      aiAnalysis: analysis,
      createdAt: json['created_at'] as String? ?? 'Just now',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reporter_name': reporterName,
      'reporter_phone': reporterPhone,
      'category': category.name,
      'severity': severity,
      'latitude': latitude,
      'longitude': longitude,
      'state': state,
      'district': district,
      'landmark': landmark,
      'description': description,
      'media_urls': mediaUrls,
      'status': status,
      'is_offline_pending': isOfflinePending,
      'created_at': createdAt,
    };
  }

  // Pre-configured citizen reports for evaluation
  static List<IncidentReportModel> get sampleReports => [
        const IncidentReportModel(
          id: 'LR-2026-000123',
          reporterId: 'usr_citizen_01',
          reporterName: 'Ayush Sharma',
          reporterPhone: '+91 98765 43210',
          category: ReportCategory.landslide,
          severity: 'CRITICAL',
          latitude: 27.586,
          longitude: 91.859,
          state: 'Arunachal Pradesh',
          district: 'Tawang',
          landmark: 'NH-13 Near Lumla Turn (KM 14)',
          description:
              'Significant ground displacement and wet mud debris covered both lanes of highway after continuous morning downpour.',
          mediaUrls: ['https://storage.googleapis.com/ner-guard-demo/evidence_01.jpg'],
          status: 'UNDER_REVIEW',
          isOfflinePending: false,
          aiAnalysis: AiImageAnalysisResult(
            crackDetected: true,
            debrisDetected: true,
            roadObstructionDetected: true,
            confidenceScore: 0.93,
            summary: 'Active mudslide debris and carriageway obstruction detected.',
          ),
          createdAt: '18 mins ago',
        ),
        const IncidentReportModel(
          id: 'LR-2026-000121',
          reporterId: 'usr_citizen_02',
          reporterName: 'Sonam Norbu',
          reporterPhone: '+91 94350 22334',
          category: ReportCategory.groundCrack,
          severity: 'HIGH',
          latitude: 27.512,
          longitude: 92.110,
          state: 'Arunachal Pradesh',
          district: 'West Kameng',
          landmark: 'Dirang Hill Upper Settlement',
          description:
              'New longitudinal tension crack appearing along retaining wall of village access slope. Water seeping through soil.',
          mediaUrls: ['https://storage.googleapis.com/ner-guard-demo/evidence_02.jpg'],
          status: 'ACTION_INITIATED',
          isOfflinePending: false,
          aiAnalysis: AiImageAnalysisResult(
            crackDetected: true,
            debrisDetected: false,
            roadObstructionDetected: false,
            confidenceScore: 0.88,
            summary: 'Tension fissure detected with water percolation indicators.',
          ),
          createdAt: '1 hour ago',
        ),
        const IncidentReportModel(
          id: 'LR-2026-000119',
          reporterId: 'usr_citizen_03',
          reporterName: 'Kunzang Choden',
          reporterPhone: '+91 94351 77889',
          category: ReportCategory.rockfall,
          severity: 'MODERATE',
          latitude: 27.340,
          longitude: 88.610,
          state: 'Sikkim',
          district: 'East Sikkim',
          landmark: 'Ranipool Bypass Bridge',
          description: 'Minor boulder fall on side drainage. BRO clearing crew active.',
          mediaUrls: [],
          status: 'VERIFIED',
          isOfflinePending: false,
          createdAt: '3 hours ago',
        ),
      ];
}
