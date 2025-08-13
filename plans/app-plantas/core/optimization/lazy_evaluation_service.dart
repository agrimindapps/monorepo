// Dart imports:
import 'dart:async';

// Project imports:
import '../../database/planta_model.dart';
import '../../database/tarefa_model.dart';
import '../filtering/care_need_checker.dart';
import '../filtering/date_criteria_strategy.dart';
import 'memoization_manager.dart';

/// Serviço de lazy evaluation para operações custosas
/// Implementa avaliação sob demanda com cache inteligente
class LazyEvaluationService {
  static LazyEvaluationService? _instance;
  static LazyEvaluationService get instance =>
      _instance ??= LazyEvaluationService._();

  LazyEvaluationService._();

  final MemoizationManager _memo = MemoizationManager.instance;

  /// Cadeia de checkers para verificação de cuidados
  late final CareNeedChecker _careNeedChain;

  /// Lazy loader para estatísticas de plantas
  LazyStatisticsLoader<PlantaModel> get plantaStatistics => _plantaStatsLoader!;
  LazyStatisticsLoader<PlantaModel>? _plantaStatsLoader;

  /// Lazy loader para estatísticas de tarefas
  LazyStatisticsLoader<TarefaModel> get tarefaStatistics => _tarefaStatsLoader!;
  LazyStatisticsLoader<TarefaModel>? _tarefaStatsLoader;

  /// Lazy loader para queries de data
  LazyDateQueries get dateQueries => _dateQueries!;
  LazyDateQueries? _dateQueries;

  /// Inicializar com funções de data source
  void initialize({
    required Future<List<PlantaModel>> Function() plantaDataSource,
    required Future<List<TarefaModel>> Function() tarefaDataSource,
  }) {
    _plantaStatsLoader = LazyStatisticsLoader<PlantaModel>(
      dataSource: plantaDataSource,
      category: 'planta_statistics',
      memoManager: _memo,
    );

    _tarefaStatsLoader = LazyStatisticsLoader<TarefaModel>(
      dataSource: tarefaDataSource,
      category: 'tarefa_statistics',
      memoManager: _memo,
    );

    _dateQueries = LazyDateQueries(
      tarefaDataSource: tarefaDataSource,
      memoManager: _memo,
    );

    // Inicializar cadeia de checkers de cuidado
    _careNeedChain = CareNeedCheckerChain.createDefaultChain();
  }

  /// Lazy evaluation para contagem de plantas por espaço
  Future<Map<String, int>> lazyPlantaCountByEspaco() async {
    return _memo.memoize(
      'planta_count_by_espaco',
      () => plantaStatistics.countByField('espacoId'),
      category: 'statistics',
      customTtl: const Duration(minutes: 20),
    );
  }

  /// Lazy evaluation para estatísticas de tarefas por status
  Future<Map<String, int>> lazyTarefaStatsByStatus() async {
    return _memo.memoize(
      'tarefa_stats_by_status',
      () => tarefaStatistics.countByBooleanField('concluida'),
      category: 'statistics',
      customTtl: const Duration(minutes: 15),
    );
  }

  /// Lazy evaluation para plantas que precisam de cuidados
  Future<List<PlantaModel>> lazyPlantasNeedingCare() async {
    return _memo.memoize(
      'plantas_needing_care',
      () => _computePlantasNeedingCare(),
      category: 'calculations',
      dependencies: ['plantas', 'tarefas'],
    );
  }

  /// Invalidar cache baseado em mudanças de dados
  void invalidateOnDataChange(String dataType) {
    switch (dataType) {
      case 'plantas':
        _memo.invalidateCategory('planta_statistics');
        _memo.invalidateByDependency('plantas');
        break;
      case 'tarefas':
        _memo.invalidateCategory('tarefa_statistics');
        _memo.invalidateCategory('date_queries');
        _memo.invalidateByDependency('tarefas');
        break;
      default:
        _memo.invalidateCategory('statistics');
    }
  }

  // Implementação privada
  Future<List<PlantaModel>> _computePlantasNeedingCare() async {
    final plantas = await plantaStatistics._dataSource();
    final tarefas = await _tarefaStatsLoader!._dataSource();

    // Lógica otimizada para determinar plantas que precisam de cuidados
    final hoje = _memo.lazyEvaluate(
      'today_date',
      () => DateTime.now(),
      customTtl: const Duration(hours: 1),
    );

    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);

    // Mapear tarefas por planta para lookup O(1)
    final tarefasByPlanta = _memo.lazyEvaluate(
      'tarefas_by_planta_${hojeDate.millisecondsSinceEpoch}',
      () => _groupTarefasByPlanta(tarefas),
      customTtl: const Duration(hours: 2),
    );

    return plantas.where((planta) {
      final plantaTarefas = tarefasByPlanta[planta.id] ?? <TarefaModel>[];
      return _plantaPrecisaCuidadoHoje(planta, plantaTarefas, hojeDate);
    }).toList();
  }

  Map<String, List<TarefaModel>> _groupTarefasByPlanta(
      List<TarefaModel> tarefas) {
    final Map<String, List<TarefaModel>> grouped = {};

    for (final tarefa in tarefas) {
      grouped.putIfAbsent(tarefa.plantaId, () => []).add(tarefa);
    }

    return grouped;
  }

  bool _plantaPrecisaCuidadoHoje(
    PlantaModel planta,
    List<TarefaModel> tarefas,
    DateTime hoje,
  ) {
    // Usar cadeia de responsabilidade para verificar cuidados
    // Implementação refatorada usando Chain of Responsibility pattern
    return _careNeedChain.process(planta, tarefas, hoje);
  }
}

