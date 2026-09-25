class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? intent;
  final String? location;
  final double? currentTempC;
  final double? rainfall24hMm;
  final String? alertSeverity;
  final String? weatherCondition;
  final String? nwpSummary;
  final List<String>? advisoryPoints;
  final List<String>? followups;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.intent,
    this.location,
    this.currentTempC,
    this.rainfall24hMm,
    this.alertSeverity,
    this.weatherCondition,
    this.nwpSummary,
    this.advisoryPoints,
    this.followups,
  });
}
