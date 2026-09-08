import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum SyncItemType {
  incidentReport,
  statusUpdate,
  emergencySos,
  fieldInspection,
}

enum SyncItemStatus {
  pending,
  syncing,
  failed,
  completed,
}

class SyncQueueItem {
  final String id;
  final SyncItemType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final SyncItemStatus status;
  final String? lastError;

  const SyncQueueItem({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.status = SyncItemStatus.pending,
    this.lastError,
  });

  SyncQueueItem copyWith({
    int? attempts,
    SyncItemStatus? status,
    String? lastError,
  }) {
    return SyncQueueItem(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
        'attempts': attempts,
        'status': status.name,
        'last_error': lastError,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      type: SyncItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncItemType.incidentReport,
      ),
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      attempts: json['attempts'] as int? ?? 0,
      status: SyncItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncItemStatus.pending,
      ),
      lastError: json['last_error'] as String?,
    );
  }
}

abstract class SyncQueueManager {
  Future<void> enqueue(SyncQueueItem item);
  Future<List<SyncQueueItem>> getPendingItems();
  Future<void> markStatus(String id, SyncItemStatus status, {String? error});
  Future<void> removeItem(String id);
  Future<void> clearAll();
  int get queueLength;
}

class SyncQueueManagerImpl implements SyncQueueManager {
  static const String _storageKey = 'ner_sync_queue_items_v1';
  final List<SyncQueueItem> _items = [];

  SyncQueueManagerImpl() {
    _loadFromStorage();
  }

  @override
  int get queueLength => _items.where((i) => i.status == SyncItemStatus.pending || i.status == SyncItemStatus.failed).length;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey);
      if (raw != null) {
        _items.clear();
        for (final str in raw) {
          _items.add(SyncQueueItem.fromJson(jsonDecode(str) as Map<String, dynamic>));
        }
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_storageKey, list);
    } catch (_) {}
  }

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    _items.removeWhere((i) => i.id == item.id);
    _items.add(item);
    await _persist();
  }

  @override
  Future<List<SyncQueueItem>> getPendingItems() async {
    return _items.where((i) => i.status == SyncItemStatus.pending || i.status == SyncItemStatus.failed).toList();
  }

  @override
  Future<void> markStatus(String id, SyncItemStatus status, {String? error}) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      final item = _items[idx];
      _items[idx] = item.copyWith(
        status: status,
        attempts: status == SyncItemStatus.failed ? item.attempts + 1 : item.attempts,
        lastError: error,
      );
      if (status == SyncItemStatus.completed) {
        _items.removeAt(idx);
      }
      await _persist();
    }
  }

  @override
  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _persist();
  }

  @override
  Future<void> clearAll() async {
    _items.clear();
    await _persist();
  }
}
