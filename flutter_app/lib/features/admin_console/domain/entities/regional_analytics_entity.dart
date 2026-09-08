class StateRiskOverviewEntity {
  final String stateName;
  final String keyDistrict;
  final int compositeRiskScore;
  final String severity; // "CRITICAL", "HIGH", "MODERATE", "LOW"
  final int activeSensorsCount;
  final int blockedRoadsCount;
  final int evacuationSheltersCount;
  final int ndrfUnitsDeployed;
  final String primaryThreatCorridor;

  const StateRiskOverviewEntity({
    required this.stateName,
    required this.keyDistrict,
    required this.compositeRiskScore,
    required this.severity,
    required this.activeSensorsCount,
    required this.blockedRoadsCount,
    required this.evacuationSheltersCount,
    required this.ndrfUnitsDeployed,
    required this.primaryThreatCorridor,
  });

  Map<String, dynamic> toJson() => {
        'state_name': stateName,
        'key_district': keyDistrict,
        'composite_risk_score': compositeRiskScore,
        'severity': severity,
        'active_sensors_count': activeSensorsCount,
        'blocked_roads_count': blockedRoadsCount,
        'evacuation_shelters_count': evacuationSheltersCount,
        'ndrf_units_deployed': ndrfUnitsDeployed,
        'primary_threat_corridor': primaryThreatCorridor,
      };
}

class RegionalCommandMetricsEntity {
  final int totalMonitoredZones;
  final int activeSensorsTotal;
  final int activeCriticalAlerts;
  final int activeOrangeWarnings;
  final int blockedHighwaysTotal;
  final int totalShelterCapacity;
  final int occupiedShelterBeds;
  final List<StateRiskOverviewEntity> statesOverview;
  final String lastUpdatedTime;

  const RegionalCommandMetricsEntity({
    required this.totalMonitoredZones,
    required this.activeSensorsTotal,
    required this.activeCriticalAlerts,
    required this.activeOrangeWarnings,
    required this.blockedHighwaysTotal,
    required this.totalShelterCapacity,
    required this.occupiedShelterBeds,
    required this.statesOverview,
    required this.lastUpdatedTime,
  });

  double get shelterOccupancyRate =>
      totalShelterCapacity == 0 ? 0.0 : (occupiedShelterBeds / totalShelterCapacity);
}
