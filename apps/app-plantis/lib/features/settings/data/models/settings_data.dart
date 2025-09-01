import 'package:flutter/material.dart';

/// Modelo unificado para todas as configurações do app
class SettingsData {
  final AppSettings app;
  final NotificationSettings notifications;
  final BackupSettings backup;
  final ThemeSettings theme;
  final AccountSettings account;

  const SettingsData({
    required this.app,
    required this.notifications,
    required this.backup,
    required this.theme,
    required this.account,
  });

  /// Configurações padrão
  factory SettingsData.defaultSettings() {
    return SettingsData(
      app: AppSettings.defaultSettings(),
      notifications: NotificationSettings.defaultSettings(),
      backup: BackupSettings.defaultSettings(),
      theme: ThemeSettings.defaultSettings(),
      account: AccountSettings.defaultSettings(),
    );
  }

  /// Criar cópia com alterações
  SettingsData copyWith({
    AppSettings? app,
    NotificationSettings? notifications,
    BackupSettings? backup,
    ThemeSettings? theme,
    AccountSettings? account,
  }) {
    return SettingsData(
      app: app ?? this.app,
      notifications: notifications ?? this.notifications,
      backup: backup ?? this.backup,
      theme: theme ?? this.theme,
      account: account ?? this.account,
    );
  }

