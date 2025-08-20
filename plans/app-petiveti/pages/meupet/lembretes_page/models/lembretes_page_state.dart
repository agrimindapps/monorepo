enum LembretesPageState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

class LembretesPageStateModel {
  final LembretesPageState state;
  final String? errorMessage;
  final bool hasSelectedAnimal;
  final int lembreteCount;
  final bool isInitialized;

  const LembretesPageStateModel({
    this.state = LembretesPageState.initial,
    this.errorMessage,
    this.hasSelectedAnimal = false,
    this.lembreteCount = 0,
    this.isInitialized = false,
  });

  LembretesPageStateModel copyWith({
    LembretesPageState? state,
    String? errorMessage,
    bool? hasSelectedAnimal,
    int? lembreteCount,
    bool? isInitialized,
  }) {
    return LembretesPageStateModel(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      hasSelectedAnimal: hasSelectedAnimal ?? this.hasSelectedAnimal,
      lembreteCount: lembreteCount ?? this.lembreteCount,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool get isLoading => state == LembretesPageState.loading;
  bool get isLoaded => state == LembretesPageState.loaded;
  bool get hasError => state == LembretesPageState.error;
  bool get isEmpty => state == LembretesPageState.empty;
  bool get isInitial => state == LembretesPageState.initial;
  bool get canShowContent => isLoaded && hasSelectedAnimal && lembreteCount > 0;
  bool get shouldShowEmptyState => hasSelectedAnimal && isEmpty;
  bool get shouldShowNoAnimalSelected => !hasSelectedAnimal;
  bool get shouldShowLoading => isLoading;
  bool get shouldShowError => hasError && errorMessage != null;
}