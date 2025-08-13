// Dart imports:
import 'dart:async';
import 'dart:collection';

// Project imports:
import '../aspect_interface.dart';

/// Aspecto para coleta de estatísticas e métricas de repository
///
/// ISSUE #35: Repository Responsibilities - SOLUTION IMPLEMENTED
/// Externaliza a responsabilidade de coleta de estatísticas dos repositories core,
/// aplicando medição de forma consistente através de AOP.
///
/// Features:
/// - Coleta automática de métricas de performance
/// - Estatísticas de uso por operação
/// - Monitoramento de padrões de acesso
/// - Detecção de gargalos de performance
/// - Relatórios estatísticos agregados
/// - Cache de estatísticas com TTL
class StatisticsAspect implements RepositoryAspect {
  /// Configurações do aspecto
  final StatisticsAspectConfig config;

  /// Coletores de métricas por repository
  final Map<String, RepositoryStatisticsCollector> _collectors = {};

  /// Cache de estatísticas agregadas
  final Map<String, CachedStatistics> _statisticsCache = {};

  /// Timer para limpeza periódica de estatísticas antigas
  Timer? _cleanupTimer;

  StatisticsAspect({
    StatisticsAspectConfig? config,
  }) : config = config ?? const StatisticsAspectConfig() {
    _initializeCleanupTimer();
  }

  @override
  String get name => 'StatisticsAspect';

  @override
  int get priority => 90; // Baixa prioridade - coleta estatísticas por último

  @override
  bool get enabled => config.enabled;

