import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/plants/domain/repositories/spaces_repository.dart';
import '../../features/tasks/domain/repositories/tasks_repository.dart';
import '../data/models/backup_model.dart';
import '../data/repositories/backup_repository.dart';
import '../di/injection_container.dart';
import 'backup_audit_service.dart';
import 'backup_data_transformer_service.dart';
import 'backup_restore_service.dart';
import 'backup_validation_service.dart';
import 'secure_storage_service.dart';

/// Service principal para coordenação de operações de backup
/// Refatorado seguindo SOLID Principles - delega responsabilidades específicas
/// NOTE: Registrado manualmente em injection_container.dart (não via @singleton)
class BackupServiceRefactored {
  final IBackupRepository _backupRepository;
  final BackupDataTransformerService _transformerService;
  final BackupRestoreService _restoreService;
  final BackupAuditService _auditService;
  final SecureStorageService _storageService;

  static const String _backupSettingsKey = 'backup_settings';
  static const String _lastBackupKey = 'last_backup_timestamp';

  BackupServiceRefactored({
    required IBackupRepository backupRepository,
    required BackupValidationService validationService,
    required BackupDataTransformerService transformerService,
    required BackupRestoreService restoreService,
    required BackupAuditService auditService,
    required SecureStorageService storageService,
  }) : _backupRepository = backupRepository,
       _transformerService = transformerService,
       _restoreService = restoreService,
       _auditService = auditService,
       _storageService = storageService;

  /// Cria um backup completo dos dados do usuário
  /// Delegado para services especializados seguindo SRP
  Future<Either<Failure, BackupResult>> createBackup({
    required PlantsRepository plantsRepository,
    required SpacesRepository spacesRepository,
    required TasksRepository tasksRepository,
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
      final plantsResult = await plantsRepository.getPlants();
      final spacesResult = await spacesRepository.getSpaces();
      final tasksResult = await tasksRepository.getTasks();
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
      final backupData = BackupData(
        plants:
            plants
                .map((plant) => _transformerService.plantToJson(plant))
                .toList(),
        tasks:
            tasks.map((task) => _transformerService.taskToJson(task)).toList(),
        spaces:
            spaces
                .map((space) => _transformerService.spaceToJson(space))
                .toList(),
        settings: await _loadUserSettings(),
        userPreferences: await _loadUserPreferences(),
      );
      final backup = BackupModel(
        version: '1.0',
        timestamp: DateTime.now(),
        userId: user.id,
        metadata: metadata,
        data: backupData,
      );
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
          await _storageService.setString(
            _lastBackupKey,
            DateTime.now().toIso8601String(),
          );

          final totalItems = plants.length + spaces.length + tasks.length;
          await _auditService.logBackupCreation(
            userId: user.id,
            backupId: result.backupId ?? 'unknown',
            itemsCount: totalItems,
            isSuccess: true,
          );
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
      return await _restoreService.restoreBackup(backup, user.id, options);
    } catch (e) {
      return Left(UnknownFailure('Erro ao restaurar backup: ${e.toString()}'));
    }
  }

  /// Deleta um backup específico
  Future<Either<Failure, void>> deleteBackup(String backupId) async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final result = await _backupRepository.deleteBackup(backupId);
      await _auditService.logBackupDeletion(
        userId: user.id,
        backupId: backupId,
        isSuccess: result.isRight(),
        errorMessage:
            result.isLeft() ? result.fold((f) => f.message, (_) => null) : null,
      );

