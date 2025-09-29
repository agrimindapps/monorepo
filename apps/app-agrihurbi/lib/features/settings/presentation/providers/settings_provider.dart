import 'package:app_agrihurbi/features/settings/domain/entities/settings_entity.dart';
import 'package:app_agrihurbi/features/settings/domain/usecases/manage_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Settings Provider for App Configuration Management
/// 
/// Manages all user preferences and app configuration options
/// using Provider pattern for reactive UI updates
@injectable
class SettingsProvider with ChangeNotifier {
  final ManageSettings _manageSettings;

  SettingsProvider(this._manageSettings);

  // === STATE VARIABLES ===

  SettingsEntity? _settings;
  bool _isLoadingSettings = false;
  bool _isSavingSettings = false;
  String? _errorMessage;
  String? _successMessage;

  // === GETTERS ===

  SettingsEntity? get settings => _settings;
  bool get isLoadingSettings => _isLoadingSettings;
  bool get isSavingSettings => _isSavingSettings;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get hasError => _errorMessage != null;
  bool get hasSuccess => _successMessage != null;
  bool get isInitialized => _settings != null;

  // Theme settings
  AppTheme get theme => _settings?.theme ?? AppTheme.system;
  String get language => _settings?.language ?? 'pt_BR';

  // Notification settings
  NotificationSettings get notifications => _settings?.notifications ?? const NotificationSettings();
  bool get pushNotificationsEnabled => notifications.pushNotifications;
  bool get newsNotificationsEnabled => notifications.newsNotifications;
  bool get marketAlertsEnabled => notifications.marketAlerts;
  bool get weatherAlertsEnabled => notifications.weatherAlerts;

  // Data settings
  DataSettings get dataSettings => _settings?.dataSettings ?? const DataSettings();
  bool get autoSyncEnabled => dataSettings.autoSync;
  bool get wifiOnlySyncEnabled => dataSettings.wifiOnlySync;
  bool get cacheImagesEnabled => dataSettings.cacheImages;
  DataExportFormat get exportFormat => dataSettings.exportFormat;

  // Privacy settings
  PrivacySettings get privacy => _settings?.privacy ?? const PrivacySettings();
  bool get analyticsEnabled => privacy.analyticsEnabled;
  bool get crashReportingEnabled => privacy.crashReportingEnabled;
  bool get shareUsageDataEnabled => privacy.shareUsageData;

  // Display settings
  DisplaySettings get display => _settings?.display ?? const DisplaySettings();
  double get fontSize => display.fontSize;
  bool get highContrastEnabled => display.highContrast;
  bool get animationsEnabled => display.animations;
  String get dateFormat => display.dateFormat;
  String get currency => display.currency;
  String get unitSystem => display.unitSystem;

  // Security settings
  SecuritySettings get security => _settings?.security ?? const SecuritySettings();
  bool get biometricAuthEnabled => security.biometricAuth;
  bool get requireAuthOnOpenEnabled => security.requireAuthOnOpen;
  int get autoLockMinutes => security.autoLockMinutes;

  // Backup settings
  BackupSettings get backup => _settings?.backup ?? const BackupSettings();
  bool get autoBackupEnabled => backup.autoBackup;
  BackupFrequency get backupFrequency => backup.frequency;
  bool get includeImagesInBackup => backup.includeImages;
  BackupStorage get backupStorage => backup.storage;

  // === SETTINGS OPERATIONS ===

