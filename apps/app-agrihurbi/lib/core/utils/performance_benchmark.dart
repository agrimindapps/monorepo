import 'dart:async';

/// Utilitário para benchmark de performance das otimizações
/// 
/// Mede tempos de execução, memoria usage e FPS para validar melhorias
class PerformanceBenchmark {
  static final List<BenchmarkResult> _results = [];
  
  /// Executa benchmark de uma operação
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      stopwatch.stop();
      
      final benchmark = BenchmarkResult(
        operationName: operationName,
        duration: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
        success: true,
      );
      
      _results.add(benchmark);
      _logResult(benchmark);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      
      final benchmark = BenchmarkResult(
        operationName: operationName,
        duration: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
        success: false,
        error: e.toString(),
      );
      
      _results.add(benchmark);
      _logResult(benchmark);
      
      rethrow;
    }
  }
  
  /// Executa benchmark de operação síncrona
  static T measureSync<T>(
    String operationName,
    T Function() operation,
  ) {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = operation();
      stopwatch.stop();
      
      final benchmark = BenchmarkResult(
        operationName: operationName,
        duration: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
        success: true,
      );
      
      _results.add(benchmark);
      _logResult(benchmark);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      
      final benchmark = BenchmarkResult(
        operationName: operationName,
        duration: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
        success: false,
        error: e.toString(),
      );
      
      _results.add(benchmark);
      _logResult(benchmark);
      
      rethrow;
    }
  }
  
  /// Obtém resultados dos benchmarks
  static List<BenchmarkResult> getResults() => List.unmodifiable(_results);
  
  /// Obtém estatísticas de uma operação específica
  static OperationStats getOperationStats(String operationName) {
    final operationResults = _results
        .where((r) => r.operationName == operationName && r.success)
        .map((r) => r.duration)
        .toList();
    
    if (operationResults.isEmpty) {
      return OperationStats(
        operationName: operationName,
        totalExecutions: 0,
        averageDuration: 0,
        minDuration: 0,
        maxDuration: 0,
      );
    }
    
    operationResults.sort();
    
    return OperationStats(
      operationName: operationName,
      totalExecutions: operationResults.length,
      averageDuration: operationResults.reduce((a, b) => a + b) / operationResults.length,
      minDuration: operationResults.first,
      maxDuration: operationResults.last,
    );
  }
  
  /// Gera relatório de performance
  static String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== RELATÓRIO DE PERFORMANCE ===');
    buffer.writeln('Gerado em: ${DateTime.now()}');
    buffer.writeln('Total de operações medidas: ${_results.length}');
    buffer.writeln();
    
    // Agrupa por operação
    final operationNames = _results.map((r) => r.operationName).toSet();
    
    for (final operation in operationNames) {
      final stats = getOperationStats(operation);
      buffer.writeln('--- $operation ---');
      buffer.writeln('Execuções: ${stats.totalExecutions}');
      buffer.writeln('Tempo médio: ${stats.averageDuration.toStringAsFixed(1)}ms');
      buffer.writeln('Tempo mínimo: ${stats.minDuration}ms');
      buffer.writeln('Tempo máximo: ${stats.maxDuration}ms');
      
      // Classificação de performance
      String classification;
      if (stats.averageDuration < 50) {
        classification = '✅ EXCELENTE';
      } else if (stats.averageDuration < 200) {
        classification = '🟡 BOM';
      } else if (stats.averageDuration < 500) {
        classification = '🟠 ACEITÁVEL';
      } else {
        classification = '❌ LENTO';
      }
      buffer.writeln('Classificação: $classification');
      buffer.writeln();
    }
    
    // Comparativo antes/depois se existirem medições
    _addComparativeAnalysis(buffer);
    
    return buffer.toString();
  }
  
  /// Limpa resultados armazenados
  static void clearResults() {
    _results.clear();
  }
  
  /// Exporta resultados para JSON
  static Map<String, dynamic> exportToJson() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'totalResults': _results.length,
      'results': _results.map((r) => r.toJson()).toList(),
      'summary': {
        for (final operation in _results.map((r) => r.operationName).toSet())
          operation: getOperationStats(operation).toJson(),
      },
    };
  }
  
  static void _logResult(BenchmarkResult result) {
    print('🔍 [BENCHMARK] ${result.operationName}: ${result.duration}ms ${result.success ? "✅" : "❌"}');
  }
  
  static void _addComparativeAnalysis(StringBuffer buffer) {
    // Procura por pares "antes/depois" nas operações
    final beforeAfterPairs = <String, List<BenchmarkResult>>{};
    
    for (final result in _results) {
      if (result.operationName.contains('_antes') || result.operationName.contains('_depois')) {
        final baseOperation = result.operationName.replaceAll('_antes', '').replaceAll('_depois', '');
        beforeAfterPairs.putIfAbsent(baseOperation, () => []).add(result);
      }
    }
    
    if (beforeAfterPairs.isNotEmpty) {
      buffer.writeln('=== ANÁLISE COMPARATIVA ===');
      
      for (final entry in beforeAfterPairs.entries) {
        final operation = entry.key;
        final results = entry.value;
        
        final beforeResults = results.where((r) => r.operationName.contains('_antes')).toList();
        final afterResults = results.where((r) => r.operationName.contains('_depois')).toList();
        
        if (beforeResults.isNotEmpty && afterResults.isNotEmpty) {
          final beforeAvg = beforeResults.map((r) => r.duration).reduce((a, b) => a + b) / beforeResults.length;
          final afterAvg = afterResults.map((r) => r.duration).reduce((a, b) => a + b) / afterResults.length;
          
          final improvement = ((beforeAvg - afterAvg) / beforeAvg * 100);
          
          buffer.writeln('$operation:');
          buffer.writeln('  Antes: ${beforeAvg.toStringAsFixed(1)}ms');
          buffer.writeln('  Depois: ${afterAvg.toStringAsFixed(1)}ms');
          buffer.writeln('  Melhoria: ${improvement.toStringAsFixed(1)}%');
          
          if (improvement > 20) {
            buffer.writeln('  Status: 🚀 OTIMIZAÇÃO SIGNIFICATIVA');
          } else if (improvement > 0) {
            buffer.writeln('  Status: ✅ MELHORIA DETECTADA');
          } else {
            buffer.writeln('  Status: ⚠️ SEM MELHORIA');
          }
          buffer.writeln();
        }
      }
    }
  }
}

/// Resultado de um benchmark
class BenchmarkResult {
  final String operationName;
  final int duration;
  final DateTime timestamp;
  final bool success;
  final String? error;
  
  const BenchmarkResult({
    required this.operationName,
    required this.duration,
    required this.timestamp,
    required this.success,
    this.error,
  });
  
  Map<String, dynamic> toJson() => {
    'operationName': operationName,
    'duration': duration,
    'timestamp': timestamp.toIso8601String(),
    'success': success,
    if (error != null) 'error': error,
  };
}

/// Estatísticas de uma operação
class OperationStats {
  final String operationName;
  final int totalExecutions;
  final double averageDuration;
  final int minDuration;
  final int maxDuration;
  
  const OperationStats({
    required this.operationName,
    required this.totalExecutions,
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
  });
  
  Map<String, dynamic> toJson() => {
    'operationName': operationName,
    'totalExecutions': totalExecutions,
    'averageDuration': averageDuration,
    'minDuration': minDuration,
    'maxDuration': maxDuration,
  };
}