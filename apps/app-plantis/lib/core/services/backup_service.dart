import 'dart:convert';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../features/plants/data/models/space_model.dart';
import '../../features/plants/domain/entities/plant.dart';
import '../../features/plants/domain/entities/space.dart';
import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/plants/domain/repositories/spaces_repository.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/domain/repositories/tasks_repository.dart';
import '../data/models/backup_model.dart';
import '../data/repositories/backup_repository.dart';
import 'secure_storage_service.dart';

/// Service principal para operações de backup e restauração
@singleton
class BackupService {
  final IBackupRepository _backupRepository;
  final PlantsRepository _plantsRepository;
  final SpacesRepository _spacesRepository;
  final TasksRepository _tasksRepository;
  final SecureStorageService _storageService;

  static const String _backupSettingsKey = 'backup_settings';
  static const String _lastBackupKey = 'last_backup_timestamp';

  BackupService({
    required IBackupRepository backupRepository,
    required PlantsRepository plantsRepository,
    required SpacesRepository spacesRepository,
    required TasksRepository tasksRepository,
    required SecureStorageService storageService,
  }) : _backupRepository = backupRepository,
       _plantsRepository = plantsRepository,
       _spacesRepository = spacesRepository,
       _tasksRepository = tasksRepository,
       _storageService = storageService;

  /// Cria um backup completo dos dados do usuário
  Future<Either<Failure, BackupResult>> createBackup() async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Coleta todos os dados
      final plantsResult = await _plantsRepository.getPlants();
      final spacesResult = await _spacesRepository.getSpaces();
      final tasksResult = await _tasksRepository.getTasks();

      // Verifica se alguma operação falhou
      if (plantsResult.isLeft()) {
        return const Left(DataFailure('Erro ao carregar plantas'));
      }
      if (spacesResult.isLeft()) {
        return const Left(DataFailure('Erro ao carregar espaços'));
      }
      if (tasksResult.isLeft()) {
        return const Left(DataFailure('Erro ao carregar tarefas'));
      }

      final plants = plantsResult.getOrElse(() => []);
      final spaces = spacesResult.getOrElse(() => []);
      final tasks = tasksResult.getOrElse(() => []);

      // Carrega configurações e preferências do usuário
      final settings = await _loadUserSettings();
      final preferences = await _loadUserPreferences();

      // Cria metadados do backup
      final metadata = BackupMetadata(
        plantsCount: plants.length,
        tasksCount: tasks.length,
        spacesCount: spaces.length,
        appVersion: '1.0.0', // Pode ser obtido do package info
        platform: _getCurrentPlatform(),
        additionalInfo: {
          'created_by': 'backup_service',
          'device_info': await _getDeviceInfo(),
        },
      );

      // Converte dados para JSON
      final backupData = BackupData(
        plants: plants.map((plant) => _plantToJson(plant)).toList(),
        tasks: tasks.map((task) => _taskToJson(task)).toList(),
        spaces: spaces.map((space) => _spaceToJson(space)).toList(),
        settings: settings,
        userPreferences: preferences,
      );

      // Cria o backup
      final backup = BackupModel(
        version: '1.0',
        timestamp: DateTime.now(),
        userId: user.id,
        metadata: metadata,
        data: backupData,
      );

      // Faz upload do backup
      final uploadResult = await _backupRepository.uploadBackup(backup);

