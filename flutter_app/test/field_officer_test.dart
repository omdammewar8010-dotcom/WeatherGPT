import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ner_landslideguard/features/authentication/presentation/providers/auth_provider.dart';
import 'package:ner_landslideguard/features/field_officer/domain/entities/geotechnical_inspection_entity.dart';
import 'package:ner_landslideguard/features/field_officer/presentation/officer_dashboard_screen.dart';
import 'package:ner_landslideguard/features/field_officer/presentation/providers/field_officer_provider.dart';
import 'package:ner_landslideguard/features/field_officer/presentation/screens/officer_inspection_screen.dart';
import 'package:ner_landslideguard/features/reports/data/models/incident_report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Field Officer Console & Geotechnical Inspection Tests', () {
    test('GeotechnicalInspectionEntity serializes checklist properties', () {
      final inspection = GeotechnicalInspectionEntity(
        inspectionId: 'INSP-2026-9901',
        reportId: 'LR-2026-000123',
        inspectorId: 'off_01',
        inspectorName: 'Inspector Pemba Dorjee',
        inspectorBadge: 'IND-AR-0442',
        crackLengthMeters: 14.5,
        crackDepthCm: 42.0,
        slopeTiltMeasuredDeg: 4.2,
        seepageVisible: true,
        retainingWallDeformation: true,
        vegetationDisturbance: false,
        soilMoistureDirectReading: 85.0,
        geologicalFormationObserved: 'Fragile Schist',
        recommendedAction: 'Deploy Heavy Excavator',
        officerNotes: 'Active toe bulge detected',
        verificationStatus: 'VERIFIED',
        inspectedAt: DateTime.now(),
      );

      final json = inspection.toJson();
      expect(json['inspection_id'], 'INSP-2026-9901');
      expect(json['crack_length_meters'], 14.5);
      expect(json['slope_tilt_measured_deg'], 4.2);
      expect(json['seepage_visible'], isTrue);
      expect(json['verification_status'], 'VERIFIED');
    });

    test('FieldOfficerState calculates pending and verified counts accurately', () {
      final sampleReports = IncidentReportModel.sampleReports;
      final state = FieldOfficerState(assignedIncidents: sampleReports);

      expect(state.pendingCount >= 1, isTrue);
      expect(state.assignedIncidents.isNotEmpty, isTrue);
    });

    testWidgets('OfficerDashboardScreen renders metric counters and incident cards', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          ],
          child: const MaterialApp(
            home: OfficerDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Field Officer Console'), findsOneWidget);
      expect(find.text('Pending Verification'), findsOneWidget);
      expect(find.text('Field Verified'), findsOneWidget);
      expect(find.text('Resolved Cases'), findsOneWidget);
      expect(find.textContaining('Field Inspection'), findsWidgets);
    });

    testWidgets('OfficerInspectionScreen renders checklist inputs and submit action', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      final sample = IncidentReportModel.sampleReports.first;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          ],
          child: MaterialApp(
            home: OfficerInspectionScreen(incident: sample),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Geotechnical Inspection'), findsOneWidget);
      expect(find.text('1. Fissure & Crack Dimensions'), findsOneWidget);
      expect(find.text('2. Hydrogeological Observations'), findsOneWidget);
      expect(find.text('3. Geology & Recommended Action'), findsOneWidget);
      expect(find.text('SUBMIT INSPECTION & SIGN-OFF'), findsOneWidget);
    });
  });
}