  @override
  Future<AdviceResult> beforeOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    required OperationContext context,
  }) async {
    if (!_shouldCollectForOperation(operationName)) {
      return AdviceResult.proceed();
    }

    final collector = _getOrCreateCollector(context.repositoryName);

    // Marcar início da operação
    context.addMetric(
        'statistics_start_time', DateTime.now().millisecondsSinceEpoch);
    context.addMetric('operation_parameters_count', parameters.length);

    // Registrar tentativa de operação
    collector.recordOperationAttempt(operationName, parameters);

    // Registrar padrões de acesso se habilitado
    if (config.trackAccessPatterns) {
      collector.recordAccessPattern(operationName, parameters);
    }

    return AdviceResult.proceed(
      additionalContext: {
        'statistics_enabled': true,
        'collector_id': collector.id,
      },
    );
  }

  @override
  Future<AdviceResult> afterOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    required dynamic result,
    required OperationContext context,
  }) async {
    if (!_shouldCollectForOperation(operationName)) {
      return AdviceResult.proceed(result: result);
    }

    final collector = _getOrCreateCollector(context.repositoryName);
    final duration = _calculateDuration(context);

    // Calcular métricas do resultado
    final resultMetrics = _analyzeResult(result);

    // Registrar operação bem-sucedida
    collector.recordSuccessfulOperation(
      operationName,
      duration,
      parameters,
      result,
      resultMetrics,
    );

    // Detectar operações lentas
    if (config.detectSlowOperations &&
        duration > config.slowOperationThreshold) {
      collector.recordSlowOperation(operationName, duration, parameters);
    }

    // Detectar padrões anômalos
    if (config.detectAnomalies) {
      _detectAndRecordAnomalies(
          collector, operationName, duration, resultMetrics);
    }

    // Atualizar estatísticas em tempo real se habilitado
    if (config.realTimeStatistics) {
      _updateRealTimeStatistics(
          context.repositoryName, operationName, duration, true);
    }

    return AdviceResult.proceed(result: result);
  }

  @override
  Future<AdviceResult> onException({
    required String operationName,
    required Map<String, dynamic> parameters,
    required dynamic exception,
    required StackTrace stackTrace,
    required OperationContext context,
  }) async {
    if (!_shouldCollectForOperation(operationName)) {
      return AdviceResult.throwException(exception);
    }

    final collector = _getOrCreateCollector(context.repositoryName);
    final duration = _calculateDuration(context);

    // Registrar operação falhada
    collector.recordFailedOperation(
      operationName,
      duration,
      parameters,
      exception,
    );

    // Detectar padrões de falha
    if (config.trackFailurePatterns) {
      collector.recordFailurePattern(operationName, exception, parameters);
    }

    // Atualizar estatísticas em tempo real
    if (config.realTimeStatistics) {
      _updateRealTimeStatistics(
          context.repositoryName, operationName, duration, false);
    }

    return AdviceResult.throwException(exception);
  }

  @override
  Future<void> finallyOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    dynamic result,
    dynamic exception,
    required OperationContext context,
  }) async {
    if (!_shouldCollectForOperation(operationName)) {
      return;
    }

    final collector = _getOrCreateCollector(context.repositoryName);

    // Finalizar medição da operação
    collector.finalizeOperation(
      operationName,
      context.operationId,
      exception == null,
    );

    // Verificar se precisa fazer flush das estatísticas
    if (config.autoFlushStatistics && collector.needsFlush()) {
      await _flushStatistics(context.repositoryName);
    }

    // Limpar cache de estatísticas antigas periodicamente
    if (config.autoCleanup && _shouldRunCleanup()) {
      _cleanupOldStatistics();
    }
  }

  /// Obtém estatísticas agregadas para um repository
  Future<AggregatedStatistics> getStatistics(String repositoryName) async {
    final cacheKey = '${repositoryName}_aggregated';
    final cached = _statisticsCache[cacheKey];

    // Retornar do cache se válido
    if (cached != null && !cached.isExpired) {
      return cached.statistics as AggregatedStatistics;
    }

    final collector = _collectors[repositoryName];
    if (collector == null) {
      return AggregatedStatistics.empty(repositoryName);
    }

    // Calcular estatísticas agregadas
    final aggregated = await collector.getAggregatedStatistics();

    // Cachear resultado
    _statisticsCache[cacheKey] = CachedStatistics(
      statistics: aggregated,
      cachedAt: DateTime.now(),
      ttl: config.statisticsCacheTtl,
    );

    return aggregated;
  }

  /// Obtém estatísticas em tempo real para um repository
  RealTimeStatistics? getRealTimeStatistics(String repositoryName) {
    final collector = _collectors[repositoryName];
    return collector?.getRealTimeStatistics();
  }

  /// Obtém relatório de performance para um repository
  Future<PerformanceReport> getPerformanceReport(String repositoryName) async {
    final collector = _collectors[repositoryName];
    if (collector == null) {
      return PerformanceReport.empty(repositoryName);
    }

    return await collector.generatePerformanceReport();
  }

  /// Reseta estatísticas para um repository
  void resetStatistics(String repositoryName) {
    final collector = _collectors[repositoryName];
    collector?.reset();

    // Limpar cache relacionado
    _statisticsCache.removeWhere((key, _) => key.startsWith(repositoryName));
  }

  /// Reseta todas as estatísticas
  void resetAllStatistics() {
    for (final collector in _collectors.values) {
      collector.reset();
    }
    _statisticsCache.clear();
  }

  /// Obtém ou cria coletor para um repository
  RepositoryStatisticsCollector _getOrCreateCollector(String repositoryName) {
    return _collectors.putIfAbsent(
      repositoryName,
      () => RepositoryStatisticsCollector(
        repositoryName: repositoryName,
        config: config,
      ),
    );
  }

  /// Calcula duração da operação
  Duration _calculateDuration(OperationContext context) {
    final startTime = context.getMetric<int>('statistics_start_time');
    if (startTime != null) {
      return Duration(
          milliseconds: DateTime.now().millisecondsSinceEpoch - startTime);
    }
    return context.elapsed;
  }

  /// Analisa resultado para extrair métricas
  Map<String, dynamic> _analyzeResult(dynamic result) {
    final metrics = <String, dynamic>{};

    if (result == null) {
      metrics['result_type'] = 'null';
      metrics['result_size'] = 0;
    } else if (result is List) {
      metrics['result_type'] = 'list';
      metrics['result_size'] = result.length;
      metrics['result_empty'] = result.isEmpty;
    } else if (result is Map) {
      metrics['result_type'] = 'map';
      metrics['result_size'] = result.length;
      metrics['result_empty'] = result.isEmpty;
    } else if (result is String) {
      metrics['result_type'] = 'string';
      metrics['result_size'] = result.length;
      metrics['result_empty'] = result.isEmpty;
    } else {
      metrics['result_type'] = result.runtimeType.toString();
      metrics['result_size'] = 1;
      metrics['result_empty'] = false;
    }

    return metrics;
  }

  /// Detecta e registra anomalias
  void _detectAndRecordAnomalies(
    RepositoryStatisticsCollector collector,
    String operationName,
    Duration duration,
    Map<String, dynamic> resultMetrics,
  ) {
    // Detectar operações excessivamente lentas
    final avgDuration = collector.getAverageOperationDuration(operationName);
    if (avgDuration != null &&
        duration.inMilliseconds >
            avgDuration * config.anomalyThresholdMultiplier) {
      collector.recordAnomaly(
        AnomalyType.slowOperation,
        operationName,
        {
          'duration_ms': duration.inMilliseconds,
          'average_ms': avgDuration,
          'threshold_multiplier': config.anomalyThresholdMultiplier,
        },
      );
    }

    // Detectar resultados anormalmente grandes
    if (resultMetrics['result_size'] is int) {
      final resultSize = resultMetrics['result_size'] as int;
      final avgResultSize = collector.getAverageResultSize(operationName);
      if (avgResultSize != null &&
          resultSize > avgResultSize * config.anomalyThresholdMultiplier) {
        collector.recordAnomaly(
          AnomalyType.largeResult,
          operationName,
          {
            'result_size': resultSize,
            'average_size': avgResultSize,
            'threshold_multiplier': config.anomalyThresholdMultiplier,
          },
        );
      }
    }
  }

  /// Atualiza estatísticas em tempo real
  void _updateRealTimeStatistics(
    String repositoryName,
    String operationName,
    Duration duration,
    bool success,
  ) {
    final collector = _collectors[repositoryName];
    collector?.updateRealTimeStatistics(operationName, duration, success);
  }

  /// Faz flush das estatísticas para storage persistente
  Future<void> _flushStatistics(String repositoryName) async {
    final collector = _collectors[repositoryName];
    if (collector == null) return;

    try {
      await collector.flush();
    } catch (e) {
      // Não falhar por erro de flush de estatísticas
      // Apenas registrar para debugging
    }
  }

  /// Verifica se deve coletar estatísticas para esta operação
  bool _shouldCollectForOperation(String operationName) {
    if (config.excludedOperations.contains(operationName)) {
      return false;
    }

    if (config.includedOperations.isNotEmpty) {
      return config.includedOperations.contains(operationName);
    }

    return true;
  }

  /// Verifica se deve rodar cleanup
  bool _shouldRunCleanup() {
    // Implementação simples - pode ser melhorada com lógica mais sofisticada
    return DateTime.now().millisecondsSinceEpoch % 10000 < 100;
  }

  /// Limpa estatísticas antigas do cache
  void _cleanupOldStatistics() {
    final now = DateTime.now();
    _statisticsCache.removeWhere((key, cached) =>
        now.difference(cached.cachedAt) > config.statisticsCacheTtl);
  }

  /// Inicializa timer de limpeza
  void _initializeCleanupTimer() {
    if (config.autoCleanup && config.cleanupInterval.inSeconds > 0) {
      _cleanupTimer = Timer.periodic(config.cleanupInterval, (_) {
        _cleanupOldStatistics();
      });
    }
  }

  /// Dispõe recursos do aspecto
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    for (final collector in _collectors.values) {
      collector.dispose();
    }

    _collectors.clear();
    _statisticsCache.clear();
  }
}

