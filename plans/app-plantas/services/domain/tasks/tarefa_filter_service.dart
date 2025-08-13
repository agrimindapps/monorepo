// Dart imports:
import 'dart:async';

// Project imports:
import '../../../core/extensions/datetime_extensions.dart';

import '../../../database/tarefa_model.dart';
import '../../../repository/tarefa_repository.dart';

/// Serviço para filtros complexos de tarefas
/// Responsabilidade: Lógica de filtros e consultas específicas de tarefas
class TarefaFilterService {
  static TarefaFilterService? _instance;
  static TarefaFilterService get instance =>
      _instance ??= TarefaFilterService._();

  final TarefaRepository _repository = TarefaRepository.instance;

  TarefaFilterService._();

  /// Filtrar tarefas por critério de data
  Future<List<TarefaModel>> filterByDateCriteria(
    DateFilterCriteria criteria, {
    bool includeConcluidas = false,
  }) async {
    final tarefas = await _repository.findAll();

    return tarefas.where((tarefa) {
      if (!includeConcluidas && tarefa.concluida) return false;

      return _matchesDateCriteria(tarefa.dataExecucao, criteria);
    }).toList();
  }

  /// Stream de tarefas filtradas por critério de data
  Stream<List<TarefaModel>> watchFilteredByDate(
    DateFilterCriteria criteria, {
    bool includeConcluidas = false,
  }) {
    return _repository.tarefasStream.map((tarefas) {
      return tarefas.where((tarefa) {
        if (!includeConcluidas && tarefa.concluida) return false;

        return _matchesDateCriteria(tarefa.dataExecucao, criteria);
      }).toList();
    });
  }

  /// Filtrar tarefas por múltiplos critérios
  Future<List<TarefaModel>> filterByMultipleCriteria(
      TaskFilterCriteria criteria) async {
    final tarefas = await _repository.findAll();

    return tarefas
        .where((tarefa) => _matchesCriteria(tarefa, criteria))
        .toList();
  }

  /// Stream de tarefas com filtros múltiplos
  Stream<List<TarefaModel>> watchFilteredByMultipleCriteria(
      TaskFilterCriteria criteria) {
    return _repository.tarefasStream.map((tarefas) {
      return tarefas
          .where((tarefa) => _matchesCriteria(tarefa, criteria))
          .toList();
    });
  }

  /// Buscar tarefas por período personalizado
  Future<List<TarefaModel>> findByCustomPeriod(
    DateTime startDate,
    DateTime endDate, {
    List<String>? careTypes,
    bool? concluida,
    String? plantaId,
  }) async {
    final tarefas = await _repository.findAll();

    return tarefas.where((tarefa) {
      // Filtro de período
      if (!tarefa.dataExecucao.isBetween(startDate, endDate)) return false;

      // Filtro de tipos de cuidado
      if (careTypes != null && !careTypes.contains(tarefa.tipoCuidado)) {
        return false;
    }

      // Filtro de status
      if (concluida != null && tarefa.concluida != concluida) return false;

      // Filtro de planta
      if (plantaId != null && tarefa.plantaId != plantaId) return false;

      return true;
    }).toList();
  }

  /// Buscar tarefas com filtros avançados
  Future<List<TarefaModel>> findWithAdvancedFilters({
    List<String>? plantaIds,
    List<String>? careTypes,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchTerm,
    int limit = 100,
  }) async {
    final tarefas = await _repository.findAll();

    var filtered = tarefas.where((tarefa) {
      // Filtro de plantas
      if (plantaIds != null && !plantaIds.contains(tarefa.plantaId)) {
        return false;
    }

      // Filtro de tipos de cuidado
      if (careTypes != null && !careTypes.contains(tarefa.tipoCuidado)) {
        return false;
    }

      // Filtro de status
      if (status != null) {
        switch (status) {
          case TaskStatus.pending:
            if (tarefa.concluida) return false;
            break;
          case TaskStatus.completed:
            if (!tarefa.concluida) return false;
            break;
          case TaskStatus.overdue:
            if (tarefa.concluida || !tarefa.dataExecucao.isBeforeToday) {
              return false;
            }
            break;
        }
      }

      // Filtro de período
      if (fromDate != null && tarefa.dataExecucao.isBefore(fromDate)) {
        return false;
    }
      if (toDate != null && tarefa.dataExecucao.isAfter(toDate)) {
        return false;
    }

      // Filtro de busca por texto
      if (searchTerm != null && searchTerm.isNotEmpty) {
        final searchLower = searchTerm.toLowerCase();
        final hasMatch =
            tarefa.observacoes?.toLowerCase().contains(searchLower) ?? false;
        if (!hasMatch) return false;
      }

      return true;
    });

    return filtered.take(limit).toList();
  }

  /// Agrupar tarefas por critério específico
  Future<Map<String, List<TarefaModel>>> groupTasksBy(
      TaskGroupCriteria criteria) async {
    final tarefas = await _repository.findAll();
    final groups = <String, List<TarefaModel>>{};

    for (final tarefa in tarefas) {
      final key = _getGroupKey(tarefa, criteria);
      groups.putIfAbsent(key, () => <TarefaModel>[]).add(tarefa);
    }

    return groups;
  }

