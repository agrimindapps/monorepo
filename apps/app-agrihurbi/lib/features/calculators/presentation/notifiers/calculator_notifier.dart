import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/usecases/execute_calculation.dart';
import '../../domain/usecases/get_calculators.dart';
import '../../domain/usecases/manage_calculation_history.dart';
import '../../domain/usecases/manage_favorites.dart';
import '../../domain/usecases/save_calculation_to_history.dart';
import '../providers/calculators_di_providers.dart';
import 'calculator_state.dart';

part 'calculator_notifier.g.dart';

/// Riverpod notifier for calculator management
///
/// Manages calculators, calculations, history and favorites
/// following Clean Architecture patterns
@riverpod
class CalculatorNotifier extends _$CalculatorNotifier {
  late final GetCalculators _getCalculators;
  late final GetCalculatorById _getCalculatorById;
  late final ExecuteCalculation _executeCalculation;
  late final GetCalculationHistory _getCalculationHistory;
  late final SaveCalculationToHistory _saveCalculationToHistory;
  late final ManageFavorites _manageFavorites;

  @override
  CalculatorState build() {
    // Get use cases from Riverpod providers
    _getCalculators = ref.watch(getCalculatorsUseCaseProvider);
    _getCalculatorById = ref.watch(getCalculatorByIdUseCaseProvider);
    _executeCalculation = ref.watch(executeCalculationUseCaseProvider);
    _getCalculationHistory = ref.watch(getCalculationHistoryUseCaseProvider);
    _saveCalculationToHistory =
        ref.watch(saveCalculationToHistoryUseCaseProvider);
    _manageFavorites = ref.watch(manageFavoritesUseCaseProvider);

    return const CalculatorState();
  }

  /// Computed properties
  List<CalculatorEntity> getCalculatorsByCategory(CalculatorCategory category) {
    return state.filteredCalculators
        .where((calc) => calc.category == category)
        .toList();
  }

  List<CalculatorEntity> get favoriteCalculators {
    return state.filteredCalculators
        .where((calc) => state.favoriteCalculatorIds.contains(calc.id))
        .toList();
  }

  int get totalCalculators => state.calculators.length;
  int get totalFilteredCalculators => state.filteredCalculators.length;
  int get totalFavorites => state.favoriteCalculatorIds.length;
  int get totalHistoryItems => state.calculationHistory.length;

  bool isCalculatorFavorite(String calculatorId) {
    return state.favoriteCalculatorIds.contains(calculatorId);
  }

  /// Loads all calculators
  Future<void> loadCalculators() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    final result = await _getCalculators();

    result.fold(
      (failure) {
        debugPrint(
          'CalculatorNotifier: Erro ao carregar calculadoras - ${failure.message}',
        );
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (calculators) {
        debugPrint(
          'CalculatorNotifier: Calculadoras carregadas - ${calculators.length} itens',
        );
        state = state.copyWith(
          calculators: calculators,
          isLoading: false,
        );
        _applyFilters();
      },
    );
  }

  /// Loads calculator by ID
  Future<bool> loadCalculatorById(String calculatorId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    final result = await _getCalculatorById(calculatorId);

    bool success = false;
    result.fold(
      (failure) {
        debugPrint(
          'CalculatorNotifier: Erro ao carregar calculadora - ${failure.message}',
        );
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (calculator) {
        debugPrint(
          'CalculatorNotifier: Calculadora carregada - ${calculator.id}',
        );
        state = state.copyWith(
          selectedCalculator: calculator,
          currentInputs: {},
          currentResult: null,
          isLoading: false,
        );
        success = true;
      },
    );

    return success;
  }

  /// Selects a calculator
  void selectCalculator(CalculatorEntity? calculator) {
    state = state.copyWith(
      selectedCalculator: calculator,
      currentInputs: {},
      currentResult: null,
    );
    debugPrint(
      'CalculatorNotifier: Calculadora selecionada - ${calculator?.id ?? 'nenhuma'}',
    );
  }

  /// Updates calculation input
  void updateInput(String parameterId, dynamic value) {
    final updatedInputs = Map<String, dynamic>.from(state.currentInputs);
    updatedInputs[parameterId] = value;
    state = state.copyWith(currentInputs: updatedInputs);
  }

  /// Updates multiple inputs
  void updateInputs(Map<String, dynamic> inputs) {
    final updatedInputs = Map<String, dynamic>.from(state.currentInputs)
      ..addAll(inputs);
    state = state.copyWith(currentInputs: updatedInputs);
  }

  /// Clears current inputs
  void clearInputs() {
    state = state.copyWith(
      currentInputs: {},
      currentResult: null,
    );
  }

  /// Executes calculation on selected calculator
  Future<bool> executeCurrentCalculation() async {
    if (state.selectedCalculator == null) {
      state = state.copyWith(
        errorMessage: 'Nenhuma calculadora selecionada',
      );
      return false;
    }

    state = state.copyWith(
      isCalculating: true,
      errorMessage: null,
    );

    final result = await _executeCalculation.execute(
      ExecuteCalculationParams(
        calculatorId: state.selectedCalculator!.id,
        inputs: state.currentInputs,
      ),
    );

    bool success = false;
    result.fold(
      (failure) {
        debugPrint('CalculatorNotifier: Erro no cálculo - ${failure.message}');
        state = state.copyWith(
          isCalculating: false,
          errorMessage: failure.message,
        );
      },
      (calculationResult) {
        debugPrint('CalculatorNotifier: Cálculo executado com sucesso');
        state = state.copyWith(
          currentResult: calculationResult,
          isCalculating: false,
        );
        success = true;
        if (calculationResult.isValid) {
          _saveToHistory(calculationResult);
        }
      },
    );

    return success;
  }

  /// Saves result to history
  Future<void> _saveToHistory(CalculationResult result) async {
    final historyItem = CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user',
      calculatorId: result.calculatorId,
      calculatorName: state.selectedCalculator?.name ?? 'Calculadora',
      result: result,
      createdAt: DateTime.now(),
    );

    final saveResult = await _saveCalculationToHistory.call(historyItem);

    saveResult.fold(
      (failure) {
        debugPrint(
          'CalculatorNotifier: Erro ao salvar no histórico - ${failure.message}',
        );
      },
      (_) {
        final updatedHistory = [historyItem, ...state.calculationHistory];
        state = state.copyWith(calculationHistory: updatedHistory);
        debugPrint('CalculatorNotifier: Resultado salvo no histórico');
      },
    );
  }

