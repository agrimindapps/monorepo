import 'dart:async';
import 'dart:convert';
import 'package:core/core.dart';

/// A utility for benchmarking the performance of synchronous and asynchronous operations.
///
/// This class measures execution time and provides methods to generate reports
/// and export results, helping to validate and compare optimizations.
class PerformanceBenchmark {
  PerformanceBenchmark._();

  static final List<BenchmarkResult> _results = [];

  /// Measures the execution time of an asynchronous [operation].
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    return _measureOperation(operationName, operation) as Future<T>;
  }

  /// Measures the execution time of a synchronous [operation].
  static T measureSync<T>(
    String operationName,
    T Function() operation,
  ) {
    return _measureOperation(operationName, operation) as T;
  }

  /// Private helper to measure and record the performance of an operation.
  static FutureOr<T> _measureOperation<T>(
    String operationName,
    Function operation,
  ) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = operation();
      if (result is Future) {
        return result.then((value) {
          stopwatch.stop();
          _addResult(operationName, stopwatch.elapsed, success: true);
          return value;
        }).catchError((e) {
          stopwatch.stop();
          _addResult(operationName, stopwatch.elapsed, success: false, error: e);
          throw e;
        });
      } else {
        stopwatch.stop();
        _addResult(operationName, stopwatch.elapsed, success: true);
        return result;
      }
    } catch (e) {
      stopwatch.stop();
      _addResult(operationName, stopwatch.elapsed, success: false, error: e);
      rethrow;
    }
  }

  /// Adds a benchmark result to the internal list and logs it.
  static void _addResult(
    String operationName,
    Duration duration, {
    required bool success,
    dynamic error,
  }) {
    final result = BenchmarkResult(
      operationName: operationName,
      duration: duration,
      timestamp: DateTime.now(),
      success: success,
      error: error?.toString(),
    );
    _results.add(result);
    Logger.debug(
      '[BENCHMARK] ${result.operationName}: ${result.duration.inMilliseconds}ms ${success ? "✅" : "❌"}',
      name: 'Performance',
    );
  }

  /// Returns an unmodifiable list of all benchmark results.
  static List<BenchmarkResult> getResults() => List.unmodifiable(_results);

  /// Calculates and returns performance statistics for a specific operation.
  static OperationStats getOperationStats(String operationName) {
    final durations = _results
        .where((r) => r.operationName == operationName && r.success)
        .map((r) => r.duration.inMilliseconds)
        .toList();

    if (durations.isEmpty) {
      return OperationStats.empty(operationName);
    }

    durations.sort();
    final totalDuration = durations.reduce((a, b) => a + b);

    return OperationStats(
      operationName: operationName,
      totalExecutions: durations.length,
      averageDuration: totalDuration / durations.length,
      minDuration: durations.first,
      maxDuration: durations.last,
    );
  }

  /// Generates a formatted string report of all captured performance data.
  static String generateReport() {
    final buffer = StringBuffer()
      ..writeln('===== PERFORMANCE REPORT =====')
      ..writeln('Generated at: ${DateTime.now()}')
      ..writeln('Total operations measured: ${_results.length}')
      ..writeln();

    final operationNames = _results.map((r) => r.operationName).toSet();
    for (final name in operationNames) {
      final stats = getOperationStats(name);
      if (stats.totalExecutions == 0) continue;

      buffer
        ..writeln('--- $name ---')
        ..writeln('Executions: ${stats.totalExecutions}')
        ..writeln('Average Time: ${stats.averageDuration.toStringAsFixed(1)}ms')
        ..writeln('Min Time: ${stats.minDuration}ms')
        ..writeln('Max Time: ${stats.maxDuration}ms')
        ..writeln('Classification: ${stats.classification}')
        ..writeln();
    }

    _addComparativeAnalysis(buffer);
    return buffer.toString();
  }

  /// Clears all stored benchmark results.
  static void clearResults() => _results.clear();

  /// Exports all results and a summary to a JSON-serializable map.
  static Map<String, dynamic> exportToJson() {
    final operationNames = _results.map((r) => r.operationName).toSet();
    return {
      'reportTimestamp': DateTime.now().toIso8601String(),
      'totalResults': _results.length,
      'results': _results.map((r) => r.toJson()).toList(),
      'summary': {
        for (final name in operationNames)
          name: getOperationStats(name).toJson(),
      },
    };
  }

  /// Adds a comparative analysis section to the report for A/B testing.
  ///
  /// This method looks for operation names ending in `_before` and `_after`
  /// to compare their performance.
  static void _addComparativeAnalysis(StringBuffer buffer) {
    final pairs = <String, ({List<BenchmarkResult> before, List<BenchmarkResult> after})>{};

    for (final result in _results) {
      final isBefore = result.operationName.endsWith('_before');
      final isAfter = result.operationName.endsWith('_after');
      if (isBefore || isAfter) {
        final baseName = result.operationName.replaceAll(RegExp(r'_before$|_after$'), '');
        final entry = pairs.putIfAbsent(baseName, () => (before: [], after: []));
        if (isBefore) entry.before.add(result);
        if (isAfter) entry.after.add(result);
      }
    }

    if (pairs.isNotEmpty) {
      buffer.writeln('===== COMPARATIVE ANALYSIS =====');
      for (final MapEntry(key: baseName, value: record) in pairs.entries) {
        if (record.before.isNotEmpty && record.after.isNotEmpty) {
          final beforeAvg = getOperationStats('${baseName}_before').averageDuration;
          final afterAvg = getOperationStats('${baseName}_after').averageDuration;
          final improvement = ((beforeAvg - afterAvg) / beforeAvg * 100);

          buffer
            ..writeln('$baseName:')
            ..writeln('  Before: ${beforeAvg.toStringAsFixed(1)}ms')
            ..writeln('  After: ${afterAvg.toStringAsFixed(1)}ms')
            ..writeln('  Improvement: ${improvement.toStringAsFixed(1)}%')
            ..writeln('  Status: ${improvement > 20 ? '🚀 SIGNIFICANT OPTIMIZATION' : improvement > 0 ? '✅ IMPROVEMENT DETECTED' : '⚠️ NO IMPROVEMENT'}')
            ..writeln();
        }
      }
    }
  }
}

/// Represents the result of a single benchmark measurement.
class BenchmarkResult {
  final String operationName;
  final Duration duration;
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
        'durationMs': duration.inMilliseconds,
        'timestamp': timestamp.toIso8601String(),
        'success': success,
        if (error != null) 'error': error,
      };
}

/// Holds aggregated statistics for a set of benchmark measurements.
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

  factory OperationStats.empty(String operationName) {
    return OperationStats(
      operationName: operationName,
      totalExecutions: 0,
      averageDuration: 0,
      minDuration: 0,
      maxDuration: 0,
    );
  }

  /// A human-readable classification of the operation's performance.
  String get classification {
    if (averageDuration < 50) return '✅ EXCELLENT';
    if (averageDuration < 200) return '🟡 GOOD';
    if (averageDuration < 500) return '🟠 ACCEPTABLE';
    return '❌ SLOW';
  }

  Map<String, dynamic> toJson() => {
        'operationName': operationName,
        'totalExecutions': totalExecutions,
        'averageDurationMs': averageDuration,
        'minDurationMs': minDuration,
        'maxDurationMs': maxDuration,
        'classification': classification,
      };
}