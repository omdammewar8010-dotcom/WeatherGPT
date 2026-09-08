class RoadCorridorEntity {
  final String corridorId;
  final String highwayName;
  final String section;
  final String district;
  final String state;
  final String status; // "CLEAR", "VULNERABLE", "PARTIALLY_BLOCKED", "TOTAL_BLOCKAGE"
  final String? blockageCause;
  final int clearingProgressPct;
  final int? estimatedReopeningHours;
  final String? alternateDetour;
  final String lastReported;

  const RoadCorridorEntity({
    required this.corridorId,
    required this.highwayName,
    required this.section,
    required this.district,
    required this.state,
    required this.status,
    this.blockageCause,
    required this.clearingProgressPct,
    this.estimatedReopeningHours,
    this.alternateDetour,
    required this.lastReported,
  });

  bool get isBlocked => status == 'TOTAL_BLOCKAGE' || status == 'PARTIALLY_BLOCKED';

  factory RoadCorridorEntity.fromJson(Map<String, dynamic> json) {
    return RoadCorridorEntity(
      corridorId: json['corridor_id'] ?? 'ROAD-01',
      highwayName: json['highway_name'] ?? 'National Highway',
      section: json['section'] ?? 'Main Corridor',
      district: json['district'] ?? 'Tawang',
      state: json['state'] ?? 'Arunachal Pradesh',
      status: json['status'] ?? 'CLEAR',
      blockageCause: json['blockage_cause'],
      clearingProgressPct: (json['clearing_progress_pct'] as num?)?.toInt() ?? 0,
      estimatedReopeningHours: (json['estimated_reopening_hours'] as num?)?.toInt(),
      alternateDetour: json['alternate_detour'],
      lastReported: json['last_reported'] ?? 'Recently',
    );
  }

  Map<String, dynamic> toJson() => {
        'corridor_id': corridorId,
        'highway_name': highwayName,
        'section': section,
        'district': district,
        'state': state,
        'status': status,
        'blockage_cause': blockageCause,
        'clearing_progress_pct': clearingProgressPct,
        'estimated_reopening_hours': estimatedReopeningHours,
        'alternate_detour': alternateDetour,
        'last_reported': lastReported,
      };
}

class HistoricalLandslideEventEntity {
  final String eventId;
  final String locationName;
  final String district;
  final String state;
  final int year;
  final String month;
  final String triggerMechanism;
  final int debrisVolumeM3;
  final int fatalitiesCount;
  final String highwaySevered;
  final int restorationDays;
  final String geotechnicalSummary;

  const HistoricalLandslideEventEntity({
    required this.eventId,
    required this.locationName,
    required this.district,
    required this.state,
    required this.year,
    required this.month,
    required this.triggerMechanism,
    required this.debrisVolumeM3,
    required this.fatalitiesCount,
    required this.highwaySevered,
    required this.restorationDays,
    required this.geotechnicalSummary,
  });

  factory HistoricalLandslideEventEntity.fromJson(Map<String, dynamic> json) {
    return HistoricalLandslideEventEntity(
      eventId: json['event_id'] ?? 'HIST-01',
      locationName: json['location_name'] ?? 'Landslide Location',
      district: json['district'] ?? 'Tawang',
      state: json['state'] ?? 'Arunachal Pradesh',
      year: (json['year'] as num?)?.toInt() ?? 2024,
      month: json['month'] ?? 'July',
      triggerMechanism: json['trigger_mechanism'] ?? 'Monsoon Rain',
      debrisVolumeM3: (json['debris_volume_m3'] as num?)?.toInt() ?? 0,
      fatalitiesCount: (json['fatalities_count'] as num?)?.toInt() ?? 0,
      highwaySevered: json['highway_severed'] ?? 'Main Road',
      restorationDays: (json['restoration_days'] as num?)?.toInt() ?? 1,
      geotechnicalSummary: json['geotechnical_summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'location_name': locationName,
        'district': district,
        'state': state,
        'year': year,
        'month': month,
        'trigger_mechanism': triggerMechanism,
        'debris_volume_m3': debrisVolumeM3,
        'fatalities_count': fatalitiesCount,
        'highway_severed': highwaySevered,
        'restoration_days': restorationDays,
        'geotechnical_summary': geotechnicalSummary,
      };
}
