import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/models/user_preferences.dart';
import '../../database/repositories/i_user_preferences_repository.dart';
import 'core_providers.dart';

part 'preferences_notifier.g.dart';

/// Estado das preferências do usuário
class PreferencesState {
  final bool pragasDetectadasEnabled;
  final bool lembretesAplicacaoEnabled;
  final bool isInitialized;

  const PreferencesState({
    required this.pragasDetectadasEnabled,
    required this.lembretesAplicacaoEnabled,
    required this.isInitialized,
  });

  /// Estado inicial com valores padrão
  factory PreferencesState.initial() {
    return const PreferencesState(
      pragasDetectadasEnabled: true,
      lembretesAplicacaoEnabled: true,
      isInitialized: false,
    );
  }

  /// Cria estado a partir de UserPreferences
  factory PreferencesState.fromUserPreferences(UserPreferences preferences) {
    return PreferencesState(
      pragasDetectadasEnabled: preferences.pragasDetectadasEnabled,
      lembretesAplicacaoEnabled: preferences.lembretesAplicacaoEnabled,
      isInitialized: true,
    );
  }

  /// Copia o estado com novos valores
  PreferencesState copyWith({
    bool? pragasDetectadasEnabled,
    bool? lembretesAplicacaoEnabled,
    bool? isInitialized,
  }) {
    return PreferencesState(
      pragasDetectadasEnabled:
          pragasDetectadasEnabled ?? this.pragasDetectadasEnabled,
      lembretesAplicacaoEnabled:
          lembretesAplicacaoEnabled ?? this.lembretesAplicacaoEnabled,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Notifier para gerenciar estado das preferências de usuário
@riverpod
class PreferencesNotifier extends _$PreferencesNotifier {
  late final IUserPreferencesRepository _preferencesRepository;

  @override
  Future<PreferencesState> build() async {
    // O repositório será injetado via Riverpod
    _preferencesRepository = ref.watch(userPreferencesRepositoryProvider);

    final userPreferences = await _preferencesRepository.getUserPreferences();

    return PreferencesState.fromUserPreferences(userPreferences);
  }

  /// Toggle notificações de pragas detectadas
  Future<void> togglePragasDetectadas(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return;

    await _preferencesRepository.updatePreferences(
      pragasDetectadasEnabled: enabled,
    );

    state = AsyncValue.data(
      currentState.copyWith(pragasDetectadasEnabled: enabled),
    );
  }

  /// Toggle lembretes de aplicação
  Future<void> toggleLembretesAplicacao(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return;

    await _preferencesRepository.updatePreferences(
      lembretesAplicacaoEnabled: enabled,
    );

    state = AsyncValue.data(
      currentState.copyWith(lembretesAplicacaoEnabled: enabled),
    );
  }

  /// Toggle genérico para qualquer tipo de notificação
  Future<void> toggleNotification(String type, bool enabled) async {
    switch (type.toLowerCase()) {
      case 'pragas':
        await togglePragasDetectadas(enabled);
        break;
      case 'lembretes':
        await toggleLembretesAplicacao(enabled);
        break;
      default:
        break;
    }
  }

  /// Obtém status de uma notificação específica
  bool getNotificationEnabled(String type) {
    final currentState = state.value;
    if (currentState == null) return false;

    switch (type.toLowerCase()) {
      case 'pragas':
        return currentState.pragasDetectadasEnabled;
      case 'lembretes':
        return currentState.lembretesAplicacaoEnabled;
      default:
        return false;
    }
  }

  /// Reset para configurações padrão
  Future<void> resetToDefaults() async {
    await _preferencesRepository.resetToDefaults();

    state = const AsyncValue.data(
      PreferencesState(
        pragasDetectadasEnabled: true,
        lembretesAplicacaoEnabled: true,
        isInitialized: true,
      ),
    );
  }

  /// Refresh das preferências (reload from storage)
  Future<void> refresh() async {
    final userPreferences = await _preferencesRepository.getUserPreferences();

    state = AsyncValue.data(
      PreferencesState.fromUserPreferences(userPreferences),
    );
  }

  /// Estatísticas das preferências
  Future<Map<String, dynamic>> getStats() async {
    // Como o repositório não tem stats, retornamos dados básicos
    final currentState = state.value;
    return {
      'isInitialized': currentState?.isInitialized ?? false,
      'pragasDetectadas': currentState?.pragasDetectadasEnabled ?? false,
      'lembretesAplicacao': currentState?.lembretesAplicacaoEnabled ?? false,
    };
  }
}
