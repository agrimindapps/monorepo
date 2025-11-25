import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/weight.dart';

import '../../states/weights_filter_state.dart';

part 'weights_filter_notifier.g.dart';


/// **SRP Pattern**: Notifier specialized for FILTERING operations ONLY
/// 
/// Responsibility: Handles weight filtering by animal and other criteria
/// - Does NOT handle CRUD operations (see WeightsCrudNotifier)
/// - Does NOT handle sorting (see WeightsSortNotifier)
/// - Does NOT handle analytics
/// - Single reason to change: filter logic changes
///
/// This focused responsibility makes it:
/// - Easy to test (mock one behavior)
/// - Reusable across features
/// - Maintainable (changes isolated)
/// 
/// Migrated to Riverpod 3.0 Notifier pattern
@riverpod
class WeightsFilterNotifier extends _$WeightsFilterNotifier {
  @override
  WeightsFilterState build() => const WeightsFilterState();

  /// Sets the selected animal for filtering
  void setSelectedAnimal(String? animalId) {
    state = state.copyWith(selectedAnimalId: animalId);
  }

  /// Clears the selected animal filter
  void clearSelectedAnimal() {
    state = state.copyWith(selectedAnimalId: null);
  }

  /// Applies the current filter to a list of weights
  /// 
  /// Filter logic is kept here for domain-specific criteria (animal-based filtering),
  /// but generic filtering could use FilterService for reusability
  List<Weight> getFilteredWeights(List<Weight> allWeights) {
    if (state.selectedAnimalId == null) {
      return allWeights;
    }

    return allWeights
        .where((w) => w.animalId == state.selectedAnimalId)
        .toList();
  }
}