      return result;
    } catch (e) {
      return Left(UnknownFailure('Erro ao deletar backup: ${e.toString()}'));
    }
  }

  /// Obtém configurações de backup
  Future<BackupSettings> getBackupSettings() async {
    try {
      final settingsJson = await _storageService.getString(_backupSettingsKey);
      if (settingsJson != null) {
        final dynamic decodedJson = jsonDecode(settingsJson);
        final Map<String, dynamic> settingsMap =
            decodedJson as Map<String, dynamic>;
        return BackupSettings.fromJson(settingsMap);
      }
      return const BackupSettings(); // Configurações padrão
    } catch (e) {
      debugPrint('❌ Erro ao carregar configurações de backup: $e');
      return const BackupSettings(); // Fallback para configurações padrão
    }
  }

  /// Salva configurações de backup
  Future<void> saveBackupSettings(BackupSettings settings) async {
    try {
      final settingsJson = jsonEncode(settings.toJson());
      await _storageService.setString(_backupSettingsKey, settingsJson);
    } catch (e) {
      debugPrint('❌ Erro ao salvar configurações de backup: $e');
    }
  }

  /// Verifica se é necessário fazer backup automático
  Future<bool> shouldAutoBackup() async {
    try {
      final settings = await getBackupSettings();
      if (!settings.autoBackupEnabled) return false;

      final lastBackupTimestamp = await getLastBackupTimestamp();
      if (lastBackupTimestamp == null) return true;

      final now = DateTime.now();
      final timeSinceLastBackup = now.difference(lastBackupTimestamp);

      switch (settings.frequency) {
        case BackupFrequency.daily:
          return timeSinceLastBackup.inDays >= 1;
        case BackupFrequency.weekly:
          return timeSinceLastBackup.inDays >= 7;
        case BackupFrequency.monthly:
          return timeSinceLastBackup.inDays >= 30;
      }
    } catch (e) {
      debugPrint('❌ Erro ao verificar se deve fazer backup: $e');
      return false;
    }
  }

  /// Obtém timestamp do último backup
  Future<DateTime?> getLastBackupTimestamp() async {
    try {
      final timestampString = await _storageService.getString(_lastBackupKey);
      if (timestampString != null) {
        return DateTime.parse(timestampString);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Erro ao obter timestamp do último backup: $e');
      return null;
    }
  }

  Future<UserEntity?> _getCurrentUser() async {
    try {
      final authRepository = sl<IAuthRepository>();
      final result = await authRepository.currentUser.first;
      return result;
    } catch (e) {
      debugPrint('❌ Erro ao obter usuário atual: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _loadUserSettings() async {
    return {
      'notifications_enabled': true,
      'theme_mode': 'system',
      'language': 'pt_BR',
    };
  }

  Future<Map<String, dynamic>> _loadUserPreferences() async {
    return {
      'view_mode': 'grid',
      'sort_by': 'name',
      'show_completed_tasks': false,
    };
  }

  Future<void> _cleanupOldBackups(String userId, int maxBackupsToKeep) async {
    try {
      await _backupRepository.deleteOldBackups(userId, maxBackupsToKeep);

      await _auditService.logBackupCleanup(
        userId: userId,
        deletedCount: 0, // Seria calculado pela implementação real
        keepCount: maxBackupsToKeep,
        isSuccess: true,
      );
    } catch (e) {
      await _auditService.logBackupCleanup(
        userId: userId,
        deletedCount: 0,
        keepCount: maxBackupsToKeep,
        isSuccess: false,
        errorMessage: e.toString(),
      );
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
      default:
        return 'unknown';
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': _getCurrentPlatform(),
      'timestamp': DateTime.now().toIso8601String(),
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
    this.autoBackupEnabled = false,
    this.frequency = BackupFrequency.weekly,
    this.wifiOnlyEnabled = true,
    this.maxBackupsToKeep = 5,
  });

  factory BackupSettings.fromJson(Map<String, dynamic> json) {
    return BackupSettings(
      autoBackupEnabled: json['auto_backup_enabled'] as bool? ?? false,
      frequency: BackupFrequency.values.firstWhere(
        (f) => f.key == (json['frequency'] as String? ?? 'weekly'),
        orElse: () => BackupFrequency.weekly,
      ),
      wifiOnlyEnabled: json['wifi_only_enabled'] as bool? ?? true,
      maxBackupsToKeep: json['max_backups_to_keep'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auto_backup_enabled': autoBackupEnabled,
      'frequency': frequency.key,
      'wifi_only_enabled': wifiOnlyEnabled,
      'max_backups_to_keep': maxBackupsToKeep,
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
  daily('daily', 'Diário'),
  weekly('weekly', 'Semanal'),
  monthly('monthly', 'Mensal');

  const BackupFrequency(this.key, this.displayName);
  final String key;
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
