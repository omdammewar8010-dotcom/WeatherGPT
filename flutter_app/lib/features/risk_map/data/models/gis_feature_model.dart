import 'package:latlong2/latlong.dart';
import '../../domain/entities/gis_feature_entity.dart';

class GisFeatureModel extends GisFeatureEntity {
  const GisFeatureModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.layerType,
    required super.position,
    super.polygonPoints,
    required super.riskScore,
    required super.riskLevel,
    required super.status,
    super.rainfall24h,
    super.forecast24h,
    super.soilMoisture,
    super.slopeDegrees,
    super.historicalEventsCount,
    super.roadStatus,
    super.metadata,
  });

  factory GisFeatureModel.fromJson(Map<String, dynamic> json) {
    List<LatLng>? points;
    if (json['polygon_coordinates'] != null) {
      final rawCoords = json['polygon_coordinates'] as List<dynamic>;
      points = rawCoords.map((pt) {
        final pair = pt as List<dynamic>;
        return LatLng((pair[0] as num).toDouble(), (pair[1] as num).toDouble());
      }).toList();
    }

    final lat = (json['latitude'] as num?)?.toDouble() ?? 27.586;
    final lng = (json['longitude'] as num?)?.toDouble() ?? 91.859;

    return GisFeatureModel(
      id: json['id'] as String? ?? 'zone_001',
      title: json['title'] as String? ?? 'Risk Zone',
      subtitle: json['subtitle'] as String? ?? 'North Eastern Region',
      layerType: _parseLayerType(json['layer_type'] as String?),
      position: LatLng(lat, lng),
      polygonPoints: points,
      riskScore: (json['risk_score'] as num?)?.toInt() ?? 50,
      riskLevel: json['risk_level'] as String? ?? 'MODERATE',
      status: json['status'] as String? ?? 'ACTIVE',
      rainfall24h: (json['rainfall_24h'] as num?)?.toDouble(),
      forecast24h: (json['forecast_24h'] as num?)?.toDouble(),
      soilMoisture: (json['soil_moisture'] as num?)?.toDouble(),
      slopeDegrees: (json['slope_degrees'] as num?)?.toDouble(),
      historicalEventsCount: (json['historical_events_count'] as num?)?.toInt(),
      roadStatus: json['road_status'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static GisLayerType _parseLayerType(String? str) {
    switch (str?.toLowerCase()) {
      case 'incident':
      case 'landslide':
        return GisLayerType.incident;
      case 'road':
        return GisLayerType.road;
      case 'sensor':
        return GisLayerType.sensor;
      case 'infrastructure':
      case 'asset':
        return GisLayerType.infrastructure;
      case 'risk_zone':
      default:
        return GisLayerType.riskZone;
    }
  }

  // Pre-configured realistic GeoJSON / GIS features across North Eastern states
  static List<GisFeatureModel> get sampleNerGisFeatures => [
        // 1. Critical Risk Zone - Tawang Sector Alpha (Arunachal Pradesh)
        GisFeatureModel(
          id: 'gis_zone_tawang_01',
          title: 'Tawang - Lumla Slope Corridor',
          subtitle: 'Tawang District, Arunachal Pradesh',
          layerType: GisLayerType.riskZone,
          position: const LatLng(27.586, 91.859),
          polygonPoints: const [
            LatLng(27.595, 91.845),
            LatLng(27.598, 91.872),
            LatLng(27.575, 91.880),
            LatLng(27.568, 91.850),
          ],
          riskScore: 87,
          riskLevel: 'CRITICAL',
          status: 'EVACUATION_ADVISORY',
          rainfall24h: 142.0,
          forecast24h: 86.0,
          soilMoisture: 91.2,
          slopeDegrees: 39.0,
          historicalEventsCount: 17,
          roadStatus: 'Vulnerable (NH-13)',
        ),

        // 2. Critical Risk Zone - Gangtok Ridge (East Sikkim)
        GisFeatureModel(
          id: 'gis_zone_gangtok_02',
          title: 'Gangtok - Ranipool Escarpment',
          subtitle: 'East Sikkim, Sikkim',
          layerType: GisLayerType.riskZone,
          position: const LatLng(27.338, 88.606),
          polygonPoints: const [
            LatLng(27.350, 88.590),
            LatLng(27.355, 88.625),
            LatLng(27.320, 88.630),
            LatLng(27.315, 88.595),
          ],
          riskScore: 89,
          riskLevel: 'CRITICAL',
          status: 'ROAD_BLOCKED',
          rainfall24h: 156.0,
          forecast24h: 94.0,
          soilMoisture: 94.5,
          slopeDegrees: 42.0,
          historicalEventsCount: 29,
          roadStatus: 'BLOCKED (NH-10)',
        ),

        // 3. High Risk Zone - Shillong Ridge (Meghalaya)
        GisFeatureModel(
          id: 'gis_zone_shillong_03',
          title: 'Cherrapunji - Shillong Slope',
          subtitle: 'East Khasi Hills, Meghalaya',
          layerType: GisLayerType.riskZone,
          position: const LatLng(25.578, 91.893),
          polygonPoints: const [
            LatLng(25.590, 91.875),
            LatLng(25.595, 91.910),
            LatLng(25.565, 91.915),
            LatLng(25.560, 91.880),
          ],
          riskScore: 82,
          riskLevel: 'CRITICAL',
          status: 'ACTIVE_MONITORING',
          rainfall24h: 138.0,
          forecast24h: 75.0,
          soilMoisture: 88.0,
          slopeDegrees: 36.0,
          historicalEventsCount: 21,
          roadStatus: 'Vulnerable (Shillong Bypass)',
        ),

        // 4. High Risk Zone - Aizawl Slopes (Mizoram)
        GisFeatureModel(
          id: 'gis_zone_aizawl_04',
          title: 'Aizawl North Ridge',
          subtitle: 'Aizawl, Mizoram',
          layerType: GisLayerType.riskZone,
          position: const LatLng(23.727, 92.717),
          polygonPoints: const [
            LatLng(23.740, 92.700),
            LatLng(23.745, 92.735),
            LatLng(23.710, 92.740),
            LatLng(23.705, 92.705),
          ],
          riskScore: 68,
          riskLevel: 'HIGH',
          status: 'WARNING_ISSUED',
          rainfall24h: 78.0,
          forecast24h: 45.0,
          soilMoisture: 76.5,
          slopeDegrees: 34.0,
          historicalEventsCount: 14,
          roadStatus: 'Watchlist',
        ),

        // 5. Active Incident Marker - Sela Pass Rockfall
        GisFeatureModel(
          id: 'gis_inc_sela_01',
          title: 'Sela Pass Rockfall & Debris Slide',
          subtitle: 'Reported by Field Patrol • 25 mins ago',
          layerType: GisLayerType.incident,
          position: const LatLng(27.502, 92.103),
          riskScore: 92,
          riskLevel: 'CRITICAL',
          status: 'UNDER_INSPECTION',
          roadStatus: 'NH-13 Partially Blocked',
        ),

        // 6. Active Incident Marker - Mangan Road Creep
        GisFeatureModel(
          id: 'gis_inc_mangan_02',
          title: 'Ground Crack & Road Subsidence',
          subtitle: 'Reported by Citizen • 1 hour ago',
          layerType: GisLayerType.incident,
          position: const LatLng(27.510, 88.530),
          riskScore: 78,
          riskLevel: 'HIGH',
          status: 'VERIFIED',
          roadStatus: 'Single Lane Traffic',
        ),

        // 7. IoT Telemetry Sensor - Tawang Slope Inclinometer #04
        GisFeatureModel(
          id: 'gis_sensor_01',
          title: 'In-Situ Pore Pressure Sensor #04',
          subtitle: 'Telemetry: 12.4 kPa (Threshold: 10 kPa)',
          layerType: GisLayerType.sensor,
          position: const LatLng(27.589, 91.865),
          riskScore: 85,
          riskLevel: 'CRITICAL',
          status: 'HIGH_PORE_PRESSURE',
          metadata: {'battery': '98%', 'lastPing': '30s ago'},
        ),

        // 8. IoT Telemetry Sensor - Gangtok Automated Rain Gauge
        GisFeatureModel(
          id: 'gis_sensor_02',
          title: 'Automated Weather Station (AWS-SK02)',
          subtitle: 'Rain Intensity: 22 mm/hr',
          layerType: GisLayerType.sensor,
          position: const LatLng(27.332, 88.612),
          riskScore: 88,
          riskLevel: 'CRITICAL',
          status: 'HEAVY_RAIN_SPIKE',
          metadata: {'rain1h': '22mm', 'humidity': '99%'},
        ),

        // 9. Critical Infrastructure - Tawang Civil Hospital
        GisFeatureModel(
          id: 'gis_infra_hosp_01',
          title: 'Tawang District Hospital (Emergency Ward)',
          subtitle: '24/7 Trauma Care & Ambulance Base',
          layerType: GisLayerType.infrastructure,
          position: const LatLng(27.581, 91.868),
          riskScore: 20,
          riskLevel: 'LOW',
          status: 'OPERATIONAL',
          metadata: {'beds': 120, 'helipad': 'Available'},
        ),

        // 10. Critical Infrastructure - Dirang Police Command
        GisFeatureModel(
          id: 'gis_infra_police_02',
          title: 'Dirang Emergency Response Base',
          subtitle: 'SDRF & Border Police Control Room',
          layerType: GisLayerType.infrastructure,
          position: const LatLng(27.355, 92.235),
          riskScore: 25,
          riskLevel: 'LOW',
          status: 'OPERATIONAL',
          metadata: {'officersOnDuty': 24, 'emergencyLine': '112'},
        ),

        // 11. Road Segment - NH-13 Trans-Arunachal Highway
        GisFeatureModel(
          id: 'gis_road_nh13',
          title: 'NH-13 Trans-Arunachal Highway',
          subtitle: 'Sela Pass - Tawang Section',
          layerType: GisLayerType.road,
          position: const LatLng(27.545, 91.950),
          riskScore: 84,
          riskLevel: 'CRITICAL',
          status: 'VULNERABLE',
          roadStatus: 'Vulnerable to Active Slump',
        ),

        // 12. Road Segment - NH-10 Siliguri-Gangtok Corridor
        GisFeatureModel(
          id: 'gis_road_nh10',
          title: 'NH-10 Siliguri - Gangtok Highway',
          subtitle: 'Corridor along Teesta River',
          layerType: GisLayerType.road,
          position: const LatLng(27.250, 88.510),
          riskScore: 90,
          riskLevel: 'CRITICAL',
          status: 'BLOCKED',
          roadStatus: 'BLOCKED at KM 28',
        ),
      ];
}