  /// Buscar tarefas com paginação
  Future<TaskPage> findPaginated({
    int page = 0,
    int size = 20,
    TaskFilterCriteria? filter,
    TaskSortCriteria sort = TaskSortCriteria.dateDesc,
  }) async {
    var tarefas = await _repository.findAll();

    // Aplicar filtros
    if (filter != null) {
      tarefas =
          tarefas.where((tarefa) => _matchesCriteria(tarefa, filter)).toList();
    }

    // Aplicar ordenação
    _sortTasks(tarefas, sort);

    // Aplicar paginação
    final totalElements = tarefas.length;
    final totalPages = (totalElements / size).ceil();
    final startIndex = page * size;
    final endIndex = (startIndex + size).clamp(0, totalElements);

    final content = startIndex < totalElements
        ? tarefas.sublist(startIndex, endIndex)
        : <TarefaModel>[];

    return TaskPage(
      content: content,
      page: page,
      size: size,
      totalElements: totalElements,
      totalPages: totalPages,
      hasNext: page < totalPages - 1,
      hasPrevious: page > 0,
    );
  }

  // Métodos auxiliares privados

  bool _matchesDateCriteria(DateTime date, DateFilterCriteria criteria) {
    switch (criteria) {
      case DateFilterCriteria.today:
        return date.isToday;
      case DateFilterCriteria.tomorrow:
        return date.isTomorrow;
      case DateFilterCriteria.yesterday:
        return date.isYesterday;
      case DateFilterCriteria.thisWeek:
        return date.isThisWeek;
      case DateFilterCriteria.thisMonth:
        return date.isThisMonth;
      case DateFilterCriteria.future:
        return date.isAfterToday;
      case DateFilterCriteria.past:
        return date.isBeforeToday;
    }
  }

  bool _matchesCriteria(TarefaModel tarefa, TaskFilterCriteria criteria) {
    if (criteria.plantaIds != null &&
        !criteria.plantaIds!.contains(tarefa.plantaId)) {
      return false;
    }

    if (criteria.careTypes != null &&
        !criteria.careTypes!.contains(tarefa.tipoCuidado)) {
      return false;
    }

    if (criteria.concluida != null && tarefa.concluida != criteria.concluida) {
      return false;
    }

    if (criteria.dateFilter != null &&
        !_matchesDateCriteria(tarefa.dataExecucao, criteria.dateFilter!)) {
      return false;
    }

    return true;
  }

  String _getGroupKey(TarefaModel tarefa, TaskGroupCriteria criteria) {
    switch (criteria) {
      case TaskGroupCriteria.careType:
        return tarefa.tipoCuidado;
      case TaskGroupCriteria.plantaId:
        return tarefa.plantaId;
      case TaskGroupCriteria.status:
        return tarefa.concluida ? 'Concluída' : 'Pendente';
      case TaskGroupCriteria.date:
        return '${tarefa.dataExecucao.year}-${tarefa.dataExecucao.month.toString().padLeft(2, '0')}-${tarefa.dataExecucao.day.toString().padLeft(2, '0')}';
      case TaskGroupCriteria.month:
        return '${tarefa.dataExecucao.year}-${tarefa.dataExecucao.month.toString().padLeft(2, '0')}';
    }
  }

  void _sortTasks(List<TarefaModel> tasks, TaskSortCriteria criteria) {
    switch (criteria) {
      case TaskSortCriteria.dateAsc:
        tasks.sort((a, b) => a.dataExecucao.compareTo(b.dataExecucao));
        break;
      case TaskSortCriteria.dateDesc:
        tasks.sort((a, b) => b.dataExecucao.compareTo(a.dataExecucao));
        break;
      case TaskSortCriteria.careType:
        tasks.sort((a, b) => a.tipoCuidado.compareTo(b.tipoCuidado));
        break;
      case TaskSortCriteria.status:
        tasks.sort(
            (a, b) => a.concluida == b.concluida ? 0 : (a.concluida ? 1 : -1));
        break;
    }
  }
}

// Enums e classes auxiliares

enum DateFilterCriteria {
  today,
  tomorrow,
  yesterday,
  thisWeek,
  thisMonth,
  future,
  past,
}

enum TaskPriority {
  low,
  medium,
  high,
  critical,
}

enum TaskStatus {
  pending,
  completed,
  overdue,
}

enum TaskGroupCriteria {
  careType,
  plantaId,
  status,
  date,
  month,
}

enum TaskSortCriteria {
  dateAsc,
  dateDesc,
  careType,
  status,
}

class TaskFilterCriteria {
  final List<String>? plantaIds;
  final List<String>? careTypes;
  final bool? concluida;
  final DateFilterCriteria? dateFilter;

  const TaskFilterCriteria({
    this.plantaIds,
    this.careTypes,
    this.concluida,
    this.dateFilter,
  });
}

class TaskPage {
  final List<TarefaModel> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const TaskPage({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });
}
