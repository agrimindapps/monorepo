import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/models/fitossanitario_hive.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/extensions/fitossanitario_hive_extension.dart';
import '../../../../core/services/access_history_service.dart';
import '../../../../core/services/random_selection_service.dart';

part 'defensivos_history_notifier.g.dart';

/// Defensivos history state
class DefensivosHistoryState {
  final List<FitossanitarioHive> recentDefensivos;
  final List<FitossanitarioHive> newDefensivos;
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
    List<FitossanitarioHive>? recentDefensivos,
    List<FitossanitarioHive>? newDefensivos,
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
  late final FitossanitarioHiveRepository _repository;
  late final AccessHistoryService _historyService;

  @override
  Future<DefensivosHistoryState> build() async {
    _repository = di.sl<FitossanitarioHiveRepository>();
    _historyService = AccessHistoryService();
    return await _loadHistory();
  }

  /// Load history and generate recommendations
  Future<DefensivosHistoryState> _loadHistory() async {
    try {
      final allDefensivos = await _repository.getActiveDefensivos();
      if (allDefensivos.isEmpty) {
        return DefensivosHistoryState.initial();
      }

      final historyData = await _loadHistoryData(allDefensivos);

      return DefensivosHistoryState(
        recentDefensivos: historyData['recent'] as List<FitossanitarioHive>,
        newDefensivos: historyData['new'] as List<FitossanitarioHive>,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      final allDefensivos = await _repository.getActiveDefensivos();
      if (allDefensivos.isNotEmpty) {
        return DefensivosHistoryState(
          recentDefensivos: RandomSelectionService.selectRandomDefensivos(allDefensivos, count: 3),
          newDefensivos: RandomSelectionService.selectNewDefensivos(allDefensivos, count: 4),
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

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    final newState = await _loadHistory();
    state = AsyncValue.data(newState);
  }

  /// Refresh history data without showing loading indicator
  Future<void> refreshHistory() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final allDefensivos = await _repository.getActiveDefensivos();
      final historyData = await _loadHistoryData(allDefensivos);

      state = AsyncValue.data(
        currentState.copyWith(
          recentDefensivos: historyData['recent'] as List<FitossanitarioHive>,
          newDefensivos: historyData['new'] as List<FitossanitarioHive>,
        ).clearError(),
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
  Future<void> recordDefensivoAccess(FitossanitarioHive defensivo) async {
    await _historyService.recordDefensivoAccess(
      id: defensivo.idReg,
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
  Future<Map<String, List<FitossanitarioHive>>> _loadHistoryData(List<FitossanitarioHive> allDefensivos) async {
    try {
      final historyItems = await _historyService.getDefensivosHistory();
      if (allDefensivos.isEmpty) {
        return {
          'recent': <FitossanitarioHive>[],
          'new': <FitossanitarioHive>[],
        };
      }

      final historicDefensivos = <FitossanitarioHive>[];

      for (final historyItem in historyItems.take(10)) {
        final defensivo = allDefensivos.firstWhere(
          (d) => d.idReg == historyItem.id,
          orElse: () => allDefensivos.firstWhere(
            (d) => d.displayName == historyItem.name,
            orElse: () => FitossanitarioHive(
              idReg: '',
              status: false,
              nomeComum: '',
              nomeTecnico: '',
              comercializado: 0,
              elegivel: false,
            ),
          ),
        );

        if (defensivo.idReg.isNotEmpty) {
          historicDefensivos.add(defensivo);
        }
      }
      List<FitossanitarioHive> recentDefensivos;
      if (historicDefensivos.isEmpty) {
        print('⚠️ Nenhum histórico de acesso encontrado. Inicializando "Últimos Acessados" com 10 defensivos aleatórios.');
        recentDefensivos = RandomSelectionService.selectRandomDefensivos(allDefensivos, count: 10);
      } else {
        print('✅ ${historicDefensivos.length} defensivos encontrados no histórico de acesso.');
        recentDefensivos = historicDefensivos;
      }
      final newDefensivos = RandomSelectionService.selectNewDefensivos(allDefensivos, count: 10);

      return {
        'recent': recentDefensivos,
        'new': newDefensivos,
      };
    } catch (e) {
      print('❌ Erro ao carregar histórico: $e');
      if (allDefensivos.isNotEmpty) {
        print('🔄 Usando seleção aleatória como fallback para ambas as listas');
        return {
          'recent': RandomSelectionService.selectRandomDefensivos(allDefensivos, count: 10),
          'new': RandomSelectionService.selectRandomDefensivos(allDefensivos, count: 10).cast<FitossanitarioHive>(),
        };
      } else {
        return {
          'recent': <FitossanitarioHive>[],
          'new': <FitossanitarioHive>[],
        };
      }
    }
  }
}
