import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dependency_providers.dart';

part 'settings_notifier.g.dart';

// Settings State class (mantida imutável)
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

// Settings Notifier com @riverpod code generation
@riverpod
class CoreSettingsNotifier extends _$CoreSettingsNotifier {
  static const String _settingsKey = 'gasometer_settings';
  late HiveStorageService _storage;

  @override
  Future<SettingsState> build() async {
    // Injetar HiveStorageService via dependency provider
    _storage = ref.watch(hiveStorageServiceProvider);

    // Carregar settings iniciais
    return await _loadSettings();
  }

  // =========================================================================
  // PRIVATE METHODS - Data Loading & Persistence
  // =========================================================================

  Future<SettingsState> _loadSettings() async {
    try {
      final result = await _storage.get<Map<String, dynamic>>(key: _settingsKey);

      return result.fold(
        (failure) {
          // Em caso de falha, retorna defaults com mensagem de erro
          return SettingsState(
            errorMessage: 'Erro ao carregar configurações: ${failure.message}',
          );
        },
        (settingsMap) {
          if (settingsMap != null) {
            return SettingsState.fromJson(settingsMap);
          }
          // Se não há dados salvos, retorna defaults
          return const SettingsState();
        },
      );
    } catch (e) {
      return SettingsState(
        errorMessage: 'Erro ao carregar configurações: $e',
      );
    }
  }

  Future<void> _saveSettings() async {
    try {
      final currentState = state.valueOrNull;
      if (currentState == null) return;

      final result = await _storage.save<Map<String, dynamic>>(
        key: _settingsKey,
        data: currentState.toJson(),
      );

      result.fold(
        (failure) {
          // Atualiza state com erro
          state = AsyncValue.data(
            currentState.copyWith(
              errorMessage: 'Erro ao salvar configurações: ${failure.message}',
            ),
          );
        },
        (_) {
          // Success - limpa erro se houver
          if (currentState.errorMessage != null) {
            state = AsyncValue.data(
              currentState.copyWith(errorMessage: null),
            );
          }
        },
      );
    } catch (e) {
      final currentState = state.valueOrNull;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: 'Erro ao salvar configurações: $e',
          ),
        );
      }
    }
  }

  // =========================================================================
  // PUBLIC METHODS - Settings Management
  // =========================================================================

  Future<void> toggleDarkMode() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isDarkMode: !currentState.isDarkMode),
    );
    await _saveSettings();
  }

  Future<void> setLanguage(String language) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(selectedLanguage: language),
    );
    await _saveSettings();
  }

  Future<void> setCurrency(String currency) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(selectedCurrency: currency),
    );
    await _saveSettings();
  }

  Future<void> toggleNotifications() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        notificationsEnabled: !currentState.notificationsEnabled,
      ),
    );
    await _saveSettings();
  }

  Future<void> toggleAnalytics() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(analyticsEnabled: !currentState.analyticsEnabled),
    );
    await _saveSettings();
  }

  Future<void> toggleAutoBackup() async {
    final currentState = state.valueOrNull;
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
    final currentState = state.valueOrNull;
    if (currentState != null && currentState.errorMessage != null) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: null),
      );
    }
  }

  // =========================================================================
  // HELPER METHODS
  // =========================================================================

  /// Recarrega settings do storage
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadSettings);
  }
}

// =========================================================================
// DERIVED PROVIDERS - Seletores específicos
// =========================================================================

/// Provider para acessar isDarkMode diretamente
@riverpod
bool isDarkMode(IsDarkModeRef ref) {
  final settingsAsync = ref.watch(coreSettingsNotifierProvider);
  return settingsAsync.valueOrNull?.isDarkMode ?? false;
}

/// Provider para acessar selectedLanguage diretamente
@riverpod
String selectedLanguage(SelectedLanguageRef ref) {
  final settingsAsync = ref.watch(coreSettingsNotifierProvider);
  return settingsAsync.valueOrNull?.selectedLanguage ?? 'pt';
}

/// Provider para acessar selectedCurrency diretamente
@riverpod
String selectedCurrency(SelectedCurrencyRef ref) {
  final settingsAsync = ref.watch(coreSettingsNotifierProvider);
  return settingsAsync.valueOrNull?.selectedCurrency ?? 'BRL';
}

/// Provider para acessar notificationsEnabled diretamente
@riverpod
bool coreNotificationsEnabled(CoreNotificationsEnabledRef ref) {
  final settingsAsync = ref.watch(coreSettingsNotifierProvider);
  return settingsAsync.valueOrNull?.notificationsEnabled ?? true;
}

/// Provider para acessar analyticsEnabled diretamente
@riverpod
bool analyticsEnabled(AnalyticsEnabledRef ref) {
  final settingsAsync = ref.watch(coreSettingsNotifierProvider);
  return settingsAsync.valueOrNull?.analyticsEnabled ?? true;
}

/// Provider para acessar autoBackupEnabled diretamente
@riverpod
bool autoBackupEnabled(AutoBackupEnabledRef ref) {
  final settingsAsync = ref.watch(coreSettingsNotifierProvider);
  return settingsAsync.valueOrNull?.autoBackupEnabled ?? true;
}