/// Loader genérico para estatísticas com lazy evaluation
class LazyStatisticsLoader<T> {
  final Future<List<T>> Function() _dataSource;
  final String _category;
  final MemoizationManager _memoManager;

  LazyStatisticsLoader({
    required Future<List<T>> Function() dataSource,
    required String category,
    required MemoizationManager memoManager,
  })  : _dataSource = dataSource,
        _category = category,
        _memoManager = memoManager;

  /// Contar por campo específico
  Future<Map<String, int>> countByField(String fieldName) async {
    return _memoManager.memoize(
      '${_category}_count_by_$fieldName',
      () => _computeCountByField(fieldName),
      category: _category,
    );
  }

  /// Contar por campo booleano (true/false)
  Future<Map<String, int>> countByBooleanField(String fieldName) async {
    return _memoManager.memoize(
      '${_category}_bool_count_$fieldName',
      () => _computeBooleanCount(fieldName),
      category: _category,
    );
  }

  /// Total de itens
  Future<int> total() async {
    return _memoManager.memoize(
      '${_category}_total',
      () => _computeTotal(),
      category: _category,
    );
  }

  // Implementações privadas
  Future<Map<String, int>> _computeCountByField(String fieldName) async {
    final data = await _dataSource();
    final Map<String, int> counts = {};

    for (final item in data) {
      final fieldValue = _getFieldValue(item, fieldName);
      final key = fieldValue?.toString() ?? 'null';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return counts;
  }

  Future<Map<String, int>> _computeBooleanCount(String fieldName) async {
    final data = await _dataSource();
    int trueCount = 0;
    int falseCount = 0;

    for (final item in data) {
      final fieldValue = _getFieldValue(item, fieldName);
      if (fieldValue == true) {
        trueCount++;
      } else {
        falseCount++;
      }
    }

    return {
      'true': trueCount,
      'false': falseCount,
    };
  }

  Future<int> _computeTotal() async {
    final data = await _dataSource();
    return data.length;
  }

  dynamic _getFieldValue(dynamic item, String fieldName) {
    // Usar reflection ou switch baseado no tipo para obter campo
    if (item is PlantaModel && fieldName == 'espacoId') {
      return item.espacoId;
    } else if (item is TarefaModel && fieldName == 'concluida') {
      return item.concluida;
    } else if (item is TarefaModel && fieldName == 'plantaId') {
      return item.plantaId;
    }

    // Para outros campos, tentar obter via toString()
    return null;
  }
}

/// Queries lazy para operações com datas usando Strategy pattern
class LazyDateQueries {
  final Future<List<TarefaModel>> Function() _tarefaDataSource;
  final MemoizationManager _memoManager;

  LazyDateQueries({
    required Future<List<TarefaModel>> Function() tarefaDataSource,
    required MemoizationManager memoManager,
  })  : _tarefaDataSource = tarefaDataSource,
        _memoManager = memoManager;

  /// Método genérico para buscar tarefas por critério de data (Strategy Pattern)
  Future<List<TarefaModel>> findByDateCriteria(
      DateCriteriaStrategy strategy) async {
    final hoje = DateTime.now();
    final cacheKey = _buildCacheKey(strategy, hoje);

    return _memoManager.memoize(
      cacheKey,
      () => _applyDateCriteria(strategy, hoje),
      category: 'date_queries',
      customTtl: strategy.cacheTtl,
    );
  }

  /// Tarefas para hoje (factory method usando Strategy)
  Future<List<TarefaModel>> forToday() async {
    return findByDateCriteria(DateCriteriaFactory.today);
  }

  /// Tarefas atrasadas (factory method usando Strategy)
  Future<List<TarefaModel>> overdue() async {
    return findByDateCriteria(DateCriteriaFactory.overdue);
  }

  /// Tarefas futuras (factory method usando Strategy)
  Future<List<TarefaModel>> future() async {
    return findByDateCriteria(DateCriteriaFactory.future);
  }

  // Implementações privadas usando Strategy Pattern
  Future<List<TarefaModel>> _applyDateCriteria(
      DateCriteriaStrategy strategy, DateTime referenceDate) async {
    final tarefas = await _tarefaDataSource();
    return strategy.apply(tarefas, referenceDate);
  }

  String _buildCacheKey(DateCriteriaStrategy strategy, DateTime referenceDate) {
    switch (strategy.criteriaName) {
      case 'today':
        // Cache diário para tarefas de hoje
        return 'tarefas_hoje_${referenceDate.day}_${referenceDate.month}_${referenceDate.year}';
      case 'overdue':
        // Cache baseado na hora para tarefas atrasadas (muda durante o dia)
        return 'tarefas_atrasadas_${referenceDate.day}_${referenceDate.month}_${referenceDate.year}_${referenceDate.hour}';
      case 'future':
        // Cache diário para tarefas futuras
        return 'tarefas_futuras_${referenceDate.day}_${referenceDate.month}_${referenceDate.year}';
      default:
        return 'tarefas_${strategy.criteriaName}_${referenceDate.millisecondsSinceEpoch}';
    }
  }
}
