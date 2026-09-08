import 'package:flutter_test/flutter_test.dart';
import 'package:ner_landslideguard/core/services/sync/background_sync_service.dart';
import 'package:ner_landslideguard/core/services/sync/connectivity_service.dart';
import 'package:ner_landslideguard/core/services/sync/retry_backoff_strategy.dart';
import 'package:ner_landslideguard/core/services/sync/sync_queue_manager.dart';

void main() {
  group('Offline Auto-Sync & Background Sync Engine Tests', () {
    test('ConnectivityService toggles status and emits on stream', () async {
      final conn = ConnectivityServiceImpl(initialStatus: NetworkStatus.online);
      expect(conn.currentStatus.isConnected, isTrue);

      conn.simulateNetworkStatus(NetworkStatus.offline);
      expect(conn.currentStatus, NetworkStatus.offline);
      expect(conn.currentStatus.isConnected, isFalse);

      conn.toggleOfflineMode();
      expect(conn.currentStatus, NetworkStatus.online);

      conn.dispose();
    });

    test('RetryBackoffStrategy calculates bounded delay with jitter', () {
      const backoff = RetryBackoffStrategy(
        baseDelay: Duration(seconds: 2),
        maxDelay: Duration(seconds: 30),
      );

      expect(backoff.calculateDelay(0), Duration.zero);

      final delay1 = backoff.calculateDelay(1);
      expect(delay1.inMilliseconds >= 1500 && delay1.inMilliseconds <= 2500, isTrue);

      final delay5 = backoff.calculateDelay(5);
      expect(delay5.inMilliseconds <= 30000, isTrue);

      expect(backoff.canRetry(2), isTrue);
      expect(backoff.canRetry(5), isFalse);
    });

    test('ConflictResolver resolves with Last-Write-Wins timestamp', () {
      final clientData = {
        'id': 'LR-001',
        'status': 'VERIFIED',
        'updated_at': '2026-09-06T20:30:00.000Z',
      };
      final serverData = {
        'id': 'LR-001',
        'status': 'PENDING',
        'updated_at': '2026-09-06T20:00:00.000Z',
      };

      final resolved = ConflictResolver.resolve(
        clientData: clientData,
        serverData: serverData,
        strategy: ConflictResolutionStrategy.lastWriteWins,
      );

      expect(resolved['status'], 'VERIFIED');
    });

    test('SyncQueueManager enqueues and tracks pending items', () async {
      final queue = SyncQueueManagerImpl();
      await queue.clearAll();

      final item = SyncQueueItem(
        id: 'TASK-SYNC-01',
        type: SyncItemType.incidentReport,
        payload: {'district': 'Tawang', 'severity': 'CRITICAL'},
        createdAt: DateTime.now(),
      );

      await queue.enqueue(item);
      final pending = await queue.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.id, 'TASK-SYNC-01');

      await queue.markStatus('TASK-SYNC-01', SyncItemStatus.completed);
      final remaining = await queue.getPendingItems();
      expect(remaining.isEmpty, isTrue);
    });

    test('BackgroundSyncService auto-triggers sync on connectivity recovery', () async {
      final conn = ConnectivityServiceImpl(initialStatus: NetworkStatus.offline);
      final queue = SyncQueueManagerImpl();
      await queue.clearAll();

      int processCalls = 0;
      final syncService = BackgroundSyncServiceImpl(
        connectivity: conn,
        queueManager: queue,
        itemProcessor: (item) async {
          processCalls++;
          return true;
        },
      );

      // Queue item while offline
      await syncService.queueItemForSync(
        SyncQueueItem(
          id: 'OFFLINE-REPORT-101',
          type: SyncItemType.incidentReport,
          payload: {'notes': 'Road cracked at Sela Pass'},
          createdAt: DateTime.now(),
        ),
      );

      expect(processCalls, 0); // No sync while offline

      // Simulate connectivity restoration
      conn.simulateNetworkStatus(NetworkStatus.online);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(processCalls, 1); // Auto-synced upon reconnect

      syncService.dispose();
      conn.dispose();
    });
  });
}