/// Coletor de estatísticas para um repository específico
class RepositoryStatisticsCollector {
  final String repositoryName;
  final StatisticsAspectConfig config;
  final String id;

  /// Estatísticas de operações
  final Map<String, OperationStatistics> _operationStats = {};

  /// Histórico de operações recentes
  final Queue<OperationRecord> _recentOperations = Queue();

  /// Padrões de acesso detectados
  final Map<String, AccessPattern> _accessPatterns = {};

  /// Anomalias detectadas
  final List<StatisticsAnomaly> _anomalies = [];

  /// Estatísticas em tempo real
  late final RealTimeStatistics _realTimeStats;

  /// Última vez que foi feito flush
  DateTime? _lastFlush;

  RepositoryStatisticsCollector({
    required this.repositoryName,
    required this.config,
  }) : id = '${repositoryName}_${DateTime.now().millisecondsSinceEpoch}' {
    _realTimeStats = RealTimeStatistics(repositoryName);
  }

  /// Registra tentativa de operação
  void recordOperationAttempt(
      String operationName, Map<String, dynamic> parameters) {
    final stats = _getOrCreateOperationStats(operationName);
    stats.recordAttempt();
  }

  /// Registra operação bem-sucedida
  void recordSuccessfulOperation(
    String operationName,
    Duration duration,
    Map<String, dynamic> parameters,
    dynamic result,
    Map<String, dynamic> resultMetrics,
  ) {
    final stats = _getOrCreateOperationStats(operationName);
    stats.recordSuccess(duration, resultMetrics);

    // Adicionar ao histórico de operações recentes
    _addToRecentOperations(OperationRecord(
      operationName: operationName,
      timestamp: DateTime.now(),
      duration: duration,
      success: true,
      parameters: Map<String, dynamic>.from(parameters),
      resultMetrics: Map<String, dynamic>.from(resultMetrics),
    ));
  }