  /// Updates search query
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
    debugPrint('CalculatorNotifier: Query de busca atualizada - "$query"');
  }

  /// Updates category filter
  void updateCategoryFilter(CalculatorCategory? category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
    debugPrint(
      'CalculatorNotifier: Categoria filtrada - ${category?.name ?? 'todas'}',
    );
  }

  /// Clears all filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedCategory: null,
    );
    _applyFilters();
    debugPrint('CalculatorNotifier: Filtros limpos');
  }

  /// Applies filters to calculator list
  void _applyFilters() {
    var filtered = List<CalculatorEntity>.from(state.calculators);

    if (state.selectedCategory != null) {
      filtered = filtered
          .where((calc) => calc.category == state.selectedCategory)
          .toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (calc) =>
                calc.name.toLowerCase().contains(query) ||
                calc.description.toLowerCase().contains(query),
          )
          .toList();
    }

    state = state.copyWith(filteredCalculators: filtered);
  }

  /// Loads calculation history
  Future<void> loadCalculationHistory() async {
    state = state.copyWith(
      isLoadingHistory: true,
      errorMessage: null,
    );

    final result = await _getCalculationHistory.call();

    result.fold(
      (failure) {
        debugPrint(
          'CalculatorNotifier: Erro ao carregar histórico - ${failure.message}',
        );
        state = state.copyWith(
          isLoadingHistory: false,
          errorMessage: failure.message,
        );
      },
      (history) {
        debugPrint(
          'CalculatorNotifier: Histórico carregado - ${history.length} itens',
        );
        state = state.copyWith(
          calculationHistory: history,
          isLoadingHistory: false,
        );
      },
    );
  }

  /// Removes item from history
  Future<bool> removeFromHistory(String historyId) async {
    final updatedHistory =
        state.calculationHistory.where((item) => item.id != historyId).toList();
    state = state.copyWith(calculationHistory: updatedHistory);
    debugPrint('CalculatorNotifier: Item removido do histórico - $historyId');
    return true;
  }

  /// Clears all history
  Future<bool> clearHistory() async {
    state = state.copyWith(calculationHistory: []);
    debugPrint('CalculatorNotifier: Histórico limpo');
    return true;
  }

  /// Loads favorites
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoadingFavorites: true);

    final result = await _manageFavorites.call(const GetFavoritesParams());

    result.fold(
      (failure) {
        debugPrint(
          'CalculatorNotifier: Erro ao carregar favoritos - ${failure.message}',
        );
        state = state.copyWith(
          isLoadingFavorites: false,
          errorMessage: failure.message,
        );
      },
      (favorites) {
        final favoriteIds =
            favorites is List ? List<String>.from(favorites) : <String>[];
        debugPrint(
          'CalculatorNotifier: Favoritos carregados - ${favoriteIds.length} itens',
        );
        state = state.copyWith(
          favoriteCalculatorIds: favoriteIds,
          isLoadingFavorites: false,
        );
      },
    );
  }

  /// Toggles favorite
  Future<bool> toggleFavorite(String calculatorId) async {
    final isFavorite = state.favoriteCalculatorIds.contains(calculatorId);

    final result = await _manageFavorites.call(
      isFavorite
          ? RemoveFavoriteParams(calculatorId)
          : AddFavoriteParams(calculatorId),
    );

    bool success = false;
    result.fold(
      (failure) {
        debugPrint(
          'CalculatorNotifier: Erro ao alterar favorito - ${failure.message}',
        );
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        final updatedFavorites = List<String>.from(state.favoriteCalculatorIds);
        if (isFavorite) {
          updatedFavorites.remove(calculatorId);
        } else {
          updatedFavorites.add(calculatorId);
        }
        state = state.copyWith(favoriteCalculatorIds: updatedFavorites);
        success = true;
        debugPrint(
          'CalculatorNotifier: Favorito ${isFavorite ? 'removido' : 'adicionado'} - $calculatorId',
        );
      },
    );

    return success;
  }

  /// Clears error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Refreshes all data
  Future<void> refreshAllData() async {
    await Future.wait([
      loadCalculators(),
      loadCalculationHistory(),
      loadFavorites(),
    ]);
  }

  /// Applies result from history
  void applyHistoryResult(CalculationHistory historyItem) {
    final calculator = state.calculators.firstWhere(
      (calc) => calc.id == historyItem.calculatorId,
      orElse: () => state.calculators.first,
    );

    state = state.copyWith(
      currentResult: historyItem.result,
      currentInputs: Map<String, dynamic>.from(historyItem.result.inputs),
      selectedCalculator: calculator,
    );

    debugPrint(
      'CalculatorNotifier: Resultado do histórico aplicado - ${historyItem.id}',
    );
  }
}
