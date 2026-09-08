import 'package:flutter_test/flutter_test.dart';
import 'package:ner_landslideguard/core/services/firebase/fcm_messaging_service.dart';
import 'package:ner_landslideguard/core/services/firebase/firebase_storage_service.dart';
import 'package:ner_landslideguard/core/services/firebase/firestore_collections.dart';
import 'package:ner_landslideguard/core/services/firebase/firestore_database_service.dart';
import 'package:ner_landslideguard/features/reports/data/models/incident_report_model.dart';
import 'package:ner_landslideguard/features/reports/domain/entities/incident_report_entity.dart';

void main() {
  group('Firebase Services Unit Tests', () {
    test('FirestoreCollections & Paths generate valid URIs', () {
      expect(FirestoreCollections.users, 'users');
      expect(FirestoreCollections.incidentReports, 'incident_reports');
      expect(
        FirestoreCollections.userNotifications('usr_123'),
        'users/usr_123/notifications',
      );
      expect(
        FirebaseStoragePaths.incidentPhoto('REP_101', 'crack.jpg'),
        'incident_media/REP_101/crack.jpg',
      );
    });

    test('FcmTopics generates formatted topic strings', () {
      expect(FcmTopics.districtTopic('East Sikkim'), 'district_east_sikkim');
      expect(FcmTopics.districtTopic('Tawang'), 'district_tawang');
      expect(FcmTopics.criticalWarnings, 'ner_alerts_critical');
    });

    test('FirestoreDatabaseService saves, retrieves and updates incident reports', () async {
      final db = FirestoreDatabaseServiceImpl();

      final newReport = IncidentReportModel(
        id: 'LR-TEST-001',
        reporterId: 'usr_cit_01',
        reporterName: 'Tashi Norbu',
        reporterPhone: '+91 98765 43210',
        category: ReportCategory.landslide,
        severity: 'HIGH',
        description: 'Test active landslide near Tawang monastery',
        state: 'Arunachal Pradesh',
        district: 'Tawang',
        landmark: 'Near Tawang Gompa Gate 2',
        latitude: 27.5860,
        longitude: 91.8590,
        mediaUrls: const [],
        status: 'SUBMITTED',
        isOfflinePending: false,
        createdAt: '2026-09-06 20:00',
      );

      await db.saveIncidentReport(newReport);
      final retrieved = await db.getIncidentReport('LR-TEST-001');
      expect(retrieved, isNotNull);
      expect(retrieved!.district, 'Tawang');
      expect(retrieved.status, 'SUBMITTED');

      // Update status by field officer
      await db.updateIncidentReportStatus(
        reportId: 'LR-TEST-001',
        newStatus: 'VERIFIED',
        verifiedBy: 'Inspector Pemba Dorjee',
        resolutionNotes: 'Field team dispatched with geo-sensors',
      );

      final updated = await db.getIncidentReport('LR-TEST-001');
      expect(updated!.status, 'VERIFIED');
      expect(updated.description, contains('Inspector Pemba Dorjee'));

      db.dispose();
    });

    test('FirebaseStorageService simulates photo upload and generates valid URL', () async {
      final storage = FirebaseStorageServiceImpl();
      double lastProgress = 0;

      final result = await storage.uploadIncidentPhoto(
        reportId: 'REP_TEST_99',
        localFilePath: '/storage/emulated/0/DCIM/evidence_01.jpg',
        onProgress: (p) => lastProgress = p,
      );

      expect(lastProgress, 1.0);
      expect(result.downloadUrl, contains('REP_TEST_99'));
      expect(result.storagePath, 'incident_media/REP_TEST_99/evidence_01.jpg');
    });

    test('FcmMessagingService manages topic subscriptions', () async {
      final fcm = FcmMessagingServiceImpl();

      await fcm.subscribeToDistrict('Tawang');
      expect(fcm.subscribedTopics.contains('district_tawang'), isTrue);
      expect(fcm.subscribedTopics.contains(FcmTopics.criticalWarnings), isTrue);

      await fcm.subscribeToRoleAlerts('field_officer');
      expect(fcm.subscribedTopics.contains(FcmTopics.fieldOfficers), isTrue);

      fcm.dispose();
    });
  });
}
