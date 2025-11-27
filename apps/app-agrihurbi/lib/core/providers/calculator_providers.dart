import 'package:core/core.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../../core/di/injection_container.dart' as di; // Commented out - migrating to Riverpod
import '../../features/calculators/domain/entities/calculation_history.dart';
import '../../features/calculators/domain/entities/calculation_result.dart';
import '../../features/calculators/domain/entities/calculation_template.dart';
import '../../features/calculators/domain/entities/calculator_category.dart';
import '../../features/calculators/domain/entities/calculator_entity.dart';
import '../../features/calculators/domain/services/calculator_favorites_service.dart';
import '../../features/calculators/domain/services/calculator_template_service.dart';
import '../../features/calculators/domain/usecases/execute_calculation.dart';
import '../../features/calculators/domain/usecases/get_calculators.dart';
import '../../features/calculators/domain/usecases/manage_calculation_history.dart';
import '../../features/calculators/domain/usecases/manage_favorites.dart';
import '../../features/calculators/domain/usecases/save_calculation_to_history.dart';

part 'calculator_providers.g.dart';

/// State principal para gerenciamento de calculadoras
class CalculatorState {
  const CalculatorState({
    this.calculators = const [],
    this.filteredCalculators = const [],
    this.selectedCalculator,
    this.isLoading = false,
    this.isCalculating = false,
    this.isLoadingHistory = false,
    this.isLoadingFavorites = false,
    this.searchQuery = '',
    this.selectedCategory,
    this.currentResult,
    this.calculationHistory = const [],
    this.favoriteCalculatorIds = const [],
    this.currentInputs = const {},
    this.errorMessage,
  });

  final List<CalculatorEntity> calculators;
  final List<CalculatorEntity> filteredCalculators;
  final CalculatorEntity? selectedCalculator;
  final bool isLoading;
  final bool isCalculating;
  final bool isLoadingHistory;
  final bool isLoadingFavorites;
  final String searchQuery;
  final CalculatorCategory? selectedCategory;
  final CalculationResult? currentResult;
  final List<CalculationHistory> calculationHistory;
  final List<String> favoriteCalculatorIds;
  final Map<String, dynamic> currentInputs;
  final String? errorMessage;
  List<CalculatorEntity> getCalculatorsByCategory(CalculatorCategory category) {
    return filteredCalculators
        .where((calc) => calc.category == category)
        .toList();
  }

  List<CalculatorEntity> get favoriteCalculators {
    return filteredCalculators
        .where((calc) => favoriteCalculatorIds.contains(calc.id))
        .toList();
  }

  int get totalCalculators => calculators.length;
  int get totalFilteredCalculators => filteredCalculators.length;
  int get totalFavorites => favoriteCalculatorIds.length;
  int get totalHistoryItems => calculationHistory.length;

  bool isCalculatorFavorite(String calculatorId) {
    return favoriteCalculatorIds.contains(calculatorId);
  }

  bool get hasError => errorMessage != null;
  bool get hasSelectedCalculator => selectedCalculator != null;
  bool get hasCurrentResult => currentResult != null;
  bool get hasInputs => currentInputs.isNotEmpty;

