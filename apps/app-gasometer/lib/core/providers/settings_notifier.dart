import 'dart:convert';

import 'package:core/core.dart';

import 'dependency_providers.dart';

part 'settings_notifier.g.dart';

class SettingsState {
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

  final bool isDarkMode;
  final String selectedLanguage;
  final String selectedCurrency;
  final bool notificationsEnabled;
  final bool analyticsEnabled;
  final bool autoBackupEnabled;
  final bool isLoading;
  final String? errorMessage;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsState &&
          runtimeType == other.runtimeType &&
          isDarkMode == other.isDarkMode &&
          selectedLanguage == other.selectedLanguage &&
          selectedCurrency == other.selectedCurrency &&
          notificationsEnabled == other.notificationsEnabled &&
          analyticsEnabled == other.analyticsEnabled &&
          autoBackupEnabled == other.autoBackupEnabled &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      isDarkMode.hashCode ^
      selectedLanguage.hashCode ^
      selectedCurrency.hashCode ^
      notificationsEnabled.hashCode ^
      analyticsEnabled.hashCode ^
      autoBackupEnabled.hashCode ^
      isLoading.hashCode ^
      errorMessage.hashCode;
}

@riverpod
class CoreSettingsNotifier extends _$CoreSettingsNotifier {
  static const String _settingsKey = 'gasometer_settings';
  late SharedPreferences _storage;

  @override
  Future<SettingsState> build() async {
    _storage = ref.watch(gasometerSharedPreferencesProvider);
    return await _loadSettings();
  }

  Future<SettingsState> _loadSettings() async {
    try {
      final settingsJson = _storage.getString(_settingsKey);

      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = Map<String, dynamic>.from(
          jsonDecode(settingsJson) as Map,
        );
        return SettingsState.fromJson(settingsMap);
      }
      return const SettingsState();
    } catch (e) {
      return SettingsState(errorMessage: 'Erro ao carregar configurações: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final currentState = state.value;
      if (currentState == null) return;

      final settingsJson = jsonEncode(currentState.toJson());
      await _storage.setString(_settingsKey, settingsJson);

      if (currentState.errorMessage != null) {
        state = AsyncValue.data(currentState.copyWith(errorMessage: null));
      }
    } catch (e) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: 'Erro ao salvar configurações: $e',
          ),
        );
      }
    }
  }

  Future<void> toggleDarkMode() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isDarkMode: !currentState.isDarkMode),
    );
    await _saveSettings();
  }

  Future<void> setLanguage(String language) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(selectedLanguage: language));
    await _saveSettings();
  }

  Future<void> setCurrency(String currency) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(selectedCurrency: currency));
    await _saveSettings();
  }

  Future<void> toggleNotifications() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        notificationsEnabled: !currentState.notificationsEnabled,
      ),
    );
    await _saveSettings();
  }

  Future<void> toggleAnalytics() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(analyticsEnabled: !currentState.analyticsEnabled),
    );
    await _saveSettings();
  }

  Future<void> toggleAutoBackup() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(autoBackupEnabled: !currentState.autoBackupEnabled),
    );
    await _saveSettings();
  }

  Future<void> resetToDefaults() async {
    state = const AsyncValue.data(SettingsState());
    await _saveSettings();
  }

  void clearError() {
    final currentState = state.value;
    if (currentState != null && currentState.errorMessage != null) {
      state = AsyncValue.data(currentState.copyWith(errorMessage: null));
    }
  }

  /// Recarrega settings do storage
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadSettings);
  }
}

/// Provider para acessar isDarkMode diretamente
@riverpod
bool isDarkMode(Ref ref) {
  final settingsAsync = ref.watch(coreSettingsProvider);
  return settingsAsync.value?.isDarkMode ?? false;
}

/// Provider para acessar selectedLanguage diretamente
@riverpod
String selectedLanguage(Ref ref) {
  final settingsAsync = ref.watch(coreSettingsProvider);
  return settingsAsync.value?.selectedLanguage ?? 'pt';
}

/// Provider para acessar selectedCurrency diretamente
@riverpod
String selectedCurrency(Ref ref) {
  final settingsAsync = ref.watch(coreSettingsProvider);
  return settingsAsync.value?.selectedCurrency ?? 'BRL';
}

/// Provider para acessar notificationsEnabled diretamente
@riverpod
bool coreNotificationsEnabled(Ref ref) {
  final settingsAsync = ref.watch(coreSettingsProvider);
  return settingsAsync.value?.notificationsEnabled ?? true;
}

/// Provider para acessar analyticsEnabled diretamente
@riverpod
bool analyticsEnabled(Ref ref) {
  final settingsAsync = ref.watch(coreSettingsProvider);
  return settingsAsync.value?.analyticsEnabled ?? true;
}

/// Provider para acessar autoBackupEnabled diretamente
@riverpod
bool autoBackupEnabled(Ref ref) {
  final settingsAsync = ref.watch(coreSettingsProvider);
  return settingsAsync.value?.autoBackupEnabled ?? true;
}
