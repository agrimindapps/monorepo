class WeightsCrudState {
  final bool isLoading;
  final String? error;

  const WeightsCrudState({this.isLoading = false, this.error});

  WeightsCrudState copyWith({bool? isLoading, String? error}) {
    return WeightsCrudState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
