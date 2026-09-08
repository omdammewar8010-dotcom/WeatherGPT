import 'dart:async';
import 'firestore_collections.dart';

class FcmNotificationPayload {
  final String title;
  final String body;
  final String? district;
  final String? alertLevel; // LOW, MEDIUM, HIGH, CRITICAL
  final String? routeTarget;
  final Map<String, dynamic> data;
  final DateTime receivedAt;

  const FcmNotificationPayload({
    required this.title,
    required this.body,
    this.district,
    this.alertLevel,
    this.routeTarget,
    this.data = const {},
    required this.receivedAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'district': district,
        'alert_level': alertLevel,
        'route_target': routeTarget,
        'data': data,
        'received_at': receivedAt.toIso8601String(),
      };
}

abstract class FcmMessagingService {
  Future<String?> getDeviceToken();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Future<void> subscribeToDistrict(String district);
  Future<void> subscribeToRoleAlerts(String role);
  Stream<FcmNotificationPayload> get onMessageStream;
  Stream<FcmNotificationPayload> get onMessageOpenedAppStream;
  Future<void> sendLocalNotification(FcmNotificationPayload payload);
}

class FcmMessagingServiceImpl implements FcmMessagingService {
  final _messageStreamController = StreamController<FcmNotificationPayload>.broadcast();
  final _openedAppStreamController = StreamController<FcmNotificationPayload>.broadcast();
  final Set<String> _subscribedTopics = {};

  Set<String> get subscribedTopics => Set.unmodifiable(_subscribedTopics);

  @override
  Future<String?> getDeviceToken() async {
    return 'fcm_token_ner_demo_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    _subscribedTopics.add(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    _subscribedTopics.remove(topic);
  }

  @override
  Future<void> subscribeToDistrict(String district) async {
    final topic = FcmTopics.districtTopic(district);
    await subscribeToTopic(topic);
    await subscribeToTopic(FcmTopics.criticalWarnings);
  }

  @override
  Future<void> subscribeToRoleAlerts(String role) async {
    if (role == 'field_officer') {
      await subscribeToTopic(FcmTopics.fieldOfficers);
    } else if (role == 'authority_admin') {
      await subscribeToTopic(FcmTopics.authorityAdmins);
    }
  }

  @override
  Stream<FcmNotificationPayload> get onMessageStream => _messageStreamController.stream;

  @override
  Stream<FcmNotificationPayload> get onMessageOpenedAppStream => _openedAppStreamController.stream;

  @override
  Future<void> sendLocalNotification(FcmNotificationPayload payload) async {
    _messageStreamController.add(payload);
  }

  void dispose() {
    _messageStreamController.close();
    _openedAppStreamController.close();
  }
}