  CalculatorState copyWith({
    List<CalculatorEntity>? calculators,
    List<CalculatorEntity>? filteredCalculators,
    CalculatorEntity? selectedCalculator,
    bool? isLoading,
    bool? isCalculating,
    bool? isLoadingHistory,
    bool? isLoadingFavorites,
    String? searchQuery,
    CalculatorCategory? selectedCategory,
    CalculationResult? currentResult,
    List<CalculationHistory>? calculationHistory,
    List<String>? favoriteCalculatorIds,
    Map<String, dynamic>? currentInputs,
    String? errorMessage,
  }) {
    return CalculatorState(
      calculators: calculators ?? this.calculators,
      filteredCalculators: filteredCalculators ?? this.filteredCalculators,
      selectedCalculator: selectedCalculator ?? this.selectedCalculator,
      isLoading: isLoading ?? this.isLoading,
      isCalculating: isCalculating ?? this.isCalculating,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentResult: currentResult ?? this.currentResult,
      calculationHistory: calculationHistory ?? this.calculationHistory,
      favoriteCalculatorIds:
          favoriteCalculatorIds ?? this.favoriteCalculatorIds,
      currentInputs: currentInputs ?? this.currentInputs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// State para execução de cálculos
class CalculatorExecutionState {
  const CalculatorExecutionState({
    this.isCalculating = false,
    this.currentResult,
    this.currentInputs = const {},
    this.activeCalculator,
    this.errorMessage,
  });

  final bool isCalculating;
  final CalculationResult? currentResult;
  final Map<String, dynamic> currentInputs;
  final CalculatorEntity? activeCalculator;
  final String? errorMessage;

  bool get hasResult => currentResult != null;
  bool get hasInputs => currentInputs.isNotEmpty;
  bool get canExecute => activeCalculator != null && currentInputs.isNotEmpty;
  bool get hasError => errorMessage != null;

  bool hasInput(String parameterId) => currentInputs.containsKey(parameterId);
  T? getInput<T>(String parameterId) => currentInputs[parameterId] as T?;

  CalculatorExecutionState copyWith({
    bool? isCalculating,
    CalculationResult? currentResult,
    Map<String, dynamic>? currentInputs,
    CalculatorEntity? activeCalculator,
    String? errorMessage,
  }) {
    return CalculatorExecutionState(
      isCalculating: isCalculating ?? this.isCalculating,
      currentResult: currentResult ?? this.currentResult,
      currentInputs: currentInputs ?? this.currentInputs,
      activeCalculator: activeCalculator ?? this.activeCalculator,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// State para funcionalidades avançadas das calculadoras
class CalculatorFeaturesState {
  const CalculatorFeaturesState({
    this.favoriteIds = const [],
    this.isLoadingFavorites = false,
    this.templates = const [],
    this.filteredTemplates = const [],
    this.isLoadingTemplates = false,
    this.templateSearchQuery = '',
    this.errorMessage,
  });

  final List<String> favoriteIds;
  final bool isLoadingFavorites;
  final List<CalculationTemplate> templates;
  final List<CalculationTemplate> filteredTemplates;
  final bool isLoadingTemplates;
  final String templateSearchQuery;
  final String? errorMessage;

  bool isFavorite(String calculatorId) => favoriteIds.contains(calculatorId);
  bool get hasError => errorMessage != null;
  int get totalFavorites => favoriteIds.length;
  int get totalTemplates => templates.length;

  CalculatorFeaturesState copyWith({
    List<String>? favoriteIds,
    bool? isLoadingFavorites,
    List<CalculationTemplate>? templates,
    List<CalculationTemplate>? filteredTemplates,
    bool? isLoadingTemplates,
    String? templateSearchQuery,
    String? errorMessage,
  }) {
    return CalculatorFeaturesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
      templates: templates ?? this.templates,
      filteredTemplates: filteredTemplates ?? this.filteredTemplates,
      isLoadingTemplates: isLoadingTemplates ?? this.isLoadingTemplates,
      templateSearchQuery: templateSearchQuery ?? this.templateSearchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier principal para gerenciamento de calculadoras
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
    return const CalculatorState();
  }

  /// Carrega todas as calculadoras
  Future<void> loadCalculators() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getCalculators();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (calculators) {
        state = state.copyWith(isLoading: false, calculators: calculators);
        _applyFilters();
      },
    );
  }

  /// Carrega calculadora por ID
  Future<bool> loadCalculatorById(String calculatorId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getCalculatorById(calculatorId);

    bool success = false;
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (calculator) {
        state = state.copyWith(
          isLoading: false,
          selectedCalculator: calculator,
          currentInputs: {},
          currentResult: null,
        );
        success = true;
      },
    );

    return success;
  }

  /// Seleciona uma calculadora
  void selectCalculator(CalculatorEntity? calculator) {
    state = state.copyWith(
      selectedCalculator: calculator,
      currentInputs: {},
      currentResult: null,
    );
  }

  /// Atualiza input de cálculo
  void updateInput(String parameterId, dynamic value) {
    final newInputs = Map<String, dynamic>.from(state.currentInputs);
    newInputs[parameterId] = value;

    state = state.copyWith(currentInputs: newInputs);
  }

  /// Atualiza múltiplos inputs
  void updateInputs(Map<String, dynamic> inputs) {
    final newInputs = Map<String, dynamic>.from(state.currentInputs);
    newInputs.addAll(inputs);

    state = state.copyWith(currentInputs: newInputs);
  }

  /// Limpa inputs atuais
  void clearInputs() {
    state = state.copyWith(currentInputs: {}, currentResult: null);
  }

  /// Executa cálculo na calculadora selecionada
  Future<bool> executeCurrentCalculation() async {
    if (state.selectedCalculator == null) {
      state = state.copyWith(errorMessage: 'Nenhuma calculadora selecionada');
      return false;
    }

    state = state.copyWith(isCalculating: true, errorMessage: null);

    final result = await _executeCalculation.execute(
      ExecuteCalculationParams(
        calculatorId: state.selectedCalculator!.id,
        inputs: state.currentInputs,
      ),
    );

    bool success = false;
    result.fold(
      (failure) => state = state.copyWith(
        isCalculating: false,
        errorMessage: failure.message,
      ),
      (calculationResult) {
        state = state.copyWith(
          isCalculating: false,
          currentResult: calculationResult,
        );
        success = true;
        if (calculationResult.isValid) {
          _saveToHistory(calculationResult);
        }
      },
    );

    return success;
  }

  /// Salva resultado no histórico
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

    saveResult.fold((failure) {}, (_) {
      final newHistory = [historyItem, ...state.calculationHistory];
      state = state.copyWith(calculationHistory: newHistory);
    });
  }

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Atualiza filtro de categoria
  void updateCategoryFilter(CalculatorCategory? category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  /// Limpa todos os filtros
  void clearFilters() {
    state = state.copyWith(searchQuery: '', selectedCategory: null);
    _applyFilters();
  }

  /// Aplica filtros à lista de calculadoras
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

  /// Carrega histórico de cálculos
  Future<void> loadCalculationHistory() async {
    state = state.copyWith(isLoadingHistory: true, errorMessage: null);

    final result = await _getCalculationHistory.call();

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: failure.message,
      ),
      (history) => state = state.copyWith(
        isLoadingHistory: false,
        calculationHistory: history,
      ),
    );
  }

  /// Remove item do histórico
  Future<bool> removeFromHistory(String historyId) async {
    final newHistory =
        state.calculationHistory.where((item) => item.id != historyId).toList();

    state = state.copyWith(calculationHistory: newHistory);
    return true;
  }

  Future<bool> clearHistory() async {
    state = state.copyWith(calculationHistory: []);
    return true;
  }

  /// Carrega favoritos
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoadingFavorites: true);

