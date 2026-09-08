import 'dart:async';
import 'connectivity_service.dart';
import 'retry_backoff_strategy.dart';
import 'sync_queue_manager.dart';

class SyncProgress {
  final int total;
  final int synced;
  final int failed;
  final bool isSyncing;
  final String? currentTaskName;
  final DateTime? lastSyncedAt;

  const SyncProgress({
    this.total = 0,
    this.synced = 0,
    this.failed = 0,
    this.isSyncing = false,
    this.currentTaskName,
    this.lastSyncedAt,
  });

  double get progressPercentage => total == 0 ? 1.0 : (synced / total);

  SyncProgress copyWith({
    int? total,
    int? synced,
    int? failed,
    bool? isSyncing,
    String? currentTaskName,
    DateTime? lastSyncedAt,
  }) {
    return SyncProgress(
      total: total ?? this.total,
      synced: synced ?? this.synced,
      failed: failed ?? this.failed,
      isSyncing: isSyncing ?? this.isSyncing,
      currentTaskName: currentTaskName ?? this.currentTaskName,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

abstract class BackgroundSyncService {
  Stream<SyncProgress> get progressStream;
  SyncProgress get currentProgress;
  Future<void> syncAllPending({bool force = false});
  Future<void> queueItemForSync(SyncQueueItem item);
  void dispose();
}

class BackgroundSyncServiceImpl implements BackgroundSyncService {
  final ConnectivityService _connectivity;
  final SyncQueueManager _queueManager;
  final RetryBackoffStrategy _backoff;
  final Future<bool> Function(SyncQueueItem item)? _itemProcessor;

  SyncProgress _progress = const SyncProgress();
  final _progressController = StreamController<SyncProgress>.broadcast();
  StreamSubscription<NetworkStatus>? _connSubscription;

  BackgroundSyncServiceImpl({
    required ConnectivityService connectivity,
    required SyncQueueManager queueManager,
    RetryBackoffStrategy? backoff,
    Future<bool> Function(SyncQueueItem item)? itemProcessor,
  })  : _connectivity = connectivity,
        _queueManager = queueManager,
        _backoff = backoff ?? const RetryBackoffStrategy(),
        _itemProcessor = itemProcessor {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connSubscription = _connectivity.statusStream.listen((status) {
      if (status.isConnected) {
        syncAllPending();
      }
    });
  }

  @override
  Stream<SyncProgress> get progressStream => _progressController.stream;

  @override
  SyncProgress get currentProgress => _progress;

  @override
  Future<void> queueItemForSync(SyncQueueItem item) async {
    await _queueManager.enqueue(item);
    _updateProgress(_progress.copyWith(total: _queueManager.queueLength));
    
    // Attempt sync immediately if online
    if (_connectivity.currentStatus.isConnected) {
      syncAllPending();
    }
  }

  @override
  Future<void> syncAllPending({bool force = false}) async {
    if (_progress.isSyncing) return;
    if (!_connectivity.currentStatus.isConnected && !force) return;

    final pending = await _queueManager.getPendingItems();
    if (pending.isEmpty) {
      _updateProgress(_progress.copyWith(total: 0, synced: 0, isSyncing: false));
      return;
    }

    _updateProgress(_progress.copyWith(
      total: pending.length,
      synced: 0,
      failed: 0,
      isSyncing: true,
      currentTaskName: 'Starting batch sync of ${pending.length} items...',
    ));

    int syncedCount = 0;
    int failedCount = 0;

    for (final item in pending) {
      if (!_backoff.canRetry(item.attempts) && !force) {
        failedCount++;
        continue;
      }

      _updateProgress(_progress.copyWith(
        currentTaskName: 'Syncing ${_describeItem(item)}...',
      ));

      await _queueManager.markStatus(item.id, SyncItemStatus.syncing);

      bool success = false;
      try {
        if (_itemProcessor != null) {
          success = await _itemProcessor(item);
        } else {
          // Simulated server processing delay
          await Future.delayed(const Duration(milliseconds: 250));
          success = true;
        }
      } catch (e) {
        success = false;
      }

      if (success) {
        await _queueManager.markStatus(item.id, SyncItemStatus.completed);
        syncedCount++;
      } else {
        await _queueManager.markStatus(item.id, SyncItemStatus.failed, error: 'Network transmission timeout');
        failedCount++;
      }

      _updateProgress(_progress.copyWith(
        synced: syncedCount,
        failed: failedCount,
      ));
    }

    _updateProgress(_progress.copyWith(
      isSyncing: false,
      currentTaskName: syncedCount > 0 ? 'Sync completed successfully' : 'Sync completed with failures',
      lastSyncedAt: DateTime.now(),
    ));
  }

  String _describeItem(SyncQueueItem item) {
    switch (item.type) {
      case SyncItemType.incidentReport:
        return 'Incident Report (${item.id})';
      case SyncItemType.statusUpdate:
        return 'Report Verification (${item.id})';
      case SyncItemType.emergencySos:
        return 'Emergency SOS Dispatch (${item.id})';
      case SyncItemType.fieldInspection:
        return 'Slope Inclinometer Reading (${item.id})';
    }
  }

  void _updateProgress(SyncProgress newProgress) {
    _progress = newProgress;
    _progressController.add(_progress);
  }

  @override
  void dispose() {
    _connSubscription?.cancel();
    _progressController.close();
  }
}
