import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'background_sync_service.dart';
import 'connectivity_service.dart';
import 'sync_queue_manager.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityServiceImpl();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final networkStatusStreamProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

final syncQueueManagerProvider = Provider<SyncQueueManager>((ref) {
  return SyncQueueManagerImpl();
});

final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  final queue = ref.watch(syncQueueManagerProvider);
  final syncService = BackgroundSyncServiceImpl(
    connectivity: connectivity,
    queueManager: queue,
  );
  ref.onDispose(() {
    syncService.dispose();
  });
  return syncService;
});

final syncProgressStreamProvider = StreamProvider<SyncProgress>((ref) {
  final service = ref.watch(backgroundSyncServiceProvider);
  return service.progressStream;
});
