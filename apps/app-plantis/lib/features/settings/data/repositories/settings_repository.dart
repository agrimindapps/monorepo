import 'package:core/core.dart' hide Column;

import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_data.dart' as data_models;

/// Implementação do repositório de configurações
class SettingsRepository implements ISettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepository({required SettingsLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, SettingsEntity>> loadSettings() async {
    try {
      await _localDataSource.migrateFromLegacySettings();

      final settingsData = await _localDataSource.loadSettings();
      final settings =
          settingsData ?? data_models.SettingsData.defaultSettings();

      return Right(_mapToEntity(settings));
    } catch (e) {
      return Left(
        CacheFailure('Erro ao carregar configurações: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(SettingsEntity settings) async {
    try {
      final settingsData = _mapFromEntity(settings);
      await _localDataSource.saveSettings(settingsData);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao salvar configurações: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationSettingsEntity>>
  loadNotificationSettings() async {
    try {
      final notificationSettings = await _localDataSource
          .loadNotificationSettings();
      return Right(_mapNotificationToEntity(notificationSettings));
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao carregar configurações de notificação: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveNotificationSettings(
    NotificationSettingsEntity settings,
  ) async {
    try {
      final notificationSettings = _mapNotificationFromEntity(settings);
      await _localDataSource.saveNotificationSettings(notificationSettings);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao salvar configurações de notificação: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, BackupSettingsEntity>> loadBackupSettings() async {
    try {
      final backupSettings = await _localDataSource.loadBackupSettings();
      return Right(_mapBackupToEntity(backupSettings));
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao carregar configurações de backup: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveBackupSettings(
    BackupSettingsEntity settings,
  ) async {
    try {
      final backupSettings = _mapBackupFromEntity(settings);
      await _localDataSource.saveBackupSettings(backupSettings);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao salvar configurações de backup: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ThemeSettingsEntity>> loadThemeSettings() async {
    try {
      final themeSettings = await _localDataSource.loadThemeSettings();
      return Right(_mapThemeToEntity(themeSettings));
    } catch (e) {
      return Left(
        CacheFailure('Erro ao carregar configurações de tema: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveThemeSettings(
    ThemeSettingsEntity settings,
  ) async {
    try {
      final themeSettings = _mapThemeFromEntity(settings);
      await _localDataSource.saveThemeSettings(themeSettings);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao salvar configurações de tema: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, AccountSettingsEntity>> loadAccountSettings() async {
    try {
      final accountSettings = await _localDataSource.loadAccountSettings();
      return Right(_mapAccountToEntity(accountSettings));
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao carregar configurações de conta: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveAccountSettings(
    AccountSettingsEntity settings,
  ) async {
    try {
      final accountSettings = _mapAccountFromEntity(settings);
      await _localDataSource.saveAccountSettings(accountSettings);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao salvar configurações de conta: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetToDefaults() async {
    try {
      await _localDataSource.clearSettings();
      final defaultSettings = data_models.SettingsData.defaultSettings();
      await _localDataSource.saveSettings(defaultSettings);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao resetar configurações: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> migrateSettings({
    int? fromVersion,
    int? toVersion,
  }) async {
    try {
      await _localDataSource.migrateFromLegacySettings();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao migrar configurações: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportSettings() async {
    try {
      final exportData = await _localDataSource.exportSettings();
      return Right(exportData);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao exportar configurações: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> importSettings(
    Map<String, dynamic> data,
  ) async {
    try {
      await _localDataSource.importSettings(data);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao importar configurações: ${e.toString()}'),
      );
    }
  }

  @override
  Future<bool> hasStoredSettings() async {
    return await _localDataSource.hasStoredSettings();
  }

  @override
  Future<DateTime?> getLastUpdated() async {
    return await _localDataSource.getLastUpdated();
  }

  SettingsEntity _mapToEntity(data_models.SettingsData data) {
    return SettingsEntity(
      app: _mapAppToEntity(data.app),
      notifications: _mapNotificationToEntity(data.notifications),
      backup: _mapBackupToEntity(data.backup),
      theme: _mapThemeToEntity(data.theme),
      account: _mapAccountToEntity(data.account),
    );
  }

  data_models.SettingsData _mapFromEntity(SettingsEntity entity) {
    return data_models.SettingsData(
      app: _mapAppFromEntity(entity.app),
      notifications: _mapNotificationFromEntity(entity.notifications),
      backup: _mapBackupFromEntity(entity.backup),
      theme: _mapThemeFromEntity(entity.theme),
      account: _mapAccountFromEntity(entity.account),
    );
  }

  AppSettingsEntity _mapAppToEntity(data_models.AppSettings data) {
    return AppSettingsEntity(
      language: data.language,
      analyticsEnabled: data.analyticsEnabled,
      crashReportsEnabled: data.crashReportsEnabled,
    );
  }

  data_models.AppSettings _mapAppFromEntity(AppSettingsEntity entity) {
    return data_models.AppSettings(
      language: entity.language,
      analyticsEnabled: entity.analyticsEnabled,
      crashReportsEnabled: entity.crashReportsEnabled,
    );
  }

  NotificationSettingsEntity _mapNotificationToEntity(
    data_models.NotificationSettings data,
  ) {
    return NotificationSettingsEntity(
      permissionsGranted: data.permissionsGranted,
      taskRemindersEnabled: data.taskRemindersEnabled,
      overdueNotificationsEnabled: data.overdueNotificationsEnabled,
      dailySummaryEnabled: data.dailySummaryEnabled,
      reminderMinutesBefore: data.reminderMinutesBefore,
      dailySummaryTime: data.dailySummaryTime,
      taskTypeSettings: Map.from(data.taskTypeSettings),
    );
  }

  data_models.NotificationSettings _mapNotificationFromEntity(
    NotificationSettingsEntity entity,
  ) {
    return data_models.NotificationSettings(
      permissionsGranted: entity.permissionsGranted,
      taskRemindersEnabled: entity.taskRemindersEnabled,
      overdueNotificationsEnabled: entity.overdueNotificationsEnabled,
      dailySummaryEnabled: entity.dailySummaryEnabled,
      reminderMinutesBefore: entity.reminderMinutesBefore,
      dailySummaryTime: entity.dailySummaryTime,
      taskTypeSettings: Map.from(entity.taskTypeSettings),
    );
  }

  BackupSettingsEntity _mapBackupToEntity(data_models.BackupSettings data) {
    return BackupSettingsEntity(
      autoBackupEnabled: data.autoBackupEnabled,
      frequency: _mapBackupFrequencyToEntity(data.frequency),
      wifiOnlyEnabled: data.wifiOnlyEnabled,
      maxBackupsToKeep: data.maxBackupsToKeep,
      lastBackupTime: data.lastBackupTime,
    );
  }

  data_models.BackupSettings _mapBackupFromEntity(BackupSettingsEntity entity) {
    return data_models.BackupSettings(
      autoBackupEnabled: entity.autoBackupEnabled,
      frequency: _mapBackupFrequencyFromEntity(entity.frequency),
      wifiOnlyEnabled: entity.wifiOnlyEnabled,
      maxBackupsToKeep: entity.maxBackupsToKeep,
      lastBackupTime: entity.lastBackupTime,
    );
  }

  BackupFrequencyEntity _mapBackupFrequencyToEntity(
    data_models.BackupFrequency frequency,
  ) {
    switch (frequency) {
      case data_models.BackupFrequency.daily:
        return BackupFrequencyEntity.daily;
      case data_models.BackupFrequency.weekly:
        return BackupFrequencyEntity.weekly;
      case data_models.BackupFrequency.monthly:
        return BackupFrequencyEntity.monthly;
    }
  }

  data_models.BackupFrequency _mapBackupFrequencyFromEntity(
    BackupFrequencyEntity frequency,
  ) {
    switch (frequency) {
      case BackupFrequencyEntity.daily:
        return data_models.BackupFrequency.daily;
      case BackupFrequencyEntity.weekly:
        return data_models.BackupFrequency.weekly;
      case BackupFrequencyEntity.monthly:
        return data_models.BackupFrequency.monthly;
    }
  }

  ThemeSettingsEntity _mapThemeToEntity(data_models.ThemeSettings data) {
    return ThemeSettingsEntity(
      themeMode: data.themeMode,
      followSystemTheme: data.followSystemTheme,
    );
  }

  data_models.ThemeSettings _mapThemeFromEntity(ThemeSettingsEntity entity) {
    return data_models.ThemeSettings(
      themeMode: entity.themeMode,
      followSystemTheme: entity.followSystemTheme,
    );
  }

  AccountSettingsEntity _mapAccountToEntity(data_models.AccountSettings data) {
    return AccountSettingsEntity(
      isAnonymous: data.isAnonymous,
      displayName: data.displayName,
      email: data.email,
      photoUrl: data.photoUrl,
    );
  }

  data_models.AccountSettings _mapAccountFromEntity(
    AccountSettingsEntity entity,
  ) {
    return data_models.AccountSettings(
      isAnonymous: entity.isAnonymous,
      displayName: entity.displayName,
      email: entity.email,
      photoUrl: entity.photoUrl,
    );
  }
}
