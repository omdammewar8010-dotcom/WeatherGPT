import 'package:flutter_test/flutter_test.dart';
import 'package:ner_landslideguard/features/weathergpt/data/models/chat_message_model.dart';
import 'package:ner_landslideguard/features/weathergpt/presentation/providers/weathergpt_provider.dart';
import 'package:ner_landslideguard/core/network/api_client.dart';

void main() {
  group('WeatherGPT Conversational Model & State Tests', () {
    test('ChatMessage model holds all meteorological and NWP fields', () {
      final msg = ChatMessage(
        id: 'msg_01',
        text: 'Heavy rain expected in Guwahati.',
        isUser: false,
        timestamp: DateTime.now(),
        intent: 'FORECAST',
        location: 'Guwahati',
        currentTempC: 28.5,
        rainfall24hMm: 68.0,
        alertSeverity: 'ORANGE',
        weatherCondition: 'Heavy Thunderstorm Showers',
        nwpSummary: 'WRF 3km and GFS agree on active moisture surge.',
        advisoryPoints: const ['Postpone pesticide sprays', 'Check drainage'],
        followups: const ['View 72h radar animation'],
      );

      expect(msg.id, 'msg_01');
      expect(msg.isUser, isFalse);
      expect(msg.intent, 'FORECAST');
      expect(msg.currentTempC, 28.5);
      expect(msg.alertSeverity, 'ORANGE');
      expect(msg.advisoryPoints?.length, 2);
    });

    test('WeatherGptNotifier initializes with welcome message and chips', () {
      final notifier = WeatherGptNotifier(ApiClient());
      expect(notifier.state.messages.isNotEmpty, isTrue);
      expect(notifier.state.messages.first.intent, 'WELCOME');
      expect(notifier.state.activeLanguage, 'en');
      expect(notifier.state.quickChips.length, greaterThanOrEqualTo(4));
    });

    test('WeatherGptNotifier language switcher updates chips to Hindi', () {
      final notifier = WeatherGptNotifier(ApiClient());
      notifier.setLanguage('hi');

      expect(notifier.state.activeLanguage, 'hi');
      expect(notifier.state.quickChips.first.contains('बारिश'), isTrue);
    });

    test('WeatherGptNotifier location update', () {
      final notifier = WeatherGptNotifier(ApiClient());
      notifier.setLocation('Tawang');

      expect(notifier.state.selectedLocation, 'Tawang');
    });
  });
}
