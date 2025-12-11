import 'package:flutter/foundation.dart';

import '../entities/plant.dart';
import '../entities/plant_task.dart';

/// Serviço de validação para PlantTasks
/// Garante integridade e consistência dos dados
class PlantTaskValidationService {
  /// Valida uma PlantTask individual
  static PlantTaskValidationResult validatePlantTask(
    PlantTask task,
    Plant? plant,
  ) {
    final errors = <String>[];
    final warnings = <String>[];
    if (task.id.isEmpty) {
      errors.add('ID da tarefa é obrigatório');
    }

    if (task.plantId.isEmpty) {
      errors.add('ID da planta é obrigatório');
    }

    if (task.title.trim().isEmpty) {
      errors.add('Título da tarefa é obrigatório');
    }

    if (task.intervalDays <= 0) {
      errors.add('Intervalo de dias deve ser maior que zero');
    }
    if (task.scheduledDate.isBefore(DateTime(2020))) {
      errors.add('Data agendada é muito antiga');
    }

    if (task.completedDate != null && task.status != TaskStatus.completed) {
      warnings.add('Tarefa tem data de conclusão mas status não é completado');
    }

    if (task.status == TaskStatus.completed && task.completedDate == null) {
      warnings.add('Tarefa marcada como completada mas sem data de conclusão');
    }

    if (task.nextScheduledDate != null &&
        task.nextScheduledDate!.isBefore(task.scheduledDate)) {
      warnings.add('Próxima data agendada é anterior à data atual');
    }
    if (plant == null) {
      warnings.add('Planta associada não encontrada (ID: ${task.plantId})');
    } else {
      if (!_plantSupportsTaskType(plant, task.type)) {
        warnings.add(
          'Planta não tem configuração para tipo de tarefa ${task.type.displayName}',
        );
      }
    }
    if (task.completedDate != null &&
        task.completedDate!.isAfter(DateTime.now())) {
      errors.add('Data de conclusão não pode ser no futuro');
    }

    if (task.createdAt.isAfter(
      DateTime.now().add(const Duration(minutes: 5)),
    )) {
      warnings.add('Data de criação parece estar no futuro');
    }
    _validateTaskTypeSpecific(task, errors, warnings);

    final result = PlantTaskValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      task: task,
      plant: plant,
    );

    if (kDebugMode && (!result.isValid || result.warnings.isNotEmpty)) {
      print(
        '⚠️ PlantTaskValidation: Problemas encontrados na tarefa ${task.id}:',
      );
      for (final error in errors) {
        print('   ERROR: $error');
      }
      for (final warning in warnings) {
        print('   WARNING: $warning');
      }
    }

