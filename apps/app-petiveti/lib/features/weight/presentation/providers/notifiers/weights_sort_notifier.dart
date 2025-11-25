import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/weight.dart';

import '../../states/weights_sort_state.dart';

part 'weights_sort_notifier.g.dart';


/// **SRP Pattern**: Notifier specialized for SORTING operations ONLY
/// 
/// Responsibility: Handles weight list sorting by different criteria
/// - Does NOT handle CRUD operations (see WeightsCrudNotifier)
/// - Does NOT handle filtering (see WeightsFilterNotifier)
/// - Does NOT handle analytics
/// - Single reason to change: sorting logic changes
///
/// This focused responsibility makes it:
/// - Easy to test (mock one behavior)
/// - Reusable across features
/// - Maintainable (changes isolated)
/// 
/// Migrated to Riverpod 3.0 Notifier pattern
@riverpod
class WeightsSortNotifier extends _$WeightsSortNotifier {
  @override
  WeightsSortState build() => const WeightsSortState();

  /// Sets the sort order for weights
  void setSortOrder(WeightSortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  /// Applies the current sort order to a list of weights
  /// 
  /// This logic could be extracted to SortService for reusability,
  /// but kept here for domain-specific sort criteria (weight-specific comparisons)
  List<Weight> sortWeights(List<Weight> weights) {
    final sorted = List<Weight>.from(weights);

    switch (state.sortOrder) {
      case WeightSortOrder.dateAsc:
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case WeightSortOrder.dateDesc:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case WeightSortOrder.weightAsc:
        sorted.sort((a, b) => a.weight.compareTo(b.weight));
        break;
      case WeightSortOrder.weightDesc:
        sorted.sort((a, b) => b.weight.compareTo(a.weight));
        break;
    }

    return sorted;
  }
}
