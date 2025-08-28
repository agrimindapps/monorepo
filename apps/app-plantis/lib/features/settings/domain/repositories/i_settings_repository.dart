import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../entities/settings_entity.dart';

/// Interface do repositório de configurações seguindo Clean Architecture
abstract class ISettingsRepository {
  /// Carrega todas as configurações salvas
  Future<Either<Failure, SettingsEntity>> loadSettings();

  /// Salva todas as configurações
  Future<Either<Failure, void>> saveSettings(SettingsEntity settings);

  /// Carrega configurações específicas de notificações
  Future<Either<Failure, NotificationSettingsEntity>> loadNotificationSettings();

  /// Salva configurações específicas de notificações
  Future<Either<Failure, void>> saveNotificationSettings(NotificationSettingsEntity settings);

  /// Carrega configurações específicas de backup
  Future<Either<Failure, BackupSettingsEntity>> loadBackupSettings();

  /// Salva configurações específicas de backup
  Future<Either<Failure, void>> saveBackupSettings(BackupSettingsEntity settings);

  /// Carrega configurações específicas de tema
  Future<Either<Failure, ThemeSettingsEntity>> loadThemeSettings();

  /// Salva configurações específicas de tema
  Future<Either<Failure, void>> saveThemeSettings(ThemeSettingsEntity settings);

  /// Carrega configurações específicas de conta
  Future<Either<Failure, AccountSettingsEntity>> loadAccountSettings();

  /// Salva configurações específicas de conta
  Future<Either<Failure, void>> saveAccountSettings(AccountSettingsEntity settings);

  /// Reseta todas as configurações para valores padrão
  Future<Either<Failure, void>> resetToDefaults();

  /// Migra configurações de versões antigas se necessário
  Future<Either<Failure, void>> migrateSettings({int? fromVersion, int? toVersion});

  /// Exporta configurações para backup
  Future<Either<Failure, Map<String, dynamic>>> exportSettings();

  /// Importa configurações de backup
  Future<Either<Failure, void>> importSettings(Map<String, dynamic> data);

  /// Verifica se existem configurações salvas
  Future<bool> hasStoredSettings();

  /// Obtém timestamp da última atualização das configurações
  Future<DateTime?> getLastUpdated();
}