import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/extensions/fitossanitario_drift_extension.dart';
import '../../../../core/services/access_history_service.dart';
import '../../../../core/providers/core_providers.dart' as core_providers;
import '../../../../database/receituagro_database.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';

part 'defensivos_history_notifier.g.dart';

/// Defensivos history state
class DefensivosHistoryState {
  final List<Fitossanitario> recentDefensivos;
  final List<Fitossanitario> newDefensivos;
  final bool isLoading;
  final String? errorMessage;

  const DefensivosHistoryState({
    required this.recentDefensivos,
    required this.newDefensivos,
    required this.isLoading,
    this.errorMessage,
  });

  factory DefensivosHistoryState.initial() {
    return const DefensivosHistoryState(
      recentDefensivos: [],
      newDefensivos: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  DefensivosHistoryState copyWith({
    List<Fitossanitario>? recentDefensivos,
    List<Fitossanitario>? newDefensivos,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DefensivosHistoryState(
      recentDefensivos: recentDefensivos ?? this.recentDefensivos,
      newDefensivos: newDefensivos ?? this.newDefensivos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  DefensivosHistoryState clearError() {
    return copyWith(errorMessage: null);
  }

  bool get hasRecentDefensivos => recentDefensivos.isNotEmpty;
  bool get hasNewDefensivos => newDefensivos.isNotEmpty;
}

/// Notifier following Single Responsibility Principle - handles only history and random selections
/// Separated from HomeDefensivosProvider to improve maintainability and testability
@riverpod
class DefensivosHistoryNotifier extends _$DefensivosHistoryNotifier {
  late final FitossanitariosRepository _repository;
  late final AccessHistoryService _historyService;

  @override
  Future<DefensivosHistoryState> build() async {
    _repository = ref.watch(core_providers.fitossanitariosRepositoryProvider);
    _historyService = AccessHistoryService();
    return await _loadHistory();
  }

  /// Load history and generate recommendations
  Future<DefensivosHistoryState> _loadHistory() async {
    try {
      final allDefensivos = await _repository.findElegiveis();
      if (allDefensivos.isEmpty) {
        return DefensivosHistoryState.initial();
      }

      final historyData = await _loadHistoryData(allDefensivos);

      return DefensivosHistoryState(
        recentDefensivos: historyData['recent'] as List<Fitossanitario>,
        newDefensivos: historyData['new'] as List<Fitossanitario>,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      final allDefensivos = await _repository.findElegiveis();
      if (allDefensivos.isNotEmpty) {
        return DefensivosHistoryState(
          recentDefensivos: _selectRandomDefensivos(allDefensivos, count: 3),
          newDefensivos: _selectNewDefensivos(allDefensivos, count: 4),
          isLoading: false,
          errorMessage: 'Erro ao carregar histórico: ${e.toString()}',
        );
      } else {
        return DefensivosHistoryState.initial().copyWith(
          errorMessage: 'Erro ao carregar histórico: ${e.toString()}',
        );
      }
    }
  }

  /// Reload history with loading indicator
  Future<void> loadHistory() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    final newState = await _loadHistory();
    state = AsyncValue.data(newState);
  }

  /// Refresh history data without showing loading indicator
  Future<void> refreshHistory() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final allDefensivos = await _repository.findElegiveis();
      final historyData = await _loadHistoryData(allDefensivos);

      state = AsyncValue.data(
        currentState
            .copyWith(
              recentDefensivos: historyData['recent'] as List<Fitossanitario>,
              newDefensivos: historyData['new'] as List<Fitossanitario>,
            )
            .clearError(),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Erro ao atualizar histórico: ${e.toString()}',
        ),
      );
    }
  }

  /// Record access to a defensivo
  Future<void> recordDefensivoAccess(Fitossanitario defensivo) async {
    await _historyService.recordDefensivoAccess(
      id: defensivo.idDefensivo,
      name: defensivo.displayName,
      fabricante: defensivo.displayFabricante,
      ingrediente: defensivo.displayIngredient,
      classe: defensivo.displayClass,
    );
  }

  /// Clear current error
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.errorMessage != null) {
      state = AsyncValue.data(currentState.clearError());
    }
  }

  /// Load history data and combine with random selection
  Future<Map<String, List<Fitossanitario>>> _loadHistoryData(
    List<Fitossanitario> allDefensivos,
  ) async {
    try {
      final historyItems = await _historyService.getDefensivosHistory();
      if (allDefensivos.isEmpty) {
        return {'recent': <Fitossanitario>[], 'new': <Fitossanitario>[]};
      }

      final historicDefensivos = <Fitossanitario>[];

      for (final historyItem in historyItems.take(10)) {
        // Find defensivo by idDefensivo first, then by name
        Fitossanitario? defensivo = allDefensivos
            .where((d) => d.idDefensivo == historyItem.id)
            .firstOrNull;

        defensivo ??=
            allDefensivos.where((d) => d.nome == historyItem.name).firstOrNull;

        if (defensivo != null) {
          historicDefensivos.add(defensivo);
        }
      }
      List<Fitossanitario> recentDefensivos;
      if (historicDefensivos.isEmpty) {
        print(
          '⚠️ Nenhum histórico de acesso encontrado. Inicializando "Últimos Acessados" com 10 defensivos aleatórios.',
        );
        recentDefensivos = _selectRandomDefensivos(allDefensivos, count: 10);
      } else {
        print(
          '✅ ${historicDefensivos.length} defensivos encontrados no histórico de acesso.',
        );
        recentDefensivos = historicDefensivos;
      }
      final newDefensivos = _selectNewDefensivos(allDefensivos, count: 10);

      return {'recent': recentDefensivos, 'new': newDefensivos};
    } catch (e) {
      print('❌ Erro ao carregar histórico: $e');
      if (allDefensivos.isNotEmpty) {
        print('🔄 Usando seleção aleatória como fallback para ambas as listas');
        return {
          'recent': _selectRandomDefensivos(allDefensivos, count: 10),
          'new': _selectRandomDefensivos(allDefensivos, count: 10),
        };
      } else {
        return {'recent': <Fitossanitario>[], 'new': <Fitossanitario>[]};
      }
    }
  }

  /// Seleciona defensivos aleatórios da lista
  List<Fitossanitario> _selectRandomDefensivos(
    List<Fitossanitario> defensivos, {
    int count = 5,
  }) {
    if (defensivos.length <= count) return List.from(defensivos);

    final shuffled = List<Fitossanitario>.from(defensivos)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Seleciona defensivos "novos" (simula seleção baseada em algum critério)
  List<Fitossanitario> _selectNewDefensivos(
    List<Fitossanitario> defensivos, {
    int count = 5,
  }) {
    // Por enquanto, apenas retorna aleatórios como fallback
    return _selectRandomDefensivos(defensivos, count: count);
  }
}
