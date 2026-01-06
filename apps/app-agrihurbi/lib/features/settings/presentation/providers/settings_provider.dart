import 'package:app_agrihurbi/features/settings/domain/entities/settings_entity.dart';
import 'package:app_agrihurbi/features/settings/domain/usecases/manage_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'settings_di_providers.dart';

part 'settings_provider.g.dart';

/// State class for Settings
class SettingsState {
  final SettingsEntity? settings;
  final bool isLoadingSettings;
  final bool isSavingSettings;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    this.settings,
    this.isLoadingSettings = false,
    this.isSavingSettings = false,
    this.errorMessage,
    this.successMessage,
  });

  SettingsState copyWith({
    SettingsEntity? settings,
    bool? isLoadingSettings,
    bool? isSavingSettings,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoadingSettings: isLoadingSettings ?? this.isLoadingSettings,
      isSavingSettings: isSavingSettings ?? this.isSavingSettings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get isInitialized => settings != null;
  AppTheme get theme => settings?.theme ?? AppTheme.system;
  String get language => settings?.language ?? 'pt_BR';
  NotificationSettings get notifications =>
      settings?.notifications ?? const NotificationSettings();
  bool get pushNotificationsEnabled => notifications.pushNotifications;
  bool get newsNotificationsEnabled => notifications.newsNotifications;
  bool get marketAlertsEnabled => notifications.marketAlerts;
  bool get weatherAlertsEnabled => notifications.weatherAlerts;
  DataSettings get dataSettings =>
      settings?.dataSettings ?? const DataSettings();
  bool get autoSyncEnabled => dataSettings.autoSync;
  bool get wifiOnlySyncEnabled => dataSettings.wifiOnlySync;
  bool get cacheImagesEnabled => dataSettings.cacheImages;
  DataExportFormat get exportFormat => dataSettings.exportFormat;
  PrivacySettings get privacy => settings?.privacy ?? const PrivacySettings();
  bool get analyticsEnabled => privacy.analyticsEnabled;
  bool get crashReportingEnabled => privacy.crashReportingEnabled;
  bool get shareUsageDataEnabled => privacy.shareUsageData;
  DisplaySettings get display => settings?.display ?? const DisplaySettings();
  double get fontSize => display.fontSize;
  bool get highContrastEnabled => display.highContrast;
  bool get animationsEnabled => display.animations;
  String get dateFormat => display.dateFormat;
  String get currency => display.currency;
  String get unitSystem => display.unitSystem;
  SecuritySettings get security =>
      settings?.security ?? const SecuritySettings();
  bool get biometricAuthEnabled => security.biometricAuth;
  bool get requireAuthOnOpenEnabled => security.requireAuthOnOpen;
  int get autoLockMinutes => security.autoLockMinutes;
  BackupSettings get backup => settings?.backup ?? const BackupSettings();
  bool get autoBackupEnabled => backup.autoBackup;
  BackupFrequency get backupFrequency => backup.frequency;
  bool get includeImagesInBackup => backup.includeImages;
  BackupStorage get backupStorage => backup.storage;
}

/// Settings Notifier using Riverpod code generation
///
/// Manages all user preferences and app configuration options
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  ManageSettings get _manageSettings => ref.read(manageSettingsProvider);

  @override
  SettingsState build() {
    return const SettingsState();
  }

  // Convenience getters for backward compatibility
  SettingsEntity? get settings => state.settings;
  bool get isLoadingSettings => state.isLoadingSettings;
  bool get isSavingSettings => state.isSavingSettings;
  String? get errorMessage => state.errorMessage;
  String? get successMessage => state.successMessage;
  bool get hasError => state.hasError;
  bool get hasSuccess => state.hasSuccess;
  bool get isInitialized => state.isInitialized;
  AppTheme get theme => state.theme;
  String get language => state.language;
  NotificationSettings get notifications => state.notifications;
  bool get pushNotificationsEnabled => state.pushNotificationsEnabled;
  bool get newsNotificationsEnabled => state.newsNotificationsEnabled;
  bool get marketAlertsEnabled => state.marketAlertsEnabled;
  bool get weatherAlertsEnabled => state.weatherAlertsEnabled;
  DataSettings get dataSettings => state.dataSettings;
  bool get autoSyncEnabled => state.autoSyncEnabled;
  bool get wifiOnlySyncEnabled => state.wifiOnlySyncEnabled;
  bool get cacheImagesEnabled => state.cacheImagesEnabled;
  DataExportFormat get exportFormat => state.exportFormat;
  PrivacySettings get privacy => state.privacy;
  bool get analyticsEnabled => state.analyticsEnabled;
  bool get crashReportingEnabled => state.crashReportingEnabled;
  bool get shareUsageDataEnabled => state.shareUsageDataEnabled;
  DisplaySettings get display => state.display;
  double get fontSize => state.fontSize;
  bool get highContrastEnabled => state.highContrastEnabled;
  bool get animationsEnabled => state.animationsEnabled;
  String get dateFormat => state.dateFormat;
  String get currency => state.currency;
  String get unitSystem => state.unitSystem;
  SecuritySettings get security => state.security;
  bool get biometricAuthEnabled => state.biometricAuthEnabled;
  bool get requireAuthOnOpenEnabled => state.requireAuthOnOpenEnabled;
  int get autoLockMinutes => state.autoLockMinutes;
  BackupSettings get backup => state.backup;
  bool get autoBackupEnabled => state.autoBackupEnabled;
  BackupFrequency get backupFrequency => state.backupFrequency;
  bool get includeImagesInBackup => state.includeImagesInBackup;
  BackupStorage get backupStorage => state.backupStorage;

  /// Load settings
  Future<void> loadSettings() async {
    if (state.isLoadingSettings) return;

    state = state.copyWith(isLoadingSettings: true, clearError: true, clearSuccess: true);

    try {
      final result = await _manageSettings.getSettings();

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar configurações: ${failure.message}',
          isLoadingSettings: false,
        ),
        (loadedSettings) => state = state.copyWith(
          settings: loadedSettings,
          isLoadingSettings: false,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoadingSettings: false,
      );
    }
  }

  /// Save settings
  Future<bool> saveSettings(SettingsEntity newSettings) async {
    if (state.isSavingSettings) return false;

    state = state.copyWith(isSavingSettings: true, clearError: true, clearSuccess: true);

    try {
      final result = await _manageSettings.updateSettings(newSettings);

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Erro ao salvar configurações: ${failure.message}',
            isSavingSettings: false,
          );
          return false;
        },
        (savedSettings) {
          state = state.copyWith(
            settings: savedSettings,
            successMessage: 'Configurações salvas com sucesso!',
            isSavingSettings: false,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isSavingSettings: false,
      );
      return false;
    }
  }

  /// Reset to default settings
  Future<bool> resetToDefaults() async {
    if (state.isSavingSettings) return false;

    state = state.copyWith(isSavingSettings: true, clearError: true, clearSuccess: true);

    try {
      final result = await _manageSettings.resetToDefaults();

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Erro ao resetar configurações: ${failure.message}',
            isSavingSettings: false,
          );
          return false;
        },
        (resetSettings) {
          state = state.copyWith(
            settings: resetSettings,
            successMessage: 'Configurações resetadas para o padrão',
            isSavingSettings: false,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isSavingSettings: false,
      );
      return false;
    }
  }

  /// Update theme
  Future<bool> updateTheme(AppTheme newTheme) async {
    if (state.settings == null) return false;

    final updatedSettings = state.settings!.copyWith(
      theme: newTheme,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Update language
  Future<bool> updateLanguage(String newLanguage) async {
    if (state.settings == null) return false;

    final updatedSettings = state.settings!.copyWith(
      language: newLanguage,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(
    NotificationSettings newNotifications,
  ) async {
    if (state.settings == null) return false;

    final updatedSettings = state.settings!.copyWith(
      notifications: newNotifications,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Toggle push notifications
  Future<bool> togglePushNotifications(bool enabled) async {
    final newNotifications = state.notifications.copyWith(pushNotifications: enabled);
    return await updateNotificationSettings(newNotifications);
  }

  /// Toggle news notifications
  Future<bool> toggleNewsNotifications(bool enabled) async {
    final newNotifications = state.notifications.copyWith(newsNotifications: enabled);
    return await updateNotificationSettings(newNotifications);
  }

  /// Toggle market alerts
  Future<bool> toggleMarketAlerts(bool enabled) async {
    final newNotifications = state.notifications.copyWith(marketAlerts: enabled);
    return await updateNotificationSettings(newNotifications);
  }

  /// Toggle weather alerts
  Future<bool> toggleWeatherAlerts(bool enabled) async {
    final newNotifications = state.notifications.copyWith(weatherAlerts: enabled);
    return await updateNotificationSettings(newNotifications);
  }

  /// Update quiet hours
  Future<bool> updateQuietHours(String start, String end) async {
    final newNotifications = state.notifications.copyWith(
      quietHoursStart: start,
      quietHoursEnd: end,
    );
    return await updateNotificationSettings(newNotifications);
  }

  /// Update data settings
  Future<bool> updateDataSettings(DataSettings newDataSettings) async {
    if (state.settings == null) return false;

    final updatedSettings = state.settings!.copyWith(
      dataSettings: newDataSettings,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Toggle auto sync
  Future<bool> toggleAutoSync(bool enabled) async {
    final newDataSettings = state.dataSettings.copyWith(autoSync: enabled);
    return await updateDataSettings(newDataSettings);
  }

  /// Toggle WiFi only sync
  Future<bool> toggleWifiOnlySync(bool enabled) async {
    final newDataSettings = state.dataSettings.copyWith(wifiOnlySync: enabled);
    return await updateDataSettings(newDataSettings);
  }

  /// Toggle cache images
  Future<bool> toggleCacheImages(bool enabled) async {
    final newDataSettings = state.dataSettings.copyWith(cacheImages: enabled);
    return await updateDataSettings(newDataSettings);
  }

  /// Update cache retention days
  Future<bool> updateCacheRetentionDays(int days) async {
    final newDataSettings = state.dataSettings.copyWith(cacheRetentionDays: days);
    return await updateDataSettings(newDataSettings);
  }

  /// Update export format
  Future<bool> updateExportFormat(DataExportFormat format) async {
    final newDataSettings = state.dataSettings.copyWith(exportFormat: format);
    return await updateDataSettings(newDataSettings);
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings(PrivacySettings newPrivacy) async {
    if (state.settings == null) return false;

    final updatedSettings = state.settings!.copyWith(
      privacy: newPrivacy,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Toggle analytics
  Future<bool> toggleAnalytics(bool enabled) async {
    final newPrivacy = state.privacy.copyWith(analyticsEnabled: enabled);
    return await updatePrivacySettings(newPrivacy);
  }

  /// Toggle crash reporting
  Future<bool> toggleCrashReporting(bool enabled) async {
    final newPrivacy = state.privacy.copyWith(crashReportingEnabled: enabled);
    return await updatePrivacySettings(newPrivacy);
  }

  /// Toggle usage data sharing
  Future<bool> toggleShareUsageData(bool enabled) async {
    final newPrivacy = state.privacy.copyWith(shareUsageData: enabled);
    return await updatePrivacySettings(newPrivacy);
  }

  /// Toggle location tracking
  Future<bool> toggleLocationTracking(bool enabled) async {
    final newPrivacy = state.privacy.copyWith(locationTracking: enabled);
    return await updatePrivacySettings(newPrivacy);
  }

  /// Update display settings
  Future<bool> updateDisplaySettings(DisplaySettings newDisplay) async {
    if (state.settings == null) return false;

    final updatedSettings = state.settings!.copyWith(
      display: newDisplay,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Update font size
  Future<bool> updateFontSize(double size) async {
    final newDisplay = state.display.copyWith(fontSize: size);
    return await updateDisplaySettings(newDisplay);
  }

  /// Toggle high contrast
  Future<bool> toggleHighContrast(bool enabled) async {
    final newDisplay = state.display.copyWith(highContrast: enabled);
    return await updateDisplaySettings(newDisplay);
  }

  /// Toggle animations
  Future<bool> toggleAnimations(bool enabled) async {
    final newDisplay = state.display.copyWith(animations: enabled);
    return await updateDisplaySettings(newDisplay);
  }

  /// Update date format
  Future<bool> updateDateFormat(String format) async {
    final newDisplay = state.display.copyWith(dateFormat: format);
    return await updateDisplaySettings(newDisplay);
  }

  /// Update currency
  Future<bool> updateCurrency(String newCurrency) async {
    final newDisplay = state.display.copyWith(currency: newCurrency);
    return await updateDisplaySettings(newDisplay);
  }

  /// Update unit system
  Future<bool> updateUnitSystem(String newUnitSystem) async {
    final newDisplay = state.display.copyWith(unitSystem: newUnitSystem);
    return await updateDisplaySettings(newDisplay);
  }

  /// Update security settings
  Future<bool> updateSecuritySettings(SecuritySettings newSecurity) async {
    if (state.settings == null) return false;

    final updatedSettings = state.settings!.copyWith(
      security: newSecurity,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Toggle biometric authentication
  Future<bool> toggleBiometricAuth(bool enabled) async {
    final newSecurity = state.security.copyWith(biometricAuth: enabled);
    return await updateSecuritySettings(newSecurity);
  }

  /// Toggle require auth on open
  Future<bool> toggleRequireAuthOnOpen(bool enabled) async {
    final newSecurity = state.security.copyWith(requireAuthOnOpen: enabled);
    return await updateSecuritySettings(newSecurity);
  }

  /// Update auto lock minutes
  Future<bool> updateAutoLockMinutes(int minutes) async {
    final newSecurity = state.security.copyWith(autoLockMinutes: minutes);
    return await updateSecuritySettings(newSecurity);
  }

  /// Update backup settings
  Future<bool> updateBackupSettings(BackupSettings newBackup) async {
    if (state.settings == null) return false;

    final updatedSettings = state.settings!.copyWith(
      backup: newBackup,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Toggle auto backup
  Future<bool> toggleAutoBackup(bool enabled) async {
    final newBackup = state.backup.copyWith(autoBackup: enabled);
    return await updateBackupSettings(newBackup);
  }

  /// Update backup frequency
  Future<bool> updateBackupFrequency(BackupFrequency frequency) async {
    final newBackup = state.backup.copyWith(frequency: frequency);
    return await updateBackupSettings(newBackup);
  }

  /// Toggle include images in backup
  Future<bool> toggleIncludeImagesInBackup(bool enabled) async {
    final newBackup = state.backup.copyWith(includeImages: enabled);
    return await updateBackupSettings(newBackup);
  }

  /// Update backup storage
  Future<bool> updateBackupStorage(BackupStorage newStorage) async {
    final newBackup = state.backup.copyWith(storage: newStorage);
    return await updateBackupSettings(newBackup);
  }

  /// Export settings
  Future<Map<String, dynamic>?> exportSettings() async {
    try {
      final result = await _manageSettings.exportSettings();

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Erro ao exportar configurações: ${failure.message}',
          );
          return null;
        },
        (data) {
          state = state.copyWith(
            successMessage: 'Configurações exportadas com sucesso!',
          );
          return data;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
      return null;
    }
  }

  /// Import settings
  Future<bool> importSettings(Map<String, dynamic> data) async {
    state = state.copyWith(isSavingSettings: true, clearError: true, clearSuccess: true);

    try {
      final result = await _manageSettings.importSettings(data);

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Erro ao importar configurações: ${failure.message}',
            isSavingSettings: false,
          );
          return false;
        },
        (importedSettings) {
          state = state.copyWith(
            settings: importedSettings as SettingsEntity?,
            successMessage: 'Configurações importadas com sucesso!',
            isSavingSettings: false,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isSavingSettings: false,
      );
      return false;
    }
  }

  /// Initialize provider
  Future<void> initialize() async {
    await loadSettings();
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  /// Get settings summary
  Map<String, dynamic> getSettingsSummary() {
    if (state.settings == null) return {};

    return {
      'theme': state.theme.displayName,
      'language': state.language,
      'notifications': state.pushNotificationsEnabled,
      'autoSync': state.autoSyncEnabled,
      'analytics': state.analyticsEnabled,
      'biometric': state.biometricAuthEnabled,
      'autoBackup': state.autoBackupEnabled,
      'lastUpdated': state.settings!.lastUpdated,
    };
  }
}
