import 'dart:math';

class RetryBackoffStrategy {
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;
  final double backoffMultiplier;

  const RetryBackoffStrategy({
    this.maxRetries = 5,
    this.baseDelay = const Duration(seconds: 2),
    this.maxDelay = const Duration(minutes: 2),
    this.backoffMultiplier = 2.0,
  });

  /// Calculate backoff duration for a given attempt index (0-based)
  Duration calculateDelay(int attempt) {
    if (attempt <= 0) return Duration.zero;
    if (attempt >= maxRetries) return maxDelay;

    // Exponential calculation: base * multiplier^(attempt - 1)
    final calculatedMs = baseDelay.inMilliseconds * pow(backoffMultiplier, attempt - 1);
    
    // Add small jitter (±15%) to avoid thundering herd on server recovery
    final random = Random();
    final jitterFactor = 0.85 + (random.nextDouble() * 0.30); // 0.85 to 1.15
    final jitteredMs = (calculatedMs * jitterFactor).round();

    final boundedMs = min(jitteredMs, maxDelay.inMilliseconds);
    return Duration(milliseconds: boundedMs);
  }

  bool canRetry(int attempt) => attempt < maxRetries;
}

enum ConflictResolutionStrategy {
  serverWins,
  clientWins,
  lastWriteWins,
}

class ConflictResolver {
  static Map<String, dynamic> resolve({
    required Map<String, dynamic> clientData,
    required Map<String, dynamic> serverData,
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.lastWriteWins,
  }) {
    switch (strategy) {
      case ConflictResolutionStrategy.clientWins:
        return Map.from(clientData);

      case ConflictResolutionStrategy.serverWins:
        return Map.from(serverData);

      case ConflictResolutionStrategy.lastWriteWins:
        final clientTimestamp = DateTime.tryParse(clientData['updated_at']?.toString() ?? '') ??
            DateTime.tryParse(clientData['created_at']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final serverTimestamp = DateTime.tryParse(serverData['updated_at']?.toString() ?? '') ??
            DateTime.tryParse(serverData['created_at']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);

        if (clientTimestamp.isAfter(serverTimestamp)) {
          return Map.from(clientData);
        } else {
          return Map.from(serverData);
        }
    }
  }
}
