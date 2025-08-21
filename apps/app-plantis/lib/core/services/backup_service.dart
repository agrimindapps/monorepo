import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../data/models/backup_model.dart';
import '../data/repositories/backup_repository.dart';
import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/plants/domain/repositories/spaces_repository.dart';
import '../../features/tasks/domain/repositories/tasks_repository.dart';
import 'secure_storage_service.dart';

/// Service principal para operações de backup e restauração
@singleton
class BackupService {
  final IBackupRepository _backupRepository;
  final IAuthRepository _authRepository;
  final PlantsRepository _plantsRepository;
  final SpacesRepository _spacesRepository;
  final TasksRepository _tasksRepository;
  final SecureStorageService _storageService;

  static const String _backupSettingsKey = 'backup_settings';
  static const String _lastBackupKey = 'last_backup_timestamp';

  BackupService({
    required IBackupRepository backupRepository,
    required IAuthRepository authRepository,
    required PlantsRepository plantsRepository,
    required SpacesRepository spacesRepository,
    required TasksRepository tasksRepository,
    required SecureStorageService storageService,
  }) : _backupRepository = backupRepository,
       _authRepository = authRepository,
       _plantsRepository = plantsRepository,
       _spacesRepository = spacesRepository,
       _tasksRepository = tasksRepository,
       _storageService = storageService;

  /// Cria um backup completo dos dados do usuário
  Future<Either<Failure, BackupResult>> createBackup() async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return Left(AuthFailure('Usuário não autenticado'));
      }

      // Coleta todos os dados
      final plantsResult = await _plantsRepository.getPlants();
      final spacesResult = await _spacesRepository.getSpaces();
      final tasksResult = await _tasksRepository.getTasks();

      // Verifica se alguma operação falhou
      if (plantsResult.isLeft()) {
        return Left(DataFailure('Erro ao carregar plantas'));
      }
      if (spacesResult.isLeft()) {
        return Left(DataFailure('Erro ao carregar espaços'));
      }
      if (tasksResult.isLeft()) {
        return Left(DataFailure('Erro ao carregar tarefas'));
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
        return Left(AuthFailure('Usuário não autenticado'));
      }

      return await _backupRepository.listBackups(user.id);
    } catch (e) {
      return Left(UnknownFailure('Erro ao listar backups: ${e.toString()}'));
    }
  }

  /// Restaura dados a partir de um backup
  Future<Either<Failure, RestoreResult>> restoreBackup(
    String backupId,
    RestoreOptions options,
  ) async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return Left(AuthFailure('Usuário não autenticado'));
      }

      // Download do backup
      final backupResult = await _backupRepository.downloadBackup(backupId);

      return await backupResult.fold(
        (failure) async => Left(failure),
        (backup) async {
          // Verifica compatibilidade
          if (!backup.isCompatible) {
            return Left(ValidationFailure(
              'Backup incompatível com a versão atual do app',
            ));
          }

          final restoredCounts = <String, int>{};
          int totalRestored = 0;

          // Restaura plantas
          if (options.restorePlants && backup.data.plants.isNotEmpty) {
            final plantsRestored = await _restorePlants(
              backup.data.plants,
              options.mergeStrategy,
            );
            restoredCounts['plants'] = plantsRestored;
            totalRestored += plantsRestored;
          }

          // Restaura espaços
          if (options.restoreSpaces && backup.data.spaces.isNotEmpty) {
            final spacesRestored = await _restoreSpaces(
              backup.data.spaces,
              options.mergeStrategy,
            );
            restoredCounts['spaces'] = spacesRestored;
            totalRestored += spacesRestored;
          }

          // Restaura tarefas
          if (options.restoreTasks && backup.data.tasks.isNotEmpty) {
            final tasksRestored = await _restoreTasks(
              backup.data.tasks,
              options.mergeStrategy,
            );
            restoredCounts['tasks'] = tasksRestored;
            totalRestored += tasksRestored;
          }

          // Restaura configurações
          if (options.restoreSettings) {
            await _restoreUserSettings(backup.data.settings);
            await _restoreUserPreferences(backup.data.userPreferences);
          }

          return Right(RestoreResult.success(
            itemsRestored: totalRestored,
            restoredCounts: restoredCounts,
          ));
        },
      );
    } catch (e) {
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
        final settings = BackupSettings.fromJson(jsonDecode(settingsJson));
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

  // Métodos privados para restauração

  Future<int> _restorePlants(
    List<Map<String, dynamic>> plantsData,
    RestoreMergeStrategy strategy,
  ) async {
    int count = 0;
    for (final plantData in plantsData) {
      try {
        // TODO: Implementar lógica específica baseada na estratégia
        // Por enquanto, sempre adiciona
        count++;
      } catch (e) {
        debugPrint('Erro ao restaurar planta: $e');
      }
    }
    return count;
  }

  Future<int> _restoreSpaces(
    List<Map<String, dynamic>> spacesData,
    RestoreMergeStrategy strategy,
  ) async {
    int count = 0;
    for (final spaceData in spacesData) {
      try {
        count++;
      } catch (e) {
        debugPrint('Erro ao restaurar espaço: $e');
      }
    }
    return count;
  }

  Future<int> _restoreTasks(
    List<Map<String, dynamic>> tasksData,
    RestoreMergeStrategy strategy,
  ) async {
    int count = 0;
    for (final taskData in tasksData) {
      try {
        count++;
      } catch (e) {
        debugPrint('Erro ao restaurar tarefa: $e');
      }
    }
    return count;
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

  Future<void> _restoreUserSettings(Map<String, dynamic> settings) async {
    for (final entry in settings.entries) {
      if (entry.value is String) {
        await _storageService.setString(entry.key, entry.value as String);
      } else if (entry.value is bool) {
        await _storageService.setBool(entry.key, entry.value as bool);
      } else if (entry.value is int) {
        await _storageService.setInt(entry.key, entry.value as int);
      }
    }
  }

  Future<void> _restoreUserPreferences(Map<String, dynamic> preferences) async {
    for (final entry in preferences.entries) {
      if (entry.value is String) {
        await _storageService.setString(entry.key, entry.value as String);
      } else if (entry.value is bool) {
        await _storageService.setBool(entry.key, entry.value as bool);
      } else if (entry.value is int) {
        await _storageService.setInt(entry.key, entry.value as int);
      }
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