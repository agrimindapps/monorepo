// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/17_peso_model.dart';
import '../../../../repository/peso_repository.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../models/peso_calculation_model.dart';
import '../models/peso_page_state.dart';
import '../services/peso_filter_service.dart';
import '../services/peso_service.dart';

/// Controller for peso page using MVC architecture
class PesoPageController extends GetxController {
  final PesoRepository _repository;
  final PesoService _pesoService;
  final PesoFilterService _filterService;
  final _animalController = Get.find<AnimalPageController>();

  final _state = PesoPageState.empty(null).obs;

  PesoPageController({
    PesoRepository? repository,
    PesoService? pesoService,
    PesoFilterService? filterService,
  })  : _repository = repository ?? PesoRepository(),
        _pesoService = pesoService ?? PesoService(),
        _filterService = filterService ?? PesoFilterService();

  // Getters
  PesoPageState get state => _state.value;
  List<PesoAnimal> get pesos => state.pesos;
  List<PesoAnimal> get filteredPesos => state.filteredPesos;
  bool get isLoading => state.isLoading;
  bool get isRefreshing => state.isRefreshing;
  String? get errorMessage => state.errorMessage;
  String? get selectedAnimalId => state.selectedAnimalId;
  Animal? get selectedAnimal => state.selectedAnimal;
  bool get hasPesos => state.hasPesos;
  bool get hasSelectedAnimal => state.hasSelectedAnimal;
  PesoViewMode get viewMode => state.viewMode;
  String get searchQuery => state.searchQuery;

  // Computed properties
  PesoAnimal? get latestPeso => state.latestPeso;
  PesoTrend get pesoTrend => state.pesoTrend;
  double? get weightChange => state.weightChange;
  int get pesoCount => state.pesoCount;

  /// Initialize controller
  static Future<PesoPageController> initialize() async {
    await PesoRepository.initialize();
    final controller = PesoPageController();
    Get.put(controller);
    return controller;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeFromAnimalController();
  }

  /// Initialize from animal controller state
  void _initializeFromAnimalController() {
    final animalId = _animalController.selectedAnimalId;
    final animal = _animalController.selectedAnimal;

    _updateState(state.copyWith(
      selectedAnimalId: animalId,
      selectedAnimal: animal,
    ));

    if (animalId.isNotEmpty) {
      loadPesos();
    }
  }

