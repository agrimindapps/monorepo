// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/16_vacina_model.dart';
import '../../../../repository/vacina_repository.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../models/paginated_vaccine_model.dart';
import '../models/vacina_page_model.dart';
import '../models/vacina_page_state.dart';
import '../services/vacina_service.dart';
import '../views/styles/vacina_constants.dart';

/// Controller responsible for managing vaccine data and business logic for the VacinaPage.
/// 
/// This controller handles:
/// - Loading and managing vaccine data from repository
/// - State management for UI components
/// - Business logic delegation to [VacinaPageModel]
/// - Error handling and user feedback
/// - Animal selection and filtering
/// 
/// Usage:
/// ```dart
/// final controller = await VacinaPageController.initialize();
/// await controller.loadVacinas();
/// ```
/// 
/// The controller uses reactive programming with GetX and maintains state
/// through [VacinaPageState]. All business logic calculations are delegated
/// to [VacinaPageModel] for better separation of concerns.
class VacinaPageController extends GetxController {
  final VacinaRepository _repository;
  final VacinaService _service;
  final _animalController = Get.find<AnimalPageController>();
  final _state = const VacinaPageState().obs;
  final _paginatedData = const PaginatedVaccineModel().obs;
  final _paginationConfig = const PaginationConfig();

  VacinaPageController({
    VacinaRepository? repository,
    VacinaService? service,
  })  : _repository = repository ?? VacinaRepository(),
        _service = service ?? VacinaService();

  /// Factory method to initialize the controller with all dependencies.
  /// 
  /// This method ensures that the [VacinaRepository] is properly initialized
  /// before creating the controller instance. Should be called before using
  /// the controller in the application.
  /// 
  /// Returns a [Future<VacinaPageController>] that resolves when initialization
  /// is complete.
  /// 
  /// Example:
  /// ```dart
  /// final controller = await VacinaPageController.initialize();
  /// ```
  static Future<VacinaPageController> initialize() async {
    await VacinaRepository.initialize();
    final controller = VacinaPageController();
    Get.put(controller);
    return controller;
  }

  // State getters
  VacinaPageState get state => _state.value;
  List<VacinaVet> get vacinas => state.vacinas;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  bool get hasVacinas => state.hasVacinas;
  bool get isEmpty => state.isEmpty;
  int get vacinaCount => state.vacinaCount;
  String? get selectedAnimalId => state.selectedAnimalId;
  Animal? get selectedAnimal => state.selectedAnimal;
  bool get hasSelectedAnimal => state.hasSelectedAnimal;
  bool get hasError => state.hasError;
  bool get hasDateRange => state.hasDateRange;
  
  // Pagination getters
  PaginatedVaccineModel get paginatedData => _paginatedData.value;
  PaginationConfig get paginationConfig => _paginationConfig;
  bool get isLoadingMore => paginatedData.isLoading;
  bool get hasMorePages => paginatedData.hasNextPage;

  // Computed getters using business logic
  List<VacinaVet> get filteredVacinas =>
      VacinaPageModel.filterVacinasByDateRange(
          vacinas, state.dataInicial, state.dataFinal);

  List<VacinaVet> get vacinasSortedByPriority =>
      VacinaPageModel.sortVacinasByPriority(vacinas);

  List<VacinaVet> get vacinasAtrasadas =>
      VacinaPageModel.getVacinasAtrasadas(vacinas);
  List<VacinaVet> get vacinasProximasDoVencimento =>
      VacinaPageModel.getVacinasProximasDoVencimento(vacinas);
  List<VacinaVet> get vacinasEmDia => VacinaPageModel.getVacinasEmDia(vacinas);

  int get totalVacinasAtrasadas => vacinasAtrasadas.length;
  int get totalVacinasProximasDoVencimento =>
      vacinasProximasDoVencimento.length;
  int get totalVacinasEmDia => vacinasEmDia.length;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _updateState(state.copyWith(isLoading: true));
      await loadVacinas();
    } catch (e) {
      final errorMessage = _service.getErrorMessage(e);
      _updateState(
          state.copyWith(errorMessage: errorMessage, isLoading: false));
      debugPrint('Erro ao inicializar VacinaPageController: $e');
    }
  }

  /// Loads vaccines for the specified animal or currently selected animal.
  /// 
  /// If [animalId] is provided, loads vaccines for that specific animal.
  /// Otherwise, uses the currently selected animal from [AnimalPageController].
  /// 
  /// The method applies date filtering based on [VacinaConstants.diasIntervaloHistorico]
  /// to load vaccines within a reasonable time range.
  /// 
  /// Throws [TimeoutException] if the operation exceeds the configured timeout.
  /// Updates the controller state with loading status and error handling.
  /// 
  /// Parameters:
  /// - [animalId]: Optional animal ID. If null, uses currently selected animal.
  Future<void> loadVacinas([String? animalId]) async {
    try {
      _updateState(state.copyWith(isLoading: true, errorMessage: null));

      final targetAnimalId = animalId ?? _animalController.selectedAnimalId;

      if (targetAnimalId.isNotEmpty) {
        final result = await _repository
            .getVacinas(
              targetAnimalId,
              dataInicial: state.dataInicial ??
                  DateTime.now()
                      .subtract(const Duration(
                          days: VacinaConstants.diasIntervaloHistorico))
                      .millisecondsSinceEpoch,
              dataFinal: state.dataFinal ??
                  DateTime.now()
                      .add(const Duration(
                          days: VacinaConstants.diasIntervaloHistorico))
                      .millisecondsSinceEpoch,
            )
            .timeout(
              VacinaConstants.timeoutOperacaoRede,
              onTimeout: () => throw TimeoutException(
                  'Tempo limite para carregar vacinas excedido',
                  VacinaConstants.timeoutOperacaoRede),
            );
        _updateState(state.copyWith(vacinas: result, isLoading: false));
      } else {
        _updateState(state.copyWith(vacinas: <VacinaVet>[], isLoading: false));
      }
    } catch (e) {
      final errorMessage = _service.getErrorMessage(e);
      _updateState(
          state.copyWith(errorMessage: errorMessage, isLoading: false));
      debugPrint('Erro ao carregar vacinas: $e');
    }
  }

  /// Deletes the specified vaccine from the repository.
  /// 
  /// This method removes the vaccine from both the repository and the local
  /// state. It includes timeout handling and proper error management.
  /// 
  /// Parameters:
  /// - [vacina]: The vaccine instance to be deleted
  /// 
  /// Throws:
  /// - [TimeoutException] if deletion exceeds timeout limit
  /// - [Exception] if deletion fails for any reason
  /// 
  /// The method will rethrow exceptions after updating the error state,
  /// allowing calling code to handle them appropriately.
  Future<void> deleteVacina(VacinaVet vacina) async {
    try {
      final result = await _repository.deleteVacina(vacina).timeout(
            VacinaConstants.timeoutOperacaoRede,
            onTimeout: () => throw TimeoutException(
                'Tempo limite para excluir vacina excedido',
                VacinaConstants.timeoutOperacaoRede),
          );
      if (result) {
        final updatedVacinas = List<VacinaVet>.from(vacinas)
          ..removeWhere((v) => v.id == vacina.id);
        _updateState(state.copyWith(vacinas: updatedVacinas));
      } else {
        throw Exception('Falha ao excluir vacina - operação não foi concluída');
      }
    } catch (e) {
      final errorMessage = _service.getErrorMessage(e);
      _updateState(state.copyWith(errorMessage: errorMessage));
      debugPrint('Erro ao excluir vacina: $e');
      rethrow;
    }
  }

  Future<void> refreshVacinas() async {
    await loadVacinas();
  }

  /// Handles animal selection change from the UI.
  /// 
  /// Updates the internal state with the new animal selection and
  /// automatically loads vaccines for the selected animal. If no
  /// animal is selected (animalId is null or empty), clears the
  /// vaccines list.
  /// 
  /// Parameters:
  /// - [animalId]: ID of the selected animal, or null if none selected
  /// - [animal]: Complete animal object for reference
  void onAnimalSelected(String? animalId, Animal? animal) {
    _updateState(state.copyWith(
      selectedAnimalId: animalId,
      selectedAnimal: animal,
    ));
    if (animalId != null && animalId.isNotEmpty) {
      loadVacinas(animalId);
    } else {
      _updateState(state.copyWith(vacinas: <VacinaVet>[]));
    }
  }

  void onDateRangeChanged(int? dataInicial, int? dataFinal) {
    _updateState(state.copyWith(
      dataInicial: dataInicial,
      dataFinal: dataFinal,
    ));
    loadVacinas();
  }

  // Business logic delegates
  bool isVacinaAtrasada(VacinaVet vacina) =>
      VacinaPageModel.isVacinaAtrasada(vacina);
  bool isVacinaProximaDoVencimento(VacinaVet vacina) =>
      VacinaPageModel.isVacinaProximaDoVencimento(vacina);
  int getDiasParaVencimento(VacinaVet vacina) =>
      VacinaPageModel.getDiasParaVencimento(vacina);

  String getSubtitle() => VacinaPageModel.getSubtitle(vacinaCount);
  String formatDateToString(int timestamp) =>
      VacinaPageModel.formatDateToString(timestamp);
  String getFormattedCurrentMonth() =>
      VacinaPageModel.getFormattedCurrentMonth();

  List<String> getAvailableMonths() =>
      VacinaPageModel.gerarListaMesesDisponiveis(vacinas);

  String getFormattedPeriod() =>
      VacinaPageModel.formatarPeriodoVacinas(vacinas);
  String getVacinaStatusColor(VacinaVet vacina) =>
      VacinaPageModel.getVacinaStatusColor(vacina);
  String getVacinaStatusText(VacinaVet vacina) =>
      VacinaPageModel.getVacinaStatusText(vacina);

  // UI state helpers
  bool shouldShowLoading() => isLoading;
  bool shouldShowError() => hasError;
  bool shouldShowNoAnimalSelected() =>
      _animalController.selectedAnimalId.isEmpty;
  bool shouldShowNoData() =>
      !shouldShowNoAnimalSelected() && isEmpty && !isLoading && !hasError;
  bool shouldShowVacinas() =>
      !shouldShowNoAnimalSelected() && hasVacinas && !isLoading && !hasError;
  bool canAddVacina() => _animalController.selectedAnimalId.isNotEmpty;

  // Search functionality
  List<VacinaVet> searchVacinas(String query) =>
      VacinaPageModel.searchVacinas(vacinas, query);

  // Additional helper methods - all delegated to VacinaPageModel
  String? getVacinaStatusMessage(VacinaVet vacina) =>
      VacinaPageModel.getVacinaStatusText(vacina);

  int diasParaProximaDose(VacinaVet vacina) =>
      VacinaPageModel.getDiasParaVencimento(vacina);

  bool isProximaVacina(VacinaVet vacina) =>
      VacinaPageModel.isVacinaProximaDoVencimento(vacina);

  List<VacinaVet> get proximasVacinas =>
      VacinaPageModel.getVacinasProximasDoVencimento(vacinas);

  Future<String> exportVacinasToCsv(String animalId) async {
    try {
      final csvData = await _repository.exportToCsv(animalId);
      return csvData;
    } catch (e) {
      debugPrint('Error exporting vacinas to CSV: $e');
      return '';
    }
  }

  // Method to retry failed operations
  Future<void> retryLastOperation() async {
    if (selectedAnimalId != null && selectedAnimalId!.isNotEmpty) {
      await loadVacinas();
    }
  }

  void clearData() {
    _updateState(const VacinaPageState());
    _paginatedData.value = const PaginatedVaccineModel();
  }

  /// Loads vaccines with pagination support.
  /// 
  /// This method implements pagination by loading vaccines in chunks
  /// rather than all at once, improving performance for large datasets.
  /// 
  /// Parameters:
  /// - [page]: The page number to load (0-based)
  /// - [pageSize]: Number of items per page
  /// - [append]: Whether to append to existing data or replace it
  Future<void> loadVaccinasPaginated({
    int page = 0,
    int? pageSize,
    bool append = false,
  }) async {
    try {
      final targetAnimalId = _animalController.selectedAnimalId;
      if (targetAnimalId.isEmpty) {
        _paginatedData.value = const PaginatedVaccineModel();
        return;
      }

      // Set loading state
      if (append) {
        _paginatedData.value = paginatedData.copyWith(isLoading: true);
      } else {
        _paginatedData.value = const PaginatedVaccineModel(isLoading: true);
      }

      final effectivePageSize = pageSize ?? paginationConfig.defaultPageSize;
      
      // For demo purposes, simulate pagination by chunking the existing data
      // In a real implementation, this would call a paginated API
      final allVaccines = await _repository.getVacinas(
        targetAnimalId,
        dataInicial: state.dataInicial ??
            DateTime.now()
                .subtract(const Duration(
                    days: VacinaConstants.diasIntervaloHistorico))
                .millisecondsSinceEpoch,
        dataFinal: state.dataFinal ??
            DateTime.now()
                .add(const Duration(
                    days: VacinaConstants.diasIntervaloHistorico))
                .millisecondsSinceEpoch,
      ).timeout(
        VacinaConstants.timeoutOperacaoRede,
        onTimeout: () => throw TimeoutException(
            'Tempo limite para carregar vacinas excedido',
            VacinaConstants.timeoutOperacaoRede),
      );

      // Simulate pagination by chunking data
      final startIndex = page * effectivePageSize;
      final endIndex = (startIndex + effectivePageSize).clamp(0, allVaccines.length);
      final pageData = startIndex < allVaccines.length 
          ? allVaccines.sublist(startIndex, endIndex)
          : <VacinaVet>[];

      final hasNext = endIndex < allVaccines.length;
      final hasPrevious = page > 0;

      if (append && paginatedData.hasItems) {
        _paginatedData.value = paginatedData.appendItems(pageData).copyWith(
          isLoading: false,
          hasNextPage: hasNext,
          hasPreviousPage: hasPrevious,
          totalCount: allVaccines.length,
        );
      } else {
        _paginatedData.value = PaginatedVaccineModel(
          items: pageData,
          totalCount: allVaccines.length,
          currentPage: page,
          pageSize: effectivePageSize,
          hasNextPage: hasNext,
          hasPreviousPage: hasPrevious,
          isLoading: false,
        );
      }

      // Also update the regular state for backward compatibility
      _updateState(state.copyWith(
        vacinas: append ? [...vacinas, ...pageData] : pageData,
        isLoading: false,
      ));
      
    } catch (e) {
      final errorMessage = _service.getErrorMessage(e);
      _paginatedData.value = paginatedData.copyWith(
        errorMessage: errorMessage,
        isLoading: false,
      );
      debugPrint('Erro ao carregar vacinas paginadas: $e');
    }
  }

  /// Loads the next page of vaccines for infinite scrolling.
  Future<void> loadNextPage() async {
    if (!paginatedData.hasNextPage || paginatedData.isLoading) return;
    
    await loadVaccinasPaginated(
      page: paginatedData.currentPage + 1,
      append: true,
    );
  }

  /// Refreshes the vaccine list from the beginning.
  Future<void> refreshVaccinesPaginated() async {
    await loadVaccinasPaginated(page: 0, append: false);
  }

  // Private helper method to update state
  void _updateState(VacinaPageState newState) {
    _state.value = newState;
  }

  // Monthly navigation methods
  final RxInt _currentMonthIndex = 0.obs;

  List<DateTime> getMonthsList() {
    if (vacinas.isEmpty) {
      return [DateTime.now()];
    }

    final dates = vacinas.map((vacina) => DateTime.fromMillisecondsSinceEpoch(vacina.dataAplicacao)).toList();
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
}
