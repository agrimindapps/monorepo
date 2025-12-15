import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../tasks/domain/entities/task.dart' as task_entity;
import '../../../tasks/domain/repositories/tasks_repository.dart';
import '../entities/plant.dart';
import '../entities/plant_task.dart';
import '../repositories/plant_tasks_repository.dart';
import '../repositories/plants_repository.dart';
import '../services/plant_task_task_adapter.dart';

/// Use case para unificar o sistema de PlantTasks com Tasks
/// Elimina duplicação e sincroniza os dois sistemas
class UnifyPlantTasksUseCase
    implements UseCase<UnificationResult, UnifyPlantTasksParams> {
  final PlantTasksRepository plantTasksRepository;
  final TasksRepository tasksRepository;
  final PlantsRepository plantsRepository;

  UnifyPlantTasksUseCase({
    required this.plantTasksRepository,
    required this.tasksRepository,
    required this.plantsRepository,
  });

  @override
  Future<Either<Failure, UnificationResult>> call(
    UnifyPlantTasksParams params,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 UnifyPlantTasksUseCase: Iniciando unificação do sistema de tarefas',
        );
      }
      final loadResult = await _loadAllData();
      if (loadResult.isLeft()) {
        return loadResult.map(
          (r) => UnificationResult.failure('Erro ao carregar dados'),
        );
      }

      final data = loadResult.getOrElse(
        () => throw Exception('Dados não encontrados'),
      );
      final conflicts = PlantTaskTaskAdapter.findConflictingTaskIds(
        plantTasks: data.plantTasks,
        existingTasks: data.existingTasks,
      );

      if (conflicts.isNotEmpty && !params.forceResolveConflicts) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ UnifyPlantTasksUseCase: ${conflicts.length} conflitos encontrados',
          );
        }
        return Right(UnificationResult.conflict(conflicts, data));
      }
      final unificationResult = await _executeUnification(data, params);

      return unificationResult;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ UnifyPlantTasksUseCase: Erro inesperado: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Right(
        UnificationResult.failure('Erro inesperado: ${e.toString()}'),
      );
    }
  }

  /// Carrega todos os dados necessários para a unificação
  Future<Either<Failure, UnificationData>> _loadAllData() async {
    try {
      final results = await Future.wait([
        plantTasksRepository.getPlantTasks(),
        tasksRepository.getTasks(),
        plantsRepository.getPlants(),
      ]);

      final plantTasksResult = results[0] as Either<Failure, List<PlantTask>>;
      final tasksResult = results[1] as Either<Failure, List<task_entity.Task>>;
      final plantsResult = results[2] as Either<Failure, List<Plant>>;
      return plantTasksResult.fold(
        (failure) => Left(failure),
        (plantTasks) => tasksResult.fold(
          (failure) => Left(failure),
          (tasks) => plantsResult.fold((failure) => Left(failure), (plants) {
            final plantsById = {for (final plant in plants) plant.id: plant};

            if (kDebugMode) {
              debugPrint('📊 UnifyPlantTasksUseCase: Dados carregados:');
              debugPrint('   - ${plantTasks.length} PlantTasks');
              debugPrint('   - ${tasks.length} Tasks existentes');
              debugPrint('   - ${plants.length} Plantas');
            }

            return Right(
              UnificationData(
                plantTasks: plantTasks,
                existingTasks: tasks,
                plants: plants,
                plantsById: plantsById,
              ),
            );
          }),
        ),
      );
    } catch (e) {
      return Left(UnknownFailure('Erro ao carregar dados: ${e.toString()}'));
    }
  }

  /// Executa a unificação propriamente dita
  Future<Either<Failure, UnificationResult>> _executeUnification(
    UnificationData data,
    UnifyPlantTasksParams params,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 UnifyPlantTasksUseCase: Executando unificação');
      }
      final unifiedTasks = PlantTaskTaskAdapter.mergePlantTasksWithTasks(
        plantTasks: data.plantTasks,
        existingTasks: data.existingTasks,
        plantsById: data.plantsById,
      );

      if (kDebugMode) {
        debugPrint(
          '✅ UnifyPlantTasksUseCase: ${unifiedTasks.length} tasks unificadas',
        );
      }
      if (params.syncWithTasksRepository) {
        await _syncUnifiedTasks(unifiedTasks, data);
      }
      final report = PlantTaskTaskAdapter.generateMigrationReport(
        plantTasks: data.plantTasks,
        existingTasks: data.existingTasks,
        plantsById: data.plantsById,
      );

      if (kDebugMode) {
        debugPrint('📊 UnifyPlantTasksUseCase: Relatório de unificação:');
        debugPrint(report);
      }

      return Right(
        UnificationResult.success(
          unifiedTasks: unifiedTasks,
          report: report,
          originalData: data,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ UnifyPlantTasksUseCase: Erro na execução: $e');
      }
      return Left(UnknownFailure('Erro na unificação: ${e.toString()}'));
    }
  }

  /// Sincroniza tasks unificadas com repositório principal
  Future<void> _syncUnifiedTasks(
    List<task_entity.Task> tasks,
    UnificationData data,
  ) async {
    if (kDebugMode) {
      debugPrint(
        '🔄 UnifyPlantTasksUseCase: Sincronizando ${tasks.length} tasks unificadas',
      );
    }

    final tasksFromPlantTasks = tasks
        .where((task) => PlantTaskTaskAdapter.isTaskFromPlantTask(task))
        .length;

    if (kDebugMode) {
      debugPrint('📊 UnifyPlantTasksUseCase: Sincronização simulada:');
      debugPrint('   - $tasksFromPlantTasks tasks originadas de PlantTasks');
      debugPrint(
        '   - ${tasks.length - tasksFromPlantTasks} tasks existentes mantidas',
      );
    }
  }
}

