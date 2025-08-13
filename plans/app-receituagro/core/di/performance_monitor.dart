// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../core/services/logging_service.dart';

/// Monitor de performance especializado para sistema de DI
/// Responsabilidade única: medir, coletar e reportar métricas de performance
class DIPerformanceMonitor {
  static DIPerformanceMonitor? _instance;
  static DIPerformanceMonitor get instance => _instance ??= DIPerformanceMonitor._();
  
  DIPerformanceMonitor._();

  // Estado do monitor
  bool _isMonitoring = false;
  DateTime? _monitoringStarted;
  
  // Métricas coletadas
  final Map<String, PerformanceMetric> _metrics = {};
  final Map<String, List<Duration>> _operationTimes = {};
  final Map<String, int> _operationCounts = {};
  final List<PerformanceEvent> _events = [];
  
  // Configurações
  int _maxEventsHistory = 1000;
  Duration _metricsRetentionPeriod = const Duration(hours: 24);
  bool _enableDetailedTracking = kDebugMode;

  /// Inicia monitoramento de performance
  void startMonitoring({
    int? maxEventsHistory,
    Duration? retentionPeriod,
    bool? enableDetailedTracking,
  }) {
    if (_isMonitoring) {
      LoggingService.debug('Performance monitor já está ativo', tag: 'DIPerformanceMonitor');
      return;
    }

    _maxEventsHistory = maxEventsHistory ?? _maxEventsHistory;
    _metricsRetentionPeriod = retentionPeriod ?? _metricsRetentionPeriod;
    _enableDetailedTracking = enableDetailedTracking ?? _enableDetailedTracking;

    _isMonitoring = true;
    _monitoringStarted = DateTime.now();

    _startPeriodicCleanup();

    LoggingService.info(
      'Performance monitor iniciado (eventos: $_maxEventsHistory, retenção: ${_metricsRetentionPeriod.inHours}h)',
      tag: 'DIPerformanceMonitor'
    );
  }

  /// Para monitoramento de performance
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _periodicCleanupTimer?.cancel();
    _periodicCleanupTimer = null;

