// Dart imports:
import 'dart:async';

// Project imports:
import '../constants/timeout_constants.dart';
import '../dependency_injection.dart';
import '../models/task_grouping.dart';
import '../models/task_model.dart';
import 'error_stream_manager.dart';

/// Serviço singleton para gerenciamento de streams de tarefas
/// Fornece streams otimizados para diferentes filtros e agrupamentos
class TaskStreamService {
  static final TaskStreamService _instance = TaskStreamService._internal();
  factory TaskStreamService() => _instance;
  TaskStreamService._internal();

  final Map<String, StreamController<int>> _taskCountStreams = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  final ErrorStreamManager _errorManager = ErrorStreamManager();

  /// Stream granular para contagem de tarefas por filtro
  Stream<int> getTaskCountStream(String filterKey) {
    if (!_taskCountStreams.containsKey(filterKey)) {
      _taskCountStreams[filterKey] = StreamController<int>.broadcast();
      _initializeCountStream(filterKey);
    }
    return _taskCountStreams[filterKey]!.stream;
  }

  /// Stream otimizado para lista de tarefas
  Stream<List<Task>> getOptimizedTaskStream(String filterKey) {
    return _errorManager.wrapStreamWithErrorHandling(
      'tasks_$filterKey',
      _getTaskStreamByFilter(filterKey),
      fallbackValue: <Task>[],
    );
  }

  /// Stream para estado de carregamento
  Stream<bool> getLoadingStateStream(String filterKey) {
    return _errorManager.wrapStreamWithErrorHandling(
      'loading_$filterKey',
      _getTaskStreamByFilter(filterKey).map((tasks) => false),
      fallbackValue: false,
    );
  }

  Stream<List<Task>> _getTaskStreamByFilter(String filterKey) {
    final taskRepository = DependencyContainer.instance.taskRepository;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(TimeoutConstants.oneDay);
    final weekEnd = today.add(TimeoutConstants.oneWeek);

    switch (filterKey) {
      case 'today':
        return taskRepository.tasksStream.map((tasks) => tasks.where((task) {
          if (task.dueDate == null) return false;
          final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
          return dueDate.isAtSameMomentAs(today) || 
                 (dueDate.isBefore(tomorrow) && dueDate.isAfter(today.subtract(TimeoutConstants.oneDay)));
        }).toList());
      case 'overdue':
        return taskRepository.tasksStream.map((tasks) => tasks.where((task) => task.isOverdue).toList());
      case 'starred':
        return taskRepository.tasksStream.map((tasks) => tasks.where((task) => task.isStarred && !task.isCompleted).toList());
      case 'week':
        return taskRepository.tasksStream.map((tasks) => tasks.where((task) {
          if (task.dueDate == null) return false;
          return task.dueDate!.isAfter(today.subtract(TimeoutConstants.oneDay)) && 
                 task.dueDate!.isBefore(weekEnd);
        }).toList());
      case 'all':
      default:
        return taskRepository.tasksStream;
    }
  }

  void _initializeCountStream(String filterKey) {
    // Aplicar error handling robusto no stream
    final resilientStream = _errorManager.wrapStreamWithErrorHandling(
      'count_$filterKey',
      _getTaskStreamByFilter(filterKey).map((tasks) => tasks.length),
      fallbackValue: 0,
    );

    final subscription = resilientStream.listen(
      (count) {
        if (_taskCountStreams.containsKey(filterKey)) {
          _taskCountStreams[filterKey]?.add(count);
        }
      },
      onError: (error, stackTrace) {
        // Error já foi tratado pelo ErrorStreamManager
        // Apenas garantir que o stream continue funcionando
        if (_taskCountStreams.containsKey(filterKey)) {
          _taskCountStreams[filterKey]?.add(0); // Fallback para 0 tasks
        }
      },
    );

    _subscriptions[filterKey] = subscription;
  }

