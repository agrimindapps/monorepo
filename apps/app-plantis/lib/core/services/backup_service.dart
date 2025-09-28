import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/plants/domain/repositories/spaces_repository.dart';
import '../../features/tasks/domain/repositories/tasks_repository.dart';
import '../data/models/backup_model.dart';
import '../data/repositories/backup_repository.dart';
import 'backup_audit_service.dart';
import 'backup_data_transformer_service.dart';
import 'backup_restore_service.dart'
    show BackupRestoreService, RestoreOptions, RestoreResult;
import 'backup_validation_service.dart';
import 'secure_storage_service.dart';

/// Service principal para coordenação de operações de backup
/// Refatorado seguindo SOLID Principles - delega responsabilidades específicas
@singleton
class BackupService {
  final IBackupRepository _backupRepository;
  final BackupValidationService _validationService;
  final BackupDataTransformerService _transformerService;
  final BackupRestoreService _restoreService;
  final BackupAuditService _auditService;
  final SecureStorageService _storageService;
  final PlantsRepository _plantsRepository;
  final SpacesRepository _spacesRepository;
  final TasksRepository _tasksRepository;

  static const String _backupSettingsKey = 'backup_settings';
  static const String _lastBackupKey = 'last_backup_timestamp';

  BackupService({
    required IBackupRepository backupRepository,
    required BackupValidationService validationService,
    required BackupDataTransformerService transformerService,
    required BackupRestoreService restoreService,
    required BackupAuditService auditService,
    required SecureStorageService storageService,
    required PlantsRepository plantsRepository,
    required SpacesRepository spacesRepository,
    required TasksRepository tasksRepository,
  }) : _backupRepository = backupRepository,
       _validationService = validationService,
       _transformerService = transformerService,
       _restoreService = restoreService,
       _auditService = auditService,
       _storageService = storageService,
       _plantsRepository = plantsRepository,
       _spacesRepository = spacesRepository,
       _tasksRepository = tasksRepository;

  /// Cria um backup completo dos dados do usuário
  /// Delegado para services especializados seguindo SRP
  Future<Either<Failure, BackupResult>> createBackup({
    PlantsRepository? plantsRepository,
    SpacesRepository? spacesRepository,
    TasksRepository? tasksRepository,
  }) async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        await _auditService.logBackupCreation(
          userId: 'unknown',
          backupId: 'failed',
          itemsCount: 0,
          isSuccess: false,
          errorMessage: 'Usuário não autenticado',
        );
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      debugPrint('📦 Iniciando criação de backup para usuário: ${user.id}');

      // Coleta dados usando repositories injetados
      final plantsResult =
          await (plantsRepository?.getPlants() ??
              _plantsRepository.getPlants());
      final spacesResult =
          await (spacesRepository?.getSpaces() ??
              _spacesRepository.getSpaces());
      final tasksResult =
          await (tasksRepository?.getTasks() ?? _tasksRepository.getTasks());

      // Verifica se alguma operação falhou
      if (plantsResult.isLeft()) {
        await _auditService.logBackupCreation(
          userId: user.id,
          backupId: 'failed',
          itemsCount: 0,
          isSuccess: false,
          errorMessage: 'Erro ao carregar plantas',
        );
        return const Left(DataFailure('Erro ao carregar plantas'));
      }

      final plants = plantsResult.getOrElse(() => []);
      final spaces = spacesResult.getOrElse(() => []);
      final tasks = tasksResult.getOrElse(() => []);

      // Cria metadados do backup
      final metadata = BackupMetadata(
        plantsCount: plants.length,
        tasksCount: tasks.length,
        spacesCount: spaces.length,
        appVersion: '1.0.0',
        platform: _getCurrentPlatform(),
        additionalInfo: {
          'created_by': 'backup_service_refactored',
          'device_info': await _getDeviceInfo(),
        },
      );

      // Usa transformer service para converter dados
      final backupData = BackupData(
        plants:
            plants
                .map((plant) => _transformerService.plantToJson(plant))
                .toList(),
        tasks:
            tasks
                .map(
                  (task) =>
                      _transformerService.taskToJson(task),
                )
                .toList(),
        spaces:
            spaces
                .map((space) => _transformerService.spaceToJson(space))
                .toList(),
        settings: await _loadUserSettings(),
        userPreferences: await _loadUserPreferences(),
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
        (failure) async {
          await _auditService.logBackupCreation(
            userId: user.id,
            backupId: backup.id ?? 'unknown',
            itemsCount: 0,
            isSuccess: false,
            errorMessage: failure.message,
          );
          return Left(failure);
        },
        (result) async {
          // Salva timestamp do último backup
          await _storageService.setString(
            _lastBackupKey,
            DateTime.now().toIso8601String(),
          );

          final totalItems = plants.length + spaces.length + tasks.length;

          // Log de sucesso
          await _auditService.logBackupCreation(
            userId: user.id,
            backupId: result.backupId ?? 'unknown',
            itemsCount: totalItems,
            isSuccess: true,
          );

          // Limpa backups antigos baseado na configuração
          final settings = await getBackupSettings();
          if (settings.maxBackupsToKeep > 0) {
            await _cleanupOldBackups(user.id, settings.maxBackupsToKeep);
          }

          debugPrint('✅ Backup criado com sucesso! Items: $totalItems');
          return Right(result);
        },
      );
    } catch (e) {
      await _auditService.logBackupCreation(
        userId: 'unknown',
        backupId: 'failed',
        itemsCount: 0,
        isSuccess: false,
        errorMessage: e.toString(),
      );
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

  /// Restaura dados a partir de um backup
  /// Delegado para BackupRestoreService seguindo SRP
  Future<Either<Failure, RestoreResult>> restoreBackup(
    String backupId,
    RestoreOptions options,
  ) async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Download do backup
      final backupResult = await _backupRepository.downloadBackup(backupId);
      if (backupResult.isLeft()) {
        return backupResult.fold(
          (failure) => Left(failure),
          (_) => throw StateError('Unexpected success'),
        );
      }

      final backup = backupResult.getOrElse(
        () => throw StateError('No backup data'),
      );

      // Delega para o RestoreService
      return await _restoreService.restoreBackup(backup, user.id, options);
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
        final settings = BackupSettings.fromJson(
          jsonDecode(settingsJson) as Map<String, dynamic>,
        );
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
      'notifications_enabled':
          await _storageService.getBool('notifications_enabled') ?? true,
      'language': await _storageService.getString('language') ?? 'pt_BR',
    };
  }

  Future<Map<String, dynamic>> _loadUserPreferences() async {
    // Carrega preferências específicas do usuário
    return {
      'preferred_units':
          await _storageService.getString('preferred_units') ?? 'metric',
      'default_space': await _storageService.getString('default_space'),
      'reminder_time':
          await _storageService.getString('reminder_time') ?? '09:00',
    };
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

  /// Limpa backups antigos baseado na configuração
  Future<void> _cleanupOldBackups(String userId, int maxBackupsToKeep) async {
    try {
      final backupsResult = await _backupRepository.listBackups(userId);
      final backups = backupsResult.getOrElse(() => []);

      if (backups.length > maxBackupsToKeep) {
        // Ordena por timestamp (mais recente primeiro) e remove os mais antigos
        backups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final backupsToDelete = backups.skip(maxBackupsToKeep);

        for (final backup in backupsToDelete) {
          await _backupRepository.deleteBackup(backup.id);
          debugPrint('🗑️ Backup antigo removido: ${backup.fileName}');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao limpar backups antigos: $e');
    }
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