    final result = await _manageFavorites.call(const GetFavoritesParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingFavorites: false,
        errorMessage: failure.message,
      ),
      (favorites) {
        final favoriteIds =
            favorites is List ? List<String>.from(favorites) : <String>[];
        state = state.copyWith(
          isLoadingFavorites: false,
          favoriteCalculatorIds: favoriteIds,
        );
      },
    );
  }

  /// Adiciona/remove favorito
  Future<bool> toggleFavorite(String calculatorId) async {
    final isFavorite = state.favoriteCalculatorIds.contains(calculatorId);

    final result = await _manageFavorites.call(
      isFavorite
          ? RemoveFavoriteParams(calculatorId)
          : AddFavoriteParams(calculatorId),
    );

    bool success = false;
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        final newFavorites = List<String>.from(state.favoriteCalculatorIds);
        if (isFavorite) {
          newFavorites.remove(calculatorId);
        } else {
          newFavorites.add(calculatorId);
        }
        state = state.copyWith(favoriteCalculatorIds: newFavorites);
        success = true;
      },
    );

    return success;
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Refresh completo dos dados
  Future<void> refreshAllData() async {
    await Future.wait([
      loadCalculators(),
      loadCalculationHistory(),
      loadFavorites(),
    ]);
  }

  /// Reaplica resultado de cálculo do histórico
  void applyHistoryResult(CalculationHistory historyItem) {
    CalculatorEntity? calculator;
    try {
      calculator = state.calculators.firstWhere(
        (calc) => calc.id == historyItem.calculatorId,
      );
    } catch (e) {
      calculator =
          state.calculators.isNotEmpty ? state.calculators.first : null;
    }

    state = state.copyWith(
      currentResult: historyItem.result,
      currentInputs: Map<String, dynamic>.from(historyItem.result.inputs),
      selectedCalculator: calculator,
    );
  }
}