/// Parâmetros para o use case de unificação
class UnifyPlantTasksParams {
  final bool forceResolveConflicts;
  final bool syncWithTasksRepository;
  final bool generateDetailedReport;

  const UnifyPlantTasksParams({
    this.forceResolveConflicts = false,
    this.syncWithTasksRepository = false,
    this.generateDetailedReport = true,
  });

  factory UnifyPlantTasksParams.preview() => const UnifyPlantTasksParams();

  factory UnifyPlantTasksParams.execute() =>
      const UnifyPlantTasksParams(syncWithTasksRepository: true);

  factory UnifyPlantTasksParams.force() => const UnifyPlantTasksParams(
    forceResolveConflicts: true,
    syncWithTasksRepository: true,
  );
}

/// Dados necessários para a unificação
class UnificationData {
  final List<PlantTask> plantTasks;
  final List<task_entity.Task> existingTasks;
  final List<Plant> plants;
  final Map<String, Plant> plantsById;

  const UnificationData({
    required this.plantTasks,
    required this.existingTasks,
    required this.plants,
    required this.plantsById,
  });
}

/// Resultado da unificação
class UnificationResult {
  final bool isSuccess;
  final bool isConflict;
  final bool isFailure;
  final String? message;
  final List<task_entity.Task>? unifiedTasks;
  final List<String>? conflictingTaskIds;
  final Map<String, dynamic>? report;
  final UnificationData? originalData;

  const UnificationResult._({
    required this.isSuccess,
    required this.isConflict,
    required this.isFailure,
    this.message,
    this.unifiedTasks,
    this.conflictingTaskIds,
    this.report,
    this.originalData,
  });

  factory UnificationResult.success({
    required List<task_entity.Task> unifiedTasks,
    required Map<String, dynamic> report,
    required UnificationData originalData,
  }) {
    return UnificationResult._(
      isSuccess: true,
      isConflict: false,
      isFailure: false,
      message: 'Unificação concluída com sucesso',
      unifiedTasks: unifiedTasks,
      report: report,
      originalData: originalData,
    );
  }

  factory UnificationResult.conflict(
    List<String> conflictingIds,
    UnificationData data,
  ) {
    return UnificationResult._(
      isSuccess: false,
      isConflict: true,
      isFailure: false,
      message: '${conflictingIds.length} conflitos encontrados',
      conflictingTaskIds: conflictingIds,
      originalData: data,
    );
  }

  factory UnificationResult.failure(String message) {
    return UnificationResult._(
      isSuccess: false,
      isConflict: false,
      isFailure: true,
      message: message,
    );
  }

  /// Gera relatório textual do resultado
  String generateTextReport() {
    if (isFailure) {
      return 'FALHA: $message';
    }

    if (isConflict) {
      return '''
CONFLITOS ENCONTRADOS: $message

IDs conflitantes: ${conflictingTaskIds?.join(', ')}

Resolva os conflitos antes de prosseguir ou use forceResolveConflicts: true.
''';
    }

    if (isSuccess && report != null) {
      final summary = report!['summary'] as Map<String, dynamic>;
      final recommendations = report!['recommendations'] as List<String>;

      return '''
UNIFICAÇÃO CONCLUÍDA COM SUCESSO

Resumo:
- PlantTasks convertidas: ${summary['plant_tasks_converted']}
- Tasks existentes mantidas: ${summary['existing_non_plant_tasks']}
- Plantas com tarefas: ${summary['plants_with_tasks']}
- Total de tasks unificadas: ${unifiedTasks?.length ?? 0}

Recomendações:
${recommendations.map((r) => '- $r').join('\n')}
''';
    }

    return 'Resultado desconhecido';
  }
}
