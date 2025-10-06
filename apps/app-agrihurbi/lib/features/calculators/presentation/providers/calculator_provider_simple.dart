import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/usecases/execute_calculation.dart';
import '../../domain/usecases/get_calculators.dart';
import '../../domain/usecases/manage_calculation_history.dart';

/// Provider Riverpod para CalculatorProvider
final calculatorProvider = ChangeNotifierProvider<CalculatorProvider>((ref) {
  return di.getIt<CalculatorProvider>();
});

/// Provider simplificado para gerenciamento de estado das calculadoras
///
/// Implementa funcionalidades básicas sem complexidade excessiva
/// Segue o padrão Provider estabelecido na migração livestock
@singleton
class CalculatorProvider extends ChangeNotifier {
  final GetCalculators _getCalculators;
  final GetCalculatorById _getCalculatorById;
  final ExecuteCalculation _executeCalculation;
  final GetCalculationHistory _getCalculationHistory;

  CalculatorProvider({
    required GetCalculators getCalculators,
    required GetCalculatorById getCalculatorById,
    required ExecuteCalculation executeCalculation,
    required GetCalculationHistory getCalculationHistory,
  }) : _getCalculators = getCalculators,
       _getCalculatorById = getCalculatorById,
       _executeCalculation = executeCalculation,
       _getCalculationHistory = getCalculationHistory;

  /// Estados de loading
  bool _isLoading = false;
  bool _isCalculating = false;
  bool _isLoadingHistory = false;

  /// Dados das calculadoras
  List<CalculatorEntity> _calculators = [];
  List<CalculatorEntity> _filteredCalculators = [];
  CalculatorEntity? _selectedCalculator;

  /// Filtros e busca
  String _searchQuery = '';
  CalculatorCategory? _selectedCategory;

  /// Resultados e histórico
  CalculationResult? _currentResult;
  List<CalculationHistory> _calculationHistory = [];

  /// Estado do cálculo atual
  Map<String, dynamic> _currentInputs = {};

  /// Erro handling
  String? _errorMessage;

  /// Favoritos armazenados por ID
  final Set<String> _favoriteIds = {};

  bool get isLoading => _isLoading;
  bool get isCalculating => _isCalculating;
  bool get isLoadingHistory => _isLoadingHistory;

  List<CalculatorEntity> get calculators => _calculators;
  List<CalculatorEntity> get filteredCalculators => _filteredCalculators;
  CalculatorEntity? get selectedCalculator => _selectedCalculator;

  String get searchQuery => _searchQuery;
  CalculatorCategory? get selectedCategory => _selectedCategory;

  CalculationResult? get currentResult => _currentResult;
  List<CalculationHistory> get calculationHistory => _calculationHistory;
  Map<String, dynamic> get currentInputs => _currentInputs;

  String? get errorMessage => _errorMessage;

  /// Calculadoras por categoria
  List<CalculatorEntity> getCalculatorsByCategory(CalculatorCategory category) {
    return _filteredCalculators
        .where((calc) => calc.category == category)
        .toList();
  }

  /// Estatísticas
  int get totalCalculators => _calculators.length;
  int get totalFilteredCalculators => _filteredCalculators.length;
  int get totalHistoryItems => _calculationHistory.length;

