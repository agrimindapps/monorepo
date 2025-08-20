// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/13_despesa_model.dart';
import '../../../../repository/despesa_repository.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../config/despesas_page_config.dart';
import '../models/despesas_page_model.dart';
import '../models/despesas_page_state.dart';
import '../services/despesas_filter_service.dart';
import '../services/despesas_service.dart';
import '../utils/despesas_utils.dart';

class DespesasPageController extends GetxController {
  final _animalController = Get.find<AnimalPageController>();
  final DespesaRepository _repository;
  final DespesasService _despesasService;
  final DespesasFilterService _filterService;

  final model = DespesasPageModel().obs;
  final state = const DespesasPageState().obs;
  
  // Debounce timer for search optimization
  Timer? _searchDebounceTimer;

  DespesasPageController({
    DespesaRepository? repository,
    DespesasService? despesasService,
    DespesasFilterService? filterService,
  })  : _repository = repository ?? DespesaRepository(),
        _despesasService = despesasService ?? DespesasService(),
        _filterService = filterService ?? DespesasFilterService();

  static Future<DespesasPageController> initialize() async {
    await DespesaRepository.initialize();
    final controller = DespesasPageController();
    Get.put(controller, tag: 'despesas_page');
    return controller;
  }

  // Getters para facilitar acesso aos dados
  List<DespesaVet> get despesas => model.value.despesas;
  List<DespesaVet> get filteredDespesas => model.value.filteredDespesas;
  bool get isLoading => state.value.isLoading;
  String? get errorMessage => state.value.errorMessage;
  bool get isInitialized => state.value.isInitialized;
  bool get hasDespesas => model.value.hasDespesas;
  int get despesaCount => model.value.despesaCount;
  String? get selectedAnimalId => model.value.selectedAnimalId;
  Animal? get selectedAnimal => model.value.selectedAnimal;
  bool get hasSelectedAnimal => model.value.hasSelectedAnimal;
  String get searchText => model.value.searchText;
  DateTime? get dataInicial => model.value.dataInicial;
  DateTime? get dataFinal => model.value.dataFinal;
  bool get hasDateRange => model.value.hasDateRange;
  double get totalDespesas => model.value.totalDespesas;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _setLoading(true);
      _setInitialized(true);
      _clearError();
      await loadDespesas();
    } catch (e) {
      _setError('${DespesasPageConfig.errorInicializar}: $e');
      debugPrint('Erro ao inicializar DespesasPageController: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDespesas([String? animalId]) async {
    try {
      _setLoading(true);
      _clearError();

      final targetAnimalId = animalId ?? _animalController.selectedAnimalId;

      if (targetAnimalId.isNotEmpty) {
        final result = await _despesasService.getDespesasForPeriod(
          animalId: targetAnimalId,
          dataInicial: dataInicial,
          dataFinal: dataFinal,
          repository: _repository,
        );
        _setDespesas(result);
      } else {
        _clearDespesas();
      }
    } catch (e) {
      _setError('${DespesasPageConfig.errorCarregarDespesas}: $e');
      debugPrint('Erro ao carregar despesas: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshDespesas() async {
    await loadDespesas();
  }

  void onAnimalSelected(String? animalId, Animal? animal) {
    _setSelectedAnimal(animalId, animal);
    if (animalId != null && animalId.isNotEmpty) {
      loadDespesas(animalId);
    } else {
      _clearDespesas();
    }
  }

  void onSearchChanged(String searchText) {
    _setSearchText(searchText);
    
    // Debounce search to improve performance
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(DespesasPageConfig.searchDebounceDuration, () {
      _updateFilteredDespesas();
    });
  }

  void onDateRangeChanged(DateTime? dataInicial, DateTime? dataFinal) {
    _setDateRange(dataInicial, dataFinal);
    loadDespesas();
  }

  void _updateFilteredDespesas() {
    final filtered = _filterService.applyFilters(
      despesas: despesas,
      searchText: searchText,
      dataInicial: dataInicial,
      dataFinal: dataFinal,
    );

    model.update((m) {
      m?.setFilteredDespesas(filtered);
    });
  }

  // State management methods - properly using copyWith for immutability
  void _setLoading(bool loading) {
    state.value = state.value.copyWith(isLoading: loading);
  }

  void _setError(String? error) {
    state.value = state.value.copyWith(errorMessage: error);
  }

  void _clearError() {
    state.value = state.value.copyWith(errorMessage: null);
  }

  void _setInitialized(bool initialized) {
    state.value = state.value.copyWith(
      isInitialized: initialized,
      lastUpdated: DateTime.now(),
    );
  }

  void _setRefreshing(bool refreshing) {
    state.value = state.value.copyWith(isRefreshing: refreshing);
  }

  // Model management methods
  void _setDespesas(List<DespesaVet> despesas) {
    model.update((m) {
      m?.setDespesas(despesas);
    });
    _updateFilteredDespesas();
  }

  void addDespesa(DespesaVet despesa) {
    model.update((m) {
      m?.addDespesa(despesa);
    });
    _updateFilteredDespesas();
  }

  void updateDespesa(DespesaVet despesa) {
    model.update((m) {
      m?.updateDespesa(despesa);
    });
    _updateFilteredDespesas();
  }

  void removeDespesa(DespesaVet despesa) {
    model.update((m) {
      m?.removeDespesa(despesa);
    });
    _updateFilteredDespesas();
  }

  void _clearDespesas() {
    model.update((m) {
      m?.clearDespesas();
    });
  }

  void _setSelectedAnimal(String? animalId, Animal? animal) {
    model.update((m) {
      m?.setSelectedAnimal(animalId, animal);
    });
  }

  void _setSearchText(String text) {
    model.update((m) {
      m?.setSearchText(text);
    });
  }

  void _setDateRange(DateTime? dataInicial, DateTime? dataFinal) {
    model.update((m) {
      m?.setDateRange(dataInicial, dataFinal);
    });
  }

  void clearSelectedAnimal() {
    model.update((m) {
      m?.clearSelectedAnimal();
    });
  }

  void clearDateRange() {
    model.update((m) {
      m?.clearDateRange();
    });
  }

  // UI helper methods
  String getSubtitle() {
    if (!isInitialized) {
      return 'Carregando...';
    }

    final count = filteredDespesas.length;
    final total = DespesasUtils.formatarValor(totalDespesas);

    if (count == 0) {
      return 'Nenhuma despesa';
    } else if (count == 1) {
      return '1 despesa • Total: R\$ $total';
    } else {
      return '$count despesas • Total: R\$ $total';
    }
  }

  // Formatting methods - simplified public interface
  String formatarDataAtual() => DespesasUtils.formatarDataAtual();
  String formatarValor(double valor) => DespesasUtils.formatarValor(valor);
  String formatarData(int timestamp) => DespesasUtils.formatarData(timestamp);
  
  String getFormattedCurrentMonth() {
    final now = DateTime.now();
    return DateFormat('MMM yy', 'pt_BR')
        .format(now)
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  List<String> getAvailableMonths() {
    return DespesasUtils.gerarListaMesesDisponiveis(despesas);
  }

  String getFormattedPeriod() {
    return DespesasUtils.formatarPeriodoDespesas(despesas);
  }

  // UI state methods - simplified interface
  bool shouldShowLoading() => isLoading;
  bool shouldShowError() => errorMessage != null;
  bool shouldShowNoAnimalSelected() => !hasSelectedAnimal;
  bool shouldShowSearchField() => despesas.isNotEmpty;
  
  bool shouldShowNoData() => hasSelectedAnimal && !isLoading && despesas.isEmpty && errorMessage == null;
  bool shouldShowDespesas() => hasSelectedAnimal && !isLoading && despesas.isNotEmpty && errorMessage == null;

  bool canAddDespesa() {
    return hasSelectedAnimal;
  }

  // Business logic methods
  List<DespesaVet> searchDespesas(String query) {
    return _filterService.filterBySearchText(despesas, query);
  }

  Future<DespesaVet?> getDespesaById(String id) async {
    return await _repository.getDespesaById(id);
  }

  double getTotalDespesas() {
    return _despesasService.calculateTotal(despesas);
  }

  double getTotalDespesasFiltradas() {
    return _despesasService.calculateTotal(filteredDespesas);
  }

  Map<String, double> getDespesasPorTipo() {
    return _despesasService.groupByTipo(despesas);
  }

  Map<String, int> getDespesasCountPorTipo() {
    return _despesasService.countByTipo(despesas);
  }

  List<DespesaVet> getDespesasRecentes({int limit = 10}) {
    return _despesasService.getRecentes(despesas, limit: limit);
  }

  Map<String, double> getDespesasPorMes() {
    return _despesasService.groupByMes(despesas);
  }

  // Export methods
  Future<String> exportToCsv(String animalId) async {
    try {
      final despesas = await _repository.getDespesas(animalId);
      return _despesasService.exportToCsv(despesas);
    } catch (e) {
      debugPrint('Error exporting despesas to CSV: $e');
      return '';
    }
  }

  Future<Uint8List> exportToPdf(String animalId, String animalName) async {
    return Uint8List(0);
  }

  // Analysis methods
  double getMediaDespesas() {
    return _despesasService.calculateAverage(despesas);
  }

  DespesaVet? getMaiorDespesa() {
    return _despesasService.getMaior(despesas);
  }

  DespesaVet? getMenorDespesa() {
    return _despesasService.getMenor(despesas);
  }

  String getTipoMaisFrequente() {
    return _despesasService.getTipoMaisFrequente(despesas);
  }

  double getGastoMensal() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final despesasDoMes = _filterService.filterByDateRange(
      despesas,
      startOfMonth,
      endOfMonth,
    );

    return _despesasService.calculateTotal(despesasDoMes);
  }

  List<DespesaVet> getDespesasDoMes([DateTime? targetMonth]) {
    final month = targetMonth ?? DateTime.now();
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    return _filterService.filterByDateRange(despesas, startOfMonth, endOfMonth);
  }

  bool hasRecentDespesas({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return despesas.any((despesa) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      return data.isAfter(cutoffDate);
    });
  }

  void clearFilters() {
    _setSearchText('');
    clearDateRange();
    _updateFilteredDespesas();
  }

  // Monthly navigation methods
  final RxInt _currentMonthIndex = 0.obs;

  List<DateTime> getMonthsList() {
    if (despesas.isEmpty) {
      return [DateTime.now()];
    }

    final dates = despesas.map((despesa) => DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa)).toList();
    final oldestDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final newestDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    return _generateMonthsBetween(oldestDate, newestDate);
  }

  List<DateTime> _generateMonthsBetween(DateTime start, DateTime end) {
    List<DateTime> months = [];
    DateTime currentDate = DateTime(start.year, start.month);
    final lastDate = DateTime(end.year, end.month);

    while (!currentDate.isAfter(lastDate)) {
      months.add(currentDate);
      currentDate = DateTime(
        currentDate.year + (currentDate.month == 12 ? 1 : 0),
        currentDate.month == 12 ? 1 : currentDate.month + 1,
      );
    }

    return months.reversed.toList();
  }

  int getCurrentMonthIndex() => _currentMonthIndex.value;

  void setCurrentMonthIndex(int index) {
    _currentMonthIndex.value = index;
    update();
  }

  @override
  void onClose() {
    // Cancel search debounce timer
    _searchDebounceTimer?.cancel();
    
    // Cleanup resources
    debugPrint('DespesasPageController disposed');
    super.onClose();
  }
}
