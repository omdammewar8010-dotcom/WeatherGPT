import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ner_landslideguard/features/roads_overwatch/domain/entities/road_corridor_entity.dart';
import 'package:ner_landslideguard/features/roads_overwatch/domain/repositories/roads_repository.dart';
import 'package:ner_landslideguard/features/roads_overwatch/presentation/providers/roads_provider.dart';
import 'package:ner_landslideguard/features/roads_overwatch/presentation/screens/road_overwatch_screen.dart';
import 'package:ner_landslideguard/features/roads_overwatch/presentation/widgets/report_road_blockage_dialog.dart';

class MockRoadsRepository implements RoadsRepository {
  bool blockageReported = false;

  @override
  Future<List<RoadCorridorEntity>> getRoadCorridors() async {
    return const [
      RoadCorridorEntity(
        corridorId: 'ROAD-NH13-01',
        highwayName: 'NH-13 (Trans-Arunachal Highway)',
        section: 'Sela Pass to Tawang KM 44',
        district: 'Tawang',
        state: 'Arunachal Pradesh',
        status: 'TOTAL_BLOCKAGE',
        blockageCause: 'Debris Avalanche & Large Granite Boulders',
        clearingProgressPct: 35,
        estimatedReopeningHours: 14,
        alternateDetour: 'Dirang - Lumla Old Military Track',
        lastReported: '15 mins ago',
      ),
      RoadCorridorEntity(
        corridorId: 'ROAD-NH10-02',
        highwayName: 'NH-10 (Siliguri - Gangtok Lifeline)',
        section: '29th Mile Seti Jhora',
        district: 'Gangtok',
        state: 'Sikkim',
        status: 'PARTIALLY_BLOCKED',
        blockageCause: 'Mudslide and single-lane debris',
        clearingProgressPct: 70,
        estimatedReopeningHours: 4,
        alternateDetour: 'Melli - Jorethang route',
        lastReported: '30 mins ago',
      ),
      RoadCorridorEntity(
        corridorId: 'ROAD-NH54-04',
        highwayName: 'NH-54 (Silchar - Aizawl Arterial)',
        section: 'Kolasib - Sairang Hillside Cut',
        district: 'Aizawl',
        state: 'Mizoram',
        status: 'CLEAR',
        blockageCause: null,
        clearingProgressPct: 100,
        estimatedReopeningHours: 0,
        alternateDetour: null,
        lastReported: '2 hours ago',
      ),
    ];
  }

  @override
  Future<List<HistoricalLandslideEventEntity>> getHistoricalLandslides({
    int? year,
    String? state,
  }) async {
    return const [
      HistoricalLandslideEventEntity(
        eventId: 'GSI-HIST-2024-01',
        locationName: 'Sela Pass North Zig-Zag Slope',
        district: 'Tawang',
        state: 'Arunachal Pradesh',
        year: 2024,
        month: 'July',
        triggerMechanism: 'Monsoon Cloudburst (280mm / 48h)',
        debrisVolumeM3: 45000,
        fatalitiesCount: 0,
        highwaySevered: 'NH-13 Trans-Arunachal Highway',
        restorationDays: 8,
        geotechnicalSummary: 'Planar failure in granite gneiss.',
      ),
      HistoricalLandslideEventEntity(
        eventId: 'GSI-HIST-2023-04',
        locationName: '29th Mile Seti Jhora Scour',
        district: 'Gangtok',
        state: 'Sikkim',
        year: 2023,
        month: 'October',
        triggerMechanism: 'GLOF Surge & Teesta River Toe Erosion',
        debrisVolumeM3: 38000,
        fatalitiesCount: 3,
        highwaySevered: 'NH-10 Siliguri-Gangtok Lifeline',
        restorationDays: 14,
        geotechnicalSummary: 'Hydrodynamic toe erosion washed away crib walls.',
      ),
    ];
  }

  @override
  Future<RoadCorridorEntity> reportRoadBlockage(RoadCorridorEntity report) async {
    blockageReported = true;
    return report.copyWith();
  }
}

extension on RoadCorridorEntity {
  RoadCorridorEntity copyWith() {
    return RoadCorridorEntity(
      corridorId: corridorId,
      highwayName: highwayName,
      section: section,
      district: district,
      state: state,
      status: status,
      blockageCause: blockageCause,
      clearingProgressPct: clearingProgressPct,
      estimatedReopeningHours: estimatedReopeningHours,
      alternateDetour: alternateDetour,
      lastReported: lastReported,
    );
  }
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 17: Historical Landslide Catalog & Road Overwatch Tests', () {
    test('RoadCorridorEntity isBlocked and JSON serialization', () {
      const blocked = RoadCorridorEntity(
        corridorId: 'ROAD-1',
        highwayName: 'NH-13',
        section: 'KM 10',
        district: 'Tawang',
        state: 'Arunachal Pradesh',
        status: 'TOTAL_BLOCKAGE',
        clearingProgressPct: 20,
        lastReported: 'Now',
      );

      const clear = RoadCorridorEntity(
        corridorId: 'ROAD-2',
        highwayName: 'NH-54',
        section: 'KM 20',
        district: 'Aizawl',
        state: 'Mizoram',
        status: 'CLEAR',
        clearingProgressPct: 100,
        lastReported: 'Now',
      );

      expect(blocked.isBlocked, isTrue);
      expect(clear.isBlocked, isFalse);

      final json = blocked.toJson();
      expect(json['highway_name'], 'NH-13');
      expect(json['status'], 'TOTAL_BLOCKAGE');
    });