  /// Comparador otimizado para listas de tarefas
  bool _taskListEquals(List<Task> a, List<Task> b) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].isCompleted != b[i].isCompleted ||
          a[i].title != b[i].title ||
          a[i].isStarred != b[i].isStarred) {
        return false;
      }
    }
    return true;
  }

  /// Pré-processa dados para evitar processamento na UI
  Stream<ProcessedTaskData> getProcessedTaskStream({
    required String filterKey,
    String? selectedTag,
    required TaskGrouping grouping,
    int? limit,
  }) {
    return _getTaskStreamByFilter(filterKey).map((tasks) {
      // Aplicar filtro de tag
      if (selectedTag != null) {
        tasks = tasks.where((task) => task.tags.contains(selectedTag)).toList();
      }

      // Aplicar limite
      if (limit != null && grouping == TaskGrouping.none) {
        tasks = tasks.take(limit).toList();
      }

      // Aplicar agrupamento
      Map<String, List<Task>>? groups;
      if (grouping != TaskGrouping.none) {
        groups = _groupTasks(tasks, grouping);
      }

      return ProcessedTaskData(
        tasks: tasks,
        groups: groups,
        totalCount: tasks.length,
        isEmpty: tasks.isEmpty,
      );
    });
  }

  Map<String, List<Task>> _groupTasks(List<Task> tasks, TaskGrouping grouping) {
    switch (grouping) {
      case TaskGrouping.priority:
        return {
          'Urgente':
              tasks.where((t) => t.priority == TaskPriority.urgent).toList(),
          'Alta': tasks.where((t) => t.priority == TaskPriority.high).toList(),
          'Média':
              tasks.where((t) => t.priority == TaskPriority.medium).toList(),
          'Baixa': tasks.where((t) => t.priority == TaskPriority.low).toList(),
        };
      case TaskGrouping.date:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(TimeoutConstants.oneDay);

        return {
          'Vencidas': tasks
              .where((t) => t.dueDate != null && t.dueDate!.isBefore(today))
              .toList(),
          'Hoje': tasks
              .where((t) =>
                  t.dueDate != null &&
                  t.dueDate!.isAfter(today.subtract(TimeoutConstants.oneDay)) &&
                  t.dueDate!.isBefore(tomorrow))
              .toList(),
          'Amanhã': tasks
              .where((t) =>
                  t.dueDate != null &&
                  t.dueDate!
                      .isAfter(tomorrow.subtract(TimeoutConstants.oneDay)) &&
                  t.dueDate!.isBefore(tomorrow.add(TimeoutConstants.oneDay)))
              .toList(),
          'Futuras': tasks
              .where((t) => t.dueDate != null && t.dueDate!.isAfter(tomorrow))
              .toList(),
          'Sem data': tasks.where((t) => t.dueDate == null).toList(),
        };
      case TaskGrouping.status:
        return {
          'Concluídas': tasks.where((t) => t.isCompleted).toList(),
          'Pendentes': tasks.where((t) => !t.isCompleted).toList(),
        };
      case TaskGrouping.tags:
        final allTags = tasks.expand((t) => t.tags).toSet().toList();
        final groups = <String, List<Task>>{};

        for (final tag in allTags) {
          groups[tag] = tasks.where((t) => t.tags.contains(tag)).toList();
        }

        groups['Sem tags'] = tasks.where((t) => t.tags.isEmpty).toList();
        return groups;
      case TaskGrouping.none:
        return {'Todas': tasks};
    }
  }

  void dispose() {
    // Cancelar subscriptions
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Fechar stream controllers
    for (final subject in _taskCountStreams.values) {
      subject.close();
    }
    _taskCountStreams.clear();

    // Limpar recursos do error manager
    _errorManager.dispose();
  }
}

class ProcessedTaskData {
  final List<Task> tasks;
  final Map<String, List<Task>>? groups;
  final int totalCount;
  final bool isEmpty;

  ProcessedTaskData({
    required this.tasks,
    this.groups,
    required this.totalCount,
    required this.isEmpty,
  });

  bool isEqual(ProcessedTaskData other) {
    if (totalCount != other.totalCount || isEmpty != other.isEmpty) {
      return false;
    }

    if (tasks.length != other.tasks.length) return false;

    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].id != other.tasks[i].id ||
          tasks[i].isCompleted != other.tasks[i].isCompleted ||
          tasks[i].title != other.tasks[i].title ||
          tasks[i].isStarred != other.tasks[i].isStarred) {
        return false;
      }
    }

    return true;
  }
}
