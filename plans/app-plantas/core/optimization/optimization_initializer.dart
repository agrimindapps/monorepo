// Dart imports:
import 'dart:async';

// Package imports:
import 'package:logging/logging.dart';

import '../../database/planta_model.dart';
import '../../database/tarefa_model.dart';
import 'enhanced_query_optimizer.dart';
import 'lazy_evaluation_service.dart';
// Project imports:
import 'memoization_manager.dart';
import 'statistics_cache_service.dart';

/// Inicializador para os serviços de otimização - ISSUE #13
/// Centraliza a configuração de todos os sistemas de memoização e cache
class OptimizationInitializer {
  static OptimizationInitializer? _instance;
  static OptimizationInitializer get instance =>
      _instance ??= OptimizationInitializer._();

  OptimizationInitializer._();

  bool _isInitialized = false;

  /// Inicializar todos os serviços de otimização com data sources
  Future<void> initialize({
    required Future<List<PlantaModel>> Function() plantaDataSource,
    required Future<List<TarefaModel>> Function() tarefaDataSource,
  }) async {
    if (_isInitialized) return;

    try {
      // 1. Configurar cleanup automático do MemoizationManager
      final memo = MemoizationManager.instance;
      memo.setupAutomaticCleanup();

      // 2. Inicializar LazyEvaluationService com data sources
      final lazyEval = LazyEvaluationService.instance;
      lazyEval.initialize(
        plantaDataSource: plantaDataSource,
        tarefaDataSource: tarefaDataSource,
      );

      // 3. Inicializar Enhanced Query Optimizer com índices
      final queryOptimizer = EnhancedQueryOptimizer.instance;
      await queryOptimizer.initialize(
        plantaProvider: plantaDataSource,
        tarefaProvider: tarefaDataSource,
      );

      // 4. Pré-aquecer estatísticas importantes
      final statsCache = StatisticsCacheService.instance;
      await _warmupImportantStatistics(
        statsCache,
        plantaDataSource,
        tarefaDataSource,
      );

      _isInitialized = true;
      Logger('OptimizationInitializer').info('Todos os serviços inicializados com sucesso');
    } catch (error) {
      Logger('OptimizationInitializer').severe('Erro durante inicialização: $error');
      rethrow;
    }
  }

  /// Re-inicializar quando dados mudarem
  Future<void> reinitializeOnDataChange({
    required Future<List<PlantaModel>> Function() plantaDataSource,
    required Future<List<TarefaModel>> Function() tarefaDataSource,
    required String dataType, // 'plantas', 'tarefas', ou 'all'
  }) async {
    try {
      final memo = MemoizationManager.instance;
      final lazyEval = LazyEvaluationService.instance;
      final queryOptimizer = EnhancedQueryOptimizer.instance;

      switch (dataType) {
        case 'plantas':
          // Invalidar caches relacionados a plantas
          memo.invalidateByDependency('plantas');
          lazyEval.invalidateOnDataChange('plantas');

          // Refresh índices de plantas
          await queryOptimizer.refreshIndexes(plantaProvider: plantaDataSource);
          break;

        case 'tarefas':
          // Invalidar caches relacionados a tarefas
          memo.invalidateByDependency('tarefas');
          lazyEval.invalidateOnDataChange('tarefas');

          // Refresh índices de tarefas
          await queryOptimizer.refreshIndexes(tarefaProvider: tarefaDataSource);
          break;

        case 'all':
          // Invalidar todos os caches
          memo.clearAll();
          lazyEval.invalidateOnDataChange('plantas');
          lazyEval.invalidateOnDataChange('tarefas');

          // Refresh todos os índices
          await queryOptimizer.refreshIndexes(
            plantaProvider: plantaDataSource,
            tarefaProvider: tarefaDataSource,
          );
          break;
      }

      Logger('OptimizationInitializer').info('Reinicialização completa para $dataType');
    } catch (error) {
      Logger('OptimizationInitializer').severe('Erro durante reinicialização: $error');
    }
  }

  /// Obter informações de debug de todos os serviços
  Map<String, dynamic> getDebugInfo() {
    if (!_isInitialized) {
      return {'status': 'not_initialized'};
    }

    return {
      'status': 'initialized',
      'memoization': MemoizationManager.instance.getDebugInfo(),
      'statistics_cache': StatisticsCacheService.instance.getDebugInfo(),
      'query_stats': EnhancedQueryOptimizer.instance.getQueryStatistics().map(
            (k, v) => MapEntry(k, v.toMap()),
          ),
    };
  }