/// Notifier para execução de cálculos
@riverpod
class CalculatorExecutionNotifier extends _$CalculatorExecutionNotifier {
  late final ExecuteCalculation _executeCalculation;

  @override
  CalculatorExecutionState build() {
    return const CalculatorExecutionState();
  }

  /// Define calculadora ativa
  void setActiveCalculator(CalculatorEntity? calculator) {
    if (calculator == null || state.activeCalculator?.id != calculator.id) {
      state = const CalculatorExecutionState();
    }

    state = state.copyWith(activeCalculator: calculator);
  }

  /// Atualiza input de cálculo
  void updateInput(String parameterId, dynamic value) {
    final newInputs = Map<String, dynamic>.from(state.currentInputs);
    newInputs[parameterId] = value;

    state = state.copyWith(
      currentInputs: newInputs,
      currentResult: null, // Limpa resultado ao alterar inputs
    );
  }

  /// Atualiza múltiplos inputs
  void updateInputs(Map<String, dynamic> inputs) {
    final newInputs = Map<String, dynamic>.from(state.currentInputs);
    newInputs.addAll(inputs);

    state = state.copyWith(
      currentInputs: newInputs,
      currentResult: null, // Limpa resultado ao alterar inputs
    );
  }

  /// Remove um input específico
  void removeInput(String parameterId) {
    final newInputs = Map<String, dynamic>.from(state.currentInputs);
    if (newInputs.remove(parameterId) != null) {
      state = state.copyWith(
        currentInputs: newInputs,
        currentResult: null, // Limpa resultado ao remover input
      );
    }
  }

  /// Limpa todos os inputs
  void clearInputs() {
    state = state.copyWith(currentInputs: {}, currentResult: null);
  }

  /// Limpa resultado atual
  void clearResult() {
    state = state.copyWith(currentResult: null);
  }

  /// Executa cálculo com a calculadora ativa
  Future<bool> executeCalculation() async {
    if (state.activeCalculator == null) {
      state = state.copyWith(
        errorMessage: 'Nenhuma calculadora ativa definida',
      );
      return false;
    }

    return await executeCalculationWithCalculator(state.activeCalculator!);
  }

  /// Executa cálculo com calculadora específica
  Future<bool> executeCalculationWithCalculator(
    CalculatorEntity calculator,
  ) async {
    state = state.copyWith(
      isCalculating: true,
      errorMessage: null,
      activeCalculator: calculator,
    );

    final result = await _executeCalculation.execute(
      ExecuteCalculationParams(
        calculatorId: calculator.id,
        inputs: state.currentInputs,
      ),
    );

    bool success = false;
    result.fold(
      (failure) => state = state.copyWith(
        isCalculating: false,
        errorMessage: failure.message,
      ),
      (calculationResult) {
        state = state.copyWith(
          isCalculating: false,
          currentResult: calculationResult,
        );
        success = true;
      },
    );

    return success;
  }

  /// Executa cálculo rápido com inputs específicos
  Future<CalculationResult?> quickCalculation(
    CalculatorEntity calculator,
    Map<String, dynamic> inputs,
  ) async {
    final result = await _executeCalculation.execute(
      ExecuteCalculationParams(calculatorId: calculator.id, inputs: inputs),
    );

    return result.fold(
      (failure) => null,
      (calculationResult) => calculationResult,
    );
  }

