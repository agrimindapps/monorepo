// Flutter imports:
import 'package:flutter/foundation.dart';

/// Monitor de performance para lazy loading de controllers
/// Mede e reporta métricas de inicialização e uso de memória
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._();
  PerformanceMonitor._();

  final Map<String, PerformanceMetric> _metrics = {};
  DateTime? _appStartTime;
  DateTime? _firstControllerReady;

  /// Inicializar monitoramento
  void initialize() {
    _appStartTime = DateTime.now();
    debugPrint('📊 PerformanceMonitor iniciado');
  }

  /// Marcar início de uma operação
  void startOperation(String operationName) {
    _metrics[operationName] = PerformanceMetric(
      name: operationName,
      startTime: DateTime.now(),
    );
  }

  /// Marcar fim de uma operação
  void endOperation(String operationName, {bool success = true, String? error}) {
    final metric = _metrics[operationName];
    if (metric != null) {
      metric.endTime = DateTime.now();
      metric.success = success;
      metric.error = error;
      
      if (success) {
        debugPrint('✅ $operationName: ${metric.durationMs}ms');
      } else {
        debugPrint('❌ $operationName falhou: $error (${metric.durationMs}ms)');
      }
      
      // Marcar primeiro controller pronto
      if (_firstControllerReady == null && success && operationName.contains('Controller')) {
        _firstControllerReady = DateTime.now();
      }
    }
  }

  /// Obter métricas de uma operação
  PerformanceMetric? getMetric(String operationName) {
    return _metrics[operationName];
  }

  /// Obter todas as métricas
  Map<String, PerformanceMetric> getAllMetrics() {
    return Map.from(_metrics);
  }

  /// Obter tempo total até primeiro controller
  Duration? get timeToFirstController {
    if (_appStartTime != null && _firstControllerReady != null) {
      return _firstControllerReady!.difference(_appStartTime!);
    }
    return null;
  }

  /// Gerar relatório de performance
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('📊 === RELATÓRIO DE PERFORMANCE ===');
    
    if (_appStartTime != null) {
      buffer.writeln('🚀 App iniciado em: ${_appStartTime!.toIso8601String()}');
    }
    
    if (timeToFirstController != null) {
      buffer.writeln('⚡ Tempo até primeiro controller: ${timeToFirstController!.inMilliseconds}ms');
    }
    
    buffer.writeln('📈 Métricas por operação:');
    
    final sortedMetrics = _metrics.values.toList()
      ..sort((a, b) => a.durationMs.compareTo(b.durationMs));
    
    for (final metric in sortedMetrics) {
      final status = metric.success ? '✅' : '❌';
      buffer.writeln('   $status ${metric.name}: ${metric.durationMs}ms');
      if (!metric.success && metric.error != null) {
        buffer.writeln('      Erro: ${metric.error}');
      }
    }
    
    // Estatísticas resumidas
    final totalOperations = _metrics.length;
    final successfulOperations = _metrics.values.where((m) => m.success).length;
    final averageDuration = _metrics.values.isEmpty 
      ? 0 
      : _metrics.values.map((m) => m.durationMs).reduce((a, b) => a + b) / _metrics.length;
    
    buffer.writeln('📋 Resumo:');
    buffer.writeln('   • Total de operações: $totalOperations');
    buffer.writeln('   • Operações bem-sucedidas: $successfulOperations');
    buffer.writeln('   • Taxa de sucesso: ${(successfulOperations / totalOperations * 100).toStringAsFixed(1)}%');
    buffer.writeln('   • Duração média: ${averageDuration.toStringAsFixed(1)}ms');
    
    return buffer.toString();
  }

  /// Imprimir relatório no console
  void printReport() {
    if (kDebugMode) {
      debugPrint(generateReport());
    }
  }

  /// Resetar métricas (útil para testes)
  @visibleForTesting
  void reset() {
    _metrics.clear();
    _appStartTime = null;
    _firstControllerReady = null;
  }

  /// Obter métricas em formato JSON
  Map<String, dynamic> toJson() {
    return {
      'appStartTime': _appStartTime?.toIso8601String(),
      'firstControllerReady': _firstControllerReady?.toIso8601String(),
      'timeToFirstControllerMs': timeToFirstController?.inMilliseconds,
      'metrics': _metrics.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

/// Métrica de performance individual
class PerformanceMetric {
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  bool success = false;
  String? error;

  PerformanceMetric({
    required this.name,
    required this.startTime,
    this.endTime,
    this.success = false,
    this.error,
  });

  /// Duração da operação em milissegundos
  int get durationMs {
    if (endTime != null) {
      return endTime!.difference(startTime).inMilliseconds;
    }
    return DateTime.now().difference(startTime).inMilliseconds;
  }

  /// Verificar se operação está em andamento
  bool get isRunning => endTime == null;

  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMs': durationMs,
      'success': success,
      'error': error,
      'isRunning': isRunning,
    };
  }

  @override
  String toString() {
    return 'PerformanceMetric(name: $name, duration: ${durationMs}ms, success: $success)';
  }
}
