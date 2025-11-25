import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/filter_service.dart';
import '../services/stats_service.dart';

part 'filter_stats_providers.g.dart';

/// Provider for FilterService
/// Single Responsibility: Provides filtering operations without persistence
@riverpod
FilterService filterService(Ref ref) {
  return FilterService();
}

/// Provider for StatsService
/// Single Responsibility: Provides statistics calculations
@riverpod
StatsService statsService(Ref ref) {
  return StatsService();
}
