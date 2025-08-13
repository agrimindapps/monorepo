// Dart imports:
import 'dart:async';

// Project imports:
import '../../core/extensions/datetime_extensions.dart';
import '../../database/espaco_model.dart';
import '../../database/planta_model.dart';
import '../../database/tarefa_model.dart';
import '../../services/domain/business_rules_service.dart';
import '../../services/domain/tasks/tarefa_filter_service.dart';
import '../espaco_repository.dart';
import '../planta_repository.dart';
import '../tarefa_repository.dart';

/// Repository Query Facade
///
/// ISSUE #33: Mixed Abstraction Levels - QUERY SOLUTION
///
/// Este facade centraliza operações complexas de consulta que envolvem
/// múltiplas entidades e lógica de negócio avançada, removendo essa
/// responsabilidade dos repositórios individuais.
///
/// RESPONSABILIDADES:
/// - Queries cross-entity complexas
/// - Filtros e aggregações que combinam múltiplas fontes
/// - Operações de busca com regras de negócio
/// - Cache inteligente para queries frequentes
///
/// BENEFÍCIOS:
/// - Repositórios focam apenas em operações CRUD básicas
/// - Queries complexas centralizadas em local apropriado
/// - Reutilização de lógica de consulta entre controllers
/// - Melhor performance com cache especializado
///
/// USAGE:
/// ```dart
/// final queryFacade = RepositoryQueryFacade.instance;
///
/// // Complex queries
/// final dashboard = await queryFacade.getDashboardQueries();
/// final search = await queryFacade.searchAcrossAllEntities('rosa');
/// final urgent = await queryFacade.getUrgentCareItems();
/// ```
class RepositoryQueryFacade {
  static RepositoryQueryFacade? _instance;
  static RepositoryQueryFacade get instance =>
      _instance ??= RepositoryQueryFacade._();

  // Low-level repository dependencies
  final PlantaRepository _plantaRepository = PlantaRepository.instance;
  final TarefaRepository _tarefaRepository = TarefaRepository.instance;
  final EspacoRepository _espacoRepository = EspacoRepository.instance;

  // High-level service dependencies
  final BusinessRulesService _businessRules = BusinessRulesService.instance;
  final TarefaFilterService _tarefaFilter = TarefaFilterService.instance;

  // Cache para queries frequentes
  final Map<String, CachedQuery> _queryCache = {};
  static const Duration _defaultCacheTtl = Duration(minutes: 5);

  RepositoryQueryFacade._();

  // ===========================================
  // DASHBOARD QUERIES (HIGH-LEVEL)
  // ===========================================

  /// Obter todas as queries necessárias para o dashboard
  ///
  /// Executa queries complexas em paralelo para otimizar performance.
  Future<DashboardQueries> getDashboardQueries() async {
    return _cachedQuery(
      'dashboard_queries',
      () async {
        // Executar todas as queries em paralelo
        final futures = await Future.wait([
          _getActiveItemsCount(),
          _getTodayTasksSummary(),
          _getOverdueTasksSummary(),
          _getSpaceUtilizationSummary(),
          _getRecentActivitySummary(),
        ]);

        return DashboardQueries(
          activeItemsCount: futures[0] as ActiveItemsCount,
          todayTasksSummary: futures[1] as TodayTasksSummary,
          overdueTasksSummary: futures[2] as OverdueTasksSummary,
          spaceUtilization: futures[3] as SpaceUtilizationSummary,
          recentActivity: futures[4] as RecentActivitySummary,
        );
      },
      ttl: const Duration(minutes: 2), // Cache curto para dados dinâmicos
    );
  }

  /// Obter contadores de items ativos
  Future<ActiveItemsCount> _getActiveItemsCount() async {
    final futures = await Future.wait([
      _plantaRepository.findAll(),
      _tarefaRepository.findAll(),
      _espacoRepository.findAtivos(),
    ]);

    final plantas = futures[0] as List<PlantaModel>;
    final tarefas = futures[1] as List<TarefaModel>;
    final espacosAtivos = futures[2] as List<EspacoModel>;

    final tarefasPendentes = tarefas.where((t) => !t.concluida).length;

    return ActiveItemsCount(
      totalPlantas: plantas.length,
      totalTarefas: tarefas.length,
      tarefasPendentes: tarefasPendentes,
      tarefasConcluidas: tarefas.length - tarefasPendentes,
      espacosAtivos: espacosAtivos.length,
    );
  }

