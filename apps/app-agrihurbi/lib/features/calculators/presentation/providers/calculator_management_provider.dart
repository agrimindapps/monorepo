import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/usecases/get_calculators.dart';

/// Provider especializado para gerenciamento de calculadoras
/// 
/// Responsabilidade única: CRUD e gerenciamento de estado de calculadoras
/// Seguindo Single Responsibility Principle
@singleton
class CalculatorManagementProvider extends ChangeNotifier {
  final GetCalculators _getCalculators;
  final GetCalculatorsByCategory _getCalculatorsByCategory;
  final GetCalculatorById _getCalculatorById;

  CalculatorManagementProvider({
    required GetCalculators getCalculators,
    required GetCalculatorsByCategory getCalculatorsByCategory,
    required GetCalculatorById getCalculatorById,
  })  : _getCalculators = getCalculators,
        _getCalculatorsByCategory = getCalculatorsByCategory,
        _getCalculatorById = getCalculatorById;

  // === STATE MANAGEMENT ===

  List<CalculatorEntity> _calculators = [];
  CalculatorEntity? _selectedCalculator;
  bool _isLoading = false;
  String? _errorMessage;

  // === GETTERS ===

  List<CalculatorEntity> get calculators => _calculators;
  CalculatorEntity? get selectedCalculator => _selectedCalculator;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  int get totalCalculators => _calculators.length;
  bool get hasSelectedCalculator => _selectedCalculator != null;
  
  /// Calculadoras por categoria
  List<CalculatorEntity> getCalculatorsByCategory(CalculatorCategory category) {
    return _calculators.where((calc) => calc.category == category).toList();
  }

  // === CALCULATOR MANAGEMENT OPERATIONS ===

  /// Carrega todas as calculadoras
  Future<void> loadCalculators() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getCalculators();
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('CalculatorManagementProvider: Erro ao carregar calculadoras - ${failure.message}');
      },
      (calculators) {
        _calculators = calculators;
        debugPrint('CalculatorManagementProvider: Calculadoras carregadas - ${calculators.length} itens');
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega calculadoras por categoria
  Future<void> loadCalculatorsByCategory(CalculatorCategory category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getCalculatorsByCategory(category);
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('CalculatorManagementProvider: Erro ao carregar calculadoras por categoria - ${failure.message}');
      },
      (calculators) {
        // Adiciona as calculadoras da categoria se não existirem
        for (final calculator in calculators) {
          if (!_calculators.any((c) => c.id == calculator.id)) {
            _calculators.add(calculator);
          }
        }
        debugPrint('CalculatorManagementProvider: Calculadoras da categoria ${category.name} carregadas - ${calculators.length} itens');
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
        debugPrint('CalculatorManagementProvider: Erro ao carregar calculadora - ${failure.message}');
      },
      (calculator) {
        _selectedCalculator = calculator;
        
        // Adiciona à lista se não existir
        if (!_calculators.any((c) => c.id == calculator.id)) {
          _calculators.add(calculator);
        }
        
        success = true;
        debugPrint('CalculatorManagementProvider: Calculadora carregada - ${calculator.id}');
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Seleciona uma calculadora
  void selectCalculator(CalculatorEntity? calculator) {
    _selectedCalculator = calculator;
    notifyListeners();
    debugPrint('CalculatorManagementProvider: Calculadora selecionada - ${calculator?.id ?? 'nenhuma'}');
  }

  /// Encontra calculadora por ID
  CalculatorEntity? findCalculatorById(String id) {
    try {
      return _calculators.firstWhere((calculator) => calculator.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se calculadora existe
  bool calculatorExists(String id) {
    return findCalculatorById(id) != null;
  }

  /// Obtém calculadoras de uma categoria específica
  List<CalculatorEntity> getCategoryCalculators(CalculatorCategory category) {
    return _calculators.where((calc) => calc.category == category).toList();
  }

  /// Obtém todas as categorias disponíveis
  Set<CalculatorCategory> getAvailableCategories() {
    return _calculators.map((calc) => calc.category).toSet();
  }

  /// Refresh completo das calculadoras
  Future<void> refreshCalculators() async {
    await loadCalculators();
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa seleção atual
  void clearSelection() {
    _selectedCalculator = null;
    notifyListeners();
  }

  /// Reset completo do estado
  void resetState() {
    _calculators.clear();
    _selectedCalculator = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('CalculatorManagementProvider: Disposed');
    super.dispose();
  }
}