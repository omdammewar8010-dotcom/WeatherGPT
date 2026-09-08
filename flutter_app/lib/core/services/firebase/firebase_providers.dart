import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fcm_messaging_service.dart';
import 'firebase_storage_service.dart';
import 'firestore_database_service.dart';

/// Provider for FirestoreDatabaseService singleton
final firestoreDatabaseServiceProvider = Provider<FirestoreDatabaseService>((ref) {
  final service = FirestoreDatabaseServiceImpl();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Provider for FirebaseStorageService
final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageServiceImpl();
});

/// Provider for FcmMessagingService
final fcmMessagingServiceProvider = Provider<FcmMessagingService>((ref) {
  final service = FcmMessagingServiceImpl();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Stream provider for live Firestore incident reports
final liveIncidentReportsStreamProvider = StreamProvider.family<List<dynamic>, String?>((ref, district) {
  final firestore = ref.watch(firestoreDatabaseServiceProvider);
  return firestore.streamIncidentReports(district: district);
});

/// Stream provider for active early warnings
final activeEarlyWarningsStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String?>((ref, district) {
  final firestore = ref.watch(firestoreDatabaseServiceProvider);
  return firestore.streamActiveWarnings(district: district);
});