  /// Obter resumo das tarefas de hoje
  Future<TodayTasksSummary> _getTodayTasksSummary() async {
    final tarefas = await _tarefaRepository.findAll();
    final tarefasHoje =
        tarefas.where((t) => t.dataExecucao.isToday && !t.concluida).toList();

    final porTipo = <String, int>{};
    final porPlanta = <String, List<TarefaModel>>{};

    for (final tarefa in tarefasHoje) {
      // Agrupar por tipo
      porTipo[tarefa.tipoCuidado] = (porTipo[tarefa.tipoCuidado] ?? 0) + 1;

      // Agrupar por planta
      porPlanta.putIfAbsent(tarefa.plantaId, () => []).add(tarefa);
    }

    return TodayTasksSummary(
      total: tarefasHoje.length,
      porTipo: porTipo,
      porPlanta: porPlanta,
      urgentes:
          tarefasHoje.where((t) => _businessRules.isTarefaUrgent(t)).length,
    );
  }

  /// Obter resumo das tarefas atrasadas
  Future<OverdueTasksSummary> _getOverdueTasksSummary() async {
    final tarefasAtrasadas = await _tarefaRepository.findAtrasadas();

    final porDiasAtraso = <int, int>{};
    final porPlanta = <String, List<TarefaModel>>{};

    for (final tarefa in tarefasAtrasadas) {
      final diasAtraso = DateTime.now().difference(tarefa.dataExecucao).inDays;
      porDiasAtraso[diasAtraso] = (porDiasAtraso[diasAtraso] ?? 0) + 1;

      porPlanta.putIfAbsent(tarefa.plantaId, () => []).add(tarefa);
    }

    return OverdueTasksSummary(
      total: tarefasAtrasadas.length,
      porDiasAtraso: porDiasAtraso,
      porPlanta: porPlanta,
      criticas: tarefasAtrasadas
          .where((t) => DateTime.now().difference(t.dataExecucao).inDays > 3)
          .length,
    );
  }

  /// Obter resumo de utilização de espaços
  Future<SpaceUtilizationSummary> _getSpaceUtilizationSummary() async {
    final espacos = await _espacoRepository.findAtivos();
    final plantas = await _plantaRepository.findAll();

    final utilizacao = <String, SpaceUtilizationInfo>{};

    for (final espaco in espacos) {
      final plantasNoEspaco =
          plantas.where((p) => p.espacoId == espaco.id).toList();

      utilizacao[espaco.id] = SpaceUtilizationInfo(
        espaco: espaco,
        plantasCount: plantasNoEspaco.length,
        plantas: plantasNoEspaco,
        utilizationPercentage:
            _calculateSpaceUtilization(plantasNoEspaco.length),
      );
    }

    return SpaceUtilizationSummary(
      totalEspacos: espacos.length,
      espacosComPlantas:
          utilizacao.values.where((u) => u.plantasCount > 0).length,
      utilizacao: utilizacao,
    );
  }

  /// Obter resumo de atividade recente
  Future<RecentActivitySummary> _getRecentActivitySummary() async {
    final ultimaSemana = DateTime.now().subtract(const Duration(days: 7));

    final futures = await Future.wait([
      _plantaRepository.findAll(),
      _tarefaRepository.findAll(),
    ]);

    final plantas = futures[0] as List<PlantaModel>;
    final tarefas = futures[1] as List<TarefaModel>;

    final plantasRecentes = plantas
        .where((p) => DateTime.fromMillisecondsSinceEpoch(p.createdAt)
            .isAfter(ultimaSemana))
        .toList();

    final tarefasConcluidasRecentes = tarefas
        .where((t) =>
            t.concluida &&
            t.dataConclusao != null &&
            t.dataConclusao!.isAfter(ultimaSemana))
        .toList();

    return RecentActivitySummary(
      plantasAdicionadas: plantasRecentes.length,
      tarefasConcluidas: tarefasConcluidasRecentes.length,
      diasAnalisados: 7,
      detalhes:
          _buildActivityDetails(plantasRecentes, tarefasConcluidasRecentes),
    );
  }