  /// Registra operação falhada
  void recordFailedOperation(
    String operationName,
    Duration duration,
    Map<String, dynamic> parameters,
    dynamic exception,
  ) {
    final stats = _getOrCreateOperationStats(operationName);
    stats.recordFailure(duration, exception);

    // Adicionar ao histórico
    _addToRecentOperations(OperationRecord(
      operationName: operationName,
      timestamp: DateTime.now(),
      duration: duration,
      success: false,
      parameters: Map<String, dynamic>.from(parameters),
      exception: exception,
    ));
  }

  /// Registra operação lenta
  void recordSlowOperation(String operationName, Duration duration,
      Map<String, dynamic> parameters) {
    final stats = _getOrCreateOperationStats(operationName);
    stats.recordSlowOperation(duration);
  }

  /// Registra padrão de acesso
  void recordAccessPattern(
      String operationName, Map<String, dynamic> parameters) {
    final pattern = _accessPatterns.putIfAbsent(
        operationName, () => AccessPattern(operationName));
    pattern.recordAccess(parameters);
  }

  /// Registra padrão de falha
  void recordFailurePattern(String operationName, dynamic exception,
      Map<String, dynamic> parameters) {
    final stats = _getOrCreateOperationStats(operationName);
    stats.recordFailurePattern(exception, parameters);
  }

  /// Registra anomalia
  void recordAnomaly(
      AnomalyType type, String operationName, Map<String, dynamic> context) {
    _anomalies.add(StatisticsAnomaly(
      type: type,
      operationName: operationName,
      timestamp: DateTime.now(),
      context: context,
    ));

    // Manter apenas as anomalias recentes
    while (_anomalies.length > config.maxAnomaliesHistory) {
      _anomalies.removeAt(0);
    }
  }

  /// Finaliza operação
  void finalizeOperation(
      String operationName, String operationId, bool success) {
    // Implementação futura para tracking de operações em andamento
  }

  /// Atualiza estatísticas em tempo real
  void updateRealTimeStatistics(
      String operationName, Duration duration, bool success) {
    _realTimeStats.update(operationName, duration, success);
  }

  /// Obtém estatísticas agregadas
  Future<AggregatedStatistics> getAggregatedStatistics() async {
    final operationStats = <String, OperationStatistics>{};
    for (final entry in _operationStats.entries) {
      operationStats[entry.key] = entry.value.copy();
    }

    return AggregatedStatistics(
      repositoryName: repositoryName,
      operationStatistics: operationStats,
      accessPatterns: Map<String, AccessPattern>.from(_accessPatterns),
      anomalies: List<StatisticsAnomaly>.from(_anomalies),
      generatedAt: DateTime.now(),
      totalOperations: _recentOperations.length,
      recentOperations:
          _recentOperations.take(config.maxRecentOperationsHistory).toList(),
    );
  }

  /// Obtém estatísticas em tempo real
  RealTimeStatistics getRealTimeStatistics() {
    return _realTimeStats.copy();
  }

  /// Gera relatório de performance
  Future<PerformanceReport> generatePerformanceReport() async {
    return PerformanceReport.generate(
      repositoryName: repositoryName,
      operationStats: _operationStats,
      recentOperations: _recentOperations,
      anomalies: _anomalies,
    );
  }

  /// Obtém duração média de uma operação
  double? getAverageOperationDuration(String operationName) {
    final stats = _operationStats[operationName];
    return stats?.averageDuration?.inMilliseconds.toDouble();
  }

  /// Obtém tamanho médio de resultado de uma operação
  double? getAverageResultSize(String operationName) {
    final stats = _operationStats[operationName];
    return stats?.averageResultSize;
  }

  /// Verifica se precisa fazer flush
  bool needsFlush() {
    if (_lastFlush == null) return true;
    return DateTime.now().difference(_lastFlush!) > config.flushInterval;
  }

  /// Faz flush das estatísticas
  Future<void> flush() async {
    // Implementação futura para persistir estatísticas
    _lastFlush = DateTime.now();
  }

  /// Reseta estatísticas
  void reset() {
    _operationStats.clear();
    _recentOperations.clear();
    _accessPatterns.clear();
    _anomalies.clear();
    _realTimeStats.reset();
    _lastFlush = null;
  }

