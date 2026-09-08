import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ner_landslideguard/features/emergency/domain/entities/emergency_sos_entity.dart';
import 'package:ner_landslideguard/features/emergency/domain/repositories/emergency_repository.dart';
import 'package:ner_landslideguard/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:ner_landslideguard/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:ner_landslideguard/features/emergency/presentation/widgets/sos_trigger_modal.dart';

class MockEmergencyRepository implements EmergencyRepository {
  bool sosTriggered = false;
  String? updatedStatus;

  @override
  Future<EmergencySosEntity> triggerSos(EmergencySosEntity entity) async {
    sosTriggered = true;
    return entity.copyWith(
      id: 'SOS-TEST-999',
      status: 'DISPATCHED',
    );
  }

  @override
  Future<List<EmergencySosEntity>> getActiveEmergencies() async {
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
        notes: 'Debris broke through ground floor.',
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
        notes: 'Culvert collapse blocked vehicle.',
        status: 'RESCUE_IN_PROGRESS',
        triageScore: 68.0,
        priorityLevel: 'P2_GROUND_RESCUE',
        dispatchedUnit: 'SDRF Mountain Rescue Team',
        timestamp: '2026-09-06T18:15:00Z',
      ),
    ];
  }

  @override
  Future<List<EvacuationShelterEntity>> getNearbyShelters(String district) async {
    return const [
      EvacuationShelterEntity(
        id: 'SHELTER-TAW-01',
        name: 'Tawang Govt Higher Secondary School Complex',
        district: 'Tawang',
        state: 'Arunachal Pradesh',
        latitude: 27.5890,
        longitude: 91.8620,
        capacityTotal: 400,
        capacityOccupied: 100,
        medicalFacility: true,
        helipadAvailable: true,
        contactOfficer: 'Col. Ranjit Singh',
        contactPhone: '+91 94360 12345',
        distanceKm: 1.8,
      ),
    ];
  }

  @override
  Future<void> updateEmergencyStatus(String sosId, String status) async {
    updatedStatus = status;
  }
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 15: MCDA Emergency Prioritizer & SOS Tests', () {
    test('EmergencyMcdaCalculator correctly computes high-priority P1 airlift score', () {
      final score = EmergencyMcdaCalculator.computeScore(
        trappedCount: 4,
        medicalEmergency: true,
        roadCutOff: true,
        vulnerableDependents: 2,
        hazardSeverity: 'CRITICAL',
      );

      expect(score, greaterThanOrEqualTo(80.0));
      final priority = EmergencyMcdaCalculator.getPriorityLevel(score);
      expect(priority, 'P1_IMMEDIATE_AIRLIFT');

      final unit = EmergencyMcdaCalculator.getRecommendedUnit(priority);
      expect(unit, contains('NDRF'));

      final factors = EmergencyMcdaCalculator.getUrgencyFactors(
        trappedCount: 4,
        medicalEmergency: true,
        roadCutOff: true,
        vulnerableDependents: 2,
      );
      expect(factors.length, 4);
      expect(factors[0], contains('4 individuals trapped'));
    });

    test('EmergencyMcdaCalculator computes low-priority P3 score', () {
      final score = EmergencyMcdaCalculator.computeScore(
        trappedCount: 0,
        medicalEmergency: false,
        roadCutOff: false,
        vulnerableDependents: 0,
        hazardSeverity: 'MODERATE',
      );

      expect(score, lessThan(50.0));
      final priority = EmergencyMcdaCalculator.getPriorityLevel(score);
      expect(priority, 'P3_SUPPORT_MONITOR');
    });

    test('EvacuationShelterEntity occupancy rate computation', () {
      const shelter = EvacuationShelterEntity(
        id: 'S1',
        name: 'Relief Camp',
        district: 'Tawang',
        state: 'Arunachal Pradesh',
        latitude: 27.58,
        longitude: 91.86,
        capacityTotal: 500,
        capacityOccupied: 250,
        medicalFacility: true,
        helipadAvailable: true,
        contactOfficer: 'Officer',
        contactPhone: '+91 000',
      );

      expect(shelter.occupancyRate, 0.5);
    });

    test('EmergencyNotifier loads emergencies, computes filters, and submits SOS', () async {
      final mockRepo = MockEmergencyRepository();
      final notifier = EmergencyNotifier(mockRepo);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.state.emergencies.length, 2);
      expect(notifier.state.shelters.length, 1);
      expect(notifier.state.p1Count, 1);
      expect(notifier.state.p2Count, 1);

      // Filter P1
      notifier.setPriorityFilter('P1');
      expect(notifier.state.sortedAndFilteredEmergencies.length, 1);
      expect(notifier.state.sortedAndFilteredEmergencies.first.priorityLevel, 'P1_IMMEDIATE_AIRLIFT');

      // Submit citizen SOS
      final sos = await notifier.submitCitizenSos(
        reporterName: 'Test Citizen',
        reporterPhone: '+91 99999 99999',
        district: 'Tawang',
        stateName: 'Arunachal Pradesh',
        latitude: 27.58,
        longitude: 91.86,
        trappedCount: 2,
        medicalEmergency: true,
        roadCutOff: true,
        vulnerableDependents: 1,
        notes: 'Immediate rescue requested',
      );

      expect(sos, isNotNull);
      expect(mockRepo.sosTriggered, isTrue);
      expect(notifier.state.activeUserSos, isNotNull);

      // Update status
      notifier.updateIncidentStatus(sos!.id, 'RESCUE_IN_PROGRESS');
      expect(notifier.state.activeUserSos?.status, 'RESCUE_IN_PROGRESS');
    });

    testWidgets('EmergencyScreen renders Citizen SOS, Helplines, and Tabs',
        (WidgetTester tester) async {
      final mockRepo = MockEmergencyRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            emergencyRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: EmergencyScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check header and tabs
      expect(find.text('Emergency SOS & MCDA Triage'), findsOneWidget);
      expect(find.text('CITIZEN SOS'), findsOneWidget);
      expect(find.text('TAP FOR SOS'), findsOneWidget);
      expect(find.text('NDRF National Disaster Helpline'), findsOneWidget);

      // Switch to MCDA Triage tab
      await tester.tap(find.textContaining('MCDA TRIAGE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('P1 AIRLIFT'), findsOneWidget);
      expect(find.textContaining('Tenzing Dorjee'), findsOneWidget);

      // Switch to Shelters tab
      await tester.tap(find.textContaining('SHELTERS'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Designated Relief Camps & Helipads'), findsOneWidget);
      expect(find.text('Tawang Govt Higher Secondary School Complex'), findsOneWidget);
    });

    testWidgets('SosTriggerModal allows selecting criteria and submitting distress signal',
        (WidgetTester tester) async {
      final mockRepo = MockEmergencyRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            emergencyRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SosTriggerModal(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Emergency SOS Distress Dispatch'), findsOneWidget);
      expect(find.text('CALCULATED MCDA PRIORITY'), findsOneWidget);

      // Tap Increment trapped count
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();

      // Scroll and Tap transmit button
      final transmitBtn = find.text('TRANSMIT RESCUE SOS NOW');
      await tester.ensureVisible(transmitBtn);
      await tester.tap(transmitBtn);
      await tester.pumpAndSettle();

      expect(mockRepo.sosTriggered, isTrue);
    });
  });
}