  /// Load pesos for selected animal
  Future<void> loadPesos() async {
    if (!hasSelectedAnimal) return;

    try {
      _updateState(state.setLoading(true));

      final loadedPesos = await _repository.getPesos(
        selectedAnimalId!,
        dataInicial: state.dataInicial,
        dataFinal: state.dataFinal,
      );

      final filteredPesos = _filterService.filterPesos(
        loadedPesos,
        searchQuery: state.searchQuery,
        sortType: state.sortType,
        sortAscending: state.sortAscending,
      );

      _updateState(state.copyWith(
        pesos: loadedPesos,
        filteredPesos: filteredPesos,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      _updateState(state.copyWith(
        isLoading: false,
        errorMessage: _pesoService.getErrorMessage(e),
      ));
      debugPrint('Error loading pesos: $e');
    }
  }

  /// Refresh pesos data
  Future<void> refreshPesos() async {
    if (!hasSelectedAnimal) return;

    try {
      _updateState(state.setRefreshing(true));
      await loadPesos();
    } finally {
      _updateState(state.setRefreshing(false));
    }
  }

  /// Add new peso record
  Future<bool> addPeso(PesoAnimal peso) async {
    try {
      _updateState(state.setLoading(true));

      final success = await _repository.addPeso(peso);

      if (success) {
        await loadPesos(); // Reload data
        return true;
      } else {
        _updateState(state.copyWith(
          isLoading: false,
          errorMessage: 'Falha ao salvar peso',
        ));
        return false;
      }
    } catch (e) {
      _updateState(state.copyWith(
        isLoading: false,
        errorMessage: _pesoService.getErrorMessage(e),
      ));
      debugPrint('Error adding peso: $e');
      return false;
    }
  }

  /// Update existing peso record
  Future<bool> updatePeso(PesoAnimal peso) async {
    try {
      _updateState(state.setLoading(true));

      final success = await _repository.updatePeso(peso);

      if (success) {
        await loadPesos(); // Reload data
        return true;
      } else {
        _updateState(state.copyWith(
          isLoading: false,
          errorMessage: 'Falha ao atualizar peso',
        ));
        return false;
      }
    } catch (e) {
      _updateState(state.copyWith(
        isLoading: false,
        errorMessage: _pesoService.getErrorMessage(e),
      ));
      debugPrint('Error updating peso: $e');
      return false;
    }
  }

  /// Delete peso record
  Future<bool> deletePeso(PesoAnimal peso) async {
    try {
      _updateState(state.setLoading(true));

      final success = await _repository.deletePeso(peso);

      if (success) {
        await loadPesos(); // Reload data
        return true;
      } else {
        _updateState(state.copyWith(
          isLoading: false,
          errorMessage: 'Falha ao excluir peso',
        ));
        return false;
      }
    } catch (e) {
      _updateState(state.copyWith(
        isLoading: false,
        errorMessage: _pesoService.getErrorMessage(e),
      ));
      debugPrint('Error deleting peso: $e');
      return false;
    }
  }

  /// Update animal selection
  void updateAnimalSelection(String? animalId, Animal? animal) {
    _updateState(state.copyWith(
      selectedAnimalId: animalId,
      selectedAnimal: animal,
      pesos: [], // Clear previous data
      filteredPesos: [],
      errorMessage: null,
    ));

    if (animalId != null && animalId.isNotEmpty) {
      loadPesos();
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _updateState(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  /// Update date filter
  void updateDateFilter(int? dataInicial, int? dataFinal) {
    _updateState(state.copyWith(
      dataInicial: dataInicial,
      dataFinal: dataFinal,
    ));
    loadPesos(); // Reload with new filter
  }

  /// Update sort settings
  void updateSort(PesoSortType sortType, bool ascending) {
    _updateState(state.copyWith(
      sortType: sortType,
      sortAscending: ascending,
    ));
    _applyFilters();
  }

  /// Change view mode
  void changeViewMode(PesoViewMode mode) {
    _updateState(state.copyWith(viewMode: mode));
  }

  /// Clear all filters
  void clearFilters() {
    _updateState(state.copyWith(
      searchQuery: '',
      dataInicial: null,
      dataFinal: null,
      sortType: PesoSortType.date,
      sortAscending: false,
    ));
    loadPesos();
  }

  /// Apply current filters to peso list
  void _applyFilters() {
    final filtered = _filterService.filterPesos(
      state.pesos,
      searchQuery: state.searchQuery,
      sortType: state.sortType,
      sortAscending: state.sortAscending,
    );

    _updateState(state.copyWith(filteredPesos: filtered));
  }

  /// Export pesos to CSV
  Future<String?> exportToCSV() async {
    if (!hasSelectedAnimal || pesos.isEmpty) return null;

    try {
      _updateState(state.setLoading(true));

      final csvData = await _repository.exportToCsv(selectedAnimalId!);

      _updateState(state.setLoading(false));
      return csvData;
    } catch (e) {
      _updateState(state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao exportar dados',
      ));
      debugPrint('Error exporting CSV: $e');
      return null;
    }
  }

  /// Get peso insights for selected animal
  List<String> getPesoInsights() {
    if (!hasSelectedAnimal || selectedAnimal == null) {
      return ['Selecione um animal para ver insights'];
    }

    return PesoCalculationModel.generateInsights(pesos, selectedAnimal!);
  }

  /// Get weight category for latest peso
  WeightCategory? getWeightCategory() {
    if (latestPeso == null || selectedAnimal == null) return null;

    return PesoCalculationModel.getWeightCategory(
      latestPeso!.peso,
      selectedAnimal!,
    );
  }

  /// Get ideal weight range for selected animal
  WeightRange? getIdealWeightRange() {
    if (selectedAnimal == null) return null;

    return PesoCalculationModel.getIdealWeightRange(selectedAnimal!);
  }

  /// Check if weighing is overdue
  bool isWeighingOverdue() {
    if (selectedAnimal == null) return false;

    final daysSince = PesoCalculationModel.daysSinceLastWeighing(pesos);
    final category = getWeightCategory() ?? WeightCategory.normal;
    final recommendedFrequency =
        PesoCalculationModel.getRecommendedWeighingFrequency(
      selectedAnimal!,
      category,
    );

    return daysSince > recommendedFrequency;
  }

  /// Clear error message
  void clearError() {
    _updateState(state.clearError());
  }

  /// Update state immutably
  void _updateState(PesoPageState newState) {
    _state.value = newState;
  }

  /// Validate peso data before saving
  String? validatePeso(double peso) {
    if (selectedAnimal == null) {
      return 'Selecione um animal primeiro';
    }

    return PesoCalculationModel.validatePeso(peso, selectedAnimal!);
  }

}
