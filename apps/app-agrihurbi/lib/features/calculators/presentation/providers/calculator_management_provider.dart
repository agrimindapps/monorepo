import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/usecases/get_calculators.dart';
import 'calculators_di_providers.dart';

part 'calculator_management_provider.g.dart';

/// State class for CalculatorManagement
class CalculatorManagementState {
  final List<CalculatorEntity> calculators;
  final CalculatorEntity? selectedCalculator;
  final bool isLoading;
  final String? errorMessage;

  const CalculatorManagementState({
    this.calculators = const [],
    this.selectedCalculator,
    this.isLoading = false,
    this.errorMessage,
  });

  CalculatorManagementState copyWith({
    List<CalculatorEntity>? calculators,
    CalculatorEntity? selectedCalculator,
    bool? isLoading,
    String? errorMessage,
    bool clearSelectedCalculator = false,
    bool clearError = false,
  }) {
    return CalculatorManagementState(
      calculators: calculators ?? this.calculators,
      selectedCalculator: clearSelectedCalculator ? null : (selectedCalculator ?? this.selectedCalculator),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  int get totalCalculators => calculators.length;
  bool get hasSelectedCalculator => selectedCalculator != null;

  List<CalculatorEntity> getCalculatorsByCategory(CalculatorCategory category) {
    return calculators.where((calc) => calc.category == category).toList();
  }

  Set<CalculatorCategory> get availableCategories {
    return calculators.map((calc) => calc.category).toSet();
  }
}

/// Provider especializado para gerenciamento de calculadoras
/// 
/// Responsabilidade única: CRUD e gerenciamento de estado de calculadoras
/// Seguindo Single Responsibility Principle
@riverpod
class CalculatorManagementNotifier extends _$CalculatorManagementNotifier {
  GetCalculators get _getCalculators => ref.read(getCalculatorsUseCaseProvider);
  GetCalculatorById get _getCalculatorById => ref.read(getCalculatorByIdUseCaseProvider);

  @override
  CalculatorManagementState build() {
    return const CalculatorManagementState();
  }

  // Convenience getters for backward compatibility
  List<CalculatorEntity> get calculators => state.calculators;
  CalculatorEntity? get selectedCalculator => state.selectedCalculator;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  int get totalCalculators => state.totalCalculators;
  bool get hasSelectedCalculator => state.hasSelectedCalculator;

  /// Calculadoras por categoria
  List<CalculatorEntity> getCalculatorsByCategory(CalculatorCategory category) {
    return state.getCalculatorsByCategory(category);
  }

  /// Carrega todas as calculadoras
  Future<void> loadCalculators() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getCalculators();
    
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        debugPrint('CalculatorManagementNotifier: Erro ao carregar calculadoras - ${failure.message}');
      },
      (loadedCalculators) {
        state = state.copyWith(
          calculators: loadedCalculators,
          isLoading: false,
        );
        debugPrint('CalculatorManagementNotifier: Calculadoras carregadas - ${loadedCalculators.length} itens');
      },
    );
  }

  /// Carrega calculadora por ID
  Future<bool> loadCalculatorById(String calculatorId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getCalculatorById(calculatorId);
    
    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        debugPrint('CalculatorManagementNotifier: Erro ao carregar calculadora - ${failure.message}');
      },
      (calculator) {
        final updatedCalculators = List<CalculatorEntity>.from(state.calculators);
        if (!updatedCalculators.any((c) => c.id == calculator.id)) {
          updatedCalculators.add(calculator);
        }
        
        state = state.copyWith(
          calculators: updatedCalculators,
          selectedCalculator: calculator,
          isLoading: false,
        );
        success = true;
        debugPrint('CalculatorManagementNotifier: Calculadora carregada - ${calculator.id}');
      },
    );

    return success;
  }

  /// Seleciona uma calculadora
  void selectCalculator(CalculatorEntity? calculator) {
    state = state.copyWith(
      selectedCalculator: calculator,
      clearSelectedCalculator: calculator == null,
    );
    debugPrint('CalculatorManagementNotifier: Calculadora selecionada - ${calculator?.id ?? 'nenhuma'}');
  }

  /// Encontra calculadora por ID
  CalculatorEntity? findCalculatorById(String id) {
    try {
      return state.calculators.firstWhere((calculator) => calculator.id == id);
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
    return state.calculators.where((calc) => calc.category == category).toList();
  }

  /// Obtém todas as categorias disponíveis
  Set<CalculatorCategory> getAvailableCategories() {
    return state.availableCategories;
  }

  /// Refresh completo das calculadoras
  Future<void> refreshCalculators() async {
    await loadCalculators();
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Limpa seleção atual
  void clearSelection() {
    state = state.copyWith(clearSelectedCalculator: true);
  }

  /// Reset completo do estado
  void resetState() {
    state = const CalculatorManagementState();
  }
}