  /// Obter métricas de performance
  Map<String, dynamic> getPerformanceMetrics() {
    if (!_isInitialized) {
      return {'status': 'not_initialized'};
    }

    final memo = MemoizationManager.instance;
    final statsCache = StatisticsCacheService.instance;

    return {
      'memoization_stats': memo.getStatistics().map(
            (k, v) => MapEntry(k, v.toMap()),
          ),
      'statistics_cache_performance': statsCache.getPerformanceMetrics().map(
            (k, v) => MapEntry(k, v.toMap()),
          ),
      'overall_hit_ratio': _calculateOverallHitRatio(),
    };
  }

  /// Limpar todos os caches (útil para debugging)
  void clearAllCaches() {
    if (!_isInitialized) return;

    MemoizationManager.instance.clearAll();
    StatisticsCacheService.instance.dispose();
    Logger('OptimizationInitializer').info('Todos os caches limpos');
  }

  // Métodos privados
  Future<void> _warmupImportantStatistics(
    StatisticsCacheService statsCache,
    Future<List<PlantaModel>> Function() plantaDataSource,
    Future<List<TarefaModel>> Function() tarefaDataSource,
  ) async {
    final warmupConfigs = [
      // Estatísticas básicas de plantas
      StatisticWarmupConfig(
        key: 'plantas_basic_stats',
        computation: () async {
          final plantas = await plantaDataSource();
          return {
            'total': plantas.length,
            'ativas': plantas.length, // Assumir todas ativas por ora
          };
        },
        type: StatisticType.basic,
        dependencies: ['plantas'],
      ),

      // Estatísticas básicas de tarefas
      StatisticWarmupConfig(
        key: 'tarefas_basic_stats',
        computation: () async {
          final tarefas = await tarefaDataSource();
          return {
            'total': tarefas.length,
            'concluidas': tarefas.where((t) => t.concluida).length,
            'pendentes': tarefas.where((t) => !t.concluida).length,
          };
        },
        type: StatisticType.basic,
        dependencies: ['tarefas'],
      ),

      // Contagem de plantas por espaço
      StatisticWarmupConfig(
        key: 'plantas_por_espaco',
        computation: () async {
          final plantas = await plantaDataSource();
          final Map<String, int> counts = {};

          for (final planta in plantas) {
            final espacoId = planta.espacoId ?? 'sem_espaco';
            counts[espacoId] = (counts[espacoId] ?? 0) + 1;
          }

          return counts;
        },
        type: StatisticType.aggregated,
        dependencies: ['plantas'],
      ),
    ];

    await statsCache.warmupStatistics(warmupConfigs);
  }

  double _calculateOverallHitRatio() {
    final memoStats = MemoizationManager.instance.getStatistics();
    final cacheStats = StatisticsCacheService.instance.getPerformanceMetrics();

    if (memoStats.isEmpty && cacheStats.isEmpty) return 0.0;

    double totalHitRatio = 0.0;
    int count = 0;

    // Hit ratio do MemoizationManager
    for (final stats in memoStats.values) {
      totalHitRatio += stats.hitRatio;
      count++;
    }

    // Hit ratio do StatisticsCacheService
    for (final stats in cacheStats.values) {
      totalHitRatio += stats.hitRatio;
      count++;
    }

    return count > 0 ? totalHitRatio / count : 0.0;
  }

  /// Configurar invalidação automática baseada em streams
  void setupStreamBasedInvalidation({
    Stream<List<PlantaModel>>? plantaStream,
    Stream<List<TarefaModel>>? tarefaStream,
  }) {
    if (!_isInitialized) return;

    if (plantaStream != null) {
      plantaStream.listen((_) {
        MemoizationManager.instance.invalidateByDependency('plantas');
        LazyEvaluationService.instance.invalidateOnDataChange('plantas');
      });
    }

    if (tarefaStream != null) {
      tarefaStream.listen((_) {
        MemoizationManager.instance.invalidateByDependency('tarefas');
        LazyEvaluationService.instance.invalidateOnDataChange('tarefas');
      });
    }
  }

  /// Dispose de todos os recursos
  void dispose() {
    if (!_isInitialized) return;

    StatisticsCacheService.instance.dispose();
    MemoizationManager.instance.clearAll();

    _isInitialized = false;
    Logger('OptimizationInitializer').info('Recursos liberados');
  }
}
