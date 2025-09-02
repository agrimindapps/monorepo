/// Retry configuration for sync operations following SOLID principles
/// 
/// Follows SRP: Single responsibility of retry configuration
/// Follows OCP: Open for extension via additional retry strategies
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final bool jitterEnabled;
  
  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 16),
    this.jitterEnabled = true,
  });

  /// Default retry configuration
  static const RetryConfig defaultConfig = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(seconds: 1),
    backoffMultiplier: 2.0,
    maxDelay: Duration(seconds: 16),
    jitterEnabled: true,
  );

  /// Aggressive retry configuration for critical operations
  static const RetryConfig aggressive = RetryConfig(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 500),
    backoffMultiplier: 1.5,
    maxDelay: Duration(seconds: 8),
    jitterEnabled: true,
  );

  /// Conservative retry configuration for less critical operations
  static const RetryConfig conservative = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 2),
    backoffMultiplier: 3.0,
    maxDelay: Duration(seconds: 30),
    jitterEnabled: false,
  );

  /// Calculates delay for the given attempt number
  Duration calculateDelay(int attemptNumber) {
    if (attemptNumber <= 0) return Duration.zero;
    
    // Calculate exponential backoff
    var delay = initialDelay.inMilliseconds * 
        (backoffMultiplier * (attemptNumber - 1));
    
    // Apply max delay limit
    if (delay > maxDelay.inMilliseconds) {
      delay = maxDelay.inMilliseconds.toDouble();
    }
    
    // Add jitter if enabled (random variation ±20%)
    if (jitterEnabled) {
      final jitterRange = delay * 0.2;
      final random = DateTime.now().millisecond / 1000.0; // Simple pseudo-random
      final jitter = (random - 0.5) * 2 * jitterRange;
      delay += jitter;
    }
    
    return Duration(milliseconds: delay.round());
  }

  /// Checks if should retry based on attempt number
  bool shouldRetry(int attemptNumber) {
    return attemptNumber < maxAttempts;
  }

  @override
  String toString() {
    return 'RetryConfig('
        'maxAttempts: $maxAttempts, '
        'initialDelay: ${initialDelay.inMilliseconds}ms, '
        'backoffMultiplier: $backoffMultiplier, '
        'maxDelay: ${maxDelay.inSeconds}s, '
        'jitterEnabled: $jitterEnabled'
        ')';
  }
}