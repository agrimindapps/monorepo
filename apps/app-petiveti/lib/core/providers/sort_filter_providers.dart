import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/filter_service.dart';
import '../services/sort_service.dart';

/// **DIP - Dependency Inversion Principle**
/// Central providers for sort and filter services
/// All features should use these providers instead of creating their own instances

/// Sort service provider for generic sorting operations
final sortServiceProvider = Provider<SortService<dynamic>>((ref) {
  return GenericSortService<dynamic>(
    sortFunction: (items, sortOrder) => items,
    resetCallback: null,
  );
});

/// Filter service provider for generic filtering operations
final filterServiceProvider = Provider<FilterService<dynamic, dynamic>>((ref) {
  return GenericFilterService<dynamic, dynamic>(
    filterFunction: (items, filterCriteria) => items,
    resetCallback: null,
  );
});