      return await uploadResult.fold(
        (failure) async => Left(failure),
        (result) async {
          // Salva timestamp do último backup
          await _storageService.setString(
            _lastBackupKey,
            DateTime.now().toIso8601String(),
          );

          // Limpa backups antigos baseado na configuração
          final settings = await getBackupSettings();
          if (settings.maxBackupsToKeep > 0) {
            await _backupRepository.deleteOldBackups(
              user.id,
              settings.maxBackupsToKeep,
            );
          }

          return Right(result);
        },
      );
    } catch (e) {
      return Left(UnknownFailure('Erro ao criar backup: ${e.toString()}'));
    }
  }

  /// Lista todos os backups disponíveis do usuário
  Future<Either<Failure, List<BackupInfo>>> listBackups() async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      return await _backupRepository.listBackups(user.id);
    } catch (e) {
      return Left(UnknownFailure('Erro ao listar backups: ${e.toString()}'));
    }
  }

  /// Restaura dados a partir de um backup com validação e rollback
  Future<Either<Failure, RestoreResult>> restoreBackup(
    String backupId,
    RestoreOptions options,
  ) async {
    Map<String, dynamic>? preRestoreBackup;
    bool needsRollback = false;
    
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // 1. VALIDAÇÃO DE INTEGRIDADE
      debugPrint('🔍 Validando integridade do backup...');
      final backupResult = await _backupRepository.downloadBackup(backupId);
      
      if (backupResult.isLeft()) {
        return backupResult.fold(
          (failure) => Left(failure),
          (_) => throw StateError('Unexpected success'),
        );
      }
      
      final backup = backupResult.getOrElse(() => throw StateError('No backup data'));
      
      // Verificar compatibilidade
      if (!backup.isCompatible) {
        return const Left(ValidationFailure(
          'Backup incompatível com a versão atual do app',
        ));
      }
      
      // Verificar integridade dos dados
      final validationResult = await _validateBackupIntegrity(backup);
      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => throw StateError('Unexpected success'),
        );
      }

      // 2. CRIAR BACKUP DE SEGURANÇA
      debugPrint('💾 Criando backup de segurança antes do restore...');
      preRestoreBackup = await _createPreRestoreBackup();
      
      if (preRestoreBackup == null) {
        return const Left(UnknownFailure('Falha ao criar backup de segurança'));
      }

      // 3. EXECUTAR RESTORE COM TRANSAÇÕES ATÔMICAS
      debugPrint('📦 Iniciando restore atômico...');
      needsRollback = true;
      
      final restoredCounts = <String, int>{};
      int totalRestored = 0;

      // Usar uma transação para garantir atomicidade
      await _executeAtomicRestore(() async {
        // Restaura plantas
        if (options.restorePlants && backup.data.plants.isNotEmpty) {
          debugPrint('🌱 Restaurando ${backup.data.plants.length} plantas...');
          final plantsRestored = await _restorePlantsWithValidation(
            backup.data.plants,
            options.mergeStrategy,
            user.id,
          );
          restoredCounts['plants'] = plantsRestored;
          totalRestored += plantsRestored;
        }

        // Restaura espaços
        if (options.restoreSpaces && backup.data.spaces.isNotEmpty) {
          debugPrint('🏠 Restaurando ${backup.data.spaces.length} espaços...');
          final spacesRestored = await _restoreSpacesWithValidation(
            backup.data.spaces,
            options.mergeStrategy,
            user.id,
          );
          restoredCounts['spaces'] = spacesRestored;
          totalRestored += spacesRestored;
        }

        // Restaura tarefas
        if (options.restoreTasks && backup.data.tasks.isNotEmpty) {
          debugPrint('✅ Restaurando ${backup.data.tasks.length} tarefas...');
          final tasksRestored = await _restoreTasksWithValidation(
            backup.data.tasks,
            options.mergeStrategy,
            user.id,
          );
          restoredCounts['tasks'] = tasksRestored;
          totalRestored += tasksRestored;
        }

        // Restaura configurações
        if (options.restoreSettings) {
          debugPrint('⚙️ Restaurando configurações...');
          await _restoreUserSettingsWithValidation(backup.data.settings);
          await _restoreUserPreferencesWithValidation(backup.data.userPreferences);
        }
      });
      
      needsRollback = false;

      // 4. CRIAR LOG DE AUDITORIA
      await _createAuditLog({
        'operation': 'restore_backup',
        'backup_id': backupId,
        'user_id': user.id,
        'timestamp': DateTime.now().toIso8601String(),
        'items_restored': totalRestored,
        'restored_counts': restoredCounts,
        'options': {
          'restore_plants': options.restorePlants,
          'restore_spaces': options.restoreSpaces,
          'restore_tasks': options.restoreTasks,
          'restore_settings': options.restoreSettings,
          'merge_strategy': options.mergeStrategy.name,
        },
      });

      debugPrint('✅ Restore concluído com sucesso! Total: $totalRestored itens');
      
      return Right(RestoreResult.success(
        itemsRestored: totalRestored,
        restoredCounts: restoredCounts,
      ));
    } catch (e, stackTrace) {
      debugPrint('❌ Erro durante restore: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // 5. EXECUTAR ROLLBACK EM CASO DE FALHA
      if (needsRollback && preRestoreBackup != null) {
        debugPrint('🔄 Executando rollback...');
        try {
          await _executeRollback(preRestoreBackup);
          debugPrint('✅ Rollback executado com sucesso');
          
          // Log do rollback
          await _createAuditLog({
            'operation': 'rollback_restore',
            'backup_id': backupId,
            'timestamp': DateTime.now().toIso8601String(),
            'error': e.toString(),
          });
          
          return Left(UnknownFailure(
            'Erro durante restore. Dados restaurados para o estado anterior: ${e.toString()}',
          ));
        } catch (rollbackError) {
          debugPrint('💥 Falha no rollback: $rollbackError');
          
          await _createAuditLog({
            'operation': 'rollback_failed',
            'backup_id': backupId,
            'timestamp': DateTime.now().toIso8601String(),
            'original_error': e.toString(),
            'rollback_error': rollbackError.toString(),
          });
          
          return Left(CriticalFailure(
            'ERRO CRÍTICO: Falha no restore e no rollback. '
            'Contate o suporte. Erro original: ${e.toString()}. '
            'Erro do rollback: ${rollbackError.toString()}',
          ));
        }
      }
      
      await _createAuditLog({
        'operation': 'restore_failed',
        'backup_id': backupId,
        'timestamp': DateTime.now().toIso8601String(),
        'error': e.toString(),
      });
      
      return Left(UnknownFailure('Erro ao restaurar backup: ${e.toString()}'));
    }
  }

  /// Deleta um backup específico
  Future<Either<Failure, void>> deleteBackup(String backupId) async {
    try {
      return await _backupRepository.deleteBackup(backupId);
    } catch (e) {
      return Left(UnknownFailure('Erro ao deletar backup: ${e.toString()}'));
    }
  }

  /// Obtém configurações de backup
  Future<BackupSettings> getBackupSettings() async {
    final settingsJson = await _storageService.getString(_backupSettingsKey);
    if (settingsJson != null) {
      try {
        final settings = BackupSettings.fromJson(jsonDecode(settingsJson) as Map<String, dynamic>);
        return settings;
      } catch (e) {
        // Se falhar ao parsear, retorna configurações padrão
        return BackupSettings.defaultSettings();
      }
    }
    return BackupSettings.defaultSettings();
  }

  /// Salva configurações de backup
  Future<void> saveBackupSettings(BackupSettings settings) async {
    await _storageService.setString(
      _backupSettingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  /// Verifica se é necessário fazer backup automático
  Future<bool> shouldAutoBackup() async {
    final settings = await getBackupSettings();
    
    if (!settings.autoBackupEnabled) return false;
    if (settings.frequency == BackupFrequency.manual) return false;

    final lastBackupStr = await _storageService.getString(_lastBackupKey);
    if (lastBackupStr == null) return true;

    try {
      final lastBackup = DateTime.parse(lastBackupStr);
      final now = DateTime.now();
      final difference = now.difference(lastBackup);

      switch (settings.frequency) {
        case BackupFrequency.daily:
          return difference.inDays >= 1;
        case BackupFrequency.weekly:
          return difference.inDays >= 7;
        case BackupFrequency.manual:
          return false;
      }
    } catch (e) {
      return true; // Se erro ao parsear data, faz backup
    }
  }

  /// Obtém timestamp do último backup
  Future<DateTime?> getLastBackupTimestamp() async {
    try {
      final lastBackupStr = await _storageService.getString(_lastBackupKey);
      if (lastBackupStr != null) {
        return DateTime.parse(lastBackupStr);
      }
    } catch (e) {
      debugPrint('Erro ao obter timestamp do último backup: $e');
    }
    return null;
  }

  // Métodos privados para conversão de dados

  Map<String, dynamic> _plantToJson(dynamic plant) {
    // Assumindo que o plant já tem método toJson()
    if (plant is Map<String, dynamic>) return plant;
    return plant.toJson() as Map<String, dynamic>;
  }

  Map<String, dynamic> _taskToJson(dynamic task) {
    if (task is Map<String, dynamic>) return task;
    return task.toJson() as Map<String, dynamic>;
  }

  Map<String, dynamic> _spaceToJson(dynamic space) {
    if (space is Map<String, dynamic>) return space;
    return space.toJson() as Map<String, dynamic>;
  }

  // Métodos privados para validação e segurança

  /// Valida a integridade dos dados do backup
  Future<Either<Failure, void>> _validateBackupIntegrity(BackupModel backup) async {
    try {
      // Verificar metadados consistentes
      if (backup.metadata.plantsCount != backup.data.plants.length) {
        return const Left(ValidationFailure('Contagem de plantas inconsistente no backup'));
      }
      if (backup.metadata.tasksCount != backup.data.tasks.length) {
        return const Left(ValidationFailure('Contagem de tarefas inconsistente no backup'));
      }
      if (backup.metadata.spacesCount != backup.data.spaces.length) {
        return const Left(ValidationFailure('Contagem de espaços inconsistente no backup'));
      }

      // Verificar estrutura dos dados das plantas
      for (int i = 0; i < backup.data.plants.length; i++) {
        final plant = backup.data.plants[i];
        if (plant['id'] == null || plant['name'] == null) {
          return Left(ValidationFailure('Planta ${i + 1} possui dados obrigatórios faltantes'));
        }
      }

      // Verificar estrutura dos dados das tarefas
      for (int i = 0; i < backup.data.tasks.length; i++) {
        final task = backup.data.tasks[i];
        if (task['id'] == null || task['title'] == null) {
          return Left(ValidationFailure('Tarefa ${i + 1} possui dados obrigatórios faltantes'));
        }
      }

      // Verificar estrutura dos dados dos espaços
      for (int i = 0; i < backup.data.spaces.length; i++) {
        final space = backup.data.spaces[i];
        if (space['id'] == null || space['name'] == null) {
          return Left(ValidationFailure('Espaço ${i + 1} possui dados obrigatórios faltantes'));
        }
      }

      debugPrint('✅ Validação de integridade concluída com sucesso');
      return const Right(null);
    } catch (e) {
      return Left(ValidationFailure('Erro na validação: ${e.toString()}'));
    }
  }

  /// Cria backup de segurança antes do restore
  Future<Map<String, dynamic>?> _createPreRestoreBackup() async {
    try {
      final user = await _getCurrentUser();
      if (user == null) return null;

      // Coleta dados atuais
      final currentPlants = await _plantsRepository.getPlants();
      final currentSpaces = await _spacesRepository.getSpaces();
      final currentTasks = await _tasksRepository.getTasks();
      
      final plants = currentPlants.getOrElse(() => []);
      final spaces = currentSpaces.getOrElse(() => []);
      final tasks = currentTasks.getOrElse(() => []);
      
      final settings = await _loadUserSettings();
      final preferences = await _loadUserPreferences();

      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'pre_restore_backup',
        'user_id': user.id,
        'data': {
          'plants': plants.map((plant) => _plantToJson(plant)).toList(),
          'tasks': tasks.map((task) => _taskToJson(task)).toList(),
          'spaces': spaces.map((space) => _spaceToJson(space)).toList(),
          'settings': settings,
          'user_preferences': preferences,
        },
      };

      // Salvar backup de segurança em storage local seguro
      await _storageService.setString(
        'pre_restore_backup_${DateTime.now().millisecondsSinceEpoch}',
        jsonEncode(backupData),
      );

      debugPrint('✅ Backup de segurança criado com sucesso');
      return backupData;
    } catch (e) {
      debugPrint('❌ Erro ao criar backup de segurança: $e');
      return null;
    }
  }

  /// Executa restore de forma atômica
  Future<void> _executeAtomicRestore(Future<void> Function() restoreFunction) async {
    // Nota: Em uma implementação real, aqui utilizariamos transações de banco de dados
    // Para este exemplo, vamos simular atomicidade com try-catch e rollback manual
    
    try {
      await restoreFunction();
    } catch (e) {
      // Em caso de erro, o rollback será executado no método principal
      rethrow;
    }
  }

  /// Executa rollback em caso de falha
  Future<void> _executeRollback(Map<String, dynamic> preRestoreBackup) async {
    try {
      final backupData = preRestoreBackup['data'] as Map<String, dynamic>;
      
      // Restaurar plantas
      final plants = backupData['plants'] as List<dynamic>;
      for (final plantData in plants) {
        try {
          await _restoreSinglePlant(plantData as Map<String, dynamic>, preRestoreBackup['user_id'] as String);
        } catch (e) {
          debugPrint('⚠️ Erro ao restaurar planta durante rollback: $e');
        }
      }
      
      // Restaurar espaços
      final spaces = backupData['spaces'] as List<dynamic>;
      for (final spaceData in spaces) {
        try {
          await _restoreSingleSpace(spaceData as Map<String, dynamic>, preRestoreBackup['user_id'] as String, RestoreMergeStrategy.replace);
        } catch (e) {
          debugPrint('⚠️ Erro ao restaurar espaço durante rollback: $e');
        }
      }
      
      // Restaurar tarefas
      final tasks = backupData['tasks'] as List<dynamic>;
      for (final taskData in tasks) {
        try {
          await _restoreSingleTask(taskData as Map<String, dynamic>, preRestoreBackup['user_id'] as String, RestoreMergeStrategy.replace);
        } catch (e) {
          debugPrint('⚠️ Erro ao restaurar tarefa durante rollback: $e');
        }
      }
      
      // Restaurar configurações
      await _restoreUserSettingsWithValidation(backupData['settings'] as Map<String, dynamic>);
      await _restoreUserPreferencesWithValidation(backupData['user_preferences'] as Map<String, dynamic>);
      
    } catch (e) {
      debugPrint('💥 Erro crítico durante rollback: $e');
      rethrow;
    }
  }

  /// Cria log de auditoria
  Future<void> _createAuditLog(Map<String, dynamic> logData) async {
    try {
      final logEntry = {
        ...logData,
        'app_version': '1.0.0',
        'platform': _getCurrentPlatform(),
      };
      
      final logKey = 'audit_log_${DateTime.now().millisecondsSinceEpoch}';
      await _storageService.setString(logKey, jsonEncode(logEntry));
      
      debugPrint('📜 Log de auditoria criado: ${logData['operation']}');
    } catch (e) {
      debugPrint('⚠️ Erro ao criar log de auditoria: $e');
      // Não lançar erro para não interromper operação principal
    }
  }

  // Métodos privados para restauração com validação

  Future<int> _restorePlantsWithValidation(
    List<Map<String, dynamic>> plantsData,
    RestoreMergeStrategy strategy,
    String userId,
  ) async {
    int count = 0;
    final errors = <String>[];
    
    for (int i = 0; i < plantsData.length; i++) {
      final plantData = plantsData[i];
      try {
        await _restoreSinglePlant(plantData, userId, strategy);
        count++;
      } catch (e) {
        final error = 'Erro ao restaurar planta ${i + 1}: $e';
        errors.add(error);
        debugPrint('❌ $error');
      }
    }
    
    if (errors.isNotEmpty && errors.length == plantsData.length) {
      throw RestoreException('Todas as plantas falharam na restauração: ${errors.join('; ')}');
    }
    
    if (errors.isNotEmpty) {
      debugPrint('⚠️ ${errors.length} plantas falharam na restauração de ${plantsData.length}');
    }
    
    return count;
  }

  Future<void> _restoreSinglePlant(
    Map<String, dynamic> plantData,
    String userId, [
    RestoreMergeStrategy strategy = RestoreMergeStrategy.merge,
  ]) async {
    try {
      // Converter dados do backup para entidade Plant
      final plant = _createPlantFromBackupData(plantData, userId);
      
      switch (strategy) {
        case RestoreMergeStrategy.replace:
          // Verificar se planta existe
          final existingResult = await _plantsRepository.getPlantById(plant.id);
          if (existingResult.isRight()) {
            // Atualizar planta existente
            await _plantsRepository.updatePlant(plant);
          } else {
            // Adicionar nova planta
            await _plantsRepository.addPlant(plant);
          }
          break;
          
        case RestoreMergeStrategy.merge:
          final existingResult = await _plantsRepository.getPlantById(plant.id);
          if (existingResult.isRight()) {
            // Fazer merge dos dados
            final existingPlant = existingResult.getOrElse(() => throw StateError('No plant'));
            final mergedPlant = _mergePlantData(existingPlant, plant);
            await _plantsRepository.updatePlant(mergedPlant);
          } else {
            // Adicionar nova planta
            await _plantsRepository.addPlant(plant);
          }
          break;
          
        case RestoreMergeStrategy.addOnly:
          final existingResult = await _plantsRepository.getPlantById(plant.id);
          if (existingResult.isLeft()) {
            // Adicionar apenas se não existir
            await _plantsRepository.addPlant(plant);
          }
          break;
      }
    } catch (e) {
      throw RestoreException('Falha ao restaurar planta: ${e.toString()}');
    }
  }

  Plant _createPlantFromBackupData(Map<String, dynamic> data, String userId) {
    try {
      return Plant(
        id: data['id']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        species: data['species']?.toString(),
        spaceId: data['spaceId']?.toString(),
        imageBase64: data['imageBase64']?.toString(),
        imageUrls: (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
        plantingDate: data['plantingDate'] != null ? DateTime.tryParse(data['plantingDate'].toString()) : null,
        notes: data['notes']?.toString(),
        isFavorited: data['isFavorited'] as bool? ?? false,
        userId: userId,
        createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt'].toString()) : null,
        updatedAt: data['updatedAt'] != null ? DateTime.tryParse(data['updatedAt'].toString()) : null,
        isDirty: false, // Marcar como sincronizado após restore
        moduleName: 'plantis',
      );
    } catch (e) {
      throw RestoreException('Erro ao criar planta dos dados de backup: ${e.toString()}');
    }
  }

  Plant _mergePlantData(Plant existing, Plant backup) {
    // Estratégia de merge: manter dados mais recentes e não sobrescrever campos importantes do usuário
    return existing.copyWith(
      name: (backup.name.isNotEmpty) ? backup.name : existing.name,
      species: backup.species ?? existing.species,
      spaceId: backup.spaceId ?? existing.spaceId,
      imageBase64: backup.imageBase64 ?? existing.imageBase64,
      imageUrls: backup.imageUrls.isNotEmpty ? backup.imageUrls : existing.imageUrls,
      plantingDate: backup.plantingDate ?? existing.plantingDate,
      notes: backup.notes ?? existing.notes,
      config: backup.config ?? existing.config,
      // Manter favoritos do estado atual para preservar preferências do usuário
      isFavorited: existing.isFavorited,
      // Atualizar timestamp
      updatedAt: DateTime.now(),
      isDirty: false,
    );
  }

  Future<int> _restoreSpacesWithValidation(
    List<Map<String, dynamic>> spacesData,
    RestoreMergeStrategy strategy,
    String userId,
  ) async {
    int count = 0;
    final errors = <String>[];
    
    for (int i = 0; i < spacesData.length; i++) {
      final spaceData = spacesData[i];
      try {
        await _restoreSingleSpace(spaceData, userId, strategy);
        count++;
      } catch (e) {
        final error = 'Erro ao restaurar espaço ${i + 1}: $e';
        errors.add(error);
        debugPrint('❌ $error');
      }
    }
    
    if (errors.isNotEmpty && errors.length == spacesData.length) {
      throw RestoreException('Todos os espaços falharam na restauração: ${errors.join('; ')}');
    }
    
    if (errors.isNotEmpty) {
      debugPrint('⚠️ ${errors.length} espaços falharam na restauração de ${spacesData.length}');
    }
    
    return count;
  }

  Future<void> _restoreSingleSpace(
    Map<String, dynamic> spaceData,
    String userId, [
    RestoreMergeStrategy strategy = RestoreMergeStrategy.merge,
  ]) async {
    try {
      // Converter dados do backup para entidade Space usando SpaceModel.fromJson
      final space = _createSpaceFromBackupData(spaceData, userId);
      
      switch (strategy) {
        case RestoreMergeStrategy.replace:
          final existingResult = await _spacesRepository.getSpaceById(space.id);
          if (existingResult.isRight()) {
            await _spacesRepository.updateSpace(space);
          } else {
            await _spacesRepository.addSpace(space);
          }
          break;
          
        case RestoreMergeStrategy.merge:
          final existingResult = await _spacesRepository.getSpaceById(space.id);
          if (existingResult.isRight()) {
            final existingSpace = existingResult.getOrElse(() => throw StateError('No space'));
            final mergedSpace = _mergeSpaceData(existingSpace, space);
            await _spacesRepository.updateSpace(mergedSpace);
          } else {
            await _spacesRepository.addSpace(space);
          }
          break;
          
        case RestoreMergeStrategy.addOnly:
          final existingResult = await _spacesRepository.getSpaceById(space.id);
          if (existingResult.isLeft()) {
            await _spacesRepository.addSpace(space);
          }
          break;
      }
    } catch (e) {
      throw RestoreException('Falha ao restaurar espaço: ${e.toString()}');
    }
  }

  Space _createSpaceFromBackupData(Map<String, dynamic> data, String userId) {
    try {
      // Convert backup data to proper format for SpaceModel.fromJson
      final spaceData = {
        'id': data['id']?.toString() ?? '',
        'name': data['name']?.toString() ?? '',
        'description': data['description']?.toString(),
        'lightCondition': data['lightCondition']?.toString() ?? data['light_condition']?.toString(),
        'humidity': (data['humidity'] as num?)?.toDouble(),
        'averageTemperature': (data['averageTemperature'] as num?)?.toDouble() ?? (data['average_temperature'] as num?)?.toDouble(),
        'createdAt': data['createdAt']?.toString() ?? data['created_at']?.toString(),
        'updatedAt': data['updatedAt']?.toString() ?? data['updated_at']?.toString(),
        'isDeleted': data['isDeleted'] as bool? ?? data['is_deleted'] as bool? ?? false,
        'isDirty': false, // Mark as clean after restore
      };
      
      return SpaceModel.fromJson(spaceData).copyWith(
        userId: userId,
        moduleName: 'plantis',
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw RestoreException('Erro ao criar Space dos dados de backup: ${e.toString()}');
    }
  }

  Space _mergeSpaceData(dynamic existing, Space backup) {
    final existingSpace = existing as Space;
    // Merge strategy: keep most recent data and preserve user preferences
    return existingSpace.copyWith(
      name: (backup.name.isNotEmpty) ? backup.name : existingSpace.name,
      description: backup.description ?? existingSpace.description,
      lightCondition: backup.lightCondition ?? existingSpace.lightCondition,
      humidity: backup.humidity ?? existingSpace.humidity,
      averageTemperature: backup.averageTemperature ?? existingSpace.averageTemperature,
      updatedAt: DateTime.now(),
      isDirty: false,
    );
  }

  Future<int> _restoreTasksWithValidation(
    List<Map<String, dynamic>> tasksData,
    RestoreMergeStrategy strategy,
    String userId,
  ) async {
    int count = 0;
    final errors = <String>[];
    
    for (int i = 0; i < tasksData.length; i++) {
      final taskData = tasksData[i];
      try {
        await _restoreSingleTask(taskData, userId, strategy);
        count++;
      } catch (e) {
        final error = 'Erro ao restaurar tarefa ${i + 1}: $e';
        errors.add(error);
        debugPrint('❌ $error');
      }
    }
    
    if (errors.isNotEmpty && errors.length == tasksData.length) {
      throw RestoreException('Todas as tarefas falharam na restauração: ${errors.join('; ')}');
    }
    
    if (errors.isNotEmpty) {
      debugPrint('⚠️ ${errors.length} tarefas falharam na restauração de ${tasksData.length}');
    }
    
    return count;
  }

  Future<void> _restoreSingleTask(
    Map<String, dynamic> taskData,
    String userId, [
    RestoreMergeStrategy strategy = RestoreMergeStrategy.merge,
  ]) async {
    try {
      // Converter dados do backup para entidade Task usando TaskModel.fromJson
      final task = _createTaskFromBackupData(taskData, userId);
      
      switch (strategy) {
        case RestoreMergeStrategy.replace:
          final existingResult = await _tasksRepository.getTaskById(task.id);
          if (existingResult.isRight()) {
            await _tasksRepository.updateTask(task);
          } else {
            await _tasksRepository.addTask(task);
          }
          break;
          
        case RestoreMergeStrategy.merge:
          final existingResult = await _tasksRepository.getTaskById(task.id);
          if (existingResult.isRight()) {
            final existingTask = existingResult.getOrElse(() => throw StateError('No task'));
            final mergedTask = _mergeTaskData(existingTask, task);
            await _tasksRepository.updateTask(mergedTask);
          } else {
            await _tasksRepository.addTask(task);
          }
          break;
          
        case RestoreMergeStrategy.addOnly:
          final existingResult = await _tasksRepository.getTaskById(task.id);
          if (existingResult.isLeft()) {
            await _tasksRepository.addTask(task);
          }
          break;
      }
    } catch (e) {
      throw RestoreException('Falha ao restaurar tarefa: ${e.toString()}');
    }
  }

  Task _createTaskFromBackupData(Map<String, dynamic> data, String userId) {
    try {
      // Convert backup data to proper format for TaskModel.fromJson
      final taskData = {
        'id': data['id']?.toString() ?? '',
        'title': data['title']?.toString() ?? '',
        'description': data['description']?.toString(),
        'plant_id': data['plantId']?.toString() ?? data['plant_id']?.toString() ?? '',
        'plant_name': data['plantName']?.toString() ?? data['plant_name']?.toString() ?? 'Planta',
        'type': data['type']?.toString() ?? 'custom',
        'status': (data['isCompleted'] as bool? ?? false) ? 'concluida' : (data['status']?.toString() ?? 'pendente'),
        'priority': data['priority']?.toString() ?? 'media',
        'due_date': data['dueDate']?.toString() ?? data['due_date']?.toString() ?? DateTime.now().toIso8601String(),
        'completed_at': data['completedAt']?.toString() ?? data['completed_at']?.toString(),
        'completion_notes': data['completionNotes']?.toString() ?? data['completion_notes']?.toString(),
        'is_recurring': data['isRecurring'] as bool? ?? data['is_recurring'] as bool? ?? false,
        'recurring_interval_days': data['recurringIntervalDays'] as int? ?? data['recurring_interval_days'] as int?,
        'next_due_date': data['nextDueDate']?.toString() ?? data['next_due_date']?.toString(),
        'created_at': data['createdAt']?.toString() ?? data['created_at']?.toString(),
        'updated_at': data['updatedAt']?.toString() ?? data['updated_at']?.toString(),
        'is_dirty': false, // Mark as clean after restore
        'is_deleted': data['isDeleted'] as bool? ?? data['is_deleted'] as bool? ?? false,
        'version': data['version'] as int? ?? 1,
        'user_id': userId,
        'module_name': 'plantis',
      };
      
      return TaskModel.fromJson(taskData);
    } catch (e) {
      throw RestoreException('Erro ao criar Task dos dados de backup: ${e.toString()}');
    }
  }

  Task _mergeTaskData(dynamic existing, Task backup) {
    final existingTask = existing as Task;
    // Merge strategy: keep most recent data but preserve current completion status
    return existingTask.copyWithTaskData(
      title: (backup.title.isNotEmpty) ? backup.title : existingTask.title,
      description: backup.description ?? existingTask.description,
      plantName: (backup.plantName.isNotEmpty) ? backup.plantName : existingTask.plantName,
      type: backup.type,
      priority: backup.priority,
      // Preserve current completion status to maintain user progress
      status: existingTask.status,
      completedAt: existingTask.completedAt,
      completionNotes: existingTask.completionNotes ?? backup.completionNotes,
      isRecurring: backup.isRecurring,
      recurringIntervalDays: backup.recurringIntervalDays,
      nextDueDate: backup.nextDueDate,
    );
  }

  // Métodos privados auxiliares

  Future<UserEntity?> _getCurrentUser() async {
    // TODO: Implementar método getCurrentUser no IAuthRepository
    // Por enquanto, retorna usuário mock para desenvolvimento
    return const UserEntity(
      id: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
    );
  }

  Future<Map<String, dynamic>> _loadUserSettings() async {
    // Carrega configurações do app
    return {
      'theme_mode': await _storageService.getString('theme_mode') ?? 'system',
      'notifications_enabled': await _storageService.getBool('notifications_enabled') ?? true,
      'language': await _storageService.getString('language') ?? 'pt_BR',
    };
  }

  Future<Map<String, dynamic>> _loadUserPreferences() async {
    // Carrega preferências específicas do usuário
    return {
      'preferred_units': await _storageService.getString('preferred_units') ?? 'metric',
      'default_space': await _storageService.getString('default_space'),
      'reminder_time': await _storageService.getString('reminder_time') ?? '09:00',
    };
  }

  Future<void> _restoreUserSettingsWithValidation(Map<String, dynamic> settings) async {
    try {
      // Lista de configurações permitidas para evitar injeção de dados mal-intencionados
      final allowedSettings = {
        'theme_mode': String,
        'notifications_enabled': bool,
        'language': String,
        'auto_backup_enabled': bool,
        'wifi_only_backup': bool,
      };
      
      for (final entry in settings.entries) {
        final key = entry.key;
        final value = entry.value;
        
        // Verificar se a configuração é permitida
        if (!allowedSettings.containsKey(key)) {
          debugPrint('⚠️ Configuração ignorada (não permitida): $key');
          continue;
        }
        
        // Verificar tipo da configuração
        final expectedType = allowedSettings[key]!;
        if (value.runtimeType != expectedType) {
          debugPrint('⚠️ Configuração ignorada (tipo incorreto): $key');
          continue;
        }
        
        // Aplicar configuração
        if (value is String) {
          await _storageService.setString(key, value);
        } else if (value is bool) {
          await _storageService.setBool(key, value);
        } else if (value is int) {
          await _storageService.setInt(key, value);
        }
        
        debugPrint('✅ Configuração restaurada: $key = $value');
      }
    } catch (e) {
      throw RestoreException('Erro ao restaurar configurações: ${e.toString()}');
    }
  }

  Future<void> _restoreUserPreferencesWithValidation(Map<String, dynamic> preferences) async {
    try {
      // Lista de preferências permitidas
      final allowedPreferences = {
        'preferred_units': String,
        'default_space': String,
        'reminder_time': String,
        'notification_sound': bool,
        'show_tips': bool,
      };
      
      for (final entry in preferences.entries) {
        final key = entry.key;
        final value = entry.value;
        
        // Verificar se a preferência é permitida
        if (!allowedPreferences.containsKey(key)) {
          debugPrint('⚠️ Preferência ignorada (não permitida): $key');
          continue;
        }
        
        // Verificar tipo da preferência
        final expectedType = allowedPreferences[key]!;
        if (value.runtimeType != expectedType) {
          debugPrint('⚠️ Preferência ignorada (tipo incorreto): $key');
          continue;
        }
        
        // Aplicar preferência
        if (value is String) {
          await _storageService.setString(key, value);
        } else if (value is bool) {
          await _storageService.setBool(key, value);
        } else if (value is int) {
          await _storageService.setInt(key, value);
        }
        
        debugPrint('✅ Preferência restaurada: $key = $value');
      }
    } catch (e) {
      throw RestoreException('Erro ao restaurar preferências: ${e.toString()}');
    }
  }

  String _getCurrentPlatform() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // Aqui poderia usar device_info_plus para obter mais informações
    return {
      'platform': _getCurrentPlatform(),
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Configurações de backup
class BackupSettings {
  final bool autoBackupEnabled;
  final BackupFrequency frequency;
  final bool wifiOnlyEnabled;
  final int maxBackupsToKeep;

  const BackupSettings({
    required this.autoBackupEnabled,
    required this.frequency,
    required this.wifiOnlyEnabled,
    required this.maxBackupsToKeep,
  });

  factory BackupSettings.defaultSettings() {
    return const BackupSettings(
      autoBackupEnabled: true,
      frequency: BackupFrequency.weekly,
      wifiOnlyEnabled: true,
      maxBackupsToKeep: 5,
    );
  }

  factory BackupSettings.fromJson(Map<String, dynamic> json) {
    return BackupSettings(
      autoBackupEnabled: json['autoBackupEnabled'] as bool? ?? true,
      frequency: BackupFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => BackupFrequency.weekly,
      ),
      wifiOnlyEnabled: json['wifiOnlyEnabled'] as bool? ?? true,
      maxBackupsToKeep: json['maxBackupsToKeep'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoBackupEnabled': autoBackupEnabled,
      'frequency': frequency.name,
      'wifiOnlyEnabled': wifiOnlyEnabled,
      'maxBackupsToKeep': maxBackupsToKeep,
    };
  }

  BackupSettings copyWith({
    bool? autoBackupEnabled,
    BackupFrequency? frequency,
    bool? wifiOnlyEnabled,
    int? maxBackupsToKeep,
  }) {
    return BackupSettings(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      frequency: frequency ?? this.frequency,
      wifiOnlyEnabled: wifiOnlyEnabled ?? this.wifiOnlyEnabled,
      maxBackupsToKeep: maxBackupsToKeep ?? this.maxBackupsToKeep,
    );
  }
}

/// Frequências de backup automático
enum BackupFrequency {
  manual('Manual'),
  daily('Diário'),
  weekly('Semanal');

  const BackupFrequency(this.displayName);
  final String displayName;
}

/// Failure específico para operações de dados
class DataFailure extends Failure {
  const DataFailure(String message) : super(message: message);
  
  @override
  List<Object?> get props => [message];
}

/// Failure crítico que requer intervenção manual
class CriticalFailure extends Failure {
  const CriticalFailure(String message) : super(message: message);
  
  @override
  List<Object?> get props => [message];
}

/// Exceção específica para operações de restore
class RestoreException implements Exception {
  final String message;
  
  const RestoreException(this.message);
  
  @override
  String toString() => 'RestoreException: $message';
}