class EarlyWarningEntity {
  final String id;
  final String title;
  final String district;
  final String state;
  final String severity; // "CRITICAL", "HIGH", "MODERATE", "ADVISORY"
  final int riskScore; // 0 to 100
  final double confidence; // 0.0 to 1.0
  final String validUntil;
  final String advisory;
  final String evacuationRoute;
  final List<String> affectedSectors;
  final String createdAt;
  final bool isActive;
  final bool isRead;

  const EarlyWarningEntity({
    required this.id,
    required this.title,
    required this.district,
    required this.state,
    required this.severity,
    required this.riskScore,
    required this.confidence,
    required this.validUntil,
    required this.advisory,
    required this.evacuationRoute,
    required this.affectedSectors,
    required this.createdAt,
    this.isActive = true,
    this.isRead = false,
  });

  EarlyWarningEntity copyWith({
    String? id,
    String? title,
    String? district,
    String? state,
    String? severity,
    int? riskScore,
    double? confidence,
    String? validUntil,
    String? advisory,
    String? evacuationRoute,
    List<String>? affectedSectors,
    String? createdAt,
    bool? isActive,
    bool? isRead,
  }) {
    return EarlyWarningEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      district: district ?? this.district,
      state: state ?? this.state,
      severity: severity ?? this.severity,
      riskScore: riskScore ?? this.riskScore,
      confidence: confidence ?? this.confidence,
      validUntil: validUntil ?? this.validUntil,
      advisory: advisory ?? this.advisory,
      evacuationRoute: evacuationRoute ?? this.evacuationRoute,
      affectedSectors: affectedSectors ?? this.affectedSectors,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isRead: isRead ?? this.isRead,
    );
  }
}
