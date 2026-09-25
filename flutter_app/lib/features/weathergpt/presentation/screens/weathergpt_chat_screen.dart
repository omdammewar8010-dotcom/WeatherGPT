import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/chat_message_model.dart';
import '../providers/weathergpt_provider.dart';
import '../widgets/voice_input_button.dart';

class WeatherGptChatScreen extends ConsumerStatefulWidget {
  const WeatherGptChatScreen({super.key});

  @override
  ConsumerState<WeatherGptChatScreen> createState() => _WeatherGptChatScreenState();
}

class _WeatherGptChatScreenState extends ConsumerState<WeatherGptChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिन्दी'},
    {'code': 'bn', 'label': 'বাংলা'},
    {'code': 'as', 'label': 'অসমীয়া'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'te', 'label': 'తెలుగు'},
    {'code': 'mr', 'label': 'मराठी'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getAlertColor(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'RED':
      case 'CRITICAL':
        return AppColors.riskCritical;
      case 'ORANGE':
      case 'HIGH':
        return AppColors.riskHigh;
      case 'YELLOW':
      case 'MODERATE':
        return AppColors.riskModerate;
      default:
        return AppColors.riskLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(weatherGptProvider);
    final notifier = ref.read(weatherGptProvider.notifier);

    // Auto-scroll when new messages arrive
    ref.listen(weatherGptProvider, (_, next) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('WeatherGPT', style: AppTypography.heading3.copyWith(fontSize: 16)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.accent.withOpacity(0.4), width: 0.8),
                        ),
                        child: const Text('MoES / IMD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.accentLight)),
                      ),
                    ],
                  ),
                  Text(
                    'Conversational Weather & NWP AI',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Language Selector Dropdown
          Container(
            margin: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: chatState.activeLanguage,
                icon: const Icon(Icons.language_rounded, size: 16, color: AppColors.accentLight),
                dropdownColor: AppColors.surface,
                items: _languages.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang['code'],
                    child: Text(
                      lang['label']!,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    notifier.setLanguage(val);
                  }
                },
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sector Advisories',
            icon: const Icon(Icons.dashboard_customize_rounded, color: AppColors.accentLight),
            onPressed: () => context.pushNamed(RouteNames.sectorAdvisories),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick Prompt Chips Carousel
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: chatState.quickChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final chip = chatState.quickChips[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => notifier.sendMessage(chip),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        chip,
                        style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Chat Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == chatState.messages.length && chatState.isLoading) {
                    return _buildLoadingBubble();
                  }
                  final msg = chatState.messages[index];
                  return _buildMessageItem(msg);
                },
              ),
            ),

            // Voice & Text Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  // Voice Mic Button for Rural / Hands-Free Accessibility
                  VoiceInputButton(
                    isRecording: chatState.isRecordingVoice,
                    onPressed: () => notifier.triggerVoiceInput(),
                  ),
                  const SizedBox(width: 10),

                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          notifier.sendMessage(text);
                          _textController.clear();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: chatState.isRecordingVoice
                            ? 'Listening... (Speak your weather query)'
                            : 'Ask WeatherGPT (e.g. Rain tomorrow in Guwahati?)',
                        hintStyle: TextStyle(
                          color: chatState.isRecordingVoice ? AppColors.riskCritical : AppColors.textMuted,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send Button
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.accentLight),
                    onPressed: () {
                      final text = _textController.text;
                      if (text.trim().isNotEmpty) {
                        notifier.sendMessage(text);
                        _textController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ),
      );
    }

    // Bot Response
    final alertColor = _getAlertColor(msg.alertSeverity);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 32),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intent & Location Badge Row
            if (msg.intent != null)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: alertColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: alertColor.withOpacity(0.4), width: 0.8),
                    ),
                    child: Text(
                      msg.intent!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: alertColor,
                      ),
                    ),
                  ),
                  if (msg.location != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• ${msg.location}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                  const Spacer(),
                  // Audio Speech Synthesis Trigger
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.accentLight),
                    tooltip: 'Read Aloud (Voice Output)',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔊 WeatherGPT audio voice read-out active (MoES Indian Voice Engine)'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 8),

            // Main Text Answer
            Text(
              msg.text,
              style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.45),
            ),

            // Meteorological Highlights Card (If provided)
            if (msg.currentTempC != null || msg.rainfall24hMm != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (msg.currentTempC != null)
                          _buildMiniStat('Temperature', '${msg.currentTempC}°C', Icons.thermostat_rounded, Colors.orangeAccent),
                        if (msg.rainfall24hMm != null)
                          _buildMiniStat('24h Rain', '${msg.rainfall24hMm} mm', Icons.water_drop_rounded, Colors.lightBlueAccent),
                        if (msg.alertSeverity != null)
                          _buildMiniStat('IMD Status', '${msg.alertSeverity} ALERT', Icons.warning_amber_rounded, alertColor),
                      ],
                    ),
                    if (msg.nwpSummary != null) ...[
                      Divider(color: AppColors.border, height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.hub_rounded, size: 14, color: AppColors.accentLight),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'NWP GFS & WRF: ${msg.nwpSummary}',
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Advisory Bullet Points (If provided)
            if (msg.advisoryPoints != null && msg.advisoryPoints!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...msg.advisoryPoints!.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📌 ', style: TextStyle(fontSize: 11)),
                      Expanded(
                        child: Text(
                          p,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentLight),
            ),
            SizedBox(width: 10),
            Text(
              'WeatherGPT is analyzing NWP models & radar feeds...',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
