class EmergencySosEntity {
  final String id;
  final String reporterName;
  final String reporterPhone;
  final String district;
  final String state;
  final double latitude;
  final double longitude;
  final int trappedCount;
  final bool medicalEmergency;
  final bool roadCutOff;
  final int vulnerableDependents;
  final String notes;
  final String status; // "PENDING", "DISPATCHED", "RESCUE_IN_PROGRESS", "RESOLVED"
  final double triageScore; // 0 - 100
  final String priorityLevel; // "P1_IMMEDIATE_AIRLIFT", "P2_GROUND_RESCUE", "P3_SUPPORT_MONITOR"
  final String dispatchedUnit;
  final String timestamp;

  const EmergencySosEntity({
    required this.id,
    required this.reporterName,
    required this.reporterPhone,
    required this.district,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.trappedCount,
    required this.medicalEmergency,
    required this.roadCutOff,
    required this.vulnerableDependents,
    required this.notes,
    required this.status,
    required this.triageScore,
    required this.priorityLevel,
    required this.dispatchedUnit,
    required this.timestamp,
  });

  EmergencySosEntity copyWith({
    String? id,
    String? reporterName,
    String? reporterPhone,
    String? district,
    String? state,
    double? latitude,
    double? longitude,
    int? trappedCount,
    bool? medicalEmergency,
    bool? roadCutOff,
    int? vulnerableDependents,
    String? notes,
    String? status,
    double? triageScore,
    String? priorityLevel,
    String? dispatchedUnit,
    String? timestamp,
  }) {
    return EmergencySosEntity(
      id: id ?? this.id,
      reporterName: reporterName ?? this.reporterName,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      district: district ?? this.district,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      trappedCount: trappedCount ?? this.trappedCount,
      medicalEmergency: medicalEmergency ?? this.medicalEmergency,
      roadCutOff: roadCutOff ?? this.roadCutOff,
      vulnerableDependents: vulnerableDependents ?? this.vulnerableDependents,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      triageScore: triageScore ?? this.triageScore,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      dispatchedUnit: dispatchedUnit ?? this.dispatchedUnit,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reporter_name': reporterName,
        'reporter_phone': reporterPhone,
        'district': district,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'trapped_count': trappedCount,
        'medical_emergency': medicalEmergency,
        'road_cut_off': roadCutOff,
        'vulnerable_dependents': vulnerableDependents,
        'notes': notes,
        'status': status,
        'triage_score': triageScore,
        'priority_level': priorityLevel,
        'dispatched_unit': dispatchedUnit,
        'timestamp': timestamp,
      };

  factory EmergencySosEntity.fromJson(Map<String, dynamic> json) {
    return EmergencySosEntity(
      id: json['sos_id']?.toString() ?? json['id']?.toString() ?? 'SOS-TEMP',
      reporterName: json['reporter_name'] ?? 'Citizen',
      reporterPhone: json['reporter_phone'] ?? '',
      district: json['district'] ?? 'Tawang',
      state: json['state'] ?? 'Arunachal Pradesh',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 27.589,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 91.862,
      trappedCount: (json['trapped_count'] as num?)?.toInt() ?? 0,
      medicalEmergency: json['medical_emergency'] == true,
      roadCutOff: json['road_cut_off'] == true,
      vulnerableDependents: (json['vulnerable_dependents'] as num?)?.toInt() ?? 0,
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'PENDING',
      triageScore: (json['triage_score'] as num?)?.toDouble() ?? 50.0,
      priorityLevel: json['priority_level'] ?? 'P2_GROUND_RESCUE',
      dispatchedUnit: json['dispatched_unit'] ?? 'SDRF Quick Response Squad',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class EvacuationShelterEntity {
  final String id;
  final String name;
  final String district;
  final String state;
  final double latitude;
  final double longitude;
  final int capacityTotal;
  final int capacityOccupied;
  final bool medicalFacility;
  final bool helipadAvailable;
  final String contactOfficer;
  final String contactPhone;
  final double distanceKm;

  const EvacuationShelterEntity({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.capacityTotal,
    required this.capacityOccupied,
    required this.medicalFacility,
    required this.helipadAvailable,
    required this.contactOfficer,
    required this.contactPhone,
    this.distanceKm = 2.4,
  });

  double get occupancyRate =>
      capacityTotal == 0 ? 0.0 : (capacityOccupied / capacityTotal);

  factory EvacuationShelterEntity.fromJson(Map<String, dynamic> json) {
    return EvacuationShelterEntity(
      id: json['shelter_id'] ?? json['id'] ?? 'SHELTER-01',
      name: json['name'] ?? 'Evacuation Relief Camp',
      district: json['district'] ?? 'Tawang',
      state: json['state'] ?? 'Arunachal Pradesh',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 27.589,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 91.862,
      capacityTotal: (json['capacity_total'] as num?)?.toInt() ?? 500,
      capacityOccupied: (json['capacity_occupied'] as num?)?.toInt() ?? 100,
      medicalFacility: json['medical_facility'] == true,
      helipadAvailable: json['helipad_available'] == true,
      contactOfficer: json['contact_officer'] ?? 'NDRF Officer In-Charge',
      contactPhone: json['contact_phone'] ?? '+91 94360 00000',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 2.4,
    );
  }
}

class EmergencyMcdaCalculator {
  static double computeScore({
    required int trappedCount,
    required bool medicalEmergency,
    required bool roadCutOff,
    required int vulnerableDependents,
    String hazardSeverity = 'HIGH',
  }) {
    double base = 30.0;
    if (hazardSeverity.toUpperCase() == 'CRITICAL') base = 40.0;
    if (hazardSeverity.toUpperCase() == 'MODERATE') base = 20.0;

    final trappedWeight = (trappedCount * 8.0).clamp(0.0, 30.0);
    final medWeight = medicalEmergency ? 20.0 : 0.0;
    final roadWeight = roadCutOff ? 15.0 : 0.0;
    final vulnWeight = (vulnerableDependents * 4.0).clamp(0.0, 15.0);

    final total = (base + trappedWeight + medWeight + roadWeight + vulnWeight).clamp(0.0, 100.0);
    return double.parse(total.toStringAsFixed(1));
  }

  static String getPriorityLevel(double score) {
    if (score >= 75.0) return 'P1_IMMEDIATE_AIRLIFT';
    if (score >= 50.0) return 'P2_GROUND_RESCUE';
    return 'P3_SUPPORT_MONITOR';
  }

  static String getRecommendedUnit(String priorityLevel) {
    switch (priorityLevel) {
      case 'P1_IMMEDIATE_AIRLIFT':
        return '12th Battalion NDRF Airborne Squad (IAF Mi-17 V5 Helicopter Liaison)';
      case 'P2_GROUND_RESCUE':
        return 'SDRF Mountain Rescue Team & BRO Heavy Earthmover Unit';
      case 'P3_SUPPORT_MONITOR':
      default:
        return 'District Civil Defense & Red Cross Volunteer Contingent';
    }
  }

  static List<String> getUrgencyFactors({
    required int trappedCount,
    required bool medicalEmergency,
    required bool roadCutOff,
    required int vulnerableDependents,
  }) {
    final factors = <String>[];
    if (trappedCount > 0) {
      factors.add('$trappedCount individuals trapped under landslide debris');
    }
    if (medicalEmergency) {
      factors.add('Critical medical trauma or oxygen support needed');
    }
    if (roadCutOff) {
      factors.add('Arterial highway access completely severed');
    }
    if (vulnerableDependents > 0) {
      factors.add('$vulnerableDependents elderly / infant dependents in high-risk zone');
    }
    if (factors.isEmpty) {
      factors.add('Standard precautionary evacuation requested');
    }
    return factors;
  }
}
