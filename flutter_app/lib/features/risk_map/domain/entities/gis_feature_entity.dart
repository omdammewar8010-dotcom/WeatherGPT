import 'package:latlong2/latlong.dart';

enum GisLayerType {
  riskZone,
  incident,
  road,
  sensor,
  infrastructure;

  String get displayName {
    switch (this) {
      case GisLayerType.riskZone:
        return 'Risk Zones';
      case GisLayerType.incident:
        return 'Landslides';
      case GisLayerType.road:
        return 'Road Network';
      case GisLayerType.sensor:
        return 'IoT Sensors';
      case GisLayerType.infrastructure:
        return 'Critical Assets';
    }
  }
}

class GisFeatureEntity {
  final String id;
  final String title;
  final String subtitle;
  final GisLayerType layerType;
  final LatLng position;
  final List<LatLng>? polygonPoints;
  final int riskScore; // 0 to 100
  final String riskLevel; // "LOW", "MODERATE", "HIGH", "CRITICAL"
  final String status; // e.g. "BLOCKED", "VULNERABLE", "CLEAR", "ACTIVE"
  final double? rainfall24h;
  final double? forecast24h;
  final double? soilMoisture;
  final double? slopeDegrees;
  final int? historicalEventsCount;
  final String? roadStatus;
  final Map<String, dynamic>? metadata;

  const GisFeatureEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.layerType,
    required this.position,
    this.polygonPoints,
    required this.riskScore,
    required this.riskLevel,
    required this.status,
    this.rainfall24h,
    this.forecast24h,
    this.soilMoisture,
    this.slopeDegrees,
    this.historicalEventsCount,
    this.roadStatus,
    this.metadata,
  });
}
