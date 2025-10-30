import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/plants_providers.dart' show ViewMode;

/// Manages view mode transitions and state
class PlantsViewModeManager {
  final Ref ref;

  PlantsViewModeManager(this.ref);

  /// Toggle between grouped and non-grouped view modes
  ViewMode toggleGrouping(ViewMode currentMode) {
    if (_isGroupedBySpaces(currentMode)) {
      // Return to previous non-grouped mode
      return currentMode == ViewMode.groupedBySpacesGrid
          ? ViewMode.grid
          : ViewMode.list;
    } else {
      // Switch to grouped view matching current mode
      return currentMode == ViewMode.grid
          ? ViewMode.groupedBySpacesGrid
          : ViewMode.groupedBySpacesList;
    }
  }

  /// Check if current view mode is grouped by spaces
  bool isGroupedBySpaces(ViewMode mode) => _isGroupedBySpaces(mode);

  /// Get display name for view mode
  String getViewModeName(ViewMode mode) {
    switch (mode) {
      case ViewMode.list:
        return 'Lista';
      case ViewMode.grid:
        return 'Grade';
      case ViewMode.groupedBySpaces:
      case ViewMode.groupedBySpacesGrid:
      case ViewMode.groupedBySpacesList:
        return 'Agrupado por Espaço';
    }
  }

  /// Get icon for view mode
  int getViewModeIcon(ViewMode mode) {
    if (_isGroupedBySpaces(mode)) {
      return 0xe3b1; // Icons.category
    }
    return 0xe3e6; // Icons.view_list
  }

  bool _isGroupedBySpaces(ViewMode mode) {
    return mode == ViewMode.groupedBySpaces ||
        mode == ViewMode.groupedBySpacesGrid ||
        mode == ViewMode.groupedBySpacesList;
  }

  /// Get initial view mode for fresh app
  ViewMode getDefaultViewMode() => ViewMode.list;

  /// Validate view mode transition
  bool isValidModeTransition(ViewMode from, ViewMode to) => true;
}
