import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_data.dart';

/// DataSource para persistência local das configurações
class SettingsLocalDataSource {
  final SharedPreferences _prefs;

  static const String _settingsKey = 'plantis_settings_unified';
  static const String _versionKey = 'plantis_settings_version';
  static const String _lastUpdatedKey = 'plantis_settings_last_updated';

  SettingsLocalDataSource({required SharedPreferences prefs})
      : _prefs = prefs;

  /// Salva configurações completas
  Future<void> saveSettings(SettingsData settings) async {
    final settingsMap = settings.toMap();
    final settingsJson = jsonEncode(settingsMap);
    
    await Future.wait([
      _prefs.setString(_settingsKey, settingsJson),
      _prefs.setInt(_versionKey, settingsMap['_version'] as int? ?? 1),
      _prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String()),
    ]);
  }

  /// Carrega configurações completas
  Future<SettingsData?> loadSettings() async {
    try {
      final settingsJson = _prefs.getString(_settingsKey);
      if (settingsJson == null) return null;

      final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
      return SettingsData.fromMap(settingsMap);
    } catch (e) {
      // Em caso de erro, retorna null para usar configurações padrão
      return null;
    }
  }

  /// Salva configurações específicas de notificações
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final currentSettings = await loadSettings() ?? SettingsData.defaultSettings();
    final updatedSettings = currentSettings.copyWith(notifications: settings);
    await saveSettings(updatedSettings);
  }

  /// Carrega configurações específicas de notificações
  Future<NotificationSettings> loadNotificationSettings() async {
    final settings = await loadSettings();
    return settings?.notifications ?? NotificationSettings.defaultSettings();
  }

  /// Salva configurações específicas de backup
  Future<void> saveBackupSettings(BackupSettings settings) async {
    final currentSettings = await loadSettings() ?? SettingsData.defaultSettings();
    final updatedSettings = currentSettings.copyWith(backup: settings);
    await saveSettings(updatedSettings);
  }

  /// Carrega configurações específicas de backup
  Future<BackupSettings> loadBackupSettings() async {
    final settings = await loadSettings();
    return settings?.backup ?? BackupSettings.defaultSettings();
  }

  /// Salva configurações específicas de tema
  Future<void> saveThemeSettings(ThemeSettings settings) async {
    final currentSettings = await loadSettings() ?? SettingsData.defaultSettings();
    final updatedSettings = currentSettings.copyWith(theme: settings);
    await saveSettings(updatedSettings);
  }

  /// Carrega configurações específicas de tema
  Future<ThemeSettings> loadThemeSettings() async {
    final settings = await loadSettings();
    return settings?.theme ?? ThemeSettings.defaultSettings();
  }

  /// Salva configurações específicas de conta
  Future<void> saveAccountSettings(AccountSettings settings) async {
    final currentSettings = await loadSettings() ?? SettingsData.defaultSettings();
    final updatedSettings = currentSettings.copyWith(account: settings);
    await saveSettings(updatedSettings);
  }

  /// Carrega configurações específicas de conta
  Future<AccountSettings> loadAccountSettings() async {
    final settings = await loadSettings();
    return settings?.account ?? AccountSettings.defaultSettings();
  }

  /// Remove todas as configurações
  Future<void> clearSettings() async {
    await Future.wait([
      _prefs.remove(_settingsKey),
      _prefs.remove(_versionKey),
      _prefs.remove(_lastUpdatedKey),
    ]);
  }

  /// Verifica se existem configurações salvas
  Future<bool> hasStoredSettings() async {
    return _prefs.containsKey(_settingsKey);
  }

  /// Obtém versão das configurações salvas
  Future<int?> getSettingsVersion() async {
    return _prefs.getInt(_versionKey);
  }

  /// Obtém timestamp da última atualização
  Future<DateTime?> getLastUpdated() async {
    final lastUpdatedString = _prefs.getString(_lastUpdatedKey);
    if (lastUpdatedString == null) return null;
    
    try {
      return DateTime.parse(lastUpdatedString);
    } catch (e) {
      return null;
    }
  }

  /// Migra configurações de formato antigo se necessário
  Future<void> migrateFromLegacySettings() async {
    // Se já tem configurações unificadas, não precisa migrar
    if (await hasStoredSettings()) return;

    // Migrar de configurações fragmentadas (legacy)
    final notificationSettings = await _migrateLegacyNotificationSettings();
    final backupSettings = await _migrateLegacyBackupSettings();
    final themeSettings = await _migrateLegacyThemeSettings();

    // Criar configurações unificadas com valores migrados
    final unifiedSettings = SettingsData(
      app: AppSettings.defaultSettings(),
      notifications: notificationSettings,
      backup: backupSettings,
      theme: themeSettings,
      account: AccountSettings.defaultSettings(),
    );

    await saveSettings(unifiedSettings);
  }

  /// Migra configurações legacy de notificações
  Future<NotificationSettings> _migrateLegacyNotificationSettings() async {
    try {
      // Keys do provider antigo
      final taskReminders = _prefs.getBool('notifications_task_reminders') ?? true;
      final overdueNotifications = _prefs.getBool('notifications_overdue') ?? true;
      final dailySummary = _prefs.getBool('notifications_daily_summary') ?? true;
      final reminderMinutes = _prefs.getInt('notifications_reminder_minutes') ?? 60;
      final dailySummaryHour = _prefs.getInt('notifications_daily_summary_hour') ?? 8;
      final dailySummaryMinute = _prefs.getInt('notifications_daily_summary_minute') ?? 0;

      // Migrar task type settings
      final Map<String, bool> taskTypeSettings = {};
      const taskTypes = ['Regar', 'Adubar', 'Podar', 'Replantar', 'Limpar', 'Pulverizar', 'Sol', 'Sombra'];
      
      for (final taskType in taskTypes) {
        taskTypeSettings[taskType] = _prefs.getBool('notifications_task_type_$taskType') ?? true;
      }

      return NotificationSettings(
        permissionsGranted: false, // Será verificado dinamicamente
        taskRemindersEnabled: taskReminders,
        overdueNotificationsEnabled: overdueNotifications,
        dailySummaryEnabled: dailySummary,
        reminderMinutesBefore: reminderMinutes,
        dailySummaryTime: TimeOfDay(hour: dailySummaryHour, minute: dailySummaryMinute),
        taskTypeSettings: taskTypeSettings,
      );
    } catch (e) {
      return NotificationSettings.defaultSettings();
    }
  }

  /// Migra configurações legacy de backup
  Future<BackupSettings> _migrateLegacyBackupSettings() async {
    try {
      // Backup settings podem não existir no formato antigo
      // Retorna configurações padrão
      return BackupSettings.defaultSettings();
    } catch (e) {
      return BackupSettings.defaultSettings();
    }
  }

  /// Migra configurações legacy de tema
  Future<ThemeSettings> _migrateLegacyThemeSettings() async {
    try {
      // Theme settings podem estar em outro provider
      // Por padrão, seguir sistema
      return ThemeSettings.defaultSettings();
    } catch (e) {
      return ThemeSettings.defaultSettings();
    }
  }

  /// Exporta configurações para backup
  Future<Map<String, dynamic>> exportSettings() async {
    final settings = await loadSettings();
    if (settings == null) return {};

    return {
      'settings': settings.toMap(),
      'exported_at': DateTime.now().toIso8601String(),
      'app_version': '1.0.0',
    };
  }

  /// Importa configurações de backup
  Future<void> importSettings(Map<String, dynamic> data) async {
    try {
      final settingsData = data['settings'] as Map<String, dynamic>?;
      if (settingsData == null) return;

      final settings = SettingsData.fromMap(settingsData);
      await saveSettings(settings);
    } catch (e) {
      // Em caso de erro, não importa
      throw Exception('Erro ao importar configurações: $e');
    }
  }
}