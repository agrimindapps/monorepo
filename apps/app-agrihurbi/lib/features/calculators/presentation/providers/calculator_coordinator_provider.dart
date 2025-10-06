import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/calculation_result.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import 'calculator_execution_provider.dart';
import 'calculator_favorites_provider.dart';
import 'calculator_history_provider.dart';
import 'calculator_management_provider.dart';
import 'calculator_search_provider.dart';

/// Provider coordenador que compõe funcionalidades de calculadoras
/// 
/// Responsabilidade única: Coordenar providers especializados seguindo SRP
/// Substitui o CalculatorProvider monolítico original de 450 linhas
@singleton
class CalculatorCoordinatorProvider extends ChangeNotifier {
  final CalculatorManagementProvider _managementProvider;
  final CalculatorExecutionProvider _executionProvider;
  final CalculatorHistoryProvider _historyProvider;
  final CalculatorFavoritesProvider _favoritesProvider;
  final CalculatorSearchProvider _searchProvider;

  CalculatorCoordinatorProvider({
    required CalculatorManagementProvider managementProvider,
    required CalculatorExecutionProvider executionProvider,
    required CalculatorHistoryProvider historyProvider,
    required CalculatorFavoritesProvider favoritesProvider,
    required CalculatorSearchProvider searchProvider,
  })  : _managementProvider = managementProvider,
        _executionProvider = executionProvider,
        _historyProvider = historyProvider,
        _favoritesProvider = favoritesProvider,
        _searchProvider = searchProvider {
    _initializeProviders();
  }
  
  CalculatorManagementProvider get managementProvider => _managementProvider;
  CalculatorExecutionProvider get executionProvider => _executionProvider;
  CalculatorHistoryProvider get historyProvider => _historyProvider;
  CalculatorFavoritesProvider get favoritesProvider => _favoritesProvider;
  CalculatorSearchProvider get searchProvider => _searchProvider;

  /// Verifica se alguma operação está em andamento
  bool get isAnyOperationInProgress =>
    _managementProvider.isLoading ||
    _executionProvider.isCalculating ||
    _historyProvider.isLoadingHistory ||
    _historyProvider.isSavingToHistory ||
    _favoritesProvider.isLoadingFavorites ||
    _favoritesProvider.isUpdatingFavorite ||
    _searchProvider.isSearching;

  /// Obtém mensagem de erro consolidada
  String? get consolidatedErrorMessage {
    final errors = <String>[];
    
    if (_managementProvider.errorMessage != null) {
      errors.add('Gerenciamento: ${_managementProvider.errorMessage}');
    }
    if (_executionProvider.errorMessage != null) {
      errors.add('Execução: ${_executionProvider.errorMessage}');
    }
    if (_historyProvider.errorMessage != null) {
      errors.add('Histórico: ${_historyProvider.errorMessage}');
    }
    if (_favoritesProvider.errorMessage != null) {
      errors.add('Favoritos: ${_favoritesProvider.errorMessage}');
    }
    if (_searchProvider.errorMessage != null) {
      errors.add('Busca: ${_searchProvider.errorMessage}');
    }
    
    return errors.isEmpty ? null : errors.join('\n');
  }

  /// Lista de calculadoras com filtros aplicados
  List<CalculatorEntity> get filteredCalculators {
    return _searchProvider.applyFilters(_managementProvider.calculators);
  }

  /// Lista de calculadoras favoritas
  List<CalculatorEntity> get favoriteCalculators {
    return _favoritesProvider.getFavoriteCalculators(_managementProvider.calculators);
  }

  /// Calculadora atualmente selecionada/ativa
  CalculatorEntity? get selectedCalculator => 
    _managementProvider.selectedCalculator ?? _executionProvider.activeCalculator;

  /// Resultado do último cálculo
  CalculationResult? get currentCalculationResult => _executionProvider.currentResult;

  /// Inicialização completa do sistema de calculadoras
  Future<void> initializeSystem() async {
    debugPrint('CalculatorCoordinatorProvider: Inicializando sistema de calculadoras');
    
    await Future.wait([
      _managementProvider.loadCalculators(),
      _historyProvider.loadCalculationHistory(),
      _favoritesProvider.loadFavorites(),
    ]);
    
    debugPrint('CalculatorCoordinatorProvider: Sistema de calculadoras inicializado');
  }

  /// Seleciona e prepara calculadora para uso
  Future<bool> selectAndPrepareCalculator(String calculatorId) async {
    debugPrint('CalculatorCoordinatorProvider: Selecionando calculadora - $calculatorId');
    final loadSuccess = await _managementProvider.loadCalculatorById(calculatorId);
    if (!loadSuccess) return false;
    final calculator = _managementProvider.selectedCalculator;
    if (calculator == null) return false;
    _executionProvider.setActiveCalculator(calculator);
    
    debugPrint('CalculatorCoordinatorProvider: Calculadora selecionada e preparada - $calculatorId');
    return true;
  }

