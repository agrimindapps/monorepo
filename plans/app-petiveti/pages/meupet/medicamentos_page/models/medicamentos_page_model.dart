// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/15_medicamento_model.dart';
import '../../../../utils/string_utils.dart';

class MedicamentosPageModel {
  List<MedicamentoVet> medicamentos;
  bool isLoading;
  String? errorMessage;
  String? selectedAnimalId;
  Animal? selectedAnimal;
  int? dataInicial;
  int? dataFinal;

  MedicamentosPageModel({
    this.medicamentos = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedAnimalId,
    this.selectedAnimal,
    this.dataInicial,
    this.dataFinal,
  });

  MedicamentosPageModel copyWith({
    List<MedicamentoVet>? medicamentos,
    bool? isLoading,
    String? errorMessage,
    String? selectedAnimalId,
    Animal? selectedAnimal,
    int? dataInicial,
    int? dataFinal,
  }) {
    return MedicamentosPageModel(
      medicamentos: medicamentos ?? this.medicamentos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedAnimalId: selectedAnimalId ?? this.selectedAnimalId,
      selectedAnimal: selectedAnimal ?? this.selectedAnimal,
      dataInicial: dataInicial ?? this.dataInicial,
      dataFinal: dataFinal ?? this.dataFinal,
    );
  }

  void setMedicamentos(List<MedicamentoVet> newMedicamentos) {
    medicamentos = List.from(newMedicamentos);
  }

  void addMedicamento(MedicamentoVet medicamento) {
    medicamentos = [...medicamentos, medicamento];
  }

  void updateMedicamento(MedicamentoVet updatedMedicamento) {
    medicamentos = medicamentos.map((medicamento) {
      return medicamento.id == updatedMedicamento.id ? updatedMedicamento : medicamento;
    }).toList();
  }

  void removeMedicamento(MedicamentoVet medicamentoToRemove) {
    medicamentos = medicamentos.where((medicamento) => medicamento.id != medicamentoToRemove.id).toList();
  }

  void clearMedicamentos() {
    medicamentos = [];
  }

  void setLoading(bool loading) {
    isLoading = loading;
  }

  void setError(String? error) {
    errorMessage = error;
  }

  void clearError() {
    errorMessage = null;
  }

  void setSelectedAnimal(String? animalId, Animal? animal) {
    selectedAnimalId = animalId;
    selectedAnimal = animal;
  }

  void clearSelectedAnimal() {
    selectedAnimalId = null;
    selectedAnimal = null;
  }

  void setDateRange(int? inicial, int? dataFinalParam) {
    dataInicial = inicial;
    dataFinal = dataFinalParam;
  }

  void clearDateRange() {
    dataInicial = null;
    dataFinal = null;
  }

  bool get hasMedicamentos => medicamentos.isNotEmpty;
  bool get isEmpty => medicamentos.isEmpty;
  int get medicamentoCount => medicamentos.length;
  bool get hasSelectedAnimal => selectedAnimalId != null && selectedAnimalId!.isNotEmpty;
  bool get hasError => errorMessage != null;
  bool get hasDateRange => dataInicial != null && dataFinal != null;

  List<MedicamentoVet> get filteredMedicamentos {
    if (!hasDateRange) return medicamentos;
    
    return medicamentos.where((medicamento) {
      final startDate = DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento);
      final endDate = DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento);
      final filterStart = DateTime.fromMillisecondsSinceEpoch(dataInicial!);
      final filterEnd = DateTime.fromMillisecondsSinceEpoch(dataFinal!);
      
      return startDate.isBefore(filterEnd.add(const Duration(days: 1))) &&
             endDate.isAfter(filterStart.subtract(const Duration(days: 1)));
    }).toList();
  }

  bool isMedicamentoActive(MedicamentoVet medicamento) {
    final today = DateTime.now();
    return today.millisecondsSinceEpoch < medicamento.fimTratamento;
  }

  int diasRestantesTratamento(MedicamentoVet medicamento) {
    final today = DateTime.now();
    final endDate = DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento);
    
    if (endDate.isBefore(today)) return 0;
    
    return endDate.difference(today).inDays;
  }

  String formatDateToString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String getFormattedCurrentMonth() {
    final now = DateTime.now();
    return StringUtils.capitalize(DateFormat('MMM yy', 'pt_BR').format(now));
  }

  List<String> getAvailableMonths() {
    if (medicamentos.isEmpty) {
      return [getFormattedCurrentMonth()];
    }

    final sortedMedicamentos = List<MedicamentoVet>.from(medicamentos)
      ..sort((a, b) => a.inicioTratamento.compareTo(b.inicioTratamento));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedMedicamentos.first.inicioTratamento);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedMedicamentos.last.inicioTratamento);

    final meses = <String>[];
    DateTime currentDate = DateTime(dataInicial.year, dataInicial.month);
    final endDate = DateTime(dataFinal.year, dataFinal.month);

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final mesFormatado = StringUtils.capitalize(
        DateFormat('MMM yy', 'pt_BR').format(currentDate)
      );
      meses.add(mesFormatado);
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    final mesAtual = getFormattedCurrentMonth();
    if (!meses.contains(mesAtual)) {
      meses.add(mesAtual);
    }

    return meses.reversed.toList();
  }

  String getFormattedPeriod() {
    if (medicamentos.isEmpty) {
      return getFormattedCurrentMonth();
    }

    final sortedMedicamentos = List<MedicamentoVet>.from(medicamentos)
      ..sort((a, b) => a.inicioTratamento.compareTo(b.inicioTratamento));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedMedicamentos.first.inicioTratamento);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedMedicamentos.last.inicioTratamento);

    final mesInicial = StringUtils.capitalize(
      DateFormat('MMM yy', 'pt_BR').format(dataInicial)
    );
    
    final mesFinal = StringUtils.capitalize(
      DateFormat('MMM yy', 'pt_BR').format(dataFinal)
    );

    if (mesInicial == mesFinal) {
      return mesInicial;
    }

    return '$mesInicial - $mesFinal';
  }

  String getSubtitle() {
    return '$medicamentoCount registros';
  }

  List<MedicamentoVet> get medicamentosAtivos {
    return medicamentos.where((medicamento) => isMedicamentoActive(medicamento)).toList();
  }

  List<MedicamentoVet> get medicamentosFinalizados {
    return medicamentos.where((medicamento) => !isMedicamentoActive(medicamento)).toList();
  }
}
