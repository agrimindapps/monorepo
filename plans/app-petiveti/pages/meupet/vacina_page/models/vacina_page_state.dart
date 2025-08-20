// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/16_vacina_model.dart';

/// State management model for VacinaPage
class VacinaPageState {
  final List<VacinaVet> vacinas;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedAnimalId;
  final Animal? selectedAnimal;
  final int? dataInicial;
  final int? dataFinal;

  const VacinaPageState({
    this.vacinas = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedAnimalId,
    this.selectedAnimal,
    this.dataInicial,
    this.dataFinal,
  });

  VacinaPageState copyWith({
    List<VacinaVet>? vacinas,
    bool? isLoading,
    String? errorMessage,
    String? selectedAnimalId,
    Animal? selectedAnimal,
    int? dataInicial,
    int? dataFinal,
  }) {
    return VacinaPageState(
      vacinas: vacinas ?? this.vacinas,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedAnimalId: selectedAnimalId ?? this.selectedAnimalId,
      selectedAnimal: selectedAnimal ?? this.selectedAnimal,
      dataInicial: dataInicial ?? this.dataInicial,
      dataFinal: dataFinal ?? this.dataFinal,
    );
  }

  // Getters for computed properties
  bool get hasVacinas => vacinas.isNotEmpty;
  bool get isEmpty => vacinas.isEmpty;
  int get vacinaCount => vacinas.length;
  bool get hasSelectedAnimal => selectedAnimalId != null && selectedAnimalId!.isNotEmpty;
  bool get hasError => errorMessage != null;
  bool get hasDateRange => dataInicial != null && dataFinal != null;
}
