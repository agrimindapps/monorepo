// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/15_medicamento_model.dart';
import '../../../../repository/medicamento_repository.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../models/medicamentos_page_model.dart';

class MedicamentosPageController extends GetxController {
  final _animalController = Get.find<AnimalPageController>();
  final _model = MedicamentosPageModel().obs;
  final MedicamentoRepository _repository;

  MedicamentosPageController({MedicamentoRepository? repository})
      : _repository = repository ?? MedicamentoRepository();

  static Future<MedicamentosPageController> initializeController() async {
    await MedicamentoRepository.initialize();
    final controller = MedicamentosPageController();
    Get.put(controller);
    return controller;
  }

  MedicamentosPageModel get model => _model.value;
  List<MedicamentoVet> get medicamentos => model.medicamentos;
  List<MedicamentoVet> get filteredMedicamentos => model.filteredMedicamentos;
  bool get isLoading => model.isLoading;
  String? get errorMessage => model.errorMessage;
  bool get hasMedicamentos => model.hasMedicamentos;
  bool get isEmpty => model.isEmpty;
  int get medicamentoCount => model.medicamentoCount;
  String? get selectedAnimalId => model.selectedAnimalId;
  Animal? get selectedAnimal => model.selectedAnimal;
  bool get hasSelectedAnimal => model.hasSelectedAnimal;
  bool get hasError => model.hasError;
  bool get hasDateRange => model.hasDateRange;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      setLoading(true);
      await loadMedicamentos();
    } catch (e) {
      setError('Erro ao inicializar controlador: $e');
      debugPrint('Erro ao inicializar MedicamentosPageController: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadMedicamentos([String? animalId]) async {
    try {
      setLoading(true);
      clearError();

      final targetAnimalId = animalId ?? _animalController.selectedAnimalId;

      if (targetAnimalId.isNotEmpty) {
        final result = await _repository.getMedicamentos(
          targetAnimalId,
          dataInicial: model.dataInicial ??
              DateTime.now()
                  .subtract(const Duration(days: 30))
                  .millisecondsSinceEpoch,
          dataFinal: model.dataFinal ??
              DateTime.now()
                  .add(const Duration(days: 30))
                  .millisecondsSinceEpoch,
        );
        setMedicamentos(result);
      } else {
        clearMedicamentos();
      }
    } catch (e) {
      setError('Failed to load medications: $e');
      debugPrint('Erro ao carregar medicamentos: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteMedicamento(MedicamentoVet medicamento) async {
    try {
      final result = await _repository.deleteMedicamento(medicamento);
      if (result) {
        removeMedicamento(medicamento);
      } else {
        throw Exception('Falha ao excluir medicamento');
      }
    } catch (e) {
      setError('Erro ao excluir medicamento: $e');
      debugPrint('Erro ao excluir medicamento: $e');
      rethrow;
    }
  }

  Future<void> refreshMedicamentos() async {
    await loadMedicamentos();
  }

  void onAnimalSelected(String? animalId, Animal? animal) {
    setSelectedAnimal(animalId, animal);
    if (animalId != null && animalId.isNotEmpty) {
      loadMedicamentos(animalId);
    } else {
      clearMedicamentos();
    }
  }

  void onDateRangeChanged(int? dataInicial, int? dataFinal) {
    setDateRange(dataInicial, dataFinal);
    loadMedicamentos();
  }

  void setLoading(bool loading) {
    _model.update((model) {
      model?.setLoading(loading);
    });
  }

  void setError(String? error) {
    _model.update((model) {
      model?.setError(error);
    });
  }

  void clearError() {
    _model.update((model) {
      model?.clearError();
    });
  }

  void setMedicamentos(List<MedicamentoVet> medicamentos) {
    _model.update((model) {
      model?.setMedicamentos(medicamentos);
    });
  }

  void addMedicamento(MedicamentoVet medicamento) {
    _model.update((model) {
      model?.addMedicamento(medicamento);
    });
  }

  void updateMedicamento(MedicamentoVet medicamento) {
    _model.update((model) {
      model?.updateMedicamento(medicamento);
    });
  }

  void removeMedicamento(MedicamentoVet medicamento) {
    _model.update((model) {
      model?.removeMedicamento(medicamento);
    });
  }

  void clearMedicamentos() {
    _model.update((model) {
      model?.clearMedicamentos();
    });
  }

  void setSelectedAnimal(String? animalId, Animal? animal) {
    _model.update((model) {
      model?.setSelectedAnimal(animalId, animal);
    });
  }

  void clearSelectedAnimal() {
    _model.update((model) {
      model?.clearSelectedAnimal();
    });
  }

  void setDateRange(int? dataInicial, int? dataFinal) {
    _model.update((model) {
      model?.setDateRange(dataInicial, dataFinal);
    });
  }

  void clearDateRange() {
    _model.update((model) {
      model?.clearDateRange();
    });
  }

  String getSubtitle() {
    return model.getSubtitle();
  }

  String formatDateToString(int timestamp) {
    return model.formatDateToString(timestamp);
  }

  String getFormattedCurrentMonth() {
    return model.getFormattedCurrentMonth();
  }

  List<String> getAvailableMonths() {
    return model.getAvailableMonths();
  }

  String getFormattedPeriod() {
    return model.getFormattedPeriod();
  }

  int diasRestantesTratamento(MedicamentoVet medicamento) {
    return model.diasRestantesTratamento(medicamento);
  }

  bool isMedicamentoActive(MedicamentoVet medicamento) {
    return model.isMedicamentoActive(medicamento);
  }

  bool shouldShowLoading() {
    return isLoading;
  }

  bool shouldShowError() {
    return hasError;
  }

  bool shouldShowNoAnimalSelected() {
    return _animalController.selectedAnimalId.isEmpty;
  }

  bool shouldShowNoData() {
    return !shouldShowNoAnimalSelected() && isEmpty && !isLoading && !hasError;
  }

  bool shouldShowMedicamentos() {
    return !shouldShowNoAnimalSelected() &&
        hasMedicamentos &&
        !isLoading &&
        !hasError;
  }

  bool canAddMedicamento() {
    return _animalController.selectedAnimalId.isNotEmpty;
  }

  List<MedicamentoVet> searchMedicamentos(String query) {
    if (query.isEmpty) return medicamentos;
    final lowercaseQuery = query.toLowerCase();
    return medicamentos.where((medicamento) {
      return medicamento.nomeMedicamento
              .toLowerCase()
              .contains(lowercaseQuery) ||
          medicamento.dosagem.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  double progressoTratamento(MedicamentoVet medicamento) {
    final inicio = medicamento.inicioTratamento;
    final fim = medicamento.fimTratamento;
    final hoje = DateTime.now().millisecondsSinceEpoch;
    if (hoje <= inicio) return 0.0;
    if (hoje >= fim) return 1.0;
    final duracaoTotal = fim - inicio;
    final decorrido = hoje - inicio;
    return decorrido / duracaoTotal;
  }

  List<MedicamentoVet> get medicamentosAtivos {
    final hoje = DateTime.now().millisecondsSinceEpoch;
    return medicamentos
        .where(
            (med) => med.inicioTratamento <= hoje && med.fimTratamento >= hoje)
        .toList();
  }

  List<MedicamentoVet> getMedicamentosParaHoje() {
    final hoje = DateTime.now();
    final hojeMilisegundos =
        DateTime(hoje.year, hoje.month, hoje.day).millisecondsSinceEpoch;
    return medicamentos
        .where((medicamento) =>
            medicamento.inicioTratamento <= hojeMilisegundos &&
            medicamento.fimTratamento >= hojeMilisegundos)
        .toList();
  }

  // Monthly navigation methods
  final RxInt _currentMonthIndex = 0.obs;

  List<DateTime> getMonthsList() {
    if (medicamentos.isEmpty) {
      return [DateTime.now()];
    }

    final dates = medicamentos.map((medicamento) => DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento)).toList();
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
