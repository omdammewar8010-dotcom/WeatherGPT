enum ReportCategory {
  landslide,
  groundCrack,
  rockfall,
  roadBlockage,
  soilErosion,
  other;

  String get displayName {
    switch (this) {
      case ReportCategory.landslide:
        return 'Landslide / Debris Flow';
      case ReportCategory.groundCrack:
        return 'Ground / Slope Crack';
      case ReportCategory.rockfall:
        return 'Rockfall / Boulder Roll';
      case ReportCategory.roadBlockage:
        return 'Road / Highway Blockage';
      case ReportCategory.soilErosion:
        return 'Severe Soil Erosion';
      case ReportCategory.other:
        return 'Other Slope Anomaly';
    }
  }

  static ReportCategory fromString(String? cat) {
    switch (cat?.toLowerCase()) {
      case 'ground_crack':
      case 'groundcrack':
        return ReportCategory.groundCrack;
      case 'rockfall':
        return ReportCategory.rockfall;
      case 'road_blockage':
      case 'roadblockage':
        return ReportCategory.roadBlockage;
      case 'soil_erosion':
      case 'soilerosion':
        return ReportCategory.soilErosion;
      case 'other':
        return ReportCategory.other;
      case 'landslide':
      default:
        return ReportCategory.landslide;
    }
  }
}

class AiImageAnalysisResult {
  final bool crackDetected;
  final bool debrisDetected;
  final bool roadObstructionDetected;
  final double confidenceScore;
  final String summary;

  const AiImageAnalysisResult({
    required this.crackDetected,
    required this.debrisDetected,
    required this.roadObstructionDetected,
    required this.confidenceScore,
    required this.summary,
  });
}

class IncidentReportEntity {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reporterPhone;
  final ReportCategory category;
  final String severity; // "CRITICAL", "HIGH", "MODERATE", "LOW"
  final double latitude;
  final double longitude;
  final String state;
  final String district;
  final String? landmark;
  final String description;
  final List<String> mediaUrls;
  final String status; // "SUBMITTED", "UNDER_REVIEW", "VERIFIED", "ACTION_INITIATED", "RESOLVED"
  final bool isOfflinePending;
  final AiImageAnalysisResult? aiAnalysis;
  final String createdAt;

  const IncidentReportEntity({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reporterPhone,
    required this.category,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.state,
    required this.district,
    this.landmark,
    required this.description,
    required this.mediaUrls,
    required this.status,
    this.isOfflinePending = false,
    this.aiAnalysis,
    required this.createdAt,
  });
}
