// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../utils/type_conversion_utils.dart';

/// Serviço para otimização de performance na inicialização
class PerformanceOptimizationService {
  // Pool de TextEditingController para reutilização
  static final Map<String, TextEditingController> _controllerPool = {};

  // Cache para valores computados
  static final Map<String, dynamic> _computedCache = {};

  // Cache para formatação de valores
  static final Map<String, String> _formatCache = {};

  /// Obtém um TextEditingController do pool ou cria um novo
  static TextEditingController getOrCreateController(String key,
      {String? initialValue}) {
    if (_controllerPool.containsKey(key)) {
      final controller = _controllerPool[key]!;
      if (initialValue != null) {
        controller.text = initialValue;
      }
      return controller;
    }

    final controller = TextEditingController(text: initialValue ?? '');
    _controllerPool[key] = controller;
    return controller;
  }

  /// Libera um controller do pool
  static void releaseController(String key) {
    final controller = _controllerPool.remove(key);
    controller?.dispose();
  }

  /// Limpa todos os controllers não utilizados
  static void clearControllerPool() {
    for (final controller in _controllerPool.values) {
      controller.dispose();
    }
    _controllerPool.clear();
  }

  /// Conversão lazy de string para double
  static double lazyDoubleConversion(String value, String cacheKey) {
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey] as double;
    }

    final result = TypeConversionUtils.safeDoubleFromString(value);
    _computedCache[cacheKey] = result;
    return result;
  }

  /// Formatação lazy de valores
  static String lazyFormatting(
      dynamic value, String cacheKey, String Function() formatter) {
    if (_formatCache.containsKey(cacheKey)) {
      return _formatCache[cacheKey]!;
    }

    final result = formatter();
    _formatCache[cacheKey] = result;
    return result;
  }

  /// Limpa cache de valores computados
  static void clearComputedCache() {
    _computedCache.clear();
  }

  /// Limpa cache de formatação
  static void clearFormatCache() {
    _formatCache.clear();
  }

  /// Limpa todos os caches
  static void clearAllCaches() {
    clearComputedCache();
    clearFormatCache();
  }

  /// Inicialização assíncrona diferida
  static Future<T> deferredInitialization<T>(
      Future<T> Function() initializer) async {
    // Adiciona um pequeno delay para não bloquear a UI
    await Future.delayed(const Duration(milliseconds: 1));
    return await initializer();
  }

  /// Executa operação com throttling
  static Future<T> throttledOperation<T>(
      String operationKey, Future<T> Function() operation,
      {Duration throttleDuration = const Duration(milliseconds: 100)}) async {
    final lastExecution = _computedCache['throttle_$operationKey'] as DateTime?;
    final now = DateTime.now();

    if (lastExecution != null &&
        now.difference(lastExecution) < throttleDuration) {
      // Retorna valor em cache se ainda dentro do período de throttling
      return _computedCache['throttle_result_$operationKey'] as T;
    }

    final result = await operation();
    _computedCache['throttle_$operationKey'] = now;
    _computedCache['throttle_result_$operationKey'] = result;

    return result;
  }

  /// Obtém estatísticas de performance
  static PerformanceStats getPerformanceStats() {
    return PerformanceStats(
      controllerPoolSize: _controllerPool.length,
      computedCacheSize: _computedCache.length,
      formatCacheSize: _formatCache.length,
      memoryUsageEstimate: _estimateMemoryUsage(),
    );
  }

  /// Estima uso de memória dos caches
  static int _estimateMemoryUsage() {
    int estimate = 0;

    // Estima uso dos controllers (aproximado)
    estimate += _controllerPool.length * 1024; // ~1KB por controller

    // Estima uso dos caches
    estimate += _computedCache.length * 64; // ~64 bytes por entrada
    estimate += _formatCache.length * 128; // ~128 bytes por string

    return estimate;
  }

  /// Limpeza automática de cache quando excede limite
  static void autoCleanupCache({int maxCacheSize = 1000}) {
    if (_computedCache.length > maxCacheSize) {
      clearComputedCache();
    }

    if (_formatCache.length > maxCacheSize) {
      clearFormatCache();
    }
  }
}

/// Estatísticas de performance
class PerformanceStats {
  final int controllerPoolSize;
  final int computedCacheSize;
  final int formatCacheSize;
  final int memoryUsageEstimate;

  PerformanceStats({
    required this.controllerPoolSize,
    required this.computedCacheSize,
    required this.formatCacheSize,
    required this.memoryUsageEstimate,
  });

  @override
  String toString() {
    return 'Performance Stats:\n'
        'Controllers: $controllerPoolSize\n'
        'Computed Cache: $computedCacheSize\n'
        'Format Cache: $formatCacheSize\n'
        'Memory Usage: ${memoryUsageEstimate}B';
  }
}
