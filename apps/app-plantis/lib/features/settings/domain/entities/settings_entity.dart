import 'package:flutter/material.dart';

/// Entidade principal das configurações (Domain layer)
class SettingsEntity {
  final AppSettingsEntity app;
  final NotificationSettingsEntity notifications;
  final BackupSettingsEntity backup;
  final ThemeSettingsEntity theme;
  final AccountSettingsEntity account;

  const SettingsEntity({
    required this.app,
    required this.notifications,
    required this.backup,
    required this.theme,
    required this.account,
  });

  /// Configurações padrão
  factory SettingsEntity.defaults() {
    return SettingsEntity(
      app: AppSettingsEntity.defaults(),
      notifications: NotificationSettingsEntity.defaults(),
      backup: BackupSettingsEntity.defaults(),
      theme: ThemeSettingsEntity.defaults(),
      account: AccountSettingsEntity.defaults(),
    );
  }

  /// Criar cópia com alterações
  SettingsEntity copyWith({
    AppSettingsEntity? app,
    NotificationSettingsEntity? notifications,
    BackupSettingsEntity? backup,
    ThemeSettingsEntity? theme,
    AccountSettingsEntity? account,
  }) {
    return SettingsEntity(
      app: app ?? this.app,
      notifications: notifications ?? this.notifications,
      backup: backup ?? this.backup,
      theme: theme ?? this.theme,
      account: account ?? this.account,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsEntity &&
        other.app == app &&
        other.notifications == notifications &&
        other.backup == backup &&
        other.theme == theme &&
        other.account == account;
  }

  @override
  int get hashCode {
    return app.hashCode ^
        notifications.hashCode ^
        backup.hashCode ^
        theme.hashCode ^
        account.hashCode;
  }

  @override
  String toString() {
    return 'SettingsEntity(app: $app, notifications: $notifications, backup: $backup, theme: $theme, account: $account)';
  }
}

/// Entidade para configurações gerais do app
class AppSettingsEntity {
  final String language;
  final bool analyticsEnabled;
  final bool crashReportsEnabled;

  const AppSettingsEntity({
    required this.language,
    required this.analyticsEnabled,
    required this.crashReportsEnabled,
  });

  factory AppSettingsEntity.defaults() {
    return const AppSettingsEntity(
      language: 'pt_BR',
      analyticsEnabled: true,
      crashReportsEnabled: true,
    );
  }

  AppSettingsEntity copyWith({
    String? language,
    bool? analyticsEnabled,
    bool? crashReportsEnabled,
  }) {
    return AppSettingsEntity(
      language: language ?? this.language,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportsEnabled: crashReportsEnabled ?? this.crashReportsEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppSettingsEntity &&
        other.language == language &&
        other.analyticsEnabled == analyticsEnabled &&
        other.crashReportsEnabled == crashReportsEnabled;
  }

  @override
  int get hashCode =>
      language.hashCode ^
      analyticsEnabled.hashCode ^
      crashReportsEnabled.hashCode;

  @override
  String toString() =>
      'AppSettingsEntity(language: $language, analyticsEnabled: $analyticsEnabled, crashReportsEnabled: $crashReportsEnabled)';
}

/// Entidade para configurações de notificações
class NotificationSettingsEntity {
  final bool permissionsGranted;
  final bool taskRemindersEnabled;
  final bool overdueNotificationsEnabled;
  final bool dailySummaryEnabled;
  final int reminderMinutesBefore;
  final TimeOfDay dailySummaryTime;
  final Map<String, bool> taskTypeSettings;

  const NotificationSettingsEntity({
    required this.permissionsGranted,
    required this.taskRemindersEnabled,
    required this.overdueNotificationsEnabled,
    required this.dailySummaryEnabled,
    required this.reminderMinutesBefore,
    required this.dailySummaryTime,
    required this.taskTypeSettings,
  });

