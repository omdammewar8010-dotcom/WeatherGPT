import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ner_landslideguard/features/alerts/data/models/early_warning_model.dart';
import 'package:ner_landslideguard/features/alerts/presentation/providers/alert_provider.dart';
import 'package:ner_landslideguard/features/alerts/presentation/screens/alert_center_screen.dart';

void main() {
  group('Alert Center & Notification Unit Tests', () {
    test('sampleWarnings contains verified critical early warnings for NER', () {
      final warnings = EarlyWarningModel.sampleWarnings;
      expect(warnings.isNotEmpty, isTrue);

      final redAlert = warnings.firstWhere((w) => w.severity == 'CRITICAL');
      expect(redAlert.district, 'Tawang');
      expect(redAlert.riskScore, 88);
      expect(redAlert.affectedSectors.contains('Sela Pass Ridge'), isTrue);
      expect(redAlert.evacuationRoute, contains('NH-13'));
    });

    test('AlertState filters by severity correctly', () {
      final sample = EarlyWarningModel.sampleWarnings;
      var state = AlertState(warnings: sample, selectedSeverityFilter: 'ALL');
      expect(state.filteredWarnings.length, sample.length);

      state = state.copyWith(selectedSeverityFilter: 'CRITICAL');
      expect(state.filteredWarnings.every((w) => w.severity == 'CRITICAL'), isTrue);
      expect(state.criticalCount, 2);

      state = state.copyWith(selectedSeverityFilter: 'HIGH');
      expect(state.filteredWarnings.every((w) => w.severity == 'HIGH'), isTrue);
      expect(state.highCount, 1);
    });

    testWidgets('AlertCenterScreen renders banner, filter chips and warning cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AlertCenterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header and Siren Banner
      expect(find.text('Emergency Alert Center'), findsOneWidget);
      expect(find.text('TEST SIREN'), findsOneWidget);

      // Verify Filter Chips
      expect(find.textContaining('All ('), findsOneWidget);
      expect(find.textContaining('🔴 Red ('), findsOneWidget);

      // Verify Warning Card Elements
      expect(find.textContaining('RED ALERT'), findsWidgets);
      expect(find.textContaining('Sela Pass'), findsWidgets);
      expect(find.text('View on Map'), findsWidgets);
      expect(find.text('Broadcast Alert'), findsWidgets);

      // Test toggle siren
      await tester.tap(find.text('TEST SIREN'));
      await tester.pumpAndSettle();
      expect(find.text('MUTE'), findsOneWidget);
    });
  });
}
