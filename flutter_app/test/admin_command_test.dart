import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ner_landslideguard/features/admin_console/domain/entities/regional_analytics_entity.dart';
import 'package:ner_landslideguard/features/admin_console/domain/repositories/admin_command_repository.dart';
import 'package:ner_landslideguard/features/admin_console/presentation/providers/admin_command_provider.dart';
import 'package:ner_landslideguard/features/admin_console/presentation/admin_command_center_screen.dart';
import 'package:ner_landslideguard/features/admin_console/presentation/widgets/emergency_broadcast_dialog.dart';

class MockAdminCommandRepository implements AdminCommandRepository {
  bool broadcastDispatched = false;

  @override
  Future<RegionalCommandMetricsEntity> getRegionalCommandMetrics() async {
    return const RegionalCommandMetricsEntity(
      totalMonitoredZones: 1482,
      activeSensorsTotal: 340,
      activeCriticalAlerts: 2,
      activeOrangeWarnings: 3,
      blockedHighwaysTotal: 3,
      totalShelterCapacity: 1850,
      occupiedShelterBeds: 380,
      lastUpdatedTime: 'Test Telemetry',
      statesOverview: [
        StateRiskOverviewEntity(
          stateName: 'Arunachal Pradesh',
          keyDistrict: 'Tawang',
          compositeRiskScore: 88,
          severity: 'CRITICAL',
          activeSensorsCount: 78,
          blockedRoadsCount: 1,
          evacuationSheltersCount: 4,
          ndrfUnitsDeployed: 3,
          primaryThreatCorridor: 'NH-13 Sela Pass Corridor',
        ),
        StateRiskOverviewEntity(
          stateName: 'Sikkim',
          keyDistrict: 'Gangtok',
          compositeRiskScore: 74,
          severity: 'HIGH',
          activeSensorsCount: 64,
          blockedRoadsCount: 1,
          evacuationSheltersCount: 3,
          ndrfUnitsDeployed: 2,
          primaryThreatCorridor: 'NH-10 29th Mile',
        ),
      ],
    );
  }

  @override
  Future<void> dispatchEmergencyBroadcast({
    required String targetState,
    required String targetDistrict,
    required String alertTitle,
    required String severity,
    required String advisoryMessage,
    required bool activateSiren,
    required bool sendSmsFallback,
  }) async {
    broadcastDispatched = true;
  }
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 14: Disaster Authority Command Center Tests', () {
    test('RegionalCommandMetricsEntity computes shelter occupancy correctly', () {
      const entity = RegionalCommandMetricsEntity(
        totalMonitoredZones: 1000,
        activeSensorsTotal: 200,
        activeCriticalAlerts: 1,
        activeOrangeWarnings: 2,
        blockedHighwaysTotal: 1,
        totalShelterCapacity: 1000,
        occupiedShelterBeds: 250,
        lastUpdatedTime: 'Now',
        statesOverview: [],
      );

      expect(entity.shelterOccupancyRate, 0.25);
    });

    test('StateRiskOverviewEntity serializes to JSON correctly', () {
      const stateOverview = StateRiskOverviewEntity(
        stateName: 'Arunachal Pradesh',
        keyDistrict: 'Tawang',
        compositeRiskScore: 88,
        severity: 'CRITICAL',
        activeSensorsCount: 78,
        blockedRoadsCount: 1,
        evacuationSheltersCount: 4,
        ndrfUnitsDeployed: 3,
        primaryThreatCorridor: 'NH-13 Sela Pass',
      );

      final json = stateOverview.toJson();
      expect(json['state_name'], 'Arunachal Pradesh');
      expect(json['composite_risk_score'], 88);
      expect(json['severity'], 'CRITICAL');
      expect(json['ndrf_units_deployed'], 3);
    });

    test('AdminCommandNotifier loads metrics and filters states', () async {
      final mockRepo = MockAdminCommandRepository();
      final notifier = AdminCommandNotifier(mockRepo);

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.state.metrics, isNotNull);
      expect(notifier.state.filteredStates.length, 2);

      // Test state filtering
      notifier.setStateFilter('Sikkim');
      expect(notifier.state.filteredStates.length, 1);
      expect(notifier.state.filteredStates.first.stateName, 'Sikkim');

      // Test reset filter
      notifier.setStateFilter('ALL');
      expect(notifier.state.filteredStates.length, 2);
    });

    test('AdminCommandNotifier executes emergency broadcast dispatch', () async {
      final mockRepo = MockAdminCommandRepository();
      final notifier = AdminCommandNotifier(mockRepo);

      final success = await notifier.broadcastEmergencyRedAlert(
        targetState: 'Arunachal Pradesh',
        targetDistrict: 'Tawang',
        alertTitle: 'RED ALERT TEST',
        severity: 'CRITICAL',
        advisoryMessage: 'Evacuate now',
        activateSiren: true,
        sendSmsFallback: true,
      );

      expect(success, isTrue);
      expect(mockRepo.broadcastDispatched, isTrue);
    });

    testWidgets('AdminCommandCenterScreen renders Macro KPI Grid and Regional Matrix',
        (WidgetTester tester) async {
      final mockRepo = MockAdminCommandRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminCommandRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: AdminCommandCenterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check title and regional matrix
      expect(find.text('Disaster Authority Command Center'), findsOneWidget);
      expect(find.text('8-State Regional Hazard Matrix'), findsOneWidget);
      expect(find.text('Hazard Sectors Monitored'), findsOneWidget);
      expect(find.text('Critical Red Warnings'), findsOneWidget);
      expect(find.text('Arunachal Pradesh'), findsOneWidget);
      expect(find.text('Sikkim'), findsOneWidget);
      expect(find.text('DISPATCH RED ALERT'), findsOneWidget);
    });

    testWidgets('EmergencyBroadcastDialog renders form controls and triggers broadcast',
        (WidgetTester tester) async {
      final mockRepo = MockAdminCommandRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminCommandRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EmergencyBroadcastDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Emergency Broadcast Station'), findsOneWidget);
      expect(find.text('Target NER State'), findsOneWidget);
      expect(find.text('DISPATCH REGIONAL RED ALERT'), findsOneWidget);

      // Tap broadcast button
      final broadcastBtn = find.text('DISPATCH REGIONAL RED ALERT');
      await tester.ensureVisible(broadcastBtn);
      await tester.tap(broadcastBtn);
      await tester.pumpAndSettle();

      expect(mockRepo.broadcastDispatched, isTrue);
    });
  });
}