    test('HistoricalLandslideEventEntity parsing and JSON mapping', () {
      final json = {
        'event_id': 'GSI-HIST-2024-01',
        'location_name': 'Sela Pass',
        'district': 'Tawang',
        'state': 'Arunachal Pradesh',
        'year': 2024,
        'month': 'July',
        'trigger_mechanism': 'Cloudburst',
        'debris_volume_m3': 45000,
        'fatalities_count': 0,
        'highway_severed': 'NH-13',
        'restoration_days': 8,
        'geotechnical_summary': 'Planar failure',
      };

      final entity = HistoricalLandslideEventEntity.fromJson(json);
      expect(entity.eventId, 'GSI-HIST-2024-01');
      expect(entity.year, 2024);
      expect(entity.debrisVolumeM3, 45000);
      expect(entity.restorationDays, 8);
    });

    test('RoadsNotifier loads corridors, filters, and reports blockage', () async {
      final mockRepo = MockRoadsRepository();
      final notifier = RoadsNotifier(mockRepo);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.state.corridors.length, 3);
      expect(notifier.state.historicalEvents.length, 2);
      expect(notifier.state.blockedCorridorsCount, 2);
      expect(notifier.state.clearCorridorsCount, 1);

      // Status filter
      notifier.setStatusFilter('BLOCKED');
      expect(notifier.state.filteredCorridors.length, 2);

      notifier.setStatusFilter('CLEAR');
      expect(notifier.state.filteredCorridors.length, 1);

      notifier.setStatusFilter('ALL');

      // State filter
      notifier.setStateFilter('Sikkim');
      expect(notifier.state.filteredCorridors.length, 1);
      expect(notifier.state.filteredCorridors.first.state, 'Sikkim');

      notifier.setStateFilter('ALL');

      // Search Query
      notifier.setSearchQuery('Sela');
      expect(notifier.state.filteredCorridors.length, 1);
      expect(notifier.state.filteredCorridors.first.section, contains('Sela Pass'));

      notifier.setSearchQuery('');

      // Year filter for historical events
      notifier.setYearFilter(2024);
      expect(notifier.state.filteredHistoricalEvents.length, 1);
      expect(notifier.state.filteredHistoricalEvents.first.year, 2024);

      // Report Blockage
      final success = await notifier.reportBlockage(
        highwayName: 'NH-13',
        section: 'KM 50',
        district: 'Tawang',
        stateName: 'Arunachal Pradesh',
        status: 'TOTAL_BLOCKAGE',
        cause: 'Granite boulder slip',
      );
      expect(success, isTrue);
      expect(mockRepo.blockageReported, isTrue);
    });

    testWidgets('RoadOverwatchScreen renders corridors, tab switching, and filters',
        (WidgetTester tester) async {
      final mockRepo = MockRoadsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            roadsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: RoadOverwatchScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header and tabs
      expect(find.text('Highway Overwatch & Historical Catalog'), findsOneWidget);
      expect(find.textContaining('HIGHWAY CORRIDORS'), findsOneWidget);
      expect(find.textContaining('GSI ARCHIVE'), findsOneWidget);
      expect(find.text('REPORT BLOCKAGE'), findsOneWidget);

      // Check rendered highway cards
      expect(find.text('NH-13 (Trans-Arunachal Highway)'), findsOneWidget);
      expect(find.text('NH-10 (Siliguri - Gangtok Lifeline)'), findsOneWidget);

      // Switch to GSI Archive tab
      await tester.tap(find.textContaining('GSI ARCHIVE'));
      await tester.pumpAndSettle();

      expect(find.text('Sela Pass North Zig-Zag Slope'), findsOneWidget);
      expect(find.text('29th Mile Seti Jhora Scour'), findsOneWidget);
      expect(find.text('Debris Volume'), findsWidgets);
    });

    testWidgets('ReportRoadBlockageDialog allows submitting blockage reports',
        (WidgetTester tester) async {
      final mockRepo = MockRoadsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            roadsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ReportRoadBlockageDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Report Road / Highway Blockage'), findsOneWidget);
      expect(find.text('SUBMIT ROAD OVERWATCH REPORT'), findsOneWidget);

      // Tap submit button
      final submitBtn = find.text('SUBMIT ROAD OVERWATCH REPORT');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(mockRepo.blockageReported, isTrue);
    });
  });
}
