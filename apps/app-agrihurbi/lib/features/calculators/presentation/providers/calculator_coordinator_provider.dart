import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/calculation_result.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import 'calculator_execution_provider.dart';
import 'calculator_favorites_provider.dart';
import 'calculator_history_provider.dart';
import 'calculator_management_provider.dart';
import 'calculator_search_provider.dart';

part 'calculator_coordinator_provider.g.dart';

/// State class for CalculatorCoordinator
class CalculatorCoordinatorState {
  final bool isInitialized;

  const CalculatorCoordinatorState({
    this.isInitialized = false,
  });

  CalculatorCoordinatorState copyWith({
    bool? isInitialized,
  }) {
    return CalculatorCoordinatorState(
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Provider coordenador que compõe funcionalidades de calculadoras
/// 
/// Responsabilidade única: Coordenar providers especializados seguindo SRP
/// Substitui o CalculatorProvider monolítico original de 450 linhas
@riverpod
class CalculatorCoordinatorNotifier extends _$CalculatorCoordinatorNotifier {
  @override
  CalculatorCoordinatorState build() {
    return const CalculatorCoordinatorState();
  }

  // Provider accessors
  CalculatorManagementNotifier get managementNotifier => 
      ref.read(calculatorManagementNotifierProvider.notifier);
  CalculatorExecutionNotifier get executionNotifier =>
      ref.read(calculatorExecutionNotifierProvider.notifier);
  CalculatorHistoryNotifier get historyNotifier =>
      ref.read(calculatorHistoryNotifierProvider.notifier);
  CalculatorFavoritesNotifier get favoritesNotifier =>
      ref.read(calculatorFavoritesNotifierProvider.notifier);
  CalculatorSearchNotifier get searchNotifier =>
      ref.read(calculatorSearchNotifierProvider.notifier);

  // State accessors
  CalculatorManagementState get managementState => 
      ref.read(calculatorManagementNotifierProvider);
  CalculatorExecutionState get executionState =>
      ref.read(calculatorExecutionNotifierProvider);
  CalculatorHistoryState get historyState =>
      ref.read(calculatorHistoryNotifierProvider);
  CalculatorFavoritesState get favoritesState =>
      ref.read(calculatorFavoritesNotifierProvider);
  CalculatorSearchState get searchState =>
      ref.read(calculatorSearchNotifierProvider);

  /// Verifica se alguma operação está em andamento
  bool get isAnyOperationInProgress =>
    managementState.isLoading ||
    executionState.isCalculating ||
    historyState.isLoadingHistory ||
    historyState.isSavingToHistory ||
    favoritesState.isLoadingFavorites ||
    favoritesState.isUpdatingFavorite ||
    searchState.isSearching;

  /// Obtém mensagem de erro consolidada
  String? get consolidatedErrorMessage {
    final errors = <String>[];
    
    if (managementState.errorMessage != null) {
      errors.add('Gerenciamento: ${managementState.errorMessage}');
    }
    if (executionState.errorMessage != null) {
      errors.add('Execução: ${executionState.errorMessage}');
    }
    if (historyState.errorMessage != null) {
      errors.add('Histórico: ${historyState.errorMessage}');
    }
    if (favoritesState.errorMessage != null) {
      errors.add('Favoritos: ${favoritesState.errorMessage}');
    }
    if (searchState.errorMessage != null) {
      errors.add('Busca: ${searchState.errorMessage}');
    }
    
    return errors.isEmpty ? null : errors.join('\n');
  }

  /// Lista de calculadoras com filtros aplicados
  List<CalculatorEntity> get filteredCalculators {
    return searchNotifier.applyFilters(managementState.calculators);
  }

  /// Lista de calculadoras favoritas
  List<CalculatorEntity> get favoriteCalculators {
    return favoritesNotifier.getFavoriteCalculators(managementState.calculators);
  }

  /// Calculadora atualmente selecionada/ativa
  CalculatorEntity? get selectedCalculator => 
    managementState.selectedCalculator ?? executionState.activeCalculator;

  /// Resultado do último cálculo
  CalculationResult? get currentCalculationResult => executionState.currentResult;

  /// Inicialização completa do sistema de calculadoras
  Future<void> initializeSystem() async {
    debugPrint('CalculatorCoordinatorNotifier: Inicializando sistema de calculadoras');
    
    await Future.wait([
      managementNotifier.loadCalculators(),
      historyNotifier.loadCalculationHistory(),
      favoritesNotifier.loadFavorites(),
    ]);

    state = state.copyWith(isInitialized: true);
    debugPrint('CalculatorCoordinatorNotifier: Sistema de calculadoras inicializado');
  }

  /// Seleciona e prepara calculadora para uso
  Future<bool> selectAndPrepareCalculator(String calculatorId) async {
    debugPrint('CalculatorCoordinatorNotifier: Selecionando calculadora - $calculatorId');
    final loadSuccess = await managementNotifier.loadCalculatorById(calculatorId);
    if (!loadSuccess) return false;
    
    final calculator = managementState.selectedCalculator;
    if (calculator == null) return false;
    
    executionNotifier.setActiveCalculator(calculator);
    
    debugPrint('CalculatorCoordinatorNotifier: Calculadora selecionada e preparada - $calculatorId');
    return true;
  }

  /// Executa cálculo completo com salvamento no histórico
  Future<bool> executeCalculationAndSave({
    String? notes,
    bool saveToHistory = true,
  }) async {
    debugPrint('CalculatorCoordinatorNotifier: Executando cálculo completo');
    
    final calculator = selectedCalculator;
    if (calculator == null) {
      debugPrint('CalculatorCoordinatorNotifier: Nenhuma calculadora selecionada');
      return false;
    }
    
    final executionSuccess = await executionNotifier.executeCalculation();
    if (!executionSuccess) return false;
    
    if (saveToHistory && executionState.currentResult != null) {
      await historyNotifier.saveToHistory(
        calculatorId: calculator.id,
        calculatorName: calculator.name,
        result: executionState.currentResult!,
        notes: notes,
      );
    }
    
    debugPrint('CalculatorCoordinatorNotifier: Cálculo completo executado com sucesso');
    return true;
  }

  /// Aplica resultado do histórico e prepara para novo cálculo
  void applyHistoryResult(String historyId) {
    final historyItem = historyState.calculationHistory
        .where((item) => item.id == historyId)
        .firstOrNull;
    
    if (historyItem == null) return;
    
    managementNotifier.selectCalculator(
      managementNotifier.findCalculatorById(historyItem.calculatorId)
    );
    executionNotifier.applyPreviousResult(historyItem.result);
    
    debugPrint('CalculatorCoordinatorNotifier: Resultado do histórico aplicado - $historyId');
  }

  /// Busca calculadoras com filtros
  Future<void> searchCalculators({
    String? query,
    CalculatorCategory? category,
  }) async {
    if (query != null) {
      searchNotifier.updateSearchQuery(query);
    }
    if (category != null) {
      searchNotifier.updateCategoryFilter(category);
    }

    await searchNotifier.searchAndFilter(managementState.calculators);
  }

  /// Alterna status de favorito da calculadora atual
  Future<bool> toggleCurrentCalculatorFavorite() async {
    final calculator = selectedCalculator;
    if (calculator == null) return false;

    return await favoritesNotifier.toggleFavorite(calculator.id);
  }

  /// Refresh completo de todos os dados
  Future<void> refreshAllData() async {
    debugPrint('CalculatorCoordinatorNotifier: Atualizando todos os dados');
    
    await Future.wait([
      managementNotifier.refreshCalculators(),
      historyNotifier.refreshHistory(),
      favoritesNotifier.refreshFavorites(),
    ]);
    
    debugPrint('CalculatorCoordinatorNotifier: Todos os dados atualizados');
  }

  /// Limpa todos os erros dos providers especializados
  void clearAllErrors() {
    managementNotifier.clearError();
    executionNotifier.clearError();
    historyNotifier.clearError();
    favoritesNotifier.clearError();
    searchNotifier.clearError();
    
    debugPrint('CalculatorCoordinatorNotifier: Todos os erros limpos');
  }

  /// Reset completo do sistema
  void resetSystem() {
    managementNotifier.resetState();
    executionNotifier.resetState();
    historyNotifier.resetState();
    favoritesNotifier.resetState();
    searchNotifier.resetState();

    state = state.copyWith(isInitialized: false);
    debugPrint('CalculatorCoordinatorNotifier: Sistema resetado');
  }

  /// Verifica se calculadora é favorita
  bool isCalculatorFavorite(String calculatorId) =>
    favoritesNotifier.isCalculatorFavorite(calculatorId);

  /// Obtém calculadoras por categoria
  List<CalculatorEntity> getCalculatorsByCategory(CalculatorCategory category) =>
    managementNotifier.getCalculatorsByCategory(category);

  /// Obtém estatísticas do histórico
  HistoryStatistics get historyStatistics =>
    historyNotifier.getHistoryStatistics();

  /// Obtém estatísticas dos favoritos
  FavoritesStatistics get favoritesStatistics =>
    favoritesNotifier.getFavoritesStatistics();

  /// Atalho para executar cálculo rápido
  Future<bool> quickCalculate() => executeCalculationAndSave();
  
  /// Atalho para buscar por termo
  Future<void> search(String query) => searchCalculators(query: query);
  
  /// Atalho para filtrar por categoria
  Future<void> filterByCategory(CalculatorCategory category) => 
    searchCalculators(category: category);
}