    LoggingService.info('Performance monitor parado', tag: 'DIPerformanceMonitor');
  }

  /// Registra início de uma operação
  /// 
  /// [operation] - Nome da operação
  /// [details] - Detalhes opcionais da operação
  /// Retorna token para usar em [endTracking]
  String startTracking(String operation, {Map<String, dynamic>? details}) {
    if (!_isMonitoring) return '';

    final token = _generateToken();
    final event = PerformanceEvent(
      token: token,
      operation: operation,
      type: EventType.start,
      timestamp: DateTime.now(),
      details: details,
    );

    _events.add(event);
    _enforceEventsLimit();

    if (_enableDetailedTracking) {
      LoggingService.debug(
        'Iniciando tracking: $operation (token: $token)',
        tag: 'DIPerformanceMonitor'
      );
    }

    return token;
  }

  /// Registra fim de uma operação
  /// 
  /// [token] - Token retornado por [startTracking]
  /// [success] - Se a operação foi bem-sucedida
  /// [details] - Detalhes opcionais do resultado
  void endTracking(String token, {bool success = true, Map<String, dynamic>? details}) {
    if (!_isMonitoring || token.isEmpty) return;

    final startEvent = _findStartEvent(token);
    if (startEvent == null) {
      LoggingService.warning('Token de tracking não encontrado: $token', tag: 'DIPerformanceMonitor');
      return;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startEvent.timestamp);
    
    final endEvent = PerformanceEvent(
      token: token,
      operation: startEvent.operation,
      type: EventType.end,
      timestamp: endTime,
      duration: duration,
      success: success,
      details: details,
    );

    _events.add(endEvent);
    _enforceEventsLimit();

    // Atualiza métricas
    _updateMetrics(startEvent.operation, duration, success);

    if (_enableDetailedTracking) {
      LoggingService.debug(
        'Finalizando tracking: ${startEvent.operation} (${duration.inMilliseconds}ms, ${success ? 'sucesso' : 'falha'})',
        tag: 'DIPerformanceMonitor'
      );
    }
  }

  /// Registra um evento de erro
  /// 
  /// [operation] - Nome da operação que falhou
  /// [error] - Erro ocorrido
  /// [stackTrace] - Stack trace opcional
  void recordError(String operation, dynamic error, [StackTrace? stackTrace]) {
    if (!_isMonitoring) return;

    final event = PerformanceEvent(
      token: _generateToken(),
      operation: operation,
      type: EventType.error,
      timestamp: DateTime.now(),
      success: false,
      details: {
        'error': error.toString(),
        'stackTrace': stackTrace?.toString(),
      },
    );

    _events.add(event);
    _enforceEventsLimit();

    // Atualiza contador de erros
    _operationCounts['${operation}_errors'] = (_operationCounts['${operation}_errors'] ?? 0) + 1;

    LoggingService.error(
      'Erro registrado para operação: $operation',
      tag: 'DIPerformanceMonitor',
      error: error,
      stackTrace: stackTrace
    );
  }

  /// Obtém métricas de uma operação específica
  /// 
  /// [operation] - Nome da operação
  PerformanceMetric? getMetricFor(String operation) {
    return _metrics[operation];
  }

  /// Obtém todas as métricas disponíveis
  Map<String, PerformanceMetric> getAllMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// Gera relatório de performance
  /// 
  /// [detailed] - Se deve incluir detalhes completos
  /// [operations] - Operações específicas para incluir no relatório
  String generateReport({bool detailed = false, List<String>? operations}) {
    if (!_isMonitoring && _metrics.isEmpty) {
      return 'Performance monitor não ativo ou sem dados';
    }

    final buffer = StringBuffer();
    final now = DateTime.now();
    final uptime = _monitoringStarted != null 
        ? now.difference(_monitoringStarted!)
        : Duration.zero;

    // Cabeçalho
    buffer.writeln('🔍 RELATÓRIO DE PERFORMANCE - DI SYSTEM');
    buffer.writeln('════════════════════════════════════════');
    buffer.writeln('Data: ${now.toLocal()}');
    buffer.writeln('Uptime: ${_formatDuration(uptime)}');
    buffer.writeln('Status: ${_isMonitoring ? "Ativo" : "Inativo"}');
    buffer.writeln('Eventos: ${_events.length}');
    buffer.writeln('');

    // Resumo geral
    if (_metrics.isNotEmpty) {
      buffer.writeln('📊 RESUMO GERAL');
      buffer.writeln('────────────────');
      
      final totalOperations = _metrics.values.fold(0, (sum, m) => sum + m.totalCalls);
      final totalErrors = _operationCounts.entries
          .where((e) => e.key.endsWith('_errors'))
          .fold(0, (sum, e) => sum + e.value);
      
      final avgResponseTime = _calculateOverallAverageTime();
      
      buffer.writeln('Total de operações: $totalOperations');
      buffer.writeln('Total de erros: $totalErrors');
      buffer.writeln('Tempo médio: ${avgResponseTime?.inMilliseconds ?? 0}ms');
      buffer.writeln('');
    }

    // Métricas por operação
    final targetOperations = operations ?? _metrics.keys.toList()..sort();
    
    if (targetOperations.isNotEmpty) {
      buffer.writeln('⚡ MÉTRICAS POR OPERAÇÃO');
      buffer.writeln('─────────────────────────');
      
      for (final operation in targetOperations) {
        final metric = _metrics[operation];
        if (metric == null) continue;

        buffer.writeln('🔹 $operation');
        buffer.writeln('   Chamadas: ${metric.totalCalls}');
        buffer.writeln('   Sucessos: ${metric.successCalls} (${((metric.successCalls / metric.totalCalls) * 100).toStringAsFixed(1)}%)');
        buffer.writeln('   Falhas: ${metric.errorCalls}');
        buffer.writeln('   Tempo médio: ${metric.averageTime.inMilliseconds}ms');
        buffer.writeln('   Tempo min: ${metric.minTime.inMilliseconds}ms');
        buffer.writeln('   Tempo max: ${metric.maxTime.inMilliseconds}ms');
        
        if (detailed) {
          final times = _operationTimes[operation];
          if (times != null && times.isNotEmpty) {
            final p95 = _calculatePercentile(times, 0.95);
            final p99 = _calculatePercentile(times, 0.99);
            buffer.writeln('   P95: ${p95.inMilliseconds}ms');
            buffer.writeln('   P99: ${p99.inMilliseconds}ms');
          }
        }
        buffer.writeln('');
      }
    }

    // Eventos recentes (apenas em modo detalhado)
    if (detailed && _events.isNotEmpty) {
      buffer.writeln('📝 EVENTOS RECENTES (últimos 10)');
      buffer.writeln('─────────────────────────────────');
      
      final recentEvents = _events
          .where((e) => now.difference(e.timestamp) < const Duration(minutes: 10))
          .take(10)
          .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      for (final event in recentEvents) {
        buffer.writeln('${_formatTime(event.timestamp)} [${event.type.name}] ${event.operation}');
        if (event.duration != null) {
          buffer.writeln('   Duração: ${event.duration!.inMilliseconds}ms');
        }
        if (!event.success) {
          buffer.writeln('   ❌ FALHA');
        }
      }
      buffer.writeln('');
    }

    // Recomendações
    buffer.writeln('💡 RECOMENDAÇÕES');
    buffer.writeln('──────────────────');
    
    final recommendations = _generateRecommendations();
    if (recommendations.isEmpty) {
      buffer.writeln('Nenhuma recomendação no momento.');
    } else {
      for (final rec in recommendations) {
        buffer.writeln('• $rec');
      }
    }

    return buffer.toString();
  }

  /// Exporta dados para análise externa
  Map<String, dynamic> exportData() {
    return {
      'monitoring': {
        'isActive': _isMonitoring,
        'startedAt': _monitoringStarted?.toIso8601String(),
        'uptime': _monitoringStarted != null 
            ? DateTime.now().difference(_monitoringStarted!).inMilliseconds
            : 0,
      },
      'metrics': _metrics.map((k, v) => MapEntry(k, v.toMap())),
      'operationCounts': Map.from(_operationCounts),
      'events': _events.map((e) => e.toMap()).toList(),
      'config': {
        'maxEvents': _maxEventsHistory,
        'retentionHours': _metricsRetentionPeriod.inHours,
        'detailedTracking': _enableDetailedTracking,
      },
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Limpa dados históricos
  void clearHistory() {
    _events.clear();
    _metrics.clear();
    _operationTimes.clear();
    _operationCounts.clear();
    
    LoggingService.info('Histórico de performance limpo', tag: 'DIPerformanceMonitor');
  }

  /// Verifica se monitor está ativo
  bool get isMonitoring => _isMonitoring;

  /// Obtém estatísticas gerais
  Map<String, dynamic> getStats() {
    return {
      'isMonitoring': _isMonitoring,
      'eventsCount': _events.length,
      'metricsCount': _metrics.length,
      'uptime': _monitoringStarted != null 
          ? DateTime.now().difference(_monitoringStarted!).inMilliseconds
          : 0,
    };
  }

  // Métodos privados

  Timer? _periodicCleanupTimer;

  void _startPeriodicCleanup() {
    _periodicCleanupTimer?.cancel();
    _periodicCleanupTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _cleanupOldData(),
    );
  }

  void _cleanupOldData() {
    final cutoff = DateTime.now().subtract(_metricsRetentionPeriod);
    _events.removeWhere((event) => event.timestamp.isBefore(cutoff));
    
    LoggingService.debug(
      'Limpeza automática executada (eventos mantidos: ${_events.length})',
      tag: 'DIPerformanceMonitor'
    );
  }

  String _generateToken() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  PerformanceEvent? _findStartEvent(String token) {
    try {
      return _events.firstWhere(
        (event) => event.token == token && event.type == EventType.start,
      );
    } catch (e) {
      return null;
    }
  }

  void _updateMetrics(String operation, Duration duration, bool success) {
    final metric = _metrics[operation] ?? PerformanceMetric(operation: operation);
    
    metric.totalCalls++;
    if (success) {
      metric.successCalls++;
    } else {
      metric.errorCalls++;
    }

    // Atualiza tempos
    final times = _operationTimes[operation] ??= [];
    times.add(duration);

    if (metric.minTime.compareTo(duration) > 0) {
      metric.minTime = duration;
    }
    if (metric.maxTime.compareTo(duration) < 0) {
      metric.maxTime = duration;
    }

    // Recalcula média
    final totalTime = times.fold(Duration.zero, (sum, time) => sum + time);
    metric.averageTime = Duration(
      microseconds: totalTime.inMicroseconds ~/ times.length,
    );

    _metrics[operation] = metric;
  }

  void _enforceEventsLimit() {
    while (_events.length > _maxEventsHistory) {
      _events.removeAt(0);
    }
  }

  Duration? _calculateOverallAverageTime() {
    if (_operationTimes.isEmpty) return null;

    var totalMicroseconds = 0;
    var totalCount = 0;

    for (final times in _operationTimes.values) {
      for (final time in times) {
        totalMicroseconds += time.inMicroseconds;
        totalCount++;
      }
    }

    return totalCount > 0
        ? Duration(microseconds: totalMicroseconds ~/ totalCount)
        : null;
  }

  Duration _calculatePercentile(List<Duration> times, double percentile) {
    final sorted = List<Duration>.from(times)..sort();
    final index = ((sorted.length - 1) * percentile).round();
    return sorted[index];
  }

  List<String> _generateRecommendations() {
    final recommendations = <String>[];

    for (final entry in _metrics.entries) {
      final operation = entry.key;
      final metric = entry.value;

      // Operações lentas
      if (metric.averageTime.inMilliseconds > 1000) {
        recommendations.add('Operação "$operation" está lenta (${metric.averageTime.inMilliseconds}ms médio)');
      }

      // Alta taxa de erro
      final errorRate = metric.errorCalls / metric.totalCalls;
      if (errorRate > 0.1) {
        recommendations.add('Operação "$operation" tem alta taxa de erro (${(errorRate * 100).toStringAsFixed(1)}%)');
      }

      // Muitas chamadas
      if (metric.totalCalls > 10000) {
        recommendations.add('Operação "$operation" tem muitas chamadas (${metric.totalCalls}). Considere caching.');
      }
    }

    return recommendations;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }

  /// Limpa instância (para testes)
  static void resetInstance() {
    _instance?.stopMonitoring();
    _instance = null;
  }
}

