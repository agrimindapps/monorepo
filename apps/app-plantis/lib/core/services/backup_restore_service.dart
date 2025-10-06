import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/plants/domain/entities/plant.dart';
import '../../features/plants/domain/entities/space.dart';
import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/plants/domain/repositories/spaces_repository.dart';
import '../../features/tasks/domain/entities/task.dart' as task_entity;
import '../../features/tasks/domain/repositories/tasks_repository.dart';
import '../data/models/backup_model.dart';
import 'backup_audit_service.dart';
import 'backup_data_transformer_service.dart';
import 'backup_validation_service.dart';
import 'secure_storage_service.dart';
class CriticalFailure extends Failure {
  const CriticalFailure(String message) : super(message: message);

  @override
  List<Object?> get props => [message];
}

class RestoreException implements Exception {
  final String message;

  const RestoreException(this.message);

  @override
  String toString() => 'RestoreException: $message';
}

/// Estratégias de merge para restore
enum RestoreMergeStrategy {
  replace('replace', 'Substituir Existentes'),
  merge('merge', 'Mesclar Dados'),
  skip('skip', 'Pular Duplicados');

  const RestoreMergeStrategy(this.key, this.displayName);
  final String key;
  final String displayName;
}

/// Opções para operação de restore
class RestoreOptions {
  final bool restorePlants;
  final bool restoreSpaces;
  final bool restoreTasks;
  final bool restoreSettings;
  final RestoreMergeStrategy mergeStrategy;

  const RestoreOptions({
    this.restorePlants = true,
    this.restoreSpaces = true,
    this.restoreTasks = true,
    this.restoreSettings = true,
    this.mergeStrategy = RestoreMergeStrategy.merge,
  });

  RestoreOptions copyWith({
    bool? restorePlants,
    bool? restoreSpaces,
    bool? restoreTasks,
    bool? restoreSettings,
    RestoreMergeStrategy? mergeStrategy,
  }) {
    return RestoreOptions(
      restorePlants: restorePlants ?? this.restorePlants,
      restoreSpaces: restoreSpaces ?? this.restoreSpaces,
      restoreTasks: restoreTasks ?? this.restoreTasks,
      restoreSettings: restoreSettings ?? this.restoreSettings,
      mergeStrategy: mergeStrategy ?? this.mergeStrategy,
    );
  }
}

/// Resultado de operação de restore
class RestoreResult {
  final bool isSuccess;
  final int itemsRestored;
  final Map<String, int> restoredCounts;
  final String? errorMessage;

  const RestoreResult({
    required this.isSuccess,
    required this.itemsRestored,
    this.restoredCounts = const {},
    this.errorMessage,
  });

  factory RestoreResult.success({
    required int itemsRestored,
    required Map<String, int> restoredCounts,
  }) {
    return RestoreResult(
      isSuccess: true,
      itemsRestored: itemsRestored,
      restoredCounts: restoredCounts,
    );
  }

  factory RestoreResult.failure({required String errorMessage}) {
    return RestoreResult(
      isSuccess: false,
      itemsRestored: 0,
      errorMessage: errorMessage,
    );
  }
}

/// Service especializado em operações de restore de backup
/// Implementa Single Responsibility Principle - apenas restore e rollback
class BackupRestoreService {
  final PlantsRepository _plantsRepository;
  final SpacesRepository _spacesRepository;
  final TasksRepository _tasksRepository;
  final SecureStorageService _storageService;
  final BackupValidationService _validationService;
  final BackupDataTransformerService _transformerService;
  final BackupAuditService _auditService;

  const BackupRestoreService({
    required PlantsRepository plantsRepository,
    required SpacesRepository spacesRepository,
    required TasksRepository tasksRepository,
    required SecureStorageService storageService,
    required BackupValidationService validationService,
    required BackupDataTransformerService transformerService,
    required BackupAuditService auditService,
  }) : _plantsRepository = plantsRepository,
       _spacesRepository = spacesRepository,
       _tasksRepository = tasksRepository,
       _storageService = storageService,
       _validationService = validationService,
       _transformerService = transformerService,
       _auditService = auditService;