  factory NotificationSettingsEntity.defaults() {
    return NotificationSettingsEntity(
      permissionsGranted: false,
      taskRemindersEnabled: true,
      overdueNotificationsEnabled: true,
      dailySummaryEnabled: true,
      reminderMinutesBefore: 60,
      dailySummaryTime: const TimeOfDay(hour: 8, minute: 0),
      taskTypeSettings: const {
        'Regar': true,
        'Adubar': true,
        'Podar': true,
        'Replantar': true,
        'Limpar': true,
        'Pulverizar': true,
        'Sol': true,
        'Sombra': true,
      },
    );
  }

  NotificationSettingsEntity copyWith({
    bool? permissionsGranted,
    bool? taskRemindersEnabled,
    bool? overdueNotificationsEnabled,
    bool? dailySummaryEnabled,
    int? reminderMinutesBefore,
    TimeOfDay? dailySummaryTime,
    Map<String, bool>? taskTypeSettings,
  }) {
    return NotificationSettingsEntity(
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      taskRemindersEnabled: taskRemindersEnabled ?? this.taskRemindersEnabled,
      overdueNotificationsEnabled:
          overdueNotificationsEnabled ?? this.overdueNotificationsEnabled,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      dailySummaryTime: dailySummaryTime ?? this.dailySummaryTime,
      taskTypeSettings: taskTypeSettings ?? Map.from(this.taskTypeSettings),
    );
  }

  /// Verifica se deve mostrar notificação baseado nas configurações
  bool shouldShowNotification(String notificationType, {String? taskType}) {
    if (!permissionsGranted) return false;

    switch (notificationType) {
      case 'task_reminder':
        if (!taskRemindersEnabled) return false;
        if (taskType != null && !isTaskTypeEnabled(taskType)) return false;
        break;
      case 'task_overdue':
        if (!overdueNotificationsEnabled) return false;
        if (taskType != null && !isTaskTypeEnabled(taskType)) return false;
        break;
      case 'daily_summary':
        if (!dailySummaryEnabled) return false;
        break;
    }

    return true;
  }

  /// Verifica se um tipo de tarefa está habilitado
  bool isTaskTypeEnabled(String taskType) {
    return taskTypeSettings[taskType] ?? true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettingsEntity &&
        other.permissionsGranted == permissionsGranted &&
        other.taskRemindersEnabled == taskRemindersEnabled &&
        other.overdueNotificationsEnabled == overdueNotificationsEnabled &&
        other.dailySummaryEnabled == dailySummaryEnabled &&
        other.reminderMinutesBefore == reminderMinutesBefore &&
        other.dailySummaryTime == dailySummaryTime &&
        _mapEquals(other.taskTypeSettings, taskTypeSettings);
  }

  @override
  int get hashCode {
    return permissionsGranted.hashCode ^
        taskRemindersEnabled.hashCode ^
        overdueNotificationsEnabled.hashCode ^
        dailySummaryEnabled.hashCode ^
        reminderMinutesBefore.hashCode ^
        dailySummaryTime.hashCode ^
        taskTypeSettings.hashCode;
  }

  @override
  String toString() {
    return 'NotificationSettingsEntity(permissionsGranted: $permissionsGranted, taskRemindersEnabled: $taskRemindersEnabled, overdueNotificationsEnabled: $overdueNotificationsEnabled, dailySummaryEnabled: $dailySummaryEnabled, reminderMinutesBefore: $reminderMinutesBefore, dailySummaryTime: $dailySummaryTime, taskTypeSettings: $taskTypeSettings)';
  }
}

/// Entidade para configurações de backup
class BackupSettingsEntity {
  final bool autoBackupEnabled;
  final BackupFrequencyEntity frequency;
  final bool wifiOnlyEnabled;
  final int maxBackupsToKeep;
  final DateTime? lastBackupTime;

  const BackupSettingsEntity({
    required this.autoBackupEnabled,
    required this.frequency,
    required this.wifiOnlyEnabled,
    required this.maxBackupsToKeep,
    this.lastBackupTime,
  });

  factory BackupSettingsEntity.defaults() {
    return const BackupSettingsEntity(
      autoBackupEnabled: true,
      frequency: BackupFrequencyEntity.daily,
      wifiOnlyEnabled: true,
      maxBackupsToKeep: 5,
      lastBackupTime: null,
    );
  }

