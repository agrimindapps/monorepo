// Dart imports:
import 'dart:async';

// Project imports:
import '../../database/planta_model.dart';
import '../../database/tarefa_model.dart';
import '../cache/cache_manager.dart';

/// Query Optimizer para resolver problemas N+1 e otimizar consultas complexas
class QueryOptimizer {
  static QueryOptimizer? _instance;
  static QueryOptimizer get instance => _instance ??= QueryOptimizer._();

  QueryOptimizer._();

  final CacheManager _cache = CacheManager.instance;

  /// Otimizar consulta de plantas que precisam de cuidados hoje
  /// Resolve N+1 fazendo apenas 2 queries ao invés de N+1
  Future<PlantaCuidadosResult> findPlantasPrecisaCuidadosHoje(
    Future<List<PlantaModel>> Function() findAllPlantas,
    Future<List<TarefaModel>> Function() findAllTarefas,
  ) async {
    return _cache.getOrSet(
      'plantas_cuidados_hoje',
      () => _executePlantasCuidadosQuery(findAllPlantas, findAllTarefas),
      ttl: const Duration(minutes: 15),
    );
  }

  /// Implementação otimizada da query de plantas com cuidados
  Future<PlantaCuidadosResult> _executePlantasCuidadosQuery(
    Future<List<PlantaModel>> Function() findAllPlantas,
    Future<List<TarefaModel>> Function() findAllTarefas,
  ) async {
    // Buscar todos os dados em paralelo (apenas 2 queries!)
    final results = await Future.wait([
      findAllPlantas(),
      findAllTarefas(),
    ]);

    final plantas = results[0] as List<PlantaModel>;
    final tarefas = results[1] as List<TarefaModel>;

    // Processar em memória de forma otimizada
    final hoje = DateTime.now();
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);

    // Usar Map para lookup O(1) ao invés de where() múltiplas vezes
    final tarefasMap = <String, List<TarefaModel>>{};
    final plantasComTarefasHoje = <String>{};
    final plantasComTarefasAtrasadas = <String>{};

    // Processar todas as tarefas em uma única passada
    for (final tarefa in tarefas) {
      final plantaId = tarefa.plantaId;

      // Agrupar tarefas por planta
      tarefasMap.putIfAbsent(plantaId, () => []).add(tarefa);

      // Só processar tarefas não concluídas
      if (!tarefa.concluida) {
        final dataExecucao = DateTime(
          tarefa.dataExecucao.year,
          tarefa.dataExecucao.month,
          tarefa.dataExecucao.day,
        );

        if (dataExecucao == hojeDate) {
          plantasComTarefasHoje.add(plantaId);
        } else if (dataExecucao.isBefore(hojeDate)) {
          plantasComTarefasAtrasadas.add(plantaId);
        }
      }
    }

    // Filtrar plantas usando Sets para O(1) lookup
    final plantasPrecisaCuidadosHoje = plantas
        .where((planta) => plantasComTarefasHoje.contains(planta.id))
        .toList();

    final plantasComTarefasAtrasadasList = plantas
        .where((planta) => plantasComTarefasAtrasadas.contains(planta.id))
        .toList();

