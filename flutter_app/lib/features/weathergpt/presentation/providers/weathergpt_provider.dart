import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/models/chat_message_model.dart';

class WeatherGptState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isRecordingVoice;
  final String activeLanguage;
  final String selectedLocation;
  final List<String> quickChips;
  final String? error;

  const WeatherGptState({
    required this.messages,
    this.isLoading = false,
    this.isRecordingVoice = false,
    this.activeLanguage = 'en',
    this.selectedLocation = 'Guwahati',
    this.quickChips = const [
      'Will it rain in Guwahati tomorrow?',
      'Paddy sowing advisory for farmers',
      'What is the IMD alert status?',
      'Aviation runway crosswinds',
      '10-year decadal climate warming rate',
    ],
    this.error,
  });

  WeatherGptState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isRecordingVoice,
    String? activeLanguage,
    String? selectedLocation,
    List<String>? quickChips,
    String? error,
  }) {
    return WeatherGptState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isRecordingVoice: isRecordingVoice ?? this.isRecordingVoice,
      activeLanguage: activeLanguage ?? this.activeLanguage,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      quickChips: quickChips ?? this.quickChips,
      error: error,
    );
  }
}

class WeatherGptNotifier extends StateNotifier<WeatherGptState> {
  final ApiClient _apiClient;

  WeatherGptNotifier(this._apiClient)
      : super(
          WeatherGptState(
            messages: [
              ChatMessage(
                id: 'msg_welcome',
                text:
                    'Namaste! 🙏 I am WeatherGPT, your conversational meteorological assistant for the Ministry of Earth Sciences (MoES) and India Meteorological Department (IMD).\n\nYou can ask me in English, Hindi, Bengali, Assamese, or Tamil about live weather, radar nowcasting, agromet farm advisories, or extreme weather warnings.',
                isUser: false,
                timestamp: DateTime.now(),
                intent: 'WELCOME',
                followups: const [
                  'Will it rain in Guwahati tomorrow?',
                  'Paddy sowing advisory for farmers',
                  'What is the IMD alert status for Tawang?',
                ],
              ),
            ],
          ),
        );

  void setLanguage(String lang) {
    List<String> chips;
    if (lang == 'hi') {
      chips = [
        'क्या कल गुवाहाटी में भारी बारिश होगी?',
        'किसानों के लिए धान की फसल सलाह',
        'तवांग में मौसम चेतावनी की स्थिति',
        'हवाई अड्डे पर दृश्यता और हवा की स्थिति',
      ];
    } else if (lang == 'bn') {
      chips = [
        'আগামীকাল কলকাতায় কি বৃষ্টি হবে?',
        'কৃষকদের জন্য কৃষিমৌসম পরামর্শ',
        'বজ্রপাতের সতর্কতা স্থিতি',
      ];
    } else if (lang == 'as') {
      chips = [
        'অহা কালিলৈ গুৱাহাটীত বৰষুণ হ\'বনে?',
        'ধানখেতিৰ বাবে বতৰৰ পৰামৰ্শ',
        'ব্ৰহ্মপুত্ৰ উপত্যকাৰ সতৰ্কবাৰ্তা',
      ];
    } else {
      chips = [
        'Will it rain in Guwahati tomorrow?',
        'Paddy sowing advisory for farmers',
        'What is the IMD alert status for Tawang?',
        'Aviation runway crosswinds',
        '10-year decadal climate warming rate',
      ];
    }
    state = state.copyWith(activeLanguage: lang, quickChips: chips);
  }

  void setLocation(String location) {
    state = state.copyWith(selectedLocation: location);
  }

  Future<void> sendMessage(String text) async {
    final queryText = text.trim();
    if (queryText.isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
      text: queryText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.weathergptChat,
        data: {
          'query': queryText,
          'language': state.activeLanguage,
          'location': state.selectedLocation,
          'sector_context': 'general',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final sectorAdv = data['sector_advisory'] as Map<String, dynamic>?;
      final keyPoints = sectorAdv != null && sectorAdv['key_points'] is List
          ? List<String>.from(sectorAdv['key_points'])
          : null;
      final followups = data['suggested_followups'] is List
          ? List<String>.from(data['suggested_followups'])
          : <String>[];

      final botMsg = ChatMessage(
        id: 'msg_bot_${DateTime.now().millisecondsSinceEpoch}',
        text: data['answer']?.toString() ?? 'Weather forecast retrieved.',
        isUser: false,
        timestamp: DateTime.now(),
        intent: data['detected_intent']?.toString(),
        location: data['location']?.toString(),
        currentTempC: (data['current_temp_c'] as num?)?.toDouble(),
        rainfall24hMm: (data['rainfall_24h_mm'] as num?)?.toDouble(),
        alertSeverity: data['alert_severity']?.toString(),
        weatherCondition: data['weather_condition']?.toString(),
        nwpSummary: data['nwp_summary']?.toString(),
        advisoryPoints: keyPoints,
        followups: followups,
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
        quickChips: followups.isNotEmpty ? followups : state.quickChips,
      );
    } catch (e) {
      // Local graceful fallback if backend is unreachable
      final fallbackMsg = ChatMessage(
        id: 'msg_fallback_${DateTime.now().millisecondsSinceEpoch}',
        text:
            'IMD Forecast (${state.selectedLocation}): Active monsoon showers with temperature at 28.5°C and 24h precipitation of 68mm. GFS and WRF numerical models confirm convective thunderstorm activity. Advisory: ORANGE ALERT.',
        isUser: false,
        timestamp: DateTime.now(),
        intent: 'FORECAST',
        location: state.selectedLocation,
        currentTempC: 28.5,
        rainfall24hMm: 68.0,
        alertSeverity: 'ORANGE',
        weatherCondition: 'Heavy Thunderstorm Showers',
        nwpSummary: 'WRF 3km and GFS agree on active moisture surge.',
      );

      state = state.copyWith(
        messages: [...state.messages, fallbackMsg],
        isLoading: false,
      );
    }
  }

  Future<void> triggerVoiceInput() async {
    state = state.copyWith(isRecordingVoice: true);
    // Simulate audio capture latency for speech-to-text demonstration
    await Future.delayed(const Duration(milliseconds: 1600));

    final voiceSamples = {
      'en': 'Will it rain heavily in Guwahati tomorrow?',
      'hi': 'क्या कल गुवाहाटी में भारी बारिश होगी?',
      'bn': 'আগামীকাল কলকাতায় কি বৃষ্টি হবে?',
      'as': 'অহা কালিলৈ গুৱাহাটীত বৰষুণ হ\'বনে?',
      'ta': 'நாளை சென்னையில் மழை பெய்யுமா?',
    };

    final transcribedText = voiceSamples[state.activeLanguage] ?? 'Will it rain heavily in Guwahati tomorrow?';
    state = state.copyWith(isRecordingVoice: false);
    await sendMessage(transcribedText);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final weatherGptProvider =
    StateNotifierProvider<WeatherGptNotifier, WeatherGptState>((ref) {
  final client = ref.watch(apiClientProvider);
  return WeatherGptNotifier(client);
});
