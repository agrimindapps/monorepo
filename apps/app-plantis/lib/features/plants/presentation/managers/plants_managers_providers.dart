import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'plant_form_state_manager.dart';
import 'plants_search_manager.dart';
import 'plants_sort_manager.dart';
import 'plants_view_mode_manager.dart';
import 'plants_realtime_sync_manager.dart';

/// Provides managers for plants feature presentation layer
/// Centralizes DIP for all managers

final plantsSearchManagerProvider = Provider((ref) {
  return PlantsSearchManager(ref);
});

final plantsViewModeManagerProvider = Provider((ref) {
  return PlantsViewModeManager(ref);
});

final plantsSortManagerProvider = Provider((ref) {
  return PlantsSortManager(ref);
});

final plantFormStateManagerProvider = Provider((ref) {
  return PlantFormStateManager();
});

final plantsRealtimeSyncManagerProvider = Provider((ref) {
  return PlantsRealtimeSyncManager(ref);
});