  BackupSettingsEntity copyWith({
    bool? autoBackupEnabled,
    BackupFrequencyEntity? frequency,
    bool? wifiOnlyEnabled,
    int? maxBackupsToKeep,
    DateTime? lastBackupTime,
  }) {
    return BackupSettingsEntity(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      frequency: frequency ?? this.frequency,
      wifiOnlyEnabled: wifiOnlyEnabled ?? this.wifiOnlyEnabled,
      maxBackupsToKeep: maxBackupsToKeep ?? this.maxBackupsToKeep,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BackupSettingsEntity &&
        other.autoBackupEnabled == autoBackupEnabled &&
        other.frequency == frequency &&
        other.wifiOnlyEnabled == wifiOnlyEnabled &&
        other.maxBackupsToKeep == maxBackupsToKeep &&
        other.lastBackupTime == lastBackupTime;
  }

  @override
  int get hashCode {
    return autoBackupEnabled.hashCode ^
        frequency.hashCode ^
        wifiOnlyEnabled.hashCode ^
        maxBackupsToKeep.hashCode ^
        lastBackupTime.hashCode;
  }

  @override
  String toString() {
    return 'BackupSettingsEntity(autoBackupEnabled: $autoBackupEnabled, frequency: $frequency, wifiOnlyEnabled: $wifiOnlyEnabled, maxBackupsToKeep: $maxBackupsToKeep, lastBackupTime: $lastBackupTime)';
  }
}

/// Entidade para configurações de tema
class ThemeSettingsEntity {
  final ThemeMode themeMode;
  final bool followSystemTheme;

  const ThemeSettingsEntity({
    required this.themeMode,
    required this.followSystemTheme,
  });

  factory ThemeSettingsEntity.defaults() {
    return const ThemeSettingsEntity(
      themeMode: ThemeMode.system,
      followSystemTheme: true,
    );
  }

  ThemeSettingsEntity copyWith({
    ThemeMode? themeMode,
    bool? followSystemTheme,
  }) {
    return ThemeSettingsEntity(
      themeMode: themeMode ?? this.themeMode,
      followSystemTheme: followSystemTheme ?? this.followSystemTheme,
    );
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThemeSettingsEntity &&
        other.themeMode == themeMode &&
        other.followSystemTheme == followSystemTheme;
  }

  @override
  int get hashCode => themeMode.hashCode ^ followSystemTheme.hashCode;

  @override
  String toString() =>
      'ThemeSettingsEntity(themeMode: $themeMode, followSystemTheme: $followSystemTheme)';
}

/// Entidade para configurações de conta
class AccountSettingsEntity {
  final bool isAnonymous;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  const AccountSettingsEntity({
    required this.isAnonymous,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  factory AccountSettingsEntity.defaults() {
    return const AccountSettingsEntity(
      isAnonymous: true,
      displayName: null,
      email: null,
      photoUrl: null,
    );
  }

  AccountSettingsEntity copyWith({
    bool? isAnonymous,
    String? displayName,
    String? email,
    String? photoUrl,
  }) {
    return AccountSettingsEntity(
      isAnonymous: isAnonymous ?? this.isAnonymous,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccountSettingsEntity &&
        other.isAnonymous == isAnonymous &&
        other.displayName == displayName &&
        other.email == email &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode {
    return isAnonymous.hashCode ^
        displayName.hashCode ^
        email.hashCode ^
        photoUrl.hashCode;
  }

  @override
  String toString() {
    return 'AccountSettingsEntity(isAnonymous: $isAnonymous, displayName: $displayName, email: $email, photoUrl: $photoUrl)';
  }
}

/// Enum para frequência de backup (Domain layer)
enum BackupFrequencyEntity {
  daily('Diário'),
  weekly('Semanal'),
  monthly('Mensal');

  const BackupFrequencyEntity(this.displayName);
  final String displayName;
}

/// Helper function para comparar maps
bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;

  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}