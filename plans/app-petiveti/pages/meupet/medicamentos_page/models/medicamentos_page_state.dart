enum MedicamentosPageState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

class MedicamentosPageStateModel {
  final MedicamentosPageState state;
  final String? errorMessage;
  final bool hasSelectedAnimal;
  final int medicamentoCount;

  const MedicamentosPageStateModel({
    this.state = MedicamentosPageState.initial,
    this.errorMessage,
    this.hasSelectedAnimal = false,
    this.medicamentoCount = 0,
  });

  MedicamentosPageStateModel copyWith({
    MedicamentosPageState? state,
    String? errorMessage,
    bool? hasSelectedAnimal,
    int? medicamentoCount,
  }) {
    return MedicamentosPageStateModel(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      hasSelectedAnimal: hasSelectedAnimal ?? this.hasSelectedAnimal,
      medicamentoCount: medicamentoCount ?? this.medicamentoCount,
    );
  }

  bool get isLoading => state == MedicamentosPageState.loading;
  bool get isLoaded => state == MedicamentosPageState.loaded;
  bool get hasError => state == MedicamentosPageState.error;
  bool get isEmpty => state == MedicamentosPageState.empty;
  bool get isInitial => state == MedicamentosPageState.initial;
  bool get canShowContent => isLoaded && hasSelectedAnimal && medicamentoCount > 0;
  bool get shouldShowEmptyState => hasSelectedAnimal && isEmpty;
  bool get shouldShowNoAnimalSelected => !hasSelectedAnimal;
}