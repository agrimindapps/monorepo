// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/app_info_model.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';

class OptionsController extends ChangeNotifier {
  // Services
  late final SettingsService _settingsService;

  // State
  SettingsData _settings = SettingsRepository.getDefaultSettings();
  AppInfo _appInfo = AppInfoRepository.getCurrentAppInfo();
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Getters
  SettingsData get settings => _settings;
  AppInfo get appInfo => _appInfo;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  Animation<double> get fadeAnimation => _fadeAnimation;

  // Settings getters
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get darkMode => _settings.darkMode;
  Language get selectedLanguage => _settings.selectedLanguage;
  WeightUnit get selectedWeightUnit => _settings.selectedWeightUnit;
  ThemeType get selectedTheme => _settings.selectedTheme;
  String get notificationTime => _settings.notificationTime;

  // App info getters
  String get appVersion => _appInfo.formattedVersion;
  String get appName => _appInfo.appName;

  OptionsController() {
    _initializeServices();
  }

  void _initializeServices() {
    _settingsService = SettingsService();
  }

  void initializeAnimation(TickerProvider vsync) {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);

    try {
      await _loadSettings();
      await _loadAppInfo();

      _isInitialized = true;
      _clearError();
    } catch (e) {
      _setError('Erro ao inicializar configurações: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadSettings() async {
    try {
      final loadedSettings = await _settingsService.loadSettings();
      _settings = loadedSettings;
    } catch (e) {
      // Use default settings if loading fails
      _settings = SettingsRepository.getDefaultSettings();
    }
  }

  Future<void> _loadAppInfo() async {
    try {
      _appInfo = AppInfoRepository.getCurrentAppInfo();
    } catch (e) {
      _appInfo = AppInfo.defaultInfo();
    }
  }

  // Settings management
  Future<void> updateNotifications(bool enabled) async {
    if (_settings.notificationsEnabled == enabled) return;

    final newSettings = _settings.copyWith(notificationsEnabled: enabled);
    await _updateSettings(newSettings);
  }

  Future<void> updateDarkMode(bool enabled) async {
    if (_settings.darkMode == enabled) return;

    final newSettings = _settings.copyWith(darkMode: enabled);
    await _updateSettings(newSettings);
  }

  Future<void> updateLanguage(Language language) async {
    if (_settings.selectedLanguage == language) return;

    final newSettings = _settings.copyWith(selectedLanguage: language);
    await _updateSettings(newSettings);
  }

  Future<void> updateWeightUnit(WeightUnit unit) async {
    if (_settings.selectedWeightUnit == unit) return;

    final newSettings = _settings.copyWith(selectedWeightUnit: unit);
    await _updateSettings(newSettings);
  }

  Future<void> updateTheme(ThemeType theme) async {
    if (_settings.selectedTheme == theme) return;

    final newSettings = _settings.copyWith(selectedTheme: theme);
    await _updateSettings(newSettings);
  }

  Future<void> updateNotificationTime(TimeOfDay time) async {
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    
    if (_settings.notificationTime == timeString) return;

    final newSettings = _settings.copyWith(notificationTime: timeString);
    await _updateSettings(newSettings);
  }

  Future<void> _updateSettings(SettingsData newSettings) async {
    try {
      await _settingsService.saveSettings(newSettings);
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      _setError('Erro ao salvar configurações: $e');
    }
  }

  // Navigation helpers
  void openTermsOfService() {
    // This would be implemented with URL launcher or modal
    debugPrint('Opening Terms of Service');
  }

  void openPrivacyPolicy() {
    // This would be implemented with URL launcher or modal
    debugPrint('Opening Privacy Policy');
  }

  void exitModule() {
    // This would navigate to the main menu
    debugPrint('Exiting module');
  }

  // Utility methods
  List<Language> getAvailableLanguages() {
    return SettingsRepository.getAvailableLanguages();
  }

  List<WeightUnit> getAvailableWeightUnits() {
    return SettingsRepository.getAvailableWeightUnits();
  }

  List<ThemeType> getAvailableThemes() {
    return SettingsRepository.getAvailableThemes();
  }

  String getLanguageDisplayName(Language language) {
    return language.displayName;
  }

  String getWeightUnitDisplayName(WeightUnit unit) {
    return unit.displayName;
  }

  String getThemeDisplayName(ThemeType theme) {
    return theme.displayName;
  }

  Color getThemeColor(ThemeType theme) {
    switch (theme) {
      case ThemeType.blue:
        return Colors.blue;
      case ThemeType.green:
        return Colors.green;
      case ThemeType.purple:
        return Colors.purple;
      case ThemeType.orange:
        return Colors.orange;
      case ThemeType.teal:
        return Colors.teal;
    }
  }

  bool isLanguageSelected(Language language) {
    return _settings.selectedLanguage == language;
  }

  bool isThemeSelected(ThemeType theme) {
    return _settings.selectedTheme == theme;
  }

  // Validation
  bool canChangeNotificationTime() {
    return _settings.notificationsEnabled;
  }

  // Statistics
  Map<String, dynamic> getSettingsStatistics() {
    return SettingsRepository.getSettingsStatistics(_settings);
  }

  bool needsBackupReminder() {
    return SettingsRepository.needsBackupReminder(_settings);
  }

  String getBackupStatusText() {
    return SettingsRepository.getBackupStatusText(_settings);
  }

  // Legal documents
  LegalDocument getTermsOfService() {
    return AppInfoRepository.getTermsOfService();
  }

  LegalDocument getPrivacyPolicy() {
    return AppInfoRepository.getPrivacyPolicy();
  }

  // System info
  Map<String, String> getSystemInfo() {
    return AppInfoRepository.getSystemInfo();
  }

  Map<String, String> getLibraries() {
    return AppInfoRepository.getLibraries();
  }

  String getAttributions() {
    return AppInfoRepository.getAttributions();
  }

  // Error handling
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('OptionsController Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Reset methods
  Future<void> resetToDefaults() async {
    try {
      final defaultSettings = SettingsRepository.getDefaultSettings();
      await _updateSettings(defaultSettings);
    } catch (e) {
      _setError('Erro ao restaurar configurações padrão: $e');
    }
  }

  Future<void> refresh() async {
    _clearError();
    await initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