  // ===========================================
  // SEARCH QUERIES (HIGH-LEVEL)
  // ===========================================

  /// Buscar em todas as entidades simultaneamente
  ///
  /// Query cross-entity que busca em plantas, espaços e tipos de cuidado.
  Future<GlobalSearchResult> searchAcrossAllEntities(String query) async {
    if (query.trim().isEmpty) {
      return const GlobalSearchResult.empty();
    }

    return _cachedQuery(
      'global_search_${query.toLowerCase()}',
      () async {
        final futures = await Future.wait([
          _plantaRepository.searchPlantas(query),
          _espacoRepository.searchEspacos(query),
          _tarefaRepository.findAll(),
        ]);

        final plantas = futures[0] as List<PlantaModel>;
        final espacos = futures[1] as List<EspacoModel>;
        final todasTarefas = futures[2] as List<TarefaModel>;

        // Buscar tarefas por tipo de cuidado
        final tarefasPorTipo = todasTarefas
            .where((t) =>
                t.tipoCuidado.toLowerCase().contains(query.toLowerCase()))
            .toList();

        // Calcular relevância dos resultados
        final plantasComRelevancia = _calculatePlantaRelevance(plantas, query);
        final espacosComRelevancia = _calculateEspacoRelevance(espacos, query);
        final tiposCuidadoEncontrados =
            _extractCareTypes(tarefasPorTipo, query);

        return GlobalSearchResult(
          query: query,
          plantas: plantasComRelevancia,
          espacos: espacosComRelevancia,
          tiposCuidado: tiposCuidadoEncontrados,
          totalResults: plantasComRelevancia.length +
              espacosComRelevancia.length +
              tiposCuidadoEncontrados.length,
        );
      },
      ttl: const Duration(minutes: 3),
    );
  }

  /// Obter itens urgentes que precisam de atenção
  ///
  /// Query complexa que identifica plantas e tarefas que precisam de atenção imediata.
  Future<UrgentCareItems> getUrgentCareItems() async {
    return _cachedQuery(
      'urgent_care_items',
      () async {
        final futures = await Future.wait([
          _plantaRepository.findAll(),
          _tarefaRepository.findAll(),
        ]);

        final plantas = futures[0] as List<PlantaModel>;
        final tarefas = futures[1] as List<TarefaModel>;

        final agora = DateTime.now();
        final tarefasHoje =
            tarefas.where((t) => t.dataExecucao.isToday && !t.concluida);
        final tarefasAtrasadas = tarefas
            .where((t) => t.dataExecucao.isBefore(agora) && !t.concluida);
        final tarefasCriticas = tarefasAtrasadas
            .where((t) => agora.difference(t.dataExecucao).inDays > 3);

        // Identificar plantas que precisam de cuidado
        final plantasNeedingCare = <PlantaModel>[];
        for (final planta in plantas) {
          final tarefasPlanta = tarefas.where((t) => t.plantaId == planta.id);
          final hasUrgent = tarefasPlanta.any((t) =>
              (t.dataExecucao.isToday && !t.concluida) ||
              (t.dataExecucao.isBefore(agora) && !t.concluida));

          if (hasUrgent) {
            plantasNeedingCare.add(planta);
          }
        }

        return UrgentCareItems(
          plantasNeedingCare: plantasNeedingCare,
          tarefasHoje: tarefasHoje.toList(),
          tarefasAtrasadas: tarefasAtrasadas.toList(),
          tarefasCriticas: tarefasCriticas.toList(),
          urgencyScore: _calculateOverallUrgencyScore(
            tarefasHoje.length,
            tarefasAtrasadas.length,
            tarefasCriticas.length,
          ),
        );
      },
      ttl: const Duration(minutes: 1), // Cache muito curto para dados urgentes
    );
  }

  // ===========================================
  // STATISTICAL QUERIES (HIGH-LEVEL)
  // ===========================================

  /// Obter estatísticas de produtividade
  ///
  /// Query que calcula métricas de produtividade baseadas em conclusão de tarefas.
  Future<ProductivityStats> getProductivityStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    final cacheKey =
        'productivity_stats_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';

    return _cachedQuery(
      cacheKey,
      () async {
        final tarefas = await _tarefaRepository.findByPeriodo(start, end);

        final concluidas = tarefas.where((t) => t.concluida).toList();
        final pendentes = tarefas.where((t) => !t.concluida).toList();
        final atrasadas = pendentes
            .where((t) => t.dataExecucao.isBefore(DateTime.now()))
            .toList();

        final completionRate =
            tarefas.isEmpty ? 0.0 : (concluidas.length / tarefas.length) * 100;

        // Calcular streak de conclusões
        final completionStreak = _calculateCompletionStreak(concluidas);

        // Calcular produtividade por tipo de cuidado
        final produtividadePorTipo = _calculateProductivityByType(concluidas);

        return ProductivityStats(
          period: DateRange(start, end),
          totalTarefas: tarefas.length,
          tarefasConcluidas: concluidas.length,
          tarefasPendentes: pendentes.length,
          tarefasAtrasadas: atrasadas.length,
          completionRate: completionRate,
          completionStreak: completionStreak,
          produtividadePorTipo: produtividadePorTipo,
        );
      },
      ttl: const Duration(minutes: 10), // Cache mais longo para estatísticas
    );
  }

  /// Obter tendências de crescimento
  ///
  /// Query que analisa o crescimento da coleção ao longo do tempo.
  Future<GrowthTrends> getGrowthTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 90));
    final end = endDate ?? DateTime.now();

    final cacheKey =
        'growth_trends_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';

    return _cachedQuery(
      cacheKey,
      () async {
        final plantas = await _plantaRepository.findAll();

        final plantasNoPeriodo = plantas.where((p) {
          final createdAt = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
          return createdAt.isAfter(start) && createdAt.isBefore(end);
        }).toList();

        // Agrupar por mês
        final crescimentoMensal = <String, int>{};
        final crescimentoSemanal = <String, int>{};

        for (final planta in plantasNoPeriodo) {
          final createdAt =
              DateTime.fromMillisecondsSinceEpoch(planta.createdAt);

          // Agrupamento mensal
          final monthKey =
              '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
          crescimentoMensal[monthKey] = (crescimentoMensal[monthKey] ?? 0) + 1;

          // Agrupamento semanal
          final weekStart =
              createdAt.subtract(Duration(days: createdAt.weekday - 1));
          final weekKey = '${weekStart.year}-W${_getWeekOfYear(weekStart)}';
          crescimentoSemanal[weekKey] = (crescimentoSemanal[weekKey] ?? 0) + 1;
        }

        final taxaCrescimento =
            _calculateGrowthRate(plantasNoPeriodo, start, end);

        return GrowthTrends(
          period: DateRange(start, end),
          crescimentoMensal: crescimentoMensal,
          crescimentoSemanal: crescimentoSemanal,
          taxaCrescimentoMensal: taxaCrescimento,
          totalNovasPlantasNoPeriodo: plantasNoPeriodo.length,
        );
      },
      ttl: const Duration(minutes: 15),
    );
  }

  // ===========================================
  // CACHE MANAGEMENT (PRIVATE)
  // ===========================================

  Future<T> _cachedQuery<T>(
    String key,
    Future<T> Function() queryFunction, {
    Duration? ttl,
  }) async {
    final cached = _queryCache[key];
    final now = DateTime.now();

    if (cached != null && cached.expiresAt.isAfter(now)) {
      return cached.data as T;
    }

    final result = await queryFunction();
    final expiration = now.add(ttl ?? _defaultCacheTtl);

    _queryCache[key] = CachedQuery(
      data: result,
      expiresAt: expiration,
    );

    return result;
  }

  /// Invalidar cache específico
  void invalidateCache([String? pattern]) {
    if (pattern == null) {
      _queryCache.clear();
    } else {
      _queryCache.removeWhere((key, value) => key.contains(pattern));
    }
  }

  /// Limpar cache expirado
  void _cleanExpiredCache() {
    final now = DateTime.now();
    _queryCache.removeWhere((key, cached) => cached.expiresAt.isBefore(now));
  }

  // ===========================================
  // PRIVATE HELPER METHODS
  // ===========================================

  double _calculateSpaceUtilization(int plantasCount) {
    // Assumindo capacidade máxima de 10 plantas por espaço
    const maxCapacity = 10;
    return (plantasCount / maxCapacity * 100).clamp(0.0, 100.0);
  }

  List<ActivityDetail> _buildActivityDetails(
    List<PlantaModel> plantasRecentes,
    List<TarefaModel> tarefasRecentes,
  ) {
    final details = <ActivityDetail>[];

    for (final planta in plantasRecentes) {
      final createdAt = DateTime.fromMillisecondsSinceEpoch(planta.createdAt);
      details.add(ActivityDetail(
        type: 'planta_adicionada',
        entityId: planta.id,
        entityName: planta.nome ?? 'Sem nome',
        timestamp: createdAt,
        description: 'Planta "${planta.nome ?? 'Sem nome'}" adicionada',
      ));
    }

    for (final tarefa in tarefasRecentes) {
      details.add(ActivityDetail(
        type: 'tarefa_concluida',
        entityId: tarefa.id,
        entityName: tarefa.tipoCuidado,
        timestamp: tarefa.dataConclusao!,
        description: 'Tarefa de ${tarefa.tipoCuidado} concluída',
      ));
    }

    // Ordenar por timestamp descendente
    details.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return details.take(20).toList(); // Limitar a 20 itens
  }

  List<PlantaSearchResult> _calculatePlantaRelevance(
    List<PlantaModel> plantas,
    String query,
  ) {
    return plantas
        .map((planta) {
          double relevance = 0.0;

          // Nome exato: relevância máxima
          if (planta.nome?.toLowerCase() == query.toLowerCase()) {
            relevance = 100.0;
          }
          // Nome contém query: alta relevância
          else if (planta.nome?.toLowerCase().contains(query.toLowerCase()) == true) {
            relevance = 80.0;
          }
          // Descrição contém query: média relevância
          else if (planta.descricao
                  .toLowerCase()
                  .contains(query.toLowerCase())) {
            relevance = 50.0;
          }

          return PlantaSearchResult(
            planta: planta,
            relevance: relevance,
            matchedFields: _getMatchedFields(planta, query),
          );
        })
        .where((result) => result.relevance > 0)
        .toList()
      ..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  List<EspacoSearchResult> _calculateEspacoRelevance(
    List<EspacoModel> espacos,
    String query,
  ) {
    return espacos
        .map((espaco) {
          double relevance = 0.0;

          if (espaco.nome.toLowerCase() == query.toLowerCase()) {
            relevance = 100.0;
          } else if (espaco.nome.toLowerCase().contains(query.toLowerCase())) {
            relevance = 80.0;
          } else if (espaco.descricao
                  ?.toLowerCase()
                  .contains(query.toLowerCase()) ==
              true) {
            relevance = 50.0;
          }

          return EspacoSearchResult(
            espaco: espaco,
            relevance: relevance,
            matchedFields: _getMatchedFieldsEspaco(espaco, query),
          );
        })
        .where((result) => result.relevance > 0)
        .toList()
      ..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  List<CareTypeSearchResult> _extractCareTypes(
    List<TarefaModel> tarefas,
    String query,
  ) {
    final tiposEncontrados = <String, CareTypeSearchResult>{};

    for (final tarefa in tarefas) {
      final tipo = tarefa.tipoCuidado;
      if (!tiposEncontrados.containsKey(tipo)) {
        double relevance = 0.0;
        if (tipo.toLowerCase() == query.toLowerCase()) {
          relevance = 100.0;
        } else if (tipo.toLowerCase().contains(query.toLowerCase())) {
          relevance = 80.0;
        }

        if (relevance > 0) {
          tiposEncontrados[tipo] = CareTypeSearchResult(
            tipoCuidado: tipo,
            relevance: relevance,
            occurrences: 1,
          );
        }
      } else {
        tiposEncontrados[tipo]!.occurrences++;
      }
    }

    return tiposEncontrados.values.toList()
      ..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  List<String> _getMatchedFields(PlantaModel planta, String query) {
    final matched = <String>[];
    final queryLower = query.toLowerCase();

    if (planta.nome?.toLowerCase().contains(queryLower) == true) {
      matched.add('nome');
    }
    if (planta.descricao.toLowerCase().contains(queryLower)) {
      matched.add('descricao');
    }

    return matched;
  }

  List<String> _getMatchedFieldsEspaco(EspacoModel espaco, String query) {
    final matched = <String>[];
    final queryLower = query.toLowerCase();

    if (espaco.nome.toLowerCase().contains(queryLower)) {
      matched.add('nome');
    }
    if (espaco.descricao?.toLowerCase().contains(queryLower) == true) {
      matched.add('descricao');
    }

    return matched;
  }

  double _calculateOverallUrgencyScore(
    int tarefasHoje,
    int tarefasAtrasadas,
    int tarefasCriticas,
  ) {
    double score = 0.0;
    score += tarefasHoje * 1.0; // 1 ponto por tarefa de hoje
    score += tarefasAtrasadas * 2.0; // 2 pontos por tarefa atrasada
    score += tarefasCriticas * 5.0; // 5 pontos por tarefa crítica
    return score;
  }

  int _calculateCompletionStreak(List<TarefaModel> concluidas) {
    if (concluidas.isEmpty) return 0;

    // Ordenar por data de conclusão
    final sorted = concluidas.where((t) => t.dataConclusao != null).toList()
      ..sort((a, b) => a.dataConclusao!.compareTo(b.dataConclusao!));

    int streak = 0;
    DateTime? lastDate;

    for (final tarefa in sorted.reversed) {
      if (lastDate == null) {
        lastDate = tarefa.dataConclusao!;
        streak = 1;
      } else {
        final diff = lastDate.difference(tarefa.dataConclusao!).inDays;
        if (diff <= 1) {
          streak++;
          lastDate = tarefa.dataConclusao!;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  Map<String, double> _calculateProductivityByType(
      List<TarefaModel> concluidas) {
    final productivity = <String, int>{};

    for (final tarefa in concluidas) {
      productivity[tarefa.tipoCuidado] =
          (productivity[tarefa.tipoCuidado] ?? 0) + 1;
    }

    final total = concluidas.length;
    return productivity
        .map((key, value) => MapEntry(key, (value / total) * 100));
  }

  double _calculateGrowthRate(
    List<PlantaModel> plantas,
    DateTime start,
    DateTime end,
  ) {
    if (plantas.isEmpty) return 0.0;

    final periodDays = end.difference(start).inDays;
    if (periodDays <= 0) return 0.0;

    final monthsInPeriod = periodDays / 30.0;
    return plantas.length / monthsInPeriod;
  }

  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).floor() + 1;
  }

  /// Limpar recursos
  Future<void> dispose() async {
    _queryCache.clear();
  }
}

// ===========================================
// DATA MODELS PARA QUERY FACADE
// ===========================================

class CachedQuery {
  final dynamic data;
  final DateTime expiresAt;

  CachedQuery({
    required this.data,
    required this.expiresAt,
  });
}

class DashboardQueries {
  final ActiveItemsCount activeItemsCount;
  final TodayTasksSummary todayTasksSummary;
  final OverdueTasksSummary overdueTasksSummary;
  final SpaceUtilizationSummary spaceUtilization;
  final RecentActivitySummary recentActivity;

  const DashboardQueries({
    required this.activeItemsCount,
    required this.todayTasksSummary,
    required this.overdueTasksSummary,
    required this.spaceUtilization,
    required this.recentActivity,
  });
}

class ActiveItemsCount {
  final int totalPlantas;
  final int totalTarefas;
  final int tarefasPendentes;
  final int tarefasConcluidas;
  final int espacosAtivos;

  const ActiveItemsCount({
    required this.totalPlantas,
    required this.totalTarefas,
    required this.tarefasPendentes,
    required this.tarefasConcluidas,
    required this.espacosAtivos,
  });
}

class TodayTasksSummary {
  final int total;
  final Map<String, int> porTipo;
  final Map<String, List<TarefaModel>> porPlanta;
  final int urgentes;

  const TodayTasksSummary({
    required this.total,
    required this.porTipo,
    required this.porPlanta,
    required this.urgentes,
  });
}

class OverdueTasksSummary {
  final int total;
  final Map<int, int> porDiasAtraso;
  final Map<String, List<TarefaModel>> porPlanta;
  final int criticas;

  const OverdueTasksSummary({
    required this.total,
    required this.porDiasAtraso,
    required this.porPlanta,
    required this.criticas,
  });
}

class SpaceUtilizationSummary {
  final int totalEspacos;
  final int espacosComPlantas;
  final Map<String, SpaceUtilizationInfo> utilizacao;

  const SpaceUtilizationSummary({
    required this.totalEspacos,
    required this.espacosComPlantas,
    required this.utilizacao,
  });
}

class SpaceUtilizationInfo {
  final EspacoModel espaco;
  final int plantasCount;
  final List<PlantaModel> plantas;
  final double utilizationPercentage;

  const SpaceUtilizationInfo({
    required this.espaco,
    required this.plantasCount,
    required this.plantas,
    required this.utilizationPercentage,
  });
}

class RecentActivitySummary {
  final int plantasAdicionadas;
  final int tarefasConcluidas;
  final int diasAnalisados;
  final List<ActivityDetail> detalhes;

  const RecentActivitySummary({
    required this.plantasAdicionadas,
    required this.tarefasConcluidas,
    required this.diasAnalisados,
    required this.detalhes,
  });
}

class ActivityDetail {
  final String type;
  final String entityId;
  final String entityName;
  final DateTime timestamp;
  final String description;

  const ActivityDetail({
    required this.type,
    required this.entityId,
    required this.entityName,
    required this.timestamp,
    required this.description,
  });
}

class GlobalSearchResult {
  final String query;
  final List<PlantaSearchResult> plantas;
  final List<EspacoSearchResult> espacos;
  final List<CareTypeSearchResult> tiposCuidado;
  final int totalResults;

  const GlobalSearchResult({
    required this.query,
    required this.plantas,
    required this.espacos,
    required this.tiposCuidado,
    required this.totalResults,
  });

  const GlobalSearchResult.empty()
      : query = '',
        plantas = const [],
        espacos = const [],
        tiposCuidado = const [],
        totalResults = 0;
}

class PlantaSearchResult {
  final PlantaModel planta;
  final double relevance;
  final List<String> matchedFields;

  const PlantaSearchResult({
    required this.planta,
    required this.relevance,
    required this.matchedFields,
  });
}

class EspacoSearchResult {
  final EspacoModel espaco;
  final double relevance;
  final List<String> matchedFields;

  const EspacoSearchResult({
    required this.espaco,
    required this.relevance,
    required this.matchedFields,
  });
}

class CareTypeSearchResult {
  final String tipoCuidado;
  final double relevance;
  int occurrences;

  CareTypeSearchResult({
    required this.tipoCuidado,
    required this.relevance,
    required this.occurrences,
  });
}

class UrgentCareItems {
  final List<PlantaModel> plantasNeedingCare;
  final List<TarefaModel> tarefasHoje;
  final List<TarefaModel> tarefasAtrasadas;
  final List<TarefaModel> tarefasCriticas;
  final double urgencyScore;

  const UrgentCareItems({
    required this.plantasNeedingCare,
    required this.tarefasHoje,
    required this.tarefasAtrasadas,
    required this.tarefasCriticas,
    required this.urgencyScore,
  });
}

class ProductivityStats {
  final DateRange period;
  final int totalTarefas;
  final int tarefasConcluidas;
  final int tarefasPendentes;
  final int tarefasAtrasadas;
  final double completionRate;
  final int completionStreak;
  final Map<String, double> produtividadePorTipo;

  const ProductivityStats({
    required this.period,
    required this.totalTarefas,
    required this.tarefasConcluidas,
    required this.tarefasPendentes,
    required this.tarefasAtrasadas,
    required this.completionRate,
    required this.completionStreak,
    required this.produtividadePorTipo,
  });
}

class GrowthTrends {
  final DateRange period;
  final Map<String, int> crescimentoMensal;
  final Map<String, int> crescimentoSemanal;
  final double taxaCrescimentoMensal;
  final int totalNovasPlantasNoPeriodo;

  const GrowthTrends({
    required this.period,
    required this.crescimentoMensal,
    required this.crescimentoSemanal,
    required this.taxaCrescimentoMensal,
    required this.totalNovasPlantasNoPeriodo,
  });
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);
}