    return result;
  }

  /// Valida uma lista de PlantTasks
  static PlantTaskBatchValidationResult validatePlantTasks(
    List<PlantTask> tasks,
    Map<String, Plant> plantsById,
  ) {
    final results = <PlantTaskValidationResult>[];
    final duplicateIds = <String>[];
    final orphanTasks = <PlantTask>[];
    final inconsistentIntervals = <PlantTask>[];
    for (final task in tasks) {
      final plant = plantsById[task.plantId];
      final result = validatePlantTask(task, plant);
      results.add(result);

      if (plant == null) {
        orphanTasks.add(task);
      }
    }
    final seenIds = <String>{};
    for (final task in tasks) {
      if (seenIds.contains(task.id)) {
        duplicateIds.add(task.id);
      } else {
        seenIds.add(task.id);
      }
    }
    final tasksByPlantAndType = <String, List<PlantTask>>{};
    for (final task in tasks) {
      final key = '${task.plantId}_${task.type.name}';
      tasksByPlantAndType.putIfAbsent(key, () => []).add(task);
    }

    for (final entry in tasksByPlantAndType.entries) {
      final tasksGroup = entry.value;
      if (tasksGroup.length > 1) {
        final intervals = tasksGroup.map((t) => t.intervalDays).toSet();
        if (intervals.length > 1) {
          inconsistentIntervals.addAll(tasksGroup);
        }
      }
    }

    final validTasks = results.where((r) => r.isValid).length;
    final invalidTasks = results.where((r) => !r.isValid).length;
    final tasksWithWarnings = results
        .where((r) => r.warnings.isNotEmpty)
        .length;

    final batchResult = PlantTaskBatchValidationResult(
      totalTasks: tasks.length,
      validTasks: validTasks,
      invalidTasks: invalidTasks,
      tasksWithWarnings: tasksWithWarnings,
      individualResults: results,
      duplicateIds: duplicateIds,
      orphanTasks: orphanTasks,
      inconsistentIntervals: inconsistentIntervals,
    );

    if (kDebugMode) {
      print('📊 PlantTaskBatchValidation: Resultado da validação em lote:');
      print('   - Total: ${batchResult.totalTasks}');
      print('   - Válidas: ${batchResult.validTasks}');
      print('   - Inválidas: ${batchResult.invalidTasks}');
      print('   - Com avisos: ${batchResult.tasksWithWarnings}');
      print('   - IDs duplicados: ${batchResult.duplicateIds.length}');
      print('   - Tarefas órfãs: ${batchResult.orphanTasks.length}');
      print(
        '   - Intervalos inconsistentes: ${batchResult.inconsistentIntervals.length}',
      );
    }

    return batchResult;
  }

  /// Verifica se a planta suporta um tipo específico de tarefa
  static bool _plantSupportsTaskType(Plant plant, TaskType taskType) {
    final config = plant.config;
    if (config == null) return false;

    switch (taskType) {
      case TaskType.watering:
        return config.hasWateringSchedule;
      case TaskType.fertilizing:
        return config.hasFertilizingSchedule;
      case TaskType.pruning:
        return config.hasPruningSchedule;
      case TaskType.sunlightCheck:
        return config.hasSunlightCheckSchedule;
      case TaskType.pestInspection:
        return config.hasPestInspectionSchedule;
      case TaskType.replanting:
        return config.hasReplantingSchedule;
    }
  }

  /// Validações específicas por tipo de tarefa
  static void _validateTaskTypeSpecific(
    PlantTask task,
    List<String> errors,
    List<String> warnings,
  ) {
    switch (task.type) {
      case TaskType.watering:
        if (task.intervalDays > 30) {
          warnings.add(
            'Intervalo de rega muito longo (${task.intervalDays} dias)',
          );
        }
        if (task.intervalDays < 1) {
          errors.add('Intervalo de rega deve ser pelo menos 1 dia');
        }
        break;

      case TaskType.fertilizing:
        if (task.intervalDays < 7) {
          warnings.add(
            'Intervalo de fertilização muito curto (${task.intervalDays} dias)',
          );
        }
        if (task.intervalDays > 365) {
          warnings.add(
            'Intervalo de fertilização muito longo (${task.intervalDays} dias)',
          );
        }
        break;

      case TaskType.pruning:
        if (task.intervalDays < 30) {
          warnings.add(
            'Intervalo de poda muito curto (${task.intervalDays} dias)',
          );
        }
        break;

      case TaskType.sunlightCheck:
        if (task.intervalDays > 14) {
          warnings.add('Verificação de luz solar deveria ser mais frequente');
        }
        break;

      case TaskType.pestInspection:
        if (task.intervalDays > 21) {
          warnings.add('Inspeção de pragas deveria ser mais frequente');
        }
        break;

      case TaskType.replanting:
        if (task.intervalDays < 365) {
          warnings.add(
            'Intervalo de replantio muito curto (${task.intervalDays} dias)',
          );
        }
        break;
    }
  }

  /// Gera relatório de saúde do sistema de tarefas
  static PlantTaskHealthReport generateHealthReport(
    List<PlantTask> tasks,
    Map<String, Plant> plantsById,
  ) {
    final validation = validatePlantTasks(tasks, plantsById);
    final now = DateTime.now();
    final pendingTasks = tasks
        .where((t) => t.status == TaskStatus.pending)
        .length;
    final completedTasks = tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    final overdueTasks = tasks
        .where((t) => t.status == TaskStatus.overdue)
        .length;
    final todayTasks = tasks.where((t) => t.isDueToday).length;
    final upcomingTasks = tasks
        .where((t) => t.isDueSoon && !t.isDueToday)
        .length;
    final oldestTask = tasks.isEmpty
        ? null
        : tasks.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
    final tasksByType = <TaskType, int>{};
    for (final task in tasks) {
      tasksByType[task.type] = (tasksByType[task.type] ?? 0) + 1;
    }
    final plantsWithoutTasks = plantsById.values
        .where((plant) => !tasks.any((task) => task.plantId == plant.id))
        .length;

    final healthScore = _calculateHealthScore(validation, tasks, plantsById);

    final report = PlantTaskHealthReport(
      timestamp: now,
      totalTasks: tasks.length,
      totalPlants: plantsById.length,
      validationResult: validation,
      healthScore: healthScore,
      statusStatistics: {
        'pending': pendingTasks,
        'completed': completedTasks,
        'overdue': overdueTasks,
      },
      temporalStatistics: {
        'today': todayTasks,
        'upcoming': upcomingTasks,
        'oldest_task_age_days': oldestTask != null
            ? now.difference(oldestTask.createdAt).inDays
            : 0,
      },
      typeStatistics: tasksByType,
      plantsWithoutTasks: plantsWithoutTasks,
    );

    if (kDebugMode) {
      print(
        '🏥 PlantTaskHealthReport: Health score: ${report.healthScore}/100',
      );
      print('   - ${report.totalTasks} tasks, ${report.totalPlants} plantas');
      print(
        '   - Válidas: ${report.validationResult.validTasks}/${report.totalTasks}',
      );
      print(
        '   - Hoje: ${report.temporalStatistics['today']}, Próximas: ${report.temporalStatistics['upcoming']}',
      );
    }

    return report;
  }

  /// Calcula score de saúde do sistema (0-100)
  static double _calculateHealthScore(
    PlantTaskBatchValidationResult validation,
    List<PlantTask> tasks,
    Map<String, Plant> plantsById,
  ) {
    if (tasks.isEmpty) return 0.0;

    double score = 100.0;
    final invalidRatio = validation.invalidTasks / validation.totalTasks;
    score -= invalidRatio * 30;
    if (validation.duplicateIds.isNotEmpty) {
      score -= 10;
    }
    final orphanRatio = validation.orphanTasks.length / validation.totalTasks;
    score -= orphanRatio * 20;
    final inconsistentRatio =
        validation.inconsistentIntervals.length / validation.totalTasks;
    score -= inconsistentRatio * 15;
    final overdueTasks = tasks
        .where((t) => t.status == TaskStatus.overdue)
        .length;
    final overdueRatio = overdueTasks / tasks.length;
    score -= overdueRatio * 25;
    final plantsWithTasks = tasks.map((t) => t.plantId).toSet().length;
    if (plantsWithTasks == plantsById.length && plantsById.isNotEmpty) {
      score += 10;
    }

    return score.clamp(0.0, 100.0);
  }
}

