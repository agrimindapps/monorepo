import 'package:core/core.dart' hide Column;

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
  final PreferencesService _preferencesService = PreferencesService();

  @override
  Future<PreferencesState> build() async {
    await _preferencesService.initialize();
    final pragasDetectadas = _preferencesService.getPragasDetectadasEnabled();
    final lembretesAplicacao = _preferencesService.getLembretesAplicacaoEnabled();

    return PreferencesState(
      pragasDetectadasEnabled: pragasDetectadas,
      lembretesAplicacaoEnabled: lembretesAplicacao,
      isInitialized: true,
    );
  }

  /// Toggle notificações de pragas detectadas
  Future<void> togglePragasDetectadas(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return;

    final success = await _preferencesService.setPragasDetectadasEnabled(enabled);
    if (success) {
      state = AsyncValue.data(
        currentState.copyWith(pragasDetectadasEnabled: enabled),
      );
    }
  }

  /// Toggle lembretes de aplicação
  Future<void> toggleLembretesAplicacao(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return;

    final success = await _preferencesService.setLembretesAplicacaoEnabled(enabled);
    if (success) {
      state = AsyncValue.data(
        currentState.copyWith(lembretesAplicacaoEnabled: enabled),
      );
    }
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
    final success = await _preferencesService.resetToDefaults();
    if (success) {
      state = const AsyncValue.data(
        PreferencesState(
          pragasDetectadasEnabled: true,
          lembretesAplicacaoEnabled: true,
          isInitialized: true,
        ),
      );
    }
  }

  /// Refresh das preferências (reload from storage)
  Future<void> refresh() async {
    final pragasDetectadas = _preferencesService.getPragasDetectadasEnabled();
    final lembretesAplicacao = _preferencesService.getLembretesAplicacaoEnabled();

    state = AsyncValue.data(
      PreferencesState(
        pragasDetectadasEnabled: pragasDetectadas,
        lembretesAplicacaoEnabled: lembretesAplicacao,
        isInitialized: true,
      ),
    );
  }

  /// Estatísticas das preferências
  Map<String, dynamic> getStats() {
    return _preferencesService.getStats();
  }
}