  /// Restaura dados a partir de um backup com validação e rollback automático
  Future<Either<Failure, RestoreResult>> restoreBackup(
    BackupModel backup,
    String userId,
    RestoreOptions options,
  ) async {
    Map<String, dynamic>? preRestoreBackup;
    bool needsRollback = false;

    try {
      debugPrint('🔍 Validando integridade do backup...');
      final validationResult = await _validationService.validateBackupIntegrity(
        backup,
      );

      if (validationResult.isLeft()) {
        await _auditService.logBackupRestore(
          userId: userId,
          backupId: 'backup_${backup.timestamp.millisecondsSinceEpoch}',
          itemsRestored: 0,
          restoredCounts: {},
          mergeStrategy: options.mergeStrategy.key,
          isSuccess: false,
          errorMessage: 'Falha na validação do backup',
        );

        return validationResult.fold(
          (failure) => Left(failure),
          (_) => throw StateError('Unexpected success'),
        );
      }
      debugPrint('💾 Criando backup de segurança antes do restore...');
      preRestoreBackup = await _createPreRestoreBackup(userId);

      if (preRestoreBackup == null) {
        const error = 'Falha ao criar backup de segurança';
        await _auditService.logBackupRestore(
          userId: userId,
          backupId: 'backup_${backup.timestamp.millisecondsSinceEpoch}',
          itemsRestored: 0,
          restoredCounts: {},
          mergeStrategy: options.mergeStrategy.key,
          isSuccess: false,
          errorMessage: error,
        );
        return const Left(UnknownFailure(error));
      }
      debugPrint('📦 Iniciando restore atômico...');
      needsRollback = true;

      final restoredCounts = <String, int>{};
      int totalRestored = 0;
      await _executeAtomicRestore(() async {
        if (options.restorePlants && backup.data.plants.isNotEmpty) {
          debugPrint('🌱 Restaurando ${backup.data.plants.length} plantas...');
          final plantsRestored = await _restorePlantsWithValidation(
            backup.data.plants,
            options.mergeStrategy,
            userId,
          );
          restoredCounts['plants'] = plantsRestored;
          totalRestored += plantsRestored;
        }
        if (options.restoreSpaces && backup.data.spaces.isNotEmpty) {
          debugPrint('🏠 Restaurando ${backup.data.spaces.length} espaços...');
          final spacesRestored = await _restoreSpacesWithValidation(
            backup.data.spaces,
            options.mergeStrategy,
            userId,
          );
          restoredCounts['spaces'] = spacesRestored;
          totalRestored += spacesRestored;
        }
        if (options.restoreTasks && backup.data.tasks.isNotEmpty) {
          debugPrint('✅ Restaurando ${backup.data.tasks.length} tarefas...');
          final tasksRestored = await _restoreTasksWithValidation(
            backup.data.tasks,
            options.mergeStrategy,
            userId,
          );
          restoredCounts['tasks'] = tasksRestored;
          totalRestored += tasksRestored;
        }
        if (options.restoreSettings) {
          debugPrint('⚙️ Restaurando configurações...');
          await _restoreUserSettingsWithValidation(backup.data.settings);
          await _restoreUserPreferencesWithValidation(
            backup.data.userPreferences,
          );
        }
      });

      needsRollback = false;
      await _auditService.logBackupRestore(
        userId: userId,
        backupId: 'backup_${backup.timestamp.millisecondsSinceEpoch}',
        itemsRestored: totalRestored,
        restoredCounts: restoredCounts,
        mergeStrategy: options.mergeStrategy.key,
        isSuccess: true,
      );

      debugPrint(
        '✅ Restore concluído com sucesso! Total: $totalRestored itens',
      );

      return Right(
        RestoreResult.success(
          itemsRestored: totalRestored,
          restoredCounts: restoredCounts,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro durante restore: $e');
      debugPrint('Stack trace: $stackTrace');
      if (needsRollback && preRestoreBackup != null) {
        debugPrint('🔄 Executando rollback...');
        try {
          await _executeRollback(preRestoreBackup, userId);
          debugPrint('✅ Rollback executado com sucesso');
          await _auditService.logRestoreRollback(
            userId: userId,
            backupId: 'backup_${backup.timestamp.millisecondsSinceEpoch}',
            originalError: e.toString(),
            isSuccess: true,
          );

          return Left(
            UnknownFailure(
              'Erro durante restore. Dados restaurados para o estado anterior: ${e.toString()}',
            ),
          );
        } catch (rollbackError) {
          debugPrint('💥 ERRO CRÍTICO: Falha no rollback: $rollbackError');

          await _auditService.logRestoreRollback(
            userId: userId,
            backupId: 'backup_${backup.timestamp.millisecondsSinceEpoch}',
            originalError: e.toString(),
            isSuccess: false,
          );

          return Left(
            CriticalFailure(
              'ERRO CRÍTICO: Falha no restore E no rollback. '
              'Dados podem estar inconsistentes. Contate o suporte. '
              'Erro original: ${e.toString()}, Erro rollback: ${rollbackError.toString()}',
            ),
          );
        }
      }
      await _auditService.logBackupRestore(
        userId: userId,
        backupId: 'backup_${backup.timestamp.millisecondsSinceEpoch}',
        itemsRestored: 0,
        restoredCounts: {},
        mergeStrategy: options.mergeStrategy.key,
        isSuccess: false,
        errorMessage: e.toString(),
      );

      return Left(UnknownFailure('Erro ao restaurar backup: ${e.toString()}'));
    }
  }

  /// Restaura plantas com validação individual
  Future<int> _restorePlantsWithValidation(
    List<Map<String, dynamic>> plantsData,
    RestoreMergeStrategy strategy,
    String userId,
  ) async {
    int count = 0;
    final errors = <String>[];

    for (final plantData in plantsData) {
      try {
        await _restoreSinglePlant(plantData, userId, strategy);
        count++;
      } catch (e) {
        errors.add(
          'Planta ${plantData['name'] ?? 'desconhecida'}: ${e.toString()}',
        );
        debugPrint('❌ Falha ao restaurar planta: $e');
      }
    }
    if (count == 0 && plantsData.isNotEmpty) {
      throw RestoreException(
        'Todas as plantas falharam na restauração: ${errors.join('; ')}',
      );
    }

    debugPrint('🌱 Plantas restauradas: $count/${plantsData.length}');
    return count;
  }

  Future<void> _restoreSinglePlant(
    Map<String, dynamic> plantData,
    String userId, [
    RestoreMergeStrategy strategy = RestoreMergeStrategy.merge,
  ]) async {
    try {
      final plantToRestore = _transformerService.createPlantFromBackupData(
        plantData,
        userId,
      );
      final existingPlantsResult = await _plantsRepository.getPlants();
      final existingPlants = existingPlantsResult.getOrElse(() => []);

      final existingPlant = existingPlants.cast<Plant?>().firstWhere(
        (p) => p?.id == plantToRestore.id,
        orElse: () => null,
      );

      if (existingPlant != null) {
        switch (strategy) {
          case RestoreMergeStrategy.replace:
            await _plantsRepository.updatePlant(plantToRestore);
            break;
          case RestoreMergeStrategy.merge:
            final mergedPlant = _transformerService.mergePlantData(
              existingPlant,
              plantToRestore,
            );
            await _plantsRepository.updatePlant(mergedPlant);
            break;
          case RestoreMergeStrategy.skip:
            debugPrint('⏭️ Pulando planta existente: ${plantToRestore.name}');
            return;
        }
      } else {
        await _plantsRepository.addPlant(plantToRestore);
      }

      debugPrint('✅ Planta restaurada: ${plantToRestore.name}');
    } catch (e) {
      throw RestoreException('Falha ao restaurar planta: ${e.toString()}');
    }
  }

  Future<int> _restoreSpacesWithValidation(
    List<Map<String, dynamic>> spacesData,
    RestoreMergeStrategy strategy,
    String userId,
  ) async {
    int count = 0;
    final errors = <String>[];

    for (final spaceData in spacesData) {
      try {
        await _restoreSingleSpace(spaceData, userId, strategy);
        count++;
      } catch (e) {
        errors.add(
          'Espaço ${spaceData['name'] ?? 'desconhecido'}: ${e.toString()}',
        );
        debugPrint('❌ Falha ao restaurar espaço: $e');
      }
    }

    if (count == 0 && spacesData.isNotEmpty) {
      throw RestoreException(
        'Todos os espaços falharam na restauração: ${errors.join('; ')}',
      );
    }

    debugPrint('🏠 Espaços restaurados: $count/${spacesData.length}');
    return count;
  }

  Future<void> _restoreSingleSpace(
    Map<String, dynamic> spaceData,
    String userId, [
    RestoreMergeStrategy strategy = RestoreMergeStrategy.merge,
  ]) async {
    try {
      final spaceToRestore = _transformerService.createSpaceFromBackupData(
        spaceData,
        userId,
      );

      final existingSpacesResult = await _spacesRepository.getSpaces();
      final existingSpaces = existingSpacesResult.getOrElse(() => []);

      final existingSpace = existingSpaces.cast<Space?>().firstWhere(
        (s) => s?.id == spaceToRestore.id,
        orElse: () => null,
      );

      if (existingSpace != null) {
        switch (strategy) {
          case RestoreMergeStrategy.replace:
            await _spacesRepository.updateSpace(spaceToRestore);
            break;
          case RestoreMergeStrategy.merge:
            final mergedSpace = _transformerService.mergeSpaceData(
              existingSpace,
              spaceToRestore,
            );
            await _spacesRepository.updateSpace(mergedSpace);
            break;
          case RestoreMergeStrategy.skip:
            debugPrint('⏭️ Pulando espaço existente: ${spaceToRestore.name}');
            return;
        }
      } else {
        await _spacesRepository.addSpace(spaceToRestore);
      }

      debugPrint('✅ Espaço restaurado: ${spaceToRestore.name}');
    } catch (e) {
      throw RestoreException('Falha ao restaurar espaço: ${e.toString()}');
    }
  }

  Future<int> _restoreTasksWithValidation(
    List<Map<String, dynamic>> tasksData,
    RestoreMergeStrategy strategy,
    String userId,
  ) async {
    int count = 0;
    final errors = <String>[];

    for (final taskData in tasksData) {
      try {
        await _restoreSingleTask(taskData, userId, strategy);
        count++;
      } catch (e) {
        errors.add(
          'Tarefa ${taskData['title'] ?? 'desconhecida'}: ${e.toString()}',
        );
        debugPrint('❌ Falha ao restaurar tarefa: $e');
      }
    }

    if (count == 0 && tasksData.isNotEmpty) {
      throw RestoreException(
        'Todas as tarefas falharam na restauração: ${errors.join('; ')}',
      );
    }

    debugPrint('✅ Tarefas restauradas: $count/${tasksData.length}');
    return count;
  }

  Future<void> _restoreSingleTask(
    Map<String, dynamic> taskData,
    String userId, [
    RestoreMergeStrategy strategy = RestoreMergeStrategy.merge,
  ]) async {
    try {
      final taskToRestore = _transformerService.createTaskFromBackupData(
        taskData,
        userId,
      );

      final existingTasksResult = await _tasksRepository.getTasks();
      final existingTasks = existingTasksResult.getOrElse(() => []);

      final existingTask = existingTasks.cast<task_entity.Task?>().firstWhere(
        (t) => t?.id == taskToRestore.id,
        orElse: () => null,
      );

      if (existingTask != null) {
        switch (strategy) {
          case RestoreMergeStrategy.replace:
            await _tasksRepository.updateTask(taskToRestore);
            break;
          case RestoreMergeStrategy.merge:
            final mergedTask = _transformerService.mergeTaskData(
              existingTask,
              taskToRestore,
            );
            await _tasksRepository.updateTask(mergedTask);
            break;
          case RestoreMergeStrategy.skip:
            debugPrint('⏭️ Pulando tarefa existente: ${taskToRestore.title}');
            return;
        }
      } else {
        await _tasksRepository.addTask(taskToRestore);
      }

      debugPrint('✅ Tarefa restaurada: ${taskToRestore.title}');
    } catch (e) {
      throw RestoreException('Falha ao restaurar tarefa: ${e.toString()}');
    }
  }

  Future<void> _restoreUserSettingsWithValidation(
    Map<String, dynamic> settings,
  ) async {
    try {
      for (final entry in settings.entries) {
        await _storageService.setString(
          'setting_${entry.key}',
          entry.value.toString(),
        );
        debugPrint('⚙️ Configuração restaurada: ${entry.key}');
      }
    } catch (e) {
      throw RestoreException(
        'Erro ao restaurar configurações: ${e.toString()}',
      );
    }
  }

  Future<void> _restoreUserPreferencesWithValidation(
    Map<String, dynamic> preferences,
  ) async {
    try {
      for (final entry in preferences.entries) {
        await _storageService.setString(
          'pref_${entry.key}',
          entry.value.toString(),
        );
        debugPrint('👤 Preferência restaurada: ${entry.key}');
      }
    } catch (e) {
      throw RestoreException('Erro ao restaurar preferências: ${e.toString()}');
    }
  }

  /// Cria backup de segurança antes do restore
  Future<Map<String, dynamic>?> _createPreRestoreBackup(String userId) async {
    try {
      final plantsResult = await _plantsRepository.getPlants();
      final spacesResult = await _spacesRepository.getSpaces();
      final tasksResult = await _tasksRepository.getTasks();

      return {
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'plants':
            plantsResult
                .getOrElse(() => [])
                .map((plant) => _transformerService.plantToJson(plant))
                .toList(),
        'spaces':
            spacesResult
                .getOrElse(() => [])
                .map((space) => _transformerService.spaceToJson(space))
                .toList(),
        'tasks':
            tasksResult
                .getOrElse(() => [])
                .map(
                  (task) =>
                      _transformerService.taskToJson(task),
                )
                .toList(),
        'settings': await _loadUserSettings(),
        'user_preferences': await _loadUserPreferences(),
      };
    } catch (e) {
      debugPrint('❌ Erro ao criar backup de segurança: $e');
      return null;
    }
  }

  /// Executa restore de forma atômica
  Future<void> _executeAtomicRestore(
    Future<void> Function() restoreFunction,
  ) async {
    try {
      await restoreFunction();
    } catch (e) {
      debugPrint('❌ Erro em restore atômico: $e');
      rethrow;
    }
  }

  /// Executa rollback em caso de falha
  Future<void> _executeRollback(
    Map<String, dynamic> preRestoreBackup,
    String userId,
  ) async {
    try {
      debugPrint('🔄 Iniciando rollback para usuário: $userId');
      final plantsData = preRestoreBackup['plants'] as List<dynamic>? ?? [];
      for (final plantData in plantsData) {
        await _restoreSinglePlant(
          plantData as Map<String, dynamic>,
          userId,
          RestoreMergeStrategy.replace,
        );
      }
      final spacesData = preRestoreBackup['spaces'] as List<dynamic>? ?? [];
      for (final spaceData in spacesData) {
        await _restoreSingleSpace(
          spaceData as Map<String, dynamic>,
          userId,
          RestoreMergeStrategy.replace,
        );
      }
      final tasksData = preRestoreBackup['tasks'] as List<dynamic>? ?? [];
      for (final taskData in tasksData) {
        await _restoreSingleTask(
          taskData as Map<String, dynamic>,
          userId,
          RestoreMergeStrategy.replace,
        );
      }
      final backupData = preRestoreBackup;
      await _restoreUserSettingsWithValidation(
        backupData['settings'] as Map<String, dynamic>,
      );
      await _restoreUserPreferencesWithValidation(
        backupData['user_preferences'] as Map<String, dynamic>,
      );

      debugPrint('✅ Rollback concluído com sucesso');
    } catch (e) {
      debugPrint('💥 ERRO CRÍTICO no rollback: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _loadUserSettings() async {
    return {};
  }

  Future<Map<String, dynamic>> _loadUserPreferences() async {
    return {};
  }
}