    return PlantaCuidadosResult(
      plantasPrecisaCuidadosHoje: plantasPrecisaCuidadosHoje,
      plantasComTarefasAtrasadas: plantasComTarefasAtrasadasList,
      tarefasMap: tarefasMap,
      processedAt: DateTime.now(),
    );
  }

  /// Otimizar múltiplas consultas por diferentes critérios de data
  Future<TarefasByDateResult> findTarefasByDateCriteria(
    Future<List<TarefaModel>> Function() findAllTarefas,
  ) async {
    return _cache.getOrSet(
      'tarefas_by_date',
      () => _executeTarefasByDateQuery(findAllTarefas),
      ttl: const Duration(minutes: 10),
    );
  }

  /// Implementação otimizada para consultas por data
  Future<TarefasByDateResult> _executeTarefasByDateQuery(
    Future<List<TarefaModel>> Function() findAllTarefas,
  ) async {
    final tarefas = await findAllTarefas();
    final hoje = DateTime.now();
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);

    final paraHoje = <TarefaModel>[];
    final futuras = <TarefaModel>[];
    final atrasadas = <TarefaModel>[];
    final concluidas = <TarefaModel>[];
    final pendentes = <TarefaModel>[];

    // Processar todas as tarefas em uma única passada
    for (final tarefa in tarefas) {
      if (tarefa.concluida) {
        concluidas.add(tarefa);
      } else {
        pendentes.add(tarefa);

        final dataExecucao = DateTime(
          tarefa.dataExecucao.year,
          tarefa.dataExecucao.month,
          tarefa.dataExecucao.day,
        );

        if (dataExecucao == hojeDate) {
          paraHoje.add(tarefa);
        } else if (dataExecucao.isAfter(hojeDate)) {
          futuras.add(tarefa);
        } else {
          atrasadas.add(tarefa);
        }
      }
    }

    return TarefasByDateResult(
      paraHoje: paraHoje,
      futuras: futuras,
      atrasadas: atrasadas,
      concluidas: concluidas,
      pendentes: pendentes,
      processedAt: DateTime.now(),
    );
  }

  /// Otimizar consultas por planta específica
  Future<List<TarefaModel>> findTarefasByPlanta(
    String plantaId,
    Future<List<TarefaModel>> Function() findAllTarefas,
  ) async {
    final cacheKey = 'tarefas_by_planta:$plantaId';

    return _cache.getOrSet(
      cacheKey,
      () async {
        final tarefas = await findAllTarefas();
        return tarefas.where((tarefa) => tarefa.plantaId == plantaId).toList();
      },
      ttl: const Duration(minutes: 5),
    );
  }

  /// Otimizar consultas por múltiplas plantas (batch operation)
  Future<Map<String, List<TarefaModel>>> findTarefasByPlantas(
    List<String> plantaIds,
    Future<List<TarefaModel>> Function() findAllTarefas,
  ) async {
    return _cache.getOrSetBatch(
      'tarefas_by_planta',
      plantaIds,
      (missingIds) async {
        final tarefas = await findAllTarefas();
        return tarefas.where((t) => missingIds.contains(t.plantaId)).toList();
      },
      (tarefa) => tarefa.plantaId,
      ttl: const Duration(minutes: 5),
    ).then((tarefas) {
      // Agrupar por planta
      final result = <String, List<TarefaModel>>{};
      for (final tarefa in tarefas) {
        result.putIfAbsent(tarefa.plantaId, () => []).add(tarefa);
      }
      return result;
    });
  }

  /// Otimizar estatísticas calculando tudo em uma passada
  Future<EstatisticasOptimizadas> calcularEstatisticas(
    Future<List<PlantaModel>> Function() findAllPlantas,
    Future<List<TarefaModel>> Function() findAllTarefas,
  ) async {
    return _cache.getOrSet(
      'estatisticas_otimizadas',
      () => _calcularEstatisticasQuery(findAllPlantas, findAllTarefas),
      ttl: const Duration(minutes: 30),
    );
  }

  /// Implementação otimizada de estatísticas
  Future<EstatisticasOptimizadas> _calcularEstatisticasQuery(
    Future<List<PlantaModel>> Function() findAllPlantas,
    Future<List<TarefaModel>> Function() findAllTarefas,
  ) async {
    final results = await Future.wait([
      findAllPlantas(),
      findAllTarefas(),
    ]);

    final plantas = results[0] as List<PlantaModel>;
    final tarefas = results[1] as List<TarefaModel>;

    final hoje = DateTime.now();
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);

    // Contar plantas por espaço
    final plantasPorEspaco = <String, int>{};
    for (final planta in plantas) {
      final espacoId = planta.espacoId ?? 'sem_espaco';
      plantasPorEspaco[espacoId] = (plantasPorEspaco[espacoId] ?? 0) + 1;
    }

    // Processar estatísticas de tarefas
    int tarefasPendentes = 0;
    int tarefasConcluidas = 0;
    int tarefasParaHoje = 0;
    int tarefasAtrasadas = 0;
    int comAgua = 0;
    int comAdubo = 0;
    final plantasComTarefasHoje = <String>{};
    final plantasComTarefasAtrasadas = <String>{};

    for (final tarefa in tarefas) {
      if (tarefa.concluida) {
        tarefasConcluidas++;
      } else {
        tarefasPendentes++;

        final dataExecucao = DateTime(
          tarefa.dataExecucao.year,
          tarefa.dataExecucao.month,
          tarefa.dataExecucao.day,
        );

        if (dataExecucao == hojeDate) {
          tarefasParaHoje++;
          plantasComTarefasHoje.add(tarefa.plantaId);

          if (tarefa.tipoCuidado == 'agua') comAgua++;
          if (tarefa.tipoCuidado == 'adubo') comAdubo++;
        } else if (dataExecucao.isBefore(hojeDate)) {
          tarefasAtrasadas++;
          plantasComTarefasAtrasadas.add(tarefa.plantaId);
        }
      }
    }

    return EstatisticasOptimizadas(
      totalPlantas: plantas.length,
      totalTarefas: tarefas.length,
      tarefasPendentes: tarefasPendentes,
      tarefasConcluidas: tarefasConcluidas,
      tarefasParaHoje: tarefasParaHoje,
      tarefasAtrasadas: tarefasAtrasadas,
      plantasComTarefasHoje: plantasComTarefasHoje.length,
      plantasComTarefasAtrasadas: plantasComTarefasAtrasadas.length,
      plantasPorEspaco: plantasPorEspaco,
      comAgua: comAgua,
      comAdubo: comAdubo,
      processedAt: DateTime.now(),
    );
  }

  /// Invalidar caches relacionados após operações de write
  void invalidateRelatedCaches(String operation, {String? entityId}) {
    switch (operation) {
      case 'planta_created':
      case 'planta_updated':
      case 'planta_deleted':
        _cache.invalidatePattern('plantas_*');
        _cache.invalidatePattern('estatisticas_*');
        break;
      case 'tarefa_created':
      case 'tarefa_updated':
      case 'tarefa_deleted':
        _cache.invalidatePattern('tarefas_*');
        _cache.invalidatePattern('plantas_cuidados_*');
        _cache.invalidatePattern('estatisticas_*');
        if (entityId != null) {
          _cache.invalidate('tarefas_by_planta:$entityId');
        }
        break;
      case 'config_updated':
        _cache.invalidatePattern('plantas_cuidados_*');
        break;
    }
  }

  /// Configurar invalidação automática baseada em streams
  void setupAutoInvalidation({
    Stream<List<PlantaModel>>? plantasStream,
    Stream<List<TarefaModel>>? tarefasStream,
  }) {
    if (plantasStream != null) {
      _cache.setupAutoInvalidation('plantas_*', plantasStream);
    }

    if (tarefasStream != null) {
      _cache.setupAutoInvalidation('tarefas_*', tarefasStream);
    }
  }

  /// Obter estatísticas do optimizer
  OptimizerStats getStats() {
    final cacheStats = _cache.getStats();
    return OptimizerStats(
      cacheStats: cacheStats,
      optimizedQueriesCount: _optimizedQueriesCount,
    );
  }

  final int _optimizedQueriesCount = 0;

  /// Dispose do optimizer
  Future<void> dispose() async {
    await _cache.dispose();
  }
}