/// Métrica de performance para uma operação
class PerformanceMetric {
  final String operation;
  int totalCalls = 0;
  int successCalls = 0;
  int errorCalls = 0;
  Duration averageTime = Duration.zero;
  Duration minTime = const Duration(days: 1); // Valor alto inicial
  Duration maxTime = Duration.zero;

  PerformanceMetric({required this.operation});

  Map<String, dynamic> toMap() {
    return {
      'operation': operation,
      'totalCalls': totalCalls,
      'successCalls': successCalls,
      'errorCalls': errorCalls,
      'averageTimeMs': averageTime.inMilliseconds,
      'minTimeMs': minTime == const Duration(days: 1) ? 0 : minTime.inMilliseconds,
      'maxTimeMs': maxTime.inMilliseconds,
    };
  }
}

/// Evento de performance registrado
class PerformanceEvent {
  final String token;
  final String operation;
  final EventType type;
  final DateTime timestamp;
  final Duration? duration;
  final bool success;
  final Map<String, dynamic>? details;

  const PerformanceEvent({
    required this.token,
    required this.operation,
    required this.type,
    required this.timestamp,
    this.duration,
    this.success = true,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'operation': operation,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'durationMs': duration?.inMilliseconds,
      'success': success,
      'details': details,
    };
  }
}

/// Tipos de eventos de performance
enum EventType {
  start('start'),
  end('end'),
  error('error');

  const EventType(this.name);
  final String name;
}