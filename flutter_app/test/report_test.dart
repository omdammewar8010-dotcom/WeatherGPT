import 'package:flutter_test/flutter_test.dart';
import 'package:ner_landslideguard/features/reports/data/models/incident_report_model.dart';
import 'package:ner_landslideguard/features/reports/domain/entities/incident_report_entity.dart';

void main() {
  group('Citizen Incident Reporting Unit Tests', () {
    test('sampleReports contains geo-tagged reports and AI vision findings', () {
      final reports = IncidentReportModel.sampleReports;
      expect(reports.isNotEmpty, isTrue);

      final first = reports.first;
      expect(first.id, 'LR-2026-000123');
      expect(first.category, ReportCategory.landslide);
      expect(first.severity, 'CRITICAL');
      expect(first.aiAnalysis, isNotNull);
      expect(first.aiAnalysis!.crackDetected, isTrue);
      expect(first.aiAnalysis!.debrisDetected, isTrue);
      expect(first.aiAnalysis!.roadObstructionDetected, isTrue);
    });

    test('ReportCategory.fromString maps all 6 hazard categories correctly', () {
      expect(ReportCategory.fromString('landslide'), ReportCategory.landslide);
      expect(ReportCategory.fromString('ground_crack'), ReportCategory.groundCrack);
      expect(ReportCategory.fromString('rockfall'), ReportCategory.rockfall);
      expect(ReportCategory.fromString('road_blockage'), ReportCategory.roadBlockage);
      expect(ReportCategory.fromString('soil_erosion'), ReportCategory.soilErosion);
      expect(ReportCategory.fromString('other'), ReportCategory.other);
      expect(ReportCategory.fromString(null), ReportCategory.landslide);
    });
  });
}