/// Resultado de validação de uma PlantTask individual
class PlantTaskValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final PlantTask task;
  final Plant? plant;

  const PlantTaskValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.task,
    this.plant,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasCriticalIssues => !isValid || errors.isNotEmpty;
}

/// Resultado de validação em lote
class PlantTaskBatchValidationResult {
  final int totalTasks;
  final int validTasks;
  final int invalidTasks;
  final int tasksWithWarnings;
  final List<PlantTaskValidationResult> individualResults;
  final List<String> duplicateIds;
  final List<PlantTask> orphanTasks;
  final List<PlantTask> inconsistentIntervals;

  const PlantTaskBatchValidationResult({
    required this.totalTasks,
    required this.validTasks,
    required this.invalidTasks,
    required this.tasksWithWarnings,
    required this.individualResults,
    required this.duplicateIds,
    required this.orphanTasks,
    required this.inconsistentIntervals,
  });

  bool get isHealthy =>
      invalidTasks == 0 && duplicateIds.isEmpty && orphanTasks.isEmpty;
  double get validRatio => totalTasks > 0 ? validTasks / totalTasks : 0.0;
}

/// Relatório de saúde do sistema
class PlantTaskHealthReport {
  final DateTime timestamp;
  final int totalTasks;
  final int totalPlants;
  final PlantTaskBatchValidationResult validationResult;
  final double healthScore;
  final Map<String, int> statusStatistics;
  final Map<String, int> temporalStatistics;
  final Map<TaskType, int> typeStatistics;
  final int plantsWithoutTasks;

  const PlantTaskHealthReport({
    required this.timestamp,
    required this.totalTasks,
    required this.totalPlants,
    required this.validationResult,
    required this.healthScore,
    required this.statusStatistics,
    required this.temporalStatistics,
    required this.typeStatistics,
    required this.plantsWithoutTasks,
  });

  bool get isHealthy => healthScore >= 80.0 && validationResult.isHealthy;

  String generateSummary() {
    return '''
📊 Plant Task System Health Report
Generated: ${timestamp.toIso8601String()}

🎯 Health Score: ${healthScore.toStringAsFixed(1)}/100 ${isHealthy ? '✅' : '⚠️'}

📈 Statistics:
- Total Tasks: $totalTasks
- Total Plants: $totalPlants
- Valid Tasks: ${validationResult.validTasks}/${validationResult.totalTasks} (${(validationResult.validRatio * 100).toStringAsFixed(1)}%)
- Plants without tasks: $plantsWithoutTasks

📋 Task Status:
- Pending: ${statusStatistics['pending']}
- Completed: ${statusStatistics['completed']}
- Overdue: ${statusStatistics['overdue']}

⏰ Schedule:
- Due today: ${temporalStatistics['today']}
- Due soon: ${temporalStatistics['upcoming']}

${validationResult.isHealthy ? '✅ System is healthy!' : '⚠️ Issues detected - check validation details'}
''';
  }
}
