/// **OCP Pattern**: Segregated sort state
/// Open for extension: features can extend with additional sort criteria
/// Closed for modification: base design remains stable
library;

// Import enum from dedicated file to avoid circular dependencies
import 'weight_sort_order.dart';
export 'weight_sort_order.dart';

/// **OCP Pattern**: State class extending implicit base behavior
/// - Immutable value object
/// - Copyable for immutable updates
/// - Can be extended with additional sort fields without modifying this class
class WeightsSortState {
  final WeightSortOrder sortOrder;

  const WeightsSortState({this.sortOrder = WeightSortOrder.dateDesc});

  /// copyWith pattern enables extension through composition
  /// Subclasses can override to add their own fields
  WeightsSortState copyWith({WeightSortOrder? sortOrder}) {
    return WeightsSortState(sortOrder: sortOrder ?? this.sortOrder);
  }
}
