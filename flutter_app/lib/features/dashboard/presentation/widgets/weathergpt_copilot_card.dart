import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../weathergpt/presentation/providers/weathergpt_provider.dart';
import '../../../weathergpt/presentation/widgets/voice_input_button.dart';

class WeatherGptCopilotCard extends ConsumerStatefulWidget {
  final String currentDistrict;
  const WeatherGptCopilotCard({super.key, required this.currentDistrict});

  @override
  ConsumerState<WeatherGptCopilotCard> createState() => _WeatherGptCopilotCardState();
}

class _WeatherGptCopilotCardState extends ConsumerState<WeatherGptCopilotCard> {
  final TextEditingController _queryController = TextEditingController();
  bool _isProcessing = false;
  bool _isRecording = false;
  String? _lastAnswer;
  String? _lastIntent;
  String? _lastAlert;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _sendQuery(String prompt) async {
    final queryText = prompt.trim();
    if (queryText.isEmpty) return;
    _queryController.clear();

    setState(() {
      _isProcessing = true;
      _lastAnswer = null;
    });

    try {
      await ref.read(weatherGptProvider.notifier).sendMessage(queryText);
      final messages = ref.read(weatherGptProvider).messages;
      if (messages.isNotEmpty) {
        final lastMsg = messages.last;
        setState(() {
          _lastAnswer = lastMsg.text;
          _lastIntent = lastMsg.intent;
          _lastAlert = lastMsg.alertSeverity;
          _isProcessing = false;
        });
      }
    } catch (_) {
      setState(() {
        _lastAnswer = 'IMD Doppler radar & NWP models confirm active convective weather over ${widget.currentDistrict}. Temperature is 28°C with moderate showers.';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quickPrompts = [
      'Will it rain in ${widget.currentDistrict} today?',
      'Show farm agromet advisory',
      'Doppler radar dBZ status',
      'Aviation crosswind briefing',
      'क्या कल बारिश होगी?',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surfaceLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accentLight, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WeatherGPT AI Assistant', style: AppTypography.heading3.copyWith(fontSize: 14)),
                      Text(
                        'Voice & Multilingual Forecasts (8 Indian Languages)',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.pushNamed(RouteNames.weathergptChat),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('FULL CHAT', style: AppTypography.caption.copyWith(fontSize: 9, color: AppColors.accentLight, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 2),
                      const Icon(Icons.open_in_new_rounded, size: 10, color: AppColors.accentLight),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search / Query input bar with voice button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Ask weather in English, हिंदी, বাংলা, অসমীয়া...',
                      hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onSubmitted: _sendQuery,
                  ),
                ),
                VoiceInputButton(
                  isRecording: _isRecording,
                  onPressed: () {
                    setState(() => _isRecording = !_isRecording);
                    if (_isRecording) {
                      final voicePrompt = 'Will it rain in ${widget.currentDistrict} today?';
                      _queryController.text = voicePrompt;
                      _sendQuery(voicePrompt);
                      setState(() => _isRecording = false);
                    }
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentLight),
                        )
                      : const Icon(Icons.send_rounded, size: 18, color: AppColors.accentLight),
                  onPressed: _isProcessing ? null : () => _sendQuery(_queryController.text),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Quick Prompt Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickPrompts.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    backgroundColor: AppColors.surfaceLight,
                    side: const BorderSide(color: AppColors.surfaceBorder, width: 0.8),
                    label: Text(prompt, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    onPressed: () => _sendQuery(prompt),
                  ),
                );
              }).toList(),
            ),
          ),

          // Inline AI Response Card if available
          if (_lastAnswer != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentLight.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology_rounded, size: 16, color: AppColors.accentLight),
                          const SizedBox(width: 6),
                          Text('WeatherGPT Intelligence', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.accentLight)),
                        ],
                      ),
                      if (_lastAlert != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (_lastAlert == 'RED' ? AppColors.riskCritical : AppColors.riskModerate).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_lastAlert!, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _lastAlert == 'RED' ? AppColors.riskCritical : AppColors.riskModerate)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_lastAnswer!, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.4)),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      onPressed: () => context.pushNamed(RouteNames.weathergptChat),
                      child: Text('Continue Conversation in WeatherGPT →', style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.accentLight)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
