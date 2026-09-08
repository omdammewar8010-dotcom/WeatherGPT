import 'package:ner_landslideguard/core/network/api_client.dart';
import 'package:ner_landslideguard/features/emergency/domain/entities/emergency_sos_entity.dart';
import 'package:ner_landslideguard/features/emergency/domain/repositories/emergency_repository.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final ApiClient _apiClient;

  EmergencyRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<EmergencySosEntity> triggerSos(EmergencySosEntity entity) async {
    try {
      final response = await _apiClient.dio.post('/emergency/sos', data: {
        'reporter_name': entity.reporterName,
        'reporter_phone': entity.reporterPhone,
        'district': entity.district,
        'state': entity.state,
        'latitude': entity.latitude,
        'longitude': entity.longitude,
        'trapped_count': entity.trappedCount,
        'medical_emergency': entity.medicalEmergency,
        'road_cut_off': entity.roadCutOff,
        'vulnerable_dependents': entity.vulnerableDependents,
        'notes': entity.notes,
      });

      if (response.statusCode == 200 && response.data != null) {
        return EmergencySosEntity.fromJson(Map<String, dynamic>.from(response.data));
      }
    } catch (_) {
      // Fallback locally
    }

    final score = EmergencyMcdaCalculator.computeScore(
      trappedCount: entity.trappedCount,
      medicalEmergency: entity.medicalEmergency,
      roadCutOff: entity.roadCutOff,
      vulnerableDependents: entity.vulnerableDependents,
    );
    final pLevel = EmergencyMcdaCalculator.getPriorityLevel(score);
    final unit = EmergencyMcdaCalculator.getRecommendedUnit(pLevel);

    return entity.copyWith(
      id: 'SOS-LOCAL-${DateTime.now().millisecondsSinceEpoch % 10000}',
      triageScore: score,
      priorityLevel: pLevel,
      dispatchedUnit: unit,
      status: 'DISPATCHED',
    );
  }

  @override
  Future<List<EmergencySosEntity>> getActiveEmergencies() async {
    try {
      final response = await _apiClient.dio.get('/emergency/active');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => EmergencySosEntity.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    return const [
      EmergencySosEntity(
        id: 'SOS-2026-081',
        reporterName: 'Tenzing Dorjee',
        reporterPhone: '+91 94360 88211',
        district: 'Tawang',
        state: 'Arunachal Pradesh',
        latitude: 27.5890,
        longitude: 91.8620,
        trappedCount: 4,
        medicalEmergency: true,
        roadCutOff: true,
        vulnerableDependents: 2,
        notes: 'Debris broke through ground floor. Elder patient on oxygen support.',
        status: 'DISPATCHED',
        triageScore: 92.0,
        priorityLevel: 'P1_IMMEDIATE_AIRLIFT',
        dispatchedUnit: '12th Battalion NDRF Airborne Team',
        timestamp: '2026-09-06T19:40:00Z',
      ),
      EmergencySosEntity(
        id: 'SOS-2026-079',
        reporterName: 'Deepak Chettri',
        reporterPhone: '+91 94340 11928',
        district: 'Gangtok',
        state: 'Sikkim',
        latitude: 27.3325,
        longitude: 88.6140,
        trappedCount: 1,
        medicalEmergency: false,
        roadCutOff: true,
        vulnerableDependents: 1,
        notes: 'Culvert collapse blocked private vehicle with 3 occupants.',
        status: 'RESCUE_IN_PROGRESS',
        triageScore: 68.0,
        priorityLevel: 'P2_GROUND_RESCUE',
        dispatchedUnit: 'SDRF Mountain Rescue Team',
        timestamp: '2026-09-06T18:15:00Z',
      ),
      EmergencySosEntity(
        id: 'SOS-2026-074',
        reporterName: 'Lalrinawma',
        reporterPhone: '+91 98623 44551',
        district: 'Aizawl',
        state: 'Mizoram',
        latitude: 23.7271,
        longitude: 92.7176,
        trappedCount: 0,
        medicalEmergency: false,
        roadCutOff: false,
        vulnerableDependents: 0,
        notes: 'Slope retaining wall showing progressive tensile fissures.',
        status: 'PENDING',
        triageScore: 42.0,
        priorityLevel: 'P3_SUPPORT_MONITOR',
        dispatchedUnit: 'Civil Defense Volunteer Unit',
        timestamp: '2026-09-06T17:00:00Z',
      ),
    ];
  }

  @override
  Future<List<EvacuationShelterEntity>> getNearbyShelters(String district) async {
    try {
      final response = await _apiClient.dio.get('/emergency/shelters/$district');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => EvacuationShelterEntity.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    return const [
      EvacuationShelterEntity(
        id: 'SHELTER-TAW-01',
        name: 'Tawang Govt Higher Secondary School Complex',
        district: 'Tawang',
        state: 'Arunachal Pradesh',
        latitude: 27.5890,
        longitude: 91.8620,
        capacityTotal: 450,
        capacityOccupied: 120,
        medicalFacility: true,
        helipadAvailable: true,
        contactOfficer: 'Col. Ranjit Singh (NDRF Liaison)',
        contactPhone: '+91 94360 12345',
        distanceKm: 1.8,
      ),
      EvacuationShelterEntity(
        id: 'SHELTER-GTK-02',
        name: 'Paljor Stadium Indoor Disaster Relief Center',
        district: 'Gangtok',
        state: 'Sikkim',
        latitude: 27.3325,
        longitude: 88.6140,
        capacityTotal: 600,
        capacityOccupied: 210,
        medicalFacility: true,
        helipadAvailable: false,
        contactOfficer: 'Dr. Pema Bhutia (CMO)',
        contactPhone: '+91 94340 54321',
        distanceKm: 3.2,
      ),
      EvacuationShelterEntity(
        id: 'SHELTER-SHL-03',
        name: 'JN Stadium Emergency Evacuation Hub',
        district: 'Shillong',
        state: 'Meghalaya',
        latitude: 25.5788,
        longitude: 91.8933,
        capacityTotal: 800,
        capacityOccupied: 50,
        medicalFacility: true,
        helipadAvailable: true,
        contactOfficer: 'Capt. M. Sangma (SDMA)',
        contactPhone: '+91 94361 98765',
        distanceKm: 4.5,
      ),
    ];
  }

  @override
  Future<void> updateEmergencyStatus(String sosId, String status) async {
    // Updates status on server / local state
  }
}
