import 'package:core/core.dart';
import 'dependency_providers.dart';

// Settings State class
class SettingsState {
  final bool isDarkMode;
  final String selectedLanguage;
  final String selectedCurrency;
  final bool notificationsEnabled;
  final bool analyticsEnabled;
  final bool autoBackupEnabled;
  final bool isLoading;
  final String? errorMessage;

  const SettingsState({
    this.isDarkMode = false,
    this.selectedLanguage = 'pt',
    this.selectedCurrency = 'BRL',
    this.notificationsEnabled = true,
    this.analyticsEnabled = true,
    this.autoBackupEnabled = true,
    this.isLoading = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? selectedLanguage,
    String? selectedCurrency,
    bool? notificationsEnabled,
    bool? analyticsEnabled,
    bool? autoBackupEnabled,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'selectedLanguage': selectedLanguage,
      'selectedCurrency': selectedCurrency,
      'notificationsEnabled': notificationsEnabled,
      'analyticsEnabled': analyticsEnabled,
      'autoBackupEnabled': autoBackupEnabled,
    };
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      selectedLanguage: json['selectedLanguage'] as String? ?? 'pt',
      selectedCurrency: json['selectedCurrency'] as String? ?? 'BRL',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
      autoBackupEnabled: json['autoBackupEnabled'] as bool? ?? true,
    );
  }
}

// Settings State Notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  final HiveStorageService _storage;
  static const String _settingsKey = 'gasometer_settings';

  SettingsNotifier(this._storage) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      state = state.copyWith(isLoading: true);

      final result = await _storage.get<Map<String, dynamic>>(key: _settingsKey);
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Erro ao carregar configurações: ${failure.message}',
          );
        },
        (settingsMap) {
          if (settingsMap != null) {
            state = SettingsState.fromJson(settingsMap);
          }
          state = state.copyWith(isLoading: false);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar configurações: $e',
      );
    }
  }

  Future<void> _saveSettings() async {
    try {
      final result = await _storage.save<Map<String, dynamic>>(
        key: _settingsKey,
        data: state.toJson(),
      );
      result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Erro ao salvar configurações: ${failure.message}',
          );
        },
        (_) {
          // Success - clear any existing error
          if (state.errorMessage != null) {
            state = state.copyWith(errorMessage: null);
          }
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao salvar configurações: $e');
    }
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    await _saveSettings();
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(selectedLanguage: language);
    await _saveSettings();
  }

  Future<void> setCurrency(String currency) async {
    state = state.copyWith(selectedCurrency: currency);
    await _saveSettings();
  }

  Future<void> toggleNotifications() async {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    await _saveSettings();
  }

  Future<void> toggleAnalytics() async {
    state = state.copyWith(analyticsEnabled: !state.analyticsEnabled);
    await _saveSettings();
  }

  Future<void> toggleAutoBackup() async {
    state = state.copyWith(autoBackupEnabled: !state.autoBackupEnabled);
    await _saveSettings();
  }

  Future<void> resetToDefaults() async {
    state = const SettingsState();
    await _saveSettings();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Settings Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final storage = ref.watch(hiveStorageServiceProvider);
  return SettingsNotifier(storage);
});