  /// Load settings
  Future<void> loadSettings() async {
    if (_isLoadingSettings) return;

    _setLoadingSettings(true);
    _clearMessages();

    try {
      final result = await _manageSettings.getSettings();
      
      result.fold(
        (failure) => _setError('Erro ao carregar configurações: ${failure.message}'),
        (settings) {
          _settings = settings;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoadingSettings(false);
    }
  }

  /// Save settings
  Future<bool> saveSettings(SettingsEntity newSettings) async {
    if (_isSavingSettings) return false;

    _setSavingSettings(true);
    _clearMessages();

    try {
      final result = await _manageSettings.updateSettings(newSettings);
      
      return result.fold(
        (failure) {
          _setError('Erro ao salvar configurações: ${failure.message}');
          return false;
        },
        (settings) {
          _settings = settings;
          _setSuccess('Configurações salvas com sucesso!');
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setSavingSettings(false);
    }
  }

  /// Reset to default settings
  Future<bool> resetToDefaults() async {
    if (_isSavingSettings) return false;

    _setSavingSettings(true);
    _clearMessages();

    try {
      final result = await _manageSettings.resetToDefaults();
      
      return result.fold(
        (failure) {
          _setError('Erro ao resetar configurações: ${failure.message}');
          return false;
        },
        (settings) {
          _settings = settings;
          _setSuccess('Configurações resetadas para o padrão');
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setSavingSettings(false);
    }
  }

  // === THEME SETTINGS ===

  /// Update theme
  Future<bool> updateTheme(AppTheme newTheme) async {
    if (_settings == null) return false;

    final updatedSettings = _settings!.copyWith(
      theme: newTheme,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Update language
  Future<bool> updateLanguage(String newLanguage) async {
    if (_settings == null) return false;

    final updatedSettings = _settings!.copyWith(
      language: newLanguage,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  // === NOTIFICATION SETTINGS ===

  /// Update notification settings
  Future<bool> updateNotificationSettings(NotificationSettings newNotifications) async {
    if (_settings == null) return false;

    final updatedSettings = _settings!.copyWith(
      notifications: newNotifications,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Toggle push notifications
  Future<bool> togglePushNotifications(bool enabled) async {
    final newNotifications = notifications.copyWith(pushNotifications: enabled);
    return await updateNotificationSettings(newNotifications);
  }

  /// Toggle news notifications
  Future<bool> toggleNewsNotifications(bool enabled) async {
    final newNotifications = notifications.copyWith(newsNotifications: enabled);
    return await updateNotificationSettings(newNotifications);
  }

  /// Toggle market alerts
  Future<bool> toggleMarketAlerts(bool enabled) async {
    final newNotifications = notifications.copyWith(marketAlerts: enabled);
    return await updateNotificationSettings(newNotifications);
  }

  /// Toggle weather alerts
  Future<bool> toggleWeatherAlerts(bool enabled) async {
    final newNotifications = notifications.copyWith(weatherAlerts: enabled);
    return await updateNotificationSettings(newNotifications);
  }

  /// Update quiet hours
  Future<bool> updateQuietHours(String start, String end) async {
    final newNotifications = notifications.copyWith(
      quietHoursStart: start,
      quietHoursEnd: end,
    );
    return await updateNotificationSettings(newNotifications);
  }

  // === DATA SETTINGS ===

  /// Update data settings
  Future<bool> updateDataSettings(DataSettings newDataSettings) async {
    if (_settings == null) return false;

    final updatedSettings = _settings!.copyWith(
      dataSettings: newDataSettings,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Toggle auto sync
  Future<bool> toggleAutoSync(bool enabled) async {
    final newDataSettings = dataSettings.copyWith(autoSync: enabled);
    return await updateDataSettings(newDataSettings);
  }

  /// Toggle WiFi only sync
  Future<bool> toggleWifiOnlySync(bool enabled) async {
    final newDataSettings = dataSettings.copyWith(wifiOnlySync: enabled);
    return await updateDataSettings(newDataSettings);
  }

  /// Toggle cache images
  Future<bool> toggleCacheImages(bool enabled) async {
    final newDataSettings = dataSettings.copyWith(cacheImages: enabled);
    return await updateDataSettings(newDataSettings);
  }

  /// Update cache retention days
  Future<bool> updateCacheRetentionDays(int days) async {
    final newDataSettings = dataSettings.copyWith(cacheRetentionDays: days);
    return await updateDataSettings(newDataSettings);
  }

  /// Update export format
  Future<bool> updateExportFormat(DataExportFormat format) async {
    final newDataSettings = dataSettings.copyWith(exportFormat: format);
    return await updateDataSettings(newDataSettings);
  }

  // === PRIVACY SETTINGS ===

  /// Update privacy settings
  Future<bool> updatePrivacySettings(PrivacySettings newPrivacy) async {
    if (_settings == null) return false;

    final updatedSettings = _settings!.copyWith(
      privacy: newPrivacy,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Toggle analytics
  Future<bool> toggleAnalytics(bool enabled) async {
    final newPrivacy = privacy.copyWith(analyticsEnabled: enabled);
    return await updatePrivacySettings(newPrivacy);
  }

  /// Toggle crash reporting
  Future<bool> toggleCrashReporting(bool enabled) async {
    final newPrivacy = privacy.copyWith(crashReportingEnabled: enabled);
    return await updatePrivacySettings(newPrivacy);
  }

  /// Toggle usage data sharing
  Future<bool> toggleShareUsageData(bool enabled) async {
    final newPrivacy = privacy.copyWith(shareUsageData: enabled);
    return await updatePrivacySettings(newPrivacy);
  }

  /// Toggle location tracking
  Future<bool> toggleLocationTracking(bool enabled) async {
    final newPrivacy = privacy.copyWith(locationTracking: enabled);
    return await updatePrivacySettings(newPrivacy);
  }

  // === DISPLAY SETTINGS ===

  /// Update display settings
  Future<bool> updateDisplaySettings(DisplaySettings newDisplay) async {
    if (_settings == null) return false;

    final updatedSettings = _settings!.copyWith(
      display: newDisplay,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Update font size
  Future<bool> updateFontSize(double size) async {
    final newDisplay = display.copyWith(fontSize: size);
    return await updateDisplaySettings(newDisplay);
  }

  /// Toggle high contrast
  Future<bool> toggleHighContrast(bool enabled) async {
    final newDisplay = display.copyWith(highContrast: enabled);
    return await updateDisplaySettings(newDisplay);
  }

  /// Toggle animations
  Future<bool> toggleAnimations(bool enabled) async {
    final newDisplay = display.copyWith(animations: enabled);
    return await updateDisplaySettings(newDisplay);
  }

  /// Update date format
  Future<bool> updateDateFormat(String format) async {
    final newDisplay = display.copyWith(dateFormat: format);
    return await updateDisplaySettings(newDisplay);
  }

  /// Update currency
  Future<bool> updateCurrency(String currency) async {
    final newDisplay = display.copyWith(currency: currency);
    return await updateDisplaySettings(newDisplay);
  }

  /// Update unit system
  Future<bool> updateUnitSystem(String unitSystem) async {
    final newDisplay = display.copyWith(unitSystem: unitSystem);
    return await updateDisplaySettings(newDisplay);
  }

  // === SECURITY SETTINGS ===

  /// Update security settings
  Future<bool> updateSecuritySettings(SecuritySettings newSecurity) async {
    if (_settings == null) return false;

    final updatedSettings = _settings!.copyWith(
      security: newSecurity,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Toggle biometric authentication
  Future<bool> toggleBiometricAuth(bool enabled) async {
    final newSecurity = security.copyWith(biometricAuth: enabled);
    return await updateSecuritySettings(newSecurity);
  }

  /// Toggle require auth on open
  Future<bool> toggleRequireAuthOnOpen(bool enabled) async {
    final newSecurity = security.copyWith(requireAuthOnOpen: enabled);
    return await updateSecuritySettings(newSecurity);
  }

  /// Update auto lock minutes
  Future<bool> updateAutoLockMinutes(int minutes) async {
    final newSecurity = security.copyWith(autoLockMinutes: minutes);
    return await updateSecuritySettings(newSecurity);
  }

  // === BACKUP SETTINGS ===

  /// Update backup settings
  Future<bool> updateBackupSettings(BackupSettings newBackup) async {
    if (_settings == null) return false;

    final updatedSettings = _settings!.copyWith(
      backup: newBackup,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Toggle auto backup
  Future<bool> toggleAutoBackup(bool enabled) async {
    final newBackup = backup.copyWith(autoBackup: enabled);
    return await updateBackupSettings(newBackup);
  }

  /// Update backup frequency
  Future<bool> updateBackupFrequency(BackupFrequency frequency) async {
    final newBackup = backup.copyWith(frequency: frequency);
    return await updateBackupSettings(newBackup);
  }

  /// Toggle include images in backup
  Future<bool> toggleIncludeImagesInBackup(bool enabled) async {
    final newBackup = backup.copyWith(includeImages: enabled);
    return await updateBackupSettings(newBackup);
  }

  /// Update backup storage
  Future<bool> updateBackupStorage(BackupStorage storage) async {
    final newBackup = backup.copyWith(storage: storage);
    return await updateBackupSettings(newBackup);
  }

  // === DATA EXPORT/IMPORT ===

  /// Export settings
  Future<Map<String, dynamic>?> exportSettings() async {
    try {
      final result = await _manageSettings.exportSettings();
      
      return result.fold(
        (failure) {
          _setError('Erro ao exportar configurações: ${failure.message}');
          return null;
        },
        (data) {
          _setSuccess('Configurações exportadas com sucesso!');
          return data;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return null;
    }
  }

  /// Import settings
  Future<bool> importSettings(Map<String, dynamic> data) async {
    _setSavingSettings(true);
    _clearMessages();

    try {
      final result = await _manageSettings.importSettings(data);
      
      return result.fold(
        (failure) {
          _setError('Erro ao importar configurações: ${failure.message}');
          return false;
        },
        (settings) {
          _settings = settings as SettingsEntity?;
          _setSuccess('Configurações importadas com sucesso!');
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setSavingSettings(false);
    }
  }

  // === UTILITY METHODS ===

  /// Initialize provider
  Future<void> initialize() async {
    await loadSettings();
  }

  /// Clear messages
  void clearMessages() {
    _clearMessages();
  }

  /// Get settings summary
  Map<String, dynamic> getSettingsSummary() {
    if (_settings == null) return {};

    return {
      'theme': theme.displayName,
      'language': language,
      'notifications': pushNotificationsEnabled,
      'autoSync': autoSyncEnabled,
      'analytics': analyticsEnabled,
      'biometric': biometricAuthEnabled,
      'autoBackup': autoBackupEnabled,
      'lastUpdated': _settings!.lastUpdated,
    };
  }

  // === PRIVATE METHODS ===

  void _setLoadingSettings(bool loading) {
    _isLoadingSettings = loading;
    notifyListeners();
  }

  void _setSavingSettings(bool saving) {
    _isSavingSettings = saving;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

}