  /// Dispõe recursos
  void dispose() {
    reset();
  }

  /// Obtém ou cria estatísticas para uma operação
  OperationStatistics _getOrCreateOperationStats(String operationName) {
    return _operationStats.putIfAbsent(
        operationName, () => OperationStatistics(operationName));
  }

  /// Adiciona operação ao histórico recente
  void _addToRecentOperations(OperationRecord record) {
    _recentOperations.add(record);

    // Manter apenas as operações recentes
    while (_recentOperations.length > config.maxRecentOperationsHistory) {
      _recentOperations.removeFirst();
    }
  }
}

// Classes auxiliares para estatísticas (implementação simplificada)

class OperationStatistics {
  final String operationName;
  int attempts = 0;
  int successes = 0;
  int failures = 0;
  int slowOperations = 0;
  final List<Duration> durations = [];
  final List<double> resultSizes = [];
  final Map<String, int> failureTypes = {};

  OperationStatistics(this.operationName);

  void recordAttempt() => attempts++;

  void recordSuccess(Duration duration, Map<String, dynamic> resultMetrics) {
    successes++;
    durations.add(duration);

    if (resultMetrics['result_size'] is int) {
      resultSizes.add((resultMetrics['result_size'] as int).toDouble());
    }
  }

  void recordFailure(Duration duration, dynamic exception) {
    failures++;
    durations.add(duration);

    final exceptionType = exception.runtimeType.toString();
    failureTypes[exceptionType] = (failureTypes[exceptionType] ?? 0) + 1;
  }

  void recordSlowOperation(Duration duration) {
    slowOperations++;
  }

  void recordFailurePattern(
      dynamic exception, Map<String, dynamic> parameters) {
    // Implementação futura para análise de padrões de falha
  }

  Duration? get averageDuration {
    if (durations.isEmpty) return null;
    final total = durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
    return Duration(milliseconds: total ~/ durations.length);
  }

  double? get averageResultSize {
    if (resultSizes.isEmpty) return null;
    return resultSizes.fold<double>(0, (sum, size) => sum + size) /
        resultSizes.length;
  }

  double get successRate {
    if (attempts == 0) return 0.0;
    return successes / attempts;
  }

  OperationStatistics copy() {
    final copy = OperationStatistics(operationName);
    copy.attempts = attempts;
    copy.successes = successes;
    copy.failures = failures;
    copy.slowOperations = slowOperations;
    copy.durations.addAll(durations);
    copy.resultSizes.addAll(resultSizes);
    copy.failureTypes.addAll(failureTypes);
    return copy;
  }
}

class AccessPattern {
  final String operationName;
  final Map<String, int> parameterPatterns = {};
  int accessCount = 0;

  AccessPattern(this.operationName);

  void recordAccess(Map<String, dynamic> parameters) {
    accessCount++;
    // Implementação simplificada - pode ser expandida
  }
}

class StatisticsAnomaly {
  final AnomalyType type;
  final String operationName;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  StatisticsAnomaly({
    required this.type,
    required this.operationName,
    required this.timestamp,
    required this.context,
  });
}

enum AnomalyType {
  slowOperation,
  highFailureRate,
  largeResult,
  unusualPattern,
}

class RealTimeStatistics {
  final String repositoryName;
  final Map<String, int> operationCounts = {};
  final Map<String, Duration> lastOperationDurations = {};
  DateTime lastUpdate = DateTime.now();

  RealTimeStatistics(this.repositoryName);

  void update(String operationName, Duration duration, bool success) {
    operationCounts[operationName] = (operationCounts[operationName] ?? 0) + 1;
    lastOperationDurations[operationName] = duration;
    lastUpdate = DateTime.now();
  }

  void reset() {
    operationCounts.clear();
    lastOperationDurations.clear();
    lastUpdate = DateTime.now();
  }

  RealTimeStatistics copy() {
    final copy = RealTimeStatistics(repositoryName);
    copy.operationCounts.addAll(operationCounts);
    copy.lastOperationDurations.addAll(lastOperationDurations);
    copy.lastUpdate = lastUpdate;
    return copy;
  }
}

class AggregatedStatistics {
  final String repositoryName;
  final Map<String, OperationStatistics> operationStatistics;
  final Map<String, AccessPattern> accessPatterns;
  final List<StatisticsAnomaly> anomalies;
  final DateTime generatedAt;
  final int totalOperations;
  final List<OperationRecord> recentOperations;

  AggregatedStatistics({
    required this.repositoryName,
    required this.operationStatistics,
    required this.accessPatterns,
    required this.anomalies,
    required this.generatedAt,
    required this.totalOperations,
    required this.recentOperations,
  });

  factory AggregatedStatistics.empty(String repositoryName) {
    return AggregatedStatistics(
      repositoryName: repositoryName,
      operationStatistics: {},
      accessPatterns: {},
      anomalies: [],
      generatedAt: DateTime.now(),
      totalOperations: 0,
      recentOperations: [],
    );
  }
}

class OperationRecord {
  final String operationName;
  final DateTime timestamp;
  final Duration duration;
  final bool success;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic>? resultMetrics;
  final dynamic exception;

  OperationRecord({
    required this.operationName,
    required this.timestamp,
    required this.duration,
    required this.success,
    required this.parameters,
    this.resultMetrics,
    this.exception,
  });
}

class PerformanceReport {
  final String repositoryName;
  final DateTime generatedAt;
  final Map<String, dynamic> summary;
  final List<String> recommendations;

  PerformanceReport({
    required this.repositoryName,
    required this.generatedAt,
    required this.summary,
    required this.recommendations,
  });

  factory PerformanceReport.empty(String repositoryName) {
    return PerformanceReport(
      repositoryName: repositoryName,
      generatedAt: DateTime.now(),
      summary: {},
      recommendations: [],
    );
  }

  static Future<PerformanceReport> generate({
    required String repositoryName,
    required Map<String, OperationStatistics> operationStats,
    required Queue<OperationRecord> recentOperations,
    required List<StatisticsAnomaly> anomalies,
  }) async {
    // Implementação futura para gerar relatório detalhado
    return PerformanceReport.empty(repositoryName);
  }
}

class CachedStatistics {
  final dynamic statistics;
  final DateTime cachedAt;
  final Duration ttl;

  CachedStatistics({
    required this.statistics,
    required this.cachedAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(cachedAt) > ttl;
}

/// Configuração do StatisticsAspect
class StatisticsAspectConfig {
  final bool enabled;
  final bool trackAccessPatterns;
  final bool detectSlowOperations;
  final bool detectAnomalies;
  final bool trackFailurePatterns;
  final bool realTimeStatistics;
  final bool autoFlushStatistics;
  final bool autoCleanup;

  final Duration slowOperationThreshold;
  final double anomalyThresholdMultiplier;
  final Duration statisticsCacheTtl;
  final Duration flushInterval;
  final Duration cleanupInterval;

  final int maxRecentOperationsHistory;
  final int maxAnomaliesHistory;

  final Set<String> includedOperations;
  final Set<String> excludedOperations;

  const StatisticsAspectConfig({
    this.enabled = true,
    this.trackAccessPatterns = true,
    this.detectSlowOperations = true,
    this.detectAnomalies = true,
    this.trackFailurePatterns = true,
    this.realTimeStatistics = true,
    this.autoFlushStatistics = false,
    this.autoCleanup = true,
    this.slowOperationThreshold = const Duration(milliseconds: 1000),
    this.anomalyThresholdMultiplier = 3.0,
    this.statisticsCacheTtl = const Duration(minutes: 5),
    this.flushInterval = const Duration(minutes: 10),
    this.cleanupInterval = const Duration(hours: 1),
    this.maxRecentOperationsHistory = 100,
    this.maxAnomaliesHistory = 50,
    this.includedOperations = const {},
    this.excludedOperations = const {},
  });

  /// Configuração de produção (menos overhead)
  factory StatisticsAspectConfig.production() {
    return const StatisticsAspectConfig(
      trackAccessPatterns: false,
      detectAnomalies: false,
      realTimeStatistics: false,
      autoFlushStatistics: true,
      maxRecentOperationsHistory: 50,
      maxAnomaliesHistory: 20,
      flushInterval: Duration(minutes: 30),
    );
  }

  /// Configuração de desenvolvimento (mais detalhes)
  factory StatisticsAspectConfig.development() {
    return const StatisticsAspectConfig(
      trackAccessPatterns: true,
      detectAnomalies: true,
      realTimeStatistics: true,
      autoFlushStatistics: false,
      slowOperationThreshold: Duration(milliseconds: 500),
      anomalyThresholdMultiplier: 2.0,
      maxRecentOperationsHistory: 200,
      maxAnomaliesHistory: 100,
    );
  }
}