  /// Aplica resultado de cálculo anterior
  void applyPreviousResult(CalculationResult result) {
    state = state.copyWith(
      currentResult: result,
      currentInputs: Map<String, dynamic>.from(result.inputs),
    );
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset completo do estado
  void resetState() {
    state = const CalculatorExecutionState();
  }
}

/// Notifier para funcionalidades avançadas das calculadoras
@riverpod
class CalculatorFeaturesNotifier extends _$CalculatorFeaturesNotifier {
  late final CalculatorFavoritesService _favoritesService;
  late final CalculatorTemplateService _templateService;

  @override
  CalculatorFeaturesState build() {
    return const CalculatorFeaturesState();
  }

  /// Inicializa os serviços
  Future<void> initialize() async {
    await Future.wait([loadFavorites(), loadTemplates()]);
  }

  /// Carrega lista de favoritos
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoadingFavorites: true, errorMessage: null);

    try {
      final favoriteIds = await _favoritesService.getFavoriteIds();
      state = state.copyWith(
        isLoadingFavorites: false,
        favoriteIds: favoriteIds,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingFavorites: false,
        errorMessage: 'Erro ao carregar favoritos: ${e.toString()}',
      );
    }
  }

  /// Alterna status de favorito
  Future<bool> toggleFavorite(String calculatorId) async {
    try {
      final success = await _favoritesService.toggleFavorite(calculatorId);
      if (success) {
        await loadFavorites(); // Recarrega lista
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao alterar favorito: ${e.toString()}',
      );
      return false;
    }
  }

  /// Adiciona calculadora aos favoritos
  Future<bool> addToFavorites(String calculatorId) async {
    try {
      final success = await _favoritesService.addToFavorites(calculatorId);
      if (success) {
        await loadFavorites();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao adicionar favorito: ${e.toString()}',
      );
      return false;
    }
  }

  /// Remove calculadora dos favoritos
  Future<bool> removeFromFavorites(String calculatorId) async {
    try {
      final success = await _favoritesService.removeFromFavorites(calculatorId);
      if (success) {
        await loadFavorites();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao remover favorito: ${e.toString()}',
      );
      return false;
    }
  }

  /// Carrega todos os templates
  Future<void> loadTemplates() async {
    state = state.copyWith(isLoadingTemplates: true, errorMessage: null);

    try {
      final templates = await _templateService.getAllTemplates();
      state = state.copyWith(isLoadingTemplates: false, templates: templates);
      _applyTemplateFilters();
    } catch (e) {
      state = state.copyWith(
        isLoadingTemplates: false,
        errorMessage: 'Erro ao carregar templates: ${e.toString()}',
      );
    }
  }

  /// Carrega templates de uma calculadora específica
  Future<List<CalculationTemplate>> getTemplatesForCalculator(
    String calculatorId,
  ) async {
    try {
      return await _templateService.getTemplatesForCalculator(calculatorId);
    } catch (e) {
      return [];
    }
  }

  /// Salva novo template
  Future<bool> saveTemplate(CalculationTemplate template) async {
    try {
      final success = await _templateService.saveTemplate(template);
      if (success) {
        await loadTemplates(); // Recarrega lista
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao salvar template: ${e.toString()}',
      );
      return false;
    }
  }

  /// Remove template
  Future<bool> deleteTemplate(String templateId) async {
    try {
      final success = await _templateService.deleteTemplate(templateId);
      if (success) {
        await loadTemplates(); // Recarrega lista
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao remover template: ${e.toString()}',
      );
      return false;
    }
  }

  /// Marca template como usado
  Future<bool> markTemplateAsUsed(String templateId) async {
    try {
      final success = await _templateService.markTemplateAsUsed(templateId);
      if (success) {
        final templates = List<CalculationTemplate>.from(state.templates);
        final templateIndex = templates.indexWhere((t) => t.id == templateId);
        if (templateIndex != -1) {
          templates[templateIndex] = templates[templateIndex].markAsUsed();
          state = state.copyWith(templates: templates);
          _applyTemplateFilters();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Busca templates
  void searchTemplates(String query) {
    state = state.copyWith(templateSearchQuery: query);
    _applyTemplateFilters();
  }

  /// Aplica filtros aos templates
  void _applyTemplateFilters() {
    var filtered = List<CalculationTemplate>.from(state.templates);
    if (state.templateSearchQuery.isNotEmpty) {
      final query = state.templateSearchQuery.toLowerCase();
      filtered = filtered
          .where(
            (template) =>
                template.name.toLowerCase().contains(query) ||
                (template.description?.toLowerCase() ?? '').contains(
                  query,
                ) ||
                template.tags.any(
                  (tag) => tag.toLowerCase().contains(query),
                ),
          )
          .toList();
    }
    filtered.sort((a, b) {
      if (a.lastUsed != null && b.lastUsed == null) return -1;
      if (a.lastUsed == null && b.lastUsed != null) return 1;
      if (a.lastUsed != null && b.lastUsed != null) {
        return b.lastUsed!.compareTo(a.lastUsed!);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    state = state.copyWith(filteredTemplates: filtered);
  }

  /// Obtém templates recentes
  Future<List<CalculationTemplate>> getRecentTemplates({int limit = 5}) async {
    try {
      return await _templateService.getRecentTemplates(limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Obtém templates populares
  Future<List<CalculationTemplate>> getPopularTemplates({int limit = 5}) async {
    try {
      return await _templateService.getPopularTemplates(limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Limpa filtros de templates
  void clearTemplateFilters() {
    state = state.copyWith(templateSearchQuery: '');
    _applyTemplateFilters();
  }

  /// Refresh completo dos dados
  Future<void> refreshAllData() async {
    await Future.wait([loadFavorites(), loadTemplates()]);
  }
}

/// Provider para lista filtrada de calculadoras
@riverpod
List<CalculatorEntity> filteredCalculators(Ref ref) {
  final state = ref.watch(calculatorProvider);
  return state.filteredCalculators;
}

/// Provider para calculadoras favoritas
@riverpod
List<CalculatorEntity> favoriteCalculators(Ref ref) {
  final state = ref.watch(calculatorProvider);
  return state.favoriteCalculators;
}

/// Provider para histórico de cálculos
@riverpod
List<CalculationHistory> calculationHistory(Ref ref) {
  final state = ref.watch(calculatorProvider);
  return state.calculationHistory;
}

/// Provider para resultado atual de cálculo
@riverpod
CalculationResult? currentCalculationResult(Ref ref) {
  final state = ref.watch(calculatorProvider);
  return state.currentResult;
}

/// Provider para inputs atuais
@riverpod
Map<String, dynamic> currentCalculationInputs(Ref ref) {
  final state = ref.watch(calculatorProvider);
  return state.currentInputs;
}

/// Provider para status de loading das calculadoras
@riverpod
bool calculatorsLoading(Ref ref) {
  final state = ref.watch(calculatorProvider);
  return state.isLoading;
}

/// Provider para status de execução de cálculo
@riverpod
bool calculationExecuting(Ref ref) {
  final state = ref.watch(calculatorProvider);
  return state.isCalculating;
}

/// Provider para templates filtrados
@riverpod
List<CalculationTemplate> filteredTemplates(Ref ref) {
  final state = ref.watch(calculatorFeaturesProvider);
  return state.filteredTemplates;
}

/// Provider para IDs de favoritos
@riverpod
List<String> favoriteCalculatorIds(Ref ref) {
  final state = ref.watch(calculatorFeaturesProvider);
  return state.favoriteIds;
}

/// Provider para status de loading de templates
@riverpod
bool templatesLoading(Ref ref) {
  final state = ref.watch(calculatorFeaturesProvider);
  return state.isLoadingTemplates;
}

/// Provider para status de loading de favoritos
@riverpod
bool favoritesLoading(Ref ref) {
  final state = ref.watch(calculatorFeaturesProvider);
  return state.isLoadingFavorites;
}
