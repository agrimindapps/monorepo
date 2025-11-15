/// **OCP Pattern**: Segregated filter state
/// Open for extension: features can extend with additional filter criteria
/// Closed for modification: base design remains stable
class WeightsFilterState {
  final String? selectedAnimalId;

  const WeightsFilterState({this.selectedAnimalId});

  /// copyWith pattern enables extension through composition
  /// Subclasses can override to add their own filter fields
  WeightsFilterState copyWith({String? selectedAnimalId}) {
    return WeightsFilterState(selectedAnimalId: selectedAnimalId);
  }
}