  /// Executa cálculo completo com salvamento no histórico
  Future<bool> executeCalculationAndSave({
    String? notes,
    bool saveToHistory = true,
  }) async {
    debugPrint('CalculatorCoordinatorProvider: Executando cálculo completo');
    
    final calculator = selectedCalculator;
    if (calculator == null) {
      debugPrint('CalculatorCoordinatorProvider: Nenhuma calculadora selecionada');
      return false;
    }
    final executionSuccess = await _executionProvider.executeCalculation();
    if (!executionSuccess) return false;
    if (saveToHistory && _executionProvider.currentResult != null) {
      await _historyProvider.saveToHistory(
        calculatorId: calculator.id,
        calculatorName: calculator.name,
        result: _executionProvider.currentResult!,
        notes: notes,
      );
    }
    
    debugPrint('CalculatorCoordinatorProvider: Cálculo completo executado com sucesso');
    return true;
  }

  /// Aplica resultado do histórico e prepara para novo cálculo
  void applyHistoryResult(String historyId) {
    final historyItem = _historyProvider.calculationHistory
        .where((item) => item.id == historyId)
        .firstOrNull;
    
    if (historyItem == null) return;
    _managementProvider.selectCalculator(
      _managementProvider.findCalculatorById(historyItem.calculatorId)
    );
    _executionProvider.applyPreviousResult(historyItem.result);
    
    debugPrint('CalculatorCoordinatorProvider: Resultado do histórico aplicado - $historyId');
  }

  /// Busca calculadoras com filtros
  Future<void> searchCalculators({
    String? query,
    CalculatorCategory? category,
  }) async {
    if (query != null) {
      _searchProvider.updateSearchQuery(query);
    }
    if (category != null) {
      _searchProvider.updateCategoryFilter(category);
    }

    await _searchProvider.searchAndFilter(_managementProvider.calculators);
  }

  /// Alterna status de favorito da calculadora atual
  Future<bool> toggleCurrentCalculatorFavorite() async {
    final calculator = selectedCalculator;
    if (calculator == null) return false;

    return await _favoritesProvider.toggleFavorite(calculator.id);
  }

  /// Refresh completo de todos os dados
  Future<void> refreshAllData() async {
    debugPrint('CalculatorCoordinatorProvider: Atualizando todos os dados');
    
    await Future.wait([
      _managementProvider.refreshCalculators(),
      _historyProvider.refreshHistory(),
      _favoritesProvider.refreshFavorites(),
    ]);
    
    debugPrint('CalculatorCoordinatorProvider: Todos os dados atualizados');
  }

  /// Limpa todos os erros dos providers especializados
  void clearAllErrors() {
    _managementProvider.clearError();
    _executionProvider.clearError();
    _historyProvider.clearError();
    _favoritesProvider.clearError();
    _searchProvider.clearError();
    
    debugPrint('CalculatorCoordinatorProvider: Todos os erros limpos');
  }

  /// Reset completo do sistema
  void resetSystem() {
    _managementProvider.resetState();
    _executionProvider.resetState();
    _historyProvider.resetState();
    _favoritesProvider.resetState();
    _searchProvider.resetState();
    
    debugPrint('CalculatorCoordinatorProvider: Sistema resetado');
  }

  /// Verifica se calculadora é favorita
  bool isCalculatorFavorite(String calculatorId) =>
    _favoritesProvider.isCalculatorFavorite(calculatorId);

  /// Obtém calculadoras por categoria
  List<CalculatorEntity> getCalculatorsByCategory(CalculatorCategory category) =>
    _managementProvider.getCalculatorsByCategory(category);

  /// Obtém estatísticas do histórico
  HistoryStatistics get historyStatistics =>
    _historyProvider.getHistoryStatistics();

  /// Obtém estatísticas dos favoritos
  FavoritesStatistics get favoritesStatistics =>
    _favoritesProvider.getFavoritesStatistics();

  void _initializeProviders() {
    _managementProvider.addListener(_onProviderChanged);
    _executionProvider.addListener(_onProviderChanged);
    _historyProvider.addListener(_onProviderChanged);
    _favoritesProvider.addListener(_onProviderChanged);
    _searchProvider.addListener(_onProviderChanged);
    
    debugPrint('CalculatorCoordinatorProvider: Providers especializados inicializados');
  }

  void _onProviderChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _managementProvider.removeListener(_onProviderChanged);
    _executionProvider.removeListener(_onProviderChanged);
    _historyProvider.removeListener(_onProviderChanged);
    _favoritesProvider.removeListener(_onProviderChanged);
    _searchProvider.removeListener(_onProviderChanged);
    
    debugPrint('CalculatorCoordinatorProvider: Disposed - listeners removidos');
    super.dispose();
  }
}

/// Extensão para facilitar acesso às operações mais comuns
extension CalculatorCoordinatorProviderExtension on CalculatorCoordinatorProvider {
  /// Atalho para executar cálculo rápido
  Future<bool> quickCalculate() => executeCalculationAndSave();
  
  /// Atalho para buscar por termo
  Future<void> search(String query) => searchCalculators(query: query);
  
  /// Atalho para filtrar por categoria
  Future<void> filterByCategory(CalculatorCategory category) => 
    searchCalculators(category: category);
}