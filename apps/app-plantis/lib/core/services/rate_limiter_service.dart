/// Exceção lançada quando o rate limit é excedido
class RateLimitException implements Exception {
  final String message;
  final Duration retryAfter;

  RateLimitException(this.message, this.retryAfter);

  @override
  String toString() => 'RateLimitException: $message';
}

/// Configuração de rate limiting por endpoint
class RateLimitConfig {
  /// Intervalo mínimo entre requests do mesmo endpoint (throttling)
  final Duration throttleInterval;

  /// Duração da janela de contagem (rolling window)
  final Duration windowDuration;

  /// Máximo de requests permitidos na janela
  final int maxRequestsPerWindow;

  const RateLimitConfig({
    this.throttleInterval = const Duration(milliseconds: 500),
    this.windowDuration = const Duration(minutes: 1),
    this.maxRequestsPerWindow = 30,
  });

  const RateLimitConfig.aggressive({
    this.throttleInterval = const Duration(milliseconds: 1000),
    this.windowDuration = const Duration(minutes: 1),
    this.maxRequestsPerWindow = 15,
  });

  const RateLimitConfig.relaxed({
    this.throttleInterval = const Duration(milliseconds: 200),
    this.windowDuration = const Duration(minutes: 1),
    this.maxRequestsPerWindow = 60,
  });
}

/// Serviço de rate limiting para proteger contra API abuse
///
/// Implementa duas estratégias:
/// 1. **Throttling**: Intervalo mínimo entre requests do mesmo endpoint
/// 2. **Window limiting**: Máximo de requests em uma janela de tempo
///
/// **Uso:**
/// ```dart
/// await _rateLimiter.checkLimit('fetch_plants');
/// final result = await firestore.collection('plants').get();
/// ```
class RateLimiterService {
  /// Timestamp do último request por endpoint (para throttling)
  final Map<String, DateTime> _lastRequestTimes = {};

  /// Lista de timestamps de requests na janela atual (para window limiting)
  final Map<String, List<DateTime>> _requestTimestamps = {};

  /// Configurações de rate limiting por endpoint
  final Map<String, RateLimitConfig> _configs = {};

  /// Configuração padrão
  final RateLimitConfig _defaultConfig = const RateLimitConfig();

  RateLimiterService();

  /// Define configuração customizada para um endpoint específico
  void setConfig(String key, RateLimitConfig config) {
    _configs[key] = config;
  }

  /// Obtém configuração para um endpoint
  RateLimitConfig _getConfig(String key) {
    return _configs[key] ?? _defaultConfig;
  }

  /// Verifica e aguarda se necessário para respeitar rate limits
  ///
  /// **Throws:**
  /// - [RateLimitException] se window limit for excedido
  ///
  /// **Aguarda automaticamente:**
  /// - Throttle delay se necessário
  Future<void> checkLimit(String key) async {
    final config = _getConfig(key);
    final now = DateTime.now();

    // 1. Window limit check (hard limit - rejeita)
    _cleanupOldTimestamps(key, now, config.windowDuration);
    final timestamps = _requestTimestamps[key] ?? [];

    if (timestamps.length >= config.maxRequestsPerWindow) {
      final oldestInWindow = timestamps.first;
      final waitTime = config.windowDuration - now.difference(oldestInWindow);

      throw RateLimitException(
        'Rate limit exceeded: ${config.maxRequestsPerWindow} requests per '
        '${config.windowDuration.inSeconds}s. Retry after ${waitTime.inSeconds}s',
        waitTime,
      );
    }

    // 2. Throttle check (soft limit - aguarda)
    final lastRequest = _lastRequestTimes[key];
    if (lastRequest != null) {
      final elapsed = now.difference(lastRequest);

      if (elapsed < config.throttleInterval) {
        final delay = config.throttleInterval - elapsed;
        await Future<void>.delayed(delay);
      }
    }

    // 3. Registra o request
    _registerRequest(key, DateTime.now());
  }

  /// Registra um request realizado
  void _registerRequest(String key, DateTime timestamp) {
    _lastRequestTimes[key] = timestamp;

    final timestamps = _requestTimestamps[key] ?? [];
    timestamps.add(timestamp);
    _requestTimestamps[key] = timestamps;
  }

  /// Remove timestamps antigos da janela de contagem
  void _cleanupOldTimestamps(String key, DateTime now, Duration window) {
    final timestamps = _requestTimestamps[key];
    if (timestamps == null) return;

    timestamps.removeWhere((timestamp) {
      return now.difference(timestamp) > window;
    });
  }

  /// Reseta todos os limites de um endpoint
  void reset(String key) {
    _lastRequestTimes.remove(key);
    _requestTimestamps.remove(key);
  }

  /// Reseta todos os rate limits
  void resetAll() {
    _lastRequestTimes.clear();
    _requestTimestamps.clear();
  }

  /// Obtém estatísticas de uso de um endpoint
  RateLimitStats getStats(String key) {
    final config = _getConfig(key);
    final now = DateTime.now();

    _cleanupOldTimestamps(key, now, config.windowDuration);

    final timestamps = _requestTimestamps[key] ?? [];
    final lastRequest = _lastRequestTimes[key];

    return RateLimitStats(
      endpoint: key,
      requestsInWindow: timestamps.length,
      maxRequestsPerWindow: config.maxRequestsPerWindow,
      lastRequestAt: lastRequest,
      canRequest: timestamps.length < config.maxRequestsPerWindow,
    );
  }
}

/// Estatísticas de uso de rate limiting
class RateLimitStats {
  final String endpoint;
  final int requestsInWindow;
  final int maxRequestsPerWindow;
  final DateTime? lastRequestAt;
  final bool canRequest;

  RateLimitStats({
    required this.endpoint,
    required this.requestsInWindow,
    required this.maxRequestsPerWindow,
    required this.lastRequestAt,
    required this.canRequest,
  });

  double get usagePercentage => (requestsInWindow / maxRequestsPerWindow) * 100;

  @override
  String toString() {
    return 'RateLimitStats('
        'endpoint: $endpoint, '
        'usage: $requestsInWindow/$maxRequestsPerWindow '
        '(${usagePercentage.toStringAsFixed(1)}%), '
        'canRequest: $canRequest'
        ')';
  }
}
