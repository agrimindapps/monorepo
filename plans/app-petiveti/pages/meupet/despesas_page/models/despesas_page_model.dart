// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/13_despesa_model.dart';

class DespesasPageModel {
  List<DespesaVet> despesas;
  List<DespesaVet> filteredDespesas;
  String? selectedAnimalId;
  Animal? selectedAnimal;
  String searchText;
  DateTime? dataInicial;
  DateTime? dataFinal;

  DespesasPageModel({
    this.despesas = const [],
    List<DespesaVet>? filteredDespesas,
    this.selectedAnimalId,
    this.selectedAnimal,
    this.searchText = '',
    this.dataInicial,
    this.dataFinal,
  }) : filteredDespesas = filteredDespesas ?? despesas;

  DespesasPageModel copyWith({
    List<DespesaVet>? despesas,
    List<DespesaVet>? filteredDespesas,
    String? selectedAnimalId,
    Animal? selectedAnimal,
    String? searchText,
    DateTime? dataInicial,
    DateTime? dataFinal,
  }) {
    return DespesasPageModel(
      despesas: despesas ?? this.despesas,
      filteredDespesas: filteredDespesas ?? this.filteredDespesas,
      selectedAnimalId: selectedAnimalId ?? this.selectedAnimalId,
      selectedAnimal: selectedAnimal ?? this.selectedAnimal,
      searchText: searchText ?? this.searchText,
      dataInicial: dataInicial ?? this.dataInicial,
      dataFinal: dataFinal ?? this.dataFinal,
    );
  }

  void addDespesa(DespesaVet despesa) {
    despesas = [...despesas, despesa];
    _updateFilteredDespesas();
  }

  void updateDespesa(DespesaVet updatedDespesa) {
    despesas = despesas.map((despesa) {
      return despesa.id == updatedDespesa.id ? updatedDespesa : despesa;
    }).toList();
    _updateFilteredDespesas();
  }

  void removeDespesa(DespesaVet despesaToRemove) {
    despesas = despesas.where((despesa) => despesa.id != despesaToRemove.id).toList();
    _updateFilteredDespesas();
  }

  void setDespesas(List<DespesaVet> newDespesas) {
    despesas = List.from(newDespesas);
    _updateFilteredDespesas();
  }

  void setFilteredDespesas(List<DespesaVet> filtered) {
    filteredDespesas = List.from(filtered);
  }

  void clearDespesas() {
    despesas = [];
    filteredDespesas = [];
  }

  void setSelectedAnimal(String? animalId, Animal? animal) {
    selectedAnimalId = animalId;
    selectedAnimal = animal;
  }

  void setSearchText(String text) {
    searchText = text;
    _updateFilteredDespesas();
  }

  void setDateRange(DateTime? inicial, DateTime? finalDate) {
    dataInicial = inicial;
    dataFinal = finalDate;
  }

  void clearSelectedAnimal() {
    selectedAnimalId = null;
    selectedAnimal = null;
  }

  void clearDateRange() {
    dataInicial = null;
    dataFinal = null;
  }

  void _updateFilteredDespesas() {
    List<DespesaVet> filtered = List.from(despesas);

    // Filtro por texto de busca
    if (searchText.isNotEmpty) {
      filtered = filtered.where((despesa) {
        return despesa.descricao.toLowerCase().contains(searchText.toLowerCase()) ||
               despesa.tipo.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    }

    // Filtro por range de datas
    if (hasDateRange) {
      filtered = filtered.where((despesa) {
        final despesaDate = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
        return despesaDate.isAfter(dataInicial!.subtract(const Duration(days: 1))) &&
               despesaDate.isBefore(dataFinal!.add(const Duration(days: 1)));
      }).toList();
    }

    filteredDespesas = filtered;
  }

  // Getters
  bool get hasDespesas => despesas.isNotEmpty;
  bool get isEmpty => despesas.isEmpty;
  int get despesaCount => filteredDespesas.length;
  bool get hasSelectedAnimal => selectedAnimalId != null && selectedAnimalId!.isNotEmpty;
  bool get hasDateRange => dataInicial != null && dataFinal != null;

  double get totalDespesas {
    return filteredDespesas.fold(0.0, (sum, despesa) => sum + despesa.valor);
  }

  double get totalTodasDespesas {
    return despesas.fold(0.0, (sum, despesa) => sum + despesa.valor);
  }

  // Utility methods removed - moved to DespesasUtils
  // Model should only contain data and simple getters

  // Business logic methods removed - moved to DespesasService
  // Model should only contain data and simple computed properties

  @override
  String toString() {
    return 'DespesasPageModel(despesas: ${despesas.length}, filteredDespesas: ${filteredDespesas.length}, '
           'selectedAnimalId: $selectedAnimalId, searchText: "$searchText", '
           'dataInicial: $dataInicial, dataFinal: $dataFinal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DespesasPageModel &&
        other.despesas.length == despesas.length &&
        other.filteredDespesas.length == filteredDespesas.length &&
        other.selectedAnimalId == selectedAnimalId &&
        other.searchText == searchText &&
        other.dataInicial == dataInicial &&
        other.dataFinal == dataFinal;
  }

  @override
  int get hashCode {
    return despesas.length.hashCode ^
        filteredDespesas.length.hashCode ^
        selectedAnimalId.hashCode ^
        searchText.hashCode ^
        dataInicial.hashCode ^
        dataFinal.hashCode;
  }
}
