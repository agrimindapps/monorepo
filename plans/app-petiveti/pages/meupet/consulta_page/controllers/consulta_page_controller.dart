// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/12_consulta_model.dart';
import '../../../../repository/consulta_repository.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../models/consulta_page_model.dart';
import '../models/consulta_page_state.dart';
import '../services/consulta_service.dart';
import '../utils/consulta_utils.dart';

class ConsultaPageController extends GetxController {
  final _animalController = Get.find<AnimalPageController>();
  final ConsultaRepository _repository;
  final ConsultaService _consultaService;

  final pageModel = ConsultaPageModel().obs;
  final pageState = const ConsultaPageState().obs;

  ConsultaPageModel get model => pageModel.value;
  ConsultaPageState get state => pageState.value;
  List<Consulta> get consultas => model.consultas;
  List<Consulta> get filteredConsultas => model.filteredConsultas;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  bool get isInitialized => state.isInitialized;
  bool get hasConsultas => model.hasConsultas;
  int get consultaCount => model.consultaCount;
  String? get selectedAnimalId => model.selectedAnimalId;
  Animal? get selectedAnimal => model.selectedAnimal;
  bool get hasSelectedAnimal => model.hasSelectedAnimal;
  String get searchText => model.searchText;
  DateTime? get selectedDate => model.selectedDate;
  String get selectedSortBy => model.selectedSortBy;
  bool get isAscending => model.isAscending;

  ConsultaPageController({
    ConsultaRepository? repository,
    ConsultaService? consultaService,
  })  : _repository = repository ?? ConsultaRepository(),
        _consultaService = consultaService ?? ConsultaService();

  static Future<ConsultaPageController> initialize() async {
    await ConsultaRepository.initialize();
    final controller = ConsultaPageController();
    Get.put(controller, tag: 'consulta_page');
    await controller._initializeController();
    return controller;
  }

