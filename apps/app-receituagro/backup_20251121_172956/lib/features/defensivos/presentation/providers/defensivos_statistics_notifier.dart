import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/extensions/fitossanitario_drift_extension.dart';
import '../../../../core/services/fitossanitarios_data_loader.dart';
import '../../../../database/receituagro_database.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';

part 'defensivos_statistics_notifier.g.dart';

/// Model for statistics data computed in background
class DefensivosStatistics {
  final int totalDefensivos;
  final int totalFabricantes;
  final int totalModoAcao;
  final int totalIngredienteAtivo;
  final int totalClasseAgronomica;

  const DefensivosStatistics({
    required this.totalDefensivos,
    required this.totalFabricantes,
    required this.totalModoAcao,
    required this.totalIngredienteAtivo,
    required this.totalClasseAgronomica,
  });

  DefensivosStatistics.empty()
    : totalDefensivos = 0,
      totalFabricantes = 0,
      totalModoAcao = 0,
      totalIngredienteAtivo = 0,
      totalClasseAgronomica = 0;
}

/// Static function for compute() - calculates statistics in background isolate
/// Performance optimization: Prevents UI thread blocking during heavy statistical calculations
DefensivosStatistics _calculateDefensivosStatistics(
  List<Fitossanitario> defensivos,
) {
  final totalDefensivos = defensivos.length;
  final totalFabricantes = defensivos
      .map((d) => d.displayFabricante)
      .toSet()
      .length;
  final totalModoAcao =
      defensivos.length; // Simplificado - usar contagem total por enquanto
  final totalIngredienteAtivo = defensivos
      .map((d) => d.displayIngredient)
      .where((i) => i.isNotEmpty)
      .toSet()
      .length;
  final totalClasseAgronomica = defensivos
      .map((d) => d.displayClass)
      .where((c) => c.isNotEmpty)
      .toSet()
      .length;

  return DefensivosStatistics(
    totalDefensivos: totalDefensivos,
    totalFabricantes: totalFabricantes,
    totalModoAcao: totalModoAcao,
    totalIngredienteAtivo: totalIngredienteAtivo,
    totalClasseAgronomica: totalClasseAgronomica,
  );
}

/// Defensivos statistics state
class DefensivosStatisticsState {
  final DefensivosStatistics statistics;
  final bool isLoading;
  final String? errorMessage;

  const DefensivosStatisticsState({
    required this.statistics,
    required this.isLoading,
    this.errorMessage,
  });

  factory DefensivosStatisticsState.initial() {
    return DefensivosStatisticsState(
      statistics: DefensivosStatistics.empty(),
      isLoading: false,
      errorMessage: null,
    );
  }

  DefensivosStatisticsState copyWith({
    DefensivosStatistics? statistics,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DefensivosStatisticsState(
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  DefensivosStatisticsState clearError() {
    return copyWith(errorMessage: null);
  }

  int get totalDefensivos => statistics.totalDefensivos;
  int get totalFabricantes => statistics.totalFabricantes;
  int get totalModoAcao => statistics.totalModoAcao;
  int get totalIngredienteAtivo => statistics.totalIngredienteAtivo;
  int get totalClasseAgronomica => statistics.totalClasseAgronomica;

  bool get hasData => statistics.totalDefensivos > 0;
  String get subtitleText => isLoading
      ? 'Calculando estatísticas...'
      : '${statistics.totalDefensivos} Registros Disponíveis';

  /// Returns formatted count text
  String getFormattedCount(int count) {
    return isLoading ? '...' : '$count';
  }

  /// Whether to show content sections
  bool get shouldShowContent => !isLoading || hasData;
}

/// Notifier following Single Responsibility Principle - handles only statistics calculation
/// Separated from HomeDefensivosProvider to improve maintainability and testability
@riverpod
class DefensivosStatisticsNotifier extends _$DefensivosStatisticsNotifier {
  late final FitossanitariosRepository _repository;

  @override
  Future<DefensivosStatisticsState> build() async {
    _repository = di.sl<FitossanitariosRepository>();
    return await _loadStatistics();
  }

  /// Load and calculate statistics
  Future<DefensivosStatisticsState> _loadStatistics() async {
    try {
      var defensivos = await _repository.findElegiveis();
      if (defensivos.isEmpty) {
        final isDataLoaded = await FitossanitariosDataLoader.isDataLoaded();

        if (!isDataLoaded) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          defensivos = await _repository.findElegiveis();
          if (defensivos.isEmpty) {
            return DefensivosStatisticsState.initial().copyWith(
              errorMessage:
                  'Dados não disponíveis no momento.\n\nPor favor, reinicie o aplicativo se o problema persistir.',
            );
          }
        }
      }
      final statistics = _calculateDefensivosStatistics(defensivos);

      return DefensivosStatisticsState(
        statistics: statistics,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      return DefensivosStatisticsState.initial().copyWith(
        errorMessage: 'Erro ao calcular estatísticas: ${e.toString()}',
      );
    }
  }

  /// Reload statistics with loading indicator
  Future<void> loadStatistics() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    final newState = await _loadStatistics();
    state = AsyncValue.data(newState);
  }

  /// Refresh statistics without showing loading indicator
  Future<void> refreshStatistics() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      var defensivos = await _repository.findElegiveis();
      final statistics = _calculateDefensivosStatistics(defensivos);

      state = AsyncValue.data(
        currentState.copyWith(statistics: statistics).clearError(),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Erro ao atualizar estatísticas: ${e.toString()}',
        ),
      );
    }
  }

  /// Clear current error
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.errorMessage != null) {
      state = AsyncValue.data(currentState.clearError());
    }
  }
}