/// Resultado otimizado das consultas de plantas com cuidados
class PlantaCuidadosResult {
  final List<PlantaModel> plantasPrecisaCuidadosHoje;
  final List<PlantaModel> plantasComTarefasAtrasadas;
  final Map<String, List<TarefaModel>> tarefasMap;
  final DateTime processedAt;

  PlantaCuidadosResult({
    required this.plantasPrecisaCuidadosHoje,
    required this.plantasComTarefasAtrasadas,
    required this.tarefasMap,
    required this.processedAt,
  });

  /// Verificar se os dados ainda são válidos (menos de 15 minutos)
  bool get isValid {
    return DateTime.now().difference(processedAt).inMinutes < 15;
  }

  /// Obter tarefas de uma planta específica
  List<TarefaModel> getTarefasForPlanta(String plantaId) {
    return tarefasMap[plantaId] ?? [];
  }
}

/// Resultado otimizado das consultas por data
class TarefasByDateResult {
  final List<TarefaModel> paraHoje;
  final List<TarefaModel> futuras;
  final List<TarefaModel> atrasadas;
  final List<TarefaModel> concluidas;
  final List<TarefaModel> pendentes;
  final DateTime processedAt;

  TarefasByDateResult({
    required this.paraHoje,
    required this.futuras,
    required this.atrasadas,
    required this.concluidas,
    required this.pendentes,
    required this.processedAt,
  });

  bool get isValid {
    return DateTime.now().difference(processedAt).inMinutes < 10;
  }
}

/// Estatísticas otimizadas calculadas em uma passada
class EstatisticasOptimizadas {
  final int totalPlantas;
  final int totalTarefas;
  final int tarefasPendentes;
  final int tarefasConcluidas;
  final int tarefasParaHoje;
  final int tarefasAtrasadas;
  final int plantasComTarefasHoje;
  final int plantasComTarefasAtrasadas;
  final Map<String, int> plantasPorEspaco;
  final int comAgua;
  final int comAdubo;
  final DateTime processedAt;

  EstatisticasOptimizadas({
    required this.totalPlantas,
    required this.totalTarefas,
    required this.tarefasPendentes,
    required this.tarefasConcluidas,
    required this.tarefasParaHoje,
    required this.tarefasAtrasadas,
    required this.plantasComTarefasHoje,
    required this.plantasComTarefasAtrasadas,
    required this.plantasPorEspaco,
    required this.comAgua,
    required this.comAdubo,
    required this.processedAt,
  });

  bool get isValid {
    return DateTime.now().difference(processedAt).inMinutes < 30;
  }

  Map<String, int> toMap() {
    return {
      'total': totalPlantas,
      'comAgua': comAgua,
      'comAdubo': comAdubo,
      'precisaCuidados': plantasComTarefasHoje,
      'comTarefasAtrasadas': plantasComTarefasAtrasadas,
    };
  }

  Map<String, int> toTarefaMap() {
    return {
      'total': totalTarefas,
      'pendentes': tarefasPendentes,
      'concluidas': tarefasConcluidas,
      'paraHoje': tarefasParaHoje,
      'atrasadas': tarefasAtrasadas,
    };
  }
}

/// Estatísticas do optimizer
class OptimizerStats {
  final CacheStats cacheStats;
  final int optimizedQueriesCount;

  OptimizerStats({
    required this.cacheStats,
    required this.optimizedQueriesCount,
  });

  @override
  String toString() {
    return 'OptimizerStats(queries: $optimizedQueriesCount, cache: $cacheStats)';
  }
}