  /// Carrega todas as calculadoras
  Future<void> loadCalculators() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getCalculators();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint(
          'CalculatorProvider: Erro ao carregar calculadoras - ${failure.message}',
        );
      },
      (calculators) {
        _calculators = calculators;
        _applyFilters();
        debugPrint(
          'CalculatorProvider: Calculadoras carregadas - ${calculators.length} itens',
        );
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega calculadora por ID
  Future<bool> loadCalculatorById(String calculatorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getCalculatorById(calculatorId);

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint(
          'CalculatorProvider: Erro ao carregar calculadora - ${failure.message}',
        );
      },
      (calculator) {
        _selectedCalculator = calculator;
        _currentInputs = {};
        _currentResult = null;
        success = true;
        debugPrint(
          'CalculatorProvider: Calculadora carregada - ${calculator.id}',
        );
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Seleciona uma calculadora
  void selectCalculator(CalculatorEntity? calculator) {
    _selectedCalculator = calculator;
    _currentInputs = {};
    _currentResult = null;
    notifyListeners();
    debugPrint(
      'CalculatorProvider: Calculadora selecionada - ${calculator?.id ?? 'nenhuma'}',
    );
  }

  /// Atualiza input de cálculo
  void updateInput(String parameterId, dynamic value) {
    _currentInputs[parameterId] = value;
    notifyListeners();
  }

  /// Atualiza múltiplos inputs
  void updateInputs(Map<String, dynamic> inputs) {
    _currentInputs.addAll(inputs);
    notifyListeners();
  }

  /// Limpa inputs atuais
  void clearInputs() {
    _currentInputs.clear();
    _currentResult = null;
    notifyListeners();
  }

  /// Executa cálculo na calculadora selecionada
  Future<bool> executeCurrentCalculation() async {
    if (_selectedCalculator == null) {
      _errorMessage = 'Nenhuma calculadora selecionada';
      notifyListeners();
      return false;
    }

    _isCalculating = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _executeCalculation(
      _selectedCalculator!.id,
      _currentInputs,
    );

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('CalculatorProvider: Erro no cálculo - ${failure.message}');
      },
      (calculationResult) {
        _currentResult = calculationResult;
        success = true;
        debugPrint('CalculatorProvider: Cálculo executado com sucesso');
      },
    );

    _isCalculating = false;
    notifyListeners();
    return success;
  }

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
    debugPrint('CalculatorProvider: Query de busca atualizada - "$query"');
  }

  /// Atualiza filtro de categoria
  void updateCategoryFilter(CalculatorCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
    debugPrint(
      'CalculatorProvider: Categoria filtrada - ${category?.name ?? 'todas'}',
    );
  }

  /// Limpa todos os filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _applyFilters();
    notifyListeners();
    debugPrint('CalculatorProvider: Filtros limpos');
  }

  /// Aplica filtros à lista de calculadoras
  void _applyFilters() {
    var filtered = List<CalculatorEntity>.from(_calculators);
    if (_selectedCategory != null) {
      filtered =
          filtered.where((calc) => calc.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered
              .where(
                (calc) =>
                    calc.name.toLowerCase().contains(query) ||
                    calc.description.toLowerCase().contains(query),
              )
              .toList();
    }

    _filteredCalculators = filtered;
  }

  /// Carrega histórico de cálculos
  Future<void> loadCalculationHistory() async {
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getCalculationHistory();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint(
          'CalculatorProvider: Erro ao carregar histórico - ${failure.message}',
        );
      },
      (history) {
        _calculationHistory = history;
        debugPrint(
          'CalculatorProvider: Histórico carregado - ${history.length} itens',
        );
      },
    );

    _isLoadingHistory = false;
    notifyListeners();
  }

  /// Remove item do histórico (simulação)
  Future<bool> removeFromHistory(String historyId) async {
    _calculationHistory.removeWhere((item) => item.id == historyId);
    notifyListeners();
    debugPrint('CalculatorProvider: Item removido do histórico - $historyId');
    return true;
  }

  /// Limpa todo o histórico (simulação)
  Future<bool> clearHistory() async {
    _calculationHistory.clear();
    notifyListeners();
    debugPrint('CalculatorProvider: Histórico limpo');
    return true;
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh completo dos dados
  Future<void> refreshAllData() async {
    await Future.wait([loadCalculators(), loadCalculationHistory()]);
  }

  /// Reaplica resultado de cálculo do histórico
  void applyHistoryResult(CalculationHistory historyItem) {
    _currentResult = historyItem.result;
    _currentInputs = Map<String, dynamic>.from(historyItem.result.inputs);
    try {
      final calculator = _calculators.firstWhere(
        (calc) => calc.id == historyItem.calculatorId,
      );
      _selectedCalculator = calculator;
    } catch (e) {
      debugPrint(
        'CalculatorProvider: Calculadora do histórico não encontrada - ${historyItem.calculatorId}',
      );
    }

    notifyListeners();
    debugPrint(
      'CalculatorProvider: Resultado do histórico aplicado - ${historyItem.id}',
    );
  }

  /// Verifica se a calculadora está marcada como favorita
  bool isCalculatorFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  /// Alterna o estado de favorito para a calculadora
  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('CalculatorProvider: Disposed');
    super.dispose();
  }
}