  Future<void> _initializeController() async {
    try {
      setLoading(true);
      setInitialized(true);
      setError(null);

      // Initialize with current animal if selected
      if (_animalController.selectedAnimalId.isNotEmpty) {
        await loadConsultas(_animalController.selectedAnimalId);
      }
    } catch (e) {
      setError('Erro ao inicializar o controlador: $e');
      debugPrint('Erro ao inicializar ConsultaPageController: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadConsultas([String? animalId]) async {
    try {
      setLoading(true);
      setError(null);

      final targetAnimalId = animalId ?? _animalController.selectedAnimalId;

      if (targetAnimalId.isNotEmpty && targetAnimalId != selectedAnimalId) {
        final result = await _consultaService.getConsultasByAnimal(
          animalId: targetAnimalId,
          repository: _repository,
        );
        setConsultas(result);
        _updateSelectedAnimal(targetAnimalId);
      } else if (targetAnimalId.isEmpty) {
        clearConsultas();
      }
    } catch (e) {
      setError('Erro ao carregar consultas: $e');
      debugPrint('Erro ao carregar consultas: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteConsulta(Consulta consulta) async {
    try {
      setLoading(true);
      final result = await _consultaService.deleteConsulta(
        consulta: consulta,
        repository: _repository,
      );

      if (result) {
        removeConsulta(consulta);
        Get.snackbar(
          'Sucesso',
          'Consulta excluída com sucesso',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        throw Exception('Falha ao excluir consulta');
      }
    } catch (e) {
      setError('Erro ao excluir consulta: $e');
      debugPrint('Erro ao excluir consulta: $e');
      Get.snackbar(
        'Erro',
        'Falha ao excluir consulta: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setLoading(false);
    }
  }

  Future<void> refreshConsultas() async {
    await loadConsultas();
  }

  void onAnimalSelected(String? animalId, Animal? animal) {
    if (animalId != selectedAnimalId) {
      setSelectedAnimal(animalId, animal);
      if (animalId != null && animalId.isNotEmpty) {
        loadConsultas(animalId);
      } else {
        clearConsultas();
      }
    }
  }

  void onSearchChanged(String searchText) {
    setSearchText(searchText);
    _updateFilteredConsultas();
  }

  void onDateFilterChanged(DateTime? date) {
    setSelectedDate(date);
    _updateFilteredConsultas();
  }

  void onSortChanged(String sortBy, {bool? ascending}) {
    setSortBy(sortBy);
    if (ascending != null) {
      setSortOrder(ascending);
    }
    _updateFilteredConsultas();
  }

  void clearFilters() {
    pageModel.update((model) {
      model?.clearFilters();
    });
    _updateFilteredConsultas();
  }

  void _updateFilteredConsultas() {
    pageModel.update((model) {
      model?.updateFilteredConsultas();
    });
  }

  void _updateSelectedAnimal(String animalId) {
    final animal = _animalController.animals.firstWhereOrNull(
      (a) => a.id == animalId,
    );
    setSelectedAnimal(animalId, animal);
  }

  // State management methods
  void setLoading(bool loading) {
    pageState.update((state) {
      state?.setLoading(loading);
    });
  }

  void setError(String? error) {
    pageState.update((state) {
      state?.setError(error);
    });
  }

  void setInitialized(bool initialized) {
    pageState.update((state) {
      state?.setInitialized(initialized);
    });
  }

  void clearError() {
    pageState.update((state) {
      state?.clearError();
    });
  }

  // Data management methods
  void setConsultas(List<Consulta> consultas) {
    pageModel.update((model) {
      model?.setConsultas(consultas);
    });
  }

  void addConsulta(Consulta consulta) {
    pageModel.update((model) {
      model?.addConsulta(consulta);
    });
  }

  void updateConsulta(Consulta consulta) {
    pageModel.update((model) {
      model?.updateConsulta(consulta);
    });
  }

  void removeConsulta(Consulta consulta) {
    pageModel.update((model) {
      model?.removeConsulta(consulta);
    });
  }

  void clearConsultas() {
    pageModel.update((model) {
      model?.clearConsultas();
    });
  }

  void setSelectedAnimal(String? animalId, Animal? animal) {
    pageModel.update((model) {
      model?.setSelectedAnimal(animalId, animal);
    });
  }

  void setSearchText(String text) {
    pageModel.update((model) {
      model?.setSearchText(text);
    });
  }

  void setSelectedDate(DateTime? date) {
    pageModel.update((model) {
      model?.setSelectedDate(date);
    });
  }

  void setSortBy(String sortBy) {
    pageModel.update((model) {
      model?.setSortBy(sortBy);
    });
  }

  void setSortOrder(bool ascending) {
    pageModel.update((model) {
      model?.setSortOrder(ascending);
    });
  }

  void clearSelectedAnimal() {
    pageModel.update((model) {
      model?.clearSelectedAnimal();
    });
  }

  // UI helper methods
  String getSubtitle() {
    if (hasSelectedAnimal && selectedAnimal != null) {
      return '${selectedAnimal!.nome} - $consultaCount consultas';
    }
    return '$consultaCount registros';
  }

  String getFormattedMonth() {
    return ConsultaUtils.getFormattedMonth();
  }

  List<String> getAvailableMonths() {
    return ConsultaUtils.gerarListaMesesDisponiveis(consultas);
  }

  String getFormattedPeriod() {
    return ConsultaUtils.formatarPeriodoConsultas(consultas);
  }

  bool shouldShowLoading() {
    return !isInitialized || isLoading;
  }

  bool shouldShowError() {
    return errorMessage != null;
  }

  bool shouldShowNoData() {
    return isInitialized &&
        !isLoading &&
        consultas.isEmpty &&
        errorMessage == null;
  }

  bool shouldShowConsultas() {
    return isInitialized &&
        !isLoading &&
        consultas.isNotEmpty &&
        errorMessage == null;
  }

  bool hasActiveFilters() {
    return searchText.isNotEmpty || selectedDate != null;
  }

  int getFilteredCount() {
    return filteredConsultas.length;
  }

  String getFilterSummary() {
    final filters = <String>[];

    if (searchText.isNotEmpty) {
      filters.add('Busca: "$searchText"');
    }

    if (selectedDate != null) {
      filters.add('Data: ${ConsultaUtils.formatDate(selectedDate!)}');
    }

    if (filters.isEmpty) {
      return 'Sem filtros aplicados';
    }

    return filters.join(' • ');
  }

  // Search and filter methods
  List<Consulta> searchConsultas(String query) {
    return _consultaService.searchConsultas(consultas, query);
  }

  List<Consulta> filterByDate(List<Consulta> consultas, DateTime date) {
    return _consultaService.filterByDate(consultas, date);
  }

  List<Consulta> sortConsultas(
      List<Consulta> consultas, String sortBy, bool ascending) {
    return _consultaService.sortConsultas(consultas, sortBy, ascending);
  }

  // Repository methods
  Future<Consulta?> getConsultaById(String id) async {
    try {
      return await _consultaService.getConsultaById(
        id: id,
        repository: _repository,
      );
    } catch (e) {
      debugPrint('Erro ao buscar consulta por ID: $e');
      return null;
    }
  }

  Future<String> exportConsultasToCsv(String animalId) async {
    try {
      return await _consultaService.exportToCsv(
        animalId: animalId,
        repository: _repository,
      );
    } catch (e) {
      debugPrint('Erro ao exportar consultas para CSV: $e');
      return '';
    }
  }

  // Statistics methods
  Map<String, dynamic> getConsultaStats() {
    return _consultaService.generateStatistics(consultas);
  }

  List<Map<String, dynamic>> getMonthlyStats() {
    return _consultaService.getMonthlyConsultaStats(consultas);
  }

  Map<String, int> getVeterinarioStats() {
    return _consultaService.getVeterinarioStats(consultas);
  }

  Map<String, int> getMotivoStats() {
    return _consultaService.getMotivoStats(consultas);
  }

  // Monthly navigation methods
  final RxInt _currentMonthIndex = 0.obs;

  List<DateTime> getMonthsList() {
    if (consultas.isEmpty) {
      return [DateTime.now()];
    }

    final dates = consultas.map((consulta) => DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta)).toList();
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