  /// Converter para Map para persistência
  Map<String, dynamic> toMap() {
    return {
      'app': app.toMap(),
      'notifications': notifications.toMap(),
      'backup': backup.toMap(),
      'theme': theme.toMap(),
      'account': account.toMap(),
      '_version': 1, // Versioning para migrations futuras
      '_lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// Criar a partir de Map
  factory SettingsData.fromMap(Map<String, dynamic> map) {
    return SettingsData(
      app: AppSettings.fromMap(map['app'] as Map<String, dynamic>? ?? {}),
      notifications: NotificationSettings.fromMap(map['notifications'] as Map<String, dynamic>? ?? {}),
      backup: BackupSettings.fromMap(map['backup'] as Map<String, dynamic>? ?? {}),
      theme: ThemeSettings.fromMap(map['theme'] as Map<String, dynamic>? ?? {}),
      account: AccountSettings.fromMap(map['account'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsData &&
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
    return 'SettingsData(app: $app, notifications: $notifications, backup: $backup, theme: $theme, account: $account)';
  }
}

/// Configurações gerais do aplicativo
class AppSettings {
  final String language;
  final bool analyticsEnabled;
  final bool crashReportsEnabled;

  const AppSettings({
    required this.language,
    required this.analyticsEnabled,
    required this.crashReportsEnabled,
  });

  factory AppSettings.defaultSettings() {
    return const AppSettings(
      language: 'pt_BR',
      analyticsEnabled: true,
      crashReportsEnabled: true,
    );
  }

  AppSettings copyWith({
    String? language,
    bool? analyticsEnabled,
    bool? crashReportsEnabled,
  }) {
    return AppSettings(
      language: language ?? this.language,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportsEnabled: crashReportsEnabled ?? this.crashReportsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'analyticsEnabled': analyticsEnabled,
      'crashReportsEnabled': crashReportsEnabled,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      language: map['language'] as String? ?? 'pt_BR',
      analyticsEnabled: map['analyticsEnabled'] as bool? ?? true,
      crashReportsEnabled: map['crashReportsEnabled'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppSettings &&
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
      'AppSettings(language: $language, analyticsEnabled: $analyticsEnabled, crashReportsEnabled: $crashReportsEnabled)';
}

/// Configurações de notificações
class NotificationSettings {
  final bool permissionsGranted;
  final bool taskRemindersEnabled;
  final bool overdueNotificationsEnabled;
  final bool dailySummaryEnabled;
  final int reminderMinutesBefore;
  final TimeOfDay dailySummaryTime;
  final Map<String, bool> taskTypeSettings;

  const NotificationSettings({
    required this.permissionsGranted,
    required this.taskRemindersEnabled,
    required this.overdueNotificationsEnabled,
    required this.dailySummaryEnabled,
    required this.reminderMinutesBefore,
    required this.dailySummaryTime,
    required this.taskTypeSettings,
  });

  factory NotificationSettings.defaultSettings() {
    return const NotificationSettings(
      permissionsGranted: false,
      taskRemindersEnabled: true,
      overdueNotificationsEnabled: true,
      dailySummaryEnabled: true,
      reminderMinutesBefore: 60,
      dailySummaryTime: TimeOfDay(hour: 8, minute: 0),
      taskTypeSettings: {
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

  NotificationSettings copyWith({
    bool? permissionsGranted,
    bool? taskRemindersEnabled,
    bool? overdueNotificationsEnabled,
    bool? dailySummaryEnabled,
    int? reminderMinutesBefore,
    TimeOfDay? dailySummaryTime,
    Map<String, bool>? taskTypeSettings,
  }) {
    return NotificationSettings(
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

  Map<String, dynamic> toMap() {
    return {
      'permissionsGranted': permissionsGranted,
      'taskRemindersEnabled': taskRemindersEnabled,
      'overdueNotificationsEnabled': overdueNotificationsEnabled,
      'dailySummaryEnabled': dailySummaryEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
      'dailySummaryTime': {
        'hour': dailySummaryTime.hour,
        'minute': dailySummaryTime.minute,
      },
      'taskTypeSettings': taskTypeSettings,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    final timeMap = map['dailySummaryTime'] as Map<String, dynamic>? ?? {'hour': 8, 'minute': 0};
    return NotificationSettings(
      permissionsGranted: map['permissionsGranted'] as bool? ?? false,
      taskRemindersEnabled: map['taskRemindersEnabled'] as bool? ?? true,
      overdueNotificationsEnabled: map['overdueNotificationsEnabled'] as bool? ?? true,
      dailySummaryEnabled: map['dailySummaryEnabled'] as bool? ?? true,
      reminderMinutesBefore: map['reminderMinutesBefore'] as int? ?? 60,
      dailySummaryTime: TimeOfDay(
        hour: timeMap['hour'] as int? ?? 8,
        minute: timeMap['minute'] as int? ?? 0,
      ),
      taskTypeSettings:
          Map<String, bool>.from(map['taskTypeSettings'] as Map<dynamic, dynamic>? ?? {
            'Regar': true,
            'Adubar': true,
            'Podar': true,
            'Replantar': true,
            'Limpar': true,
            'Pulverizar': true,
            'Sol': true,
            'Sombra': true,
          }),
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

    return other is NotificationSettings &&
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
    return 'NotificationSettings(permissionsGranted: $permissionsGranted, taskRemindersEnabled: $taskRemindersEnabled, overdueNotificationsEnabled: $overdueNotificationsEnabled, dailySummaryEnabled: $dailySummaryEnabled, reminderMinutesBefore: $reminderMinutesBefore, dailySummaryTime: $dailySummaryTime, taskTypeSettings: $taskTypeSettings)';
  }
}

/// Configurações de backup (integração com BackupService existente)
class BackupSettings {
  final bool autoBackupEnabled;
  final BackupFrequency frequency;
  final bool wifiOnlyEnabled;
  final int maxBackupsToKeep;
  final DateTime? lastBackupTime;

  const BackupSettings({
    required this.autoBackupEnabled,
    required this.frequency,
    required this.wifiOnlyEnabled,
    required this.maxBackupsToKeep,
    this.lastBackupTime,
  });

  factory BackupSettings.defaultSettings() {
    return const BackupSettings(
      autoBackupEnabled: true,
      frequency: BackupFrequency.daily,
      wifiOnlyEnabled: true,
      maxBackupsToKeep: 5,
      lastBackupTime: null,
    );
  }

  BackupSettings copyWith({
    bool? autoBackupEnabled,
    BackupFrequency? frequency,
    bool? wifiOnlyEnabled,
    int? maxBackupsToKeep,
    DateTime? lastBackupTime,
  }) {
    return BackupSettings(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      frequency: frequency ?? this.frequency,
      wifiOnlyEnabled: wifiOnlyEnabled ?? this.wifiOnlyEnabled,
      maxBackupsToKeep: maxBackupsToKeep ?? this.maxBackupsToKeep,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autoBackupEnabled': autoBackupEnabled,
      'frequency': frequency.toString(),
      'wifiOnlyEnabled': wifiOnlyEnabled,
      'maxBackupsToKeep': maxBackupsToKeep,
      'lastBackupTime': lastBackupTime?.toIso8601String(),
    };
  }

  factory BackupSettings.fromMap(Map<String, dynamic> map) {
    return BackupSettings(
      autoBackupEnabled: map['autoBackupEnabled'] as bool? ?? true,
      frequency: _parseFrequency(map['frequency'] as String?),
      wifiOnlyEnabled: map['wifiOnlyEnabled'] as bool? ?? true,
      maxBackupsToKeep: map['maxBackupsToKeep'] as int? ?? 5,
      lastBackupTime: map['lastBackupTime'] != null
          ? DateTime.parse(map['lastBackupTime'] as String)
          : null,
    );
  }

  static BackupFrequency _parseFrequency(String? frequencyString) {
    if (frequencyString == null) return BackupFrequency.daily;
    return BackupFrequency.values.firstWhere(
      (f) => f.toString() == frequencyString,
      orElse: () => BackupFrequency.daily,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BackupSettings &&
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
    return 'BackupSettings(autoBackupEnabled: $autoBackupEnabled, frequency: $frequency, wifiOnlyEnabled: $wifiOnlyEnabled, maxBackupsToKeep: $maxBackupsToKeep, lastBackupTime: $lastBackupTime)';
  }
}

/// Configurações de tema
class ThemeSettings {
  final ThemeMode themeMode;
  final bool followSystemTheme;

  const ThemeSettings({
    required this.themeMode,
    required this.followSystemTheme,
  });

  factory ThemeSettings.defaultSettings() {
    return const ThemeSettings(
      themeMode: ThemeMode.system,
      followSystemTheme: true,
    );
  }

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    bool? followSystemTheme,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      followSystemTheme: followSystemTheme ?? this.followSystemTheme,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.toString(),
      'followSystemTheme': followSystemTheme,
    };
  }

  factory ThemeSettings.fromMap(Map<String, dynamic> map) {
    return ThemeSettings(
      themeMode: _parseThemeMode(map['themeMode'] as String?),
      followSystemTheme: map['followSystemTheme'] as bool? ?? true,
    );
  }

  static ThemeMode _parseThemeMode(String? themeModeString) {
    if (themeModeString == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (t) => t.toString() == themeModeString,
      orElse: () => ThemeMode.system,
    );
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThemeSettings &&
        other.themeMode == themeMode &&
        other.followSystemTheme == followSystemTheme;
  }

  @override
  int get hashCode => themeMode.hashCode ^ followSystemTheme.hashCode;

  @override
  String toString() =>
      'ThemeSettings(themeMode: $themeMode, followSystemTheme: $followSystemTheme)';
}

/// Configurações de conta
class AccountSettings {
  final bool isAnonymous;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  const AccountSettings({
    required this.isAnonymous,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  factory AccountSettings.defaultSettings() {
    return const AccountSettings(
      isAnonymous: true,
      displayName: null,
      email: null,
      photoUrl: null,
    );
  }

  AccountSettings copyWith({
    bool? isAnonymous,
    String? displayName,
    String? email,
    String? photoUrl,
  }) {
    return AccountSettings(
      isAnonymous: isAnonymous ?? this.isAnonymous,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isAnonymous': isAnonymous,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  factory AccountSettings.fromMap(Map<String, dynamic> map) {
    return AccountSettings(
      isAnonymous: map['isAnonymous'] as bool? ?? true,
      displayName: map['displayName'] as String?,
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccountSettings &&
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
    return 'AccountSettings(isAnonymous: $isAnonymous, displayName: $displayName, email: $email, photoUrl: $photoUrl)';
  }
}

/// Enum para frequência de backup (compatível com core)
enum BackupFrequency {
  daily('Diário'),
  weekly('Semanal'),
  monthly('Mensal');

  const BackupFrequency(this.displayName);
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