import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state_widget.dart';

/// Legacy wrapper for EmptyPlantsWidget - now uses consolidated EmptyStateWidget
/// Kept for backward compatibility during transition
class EmptyPlantsWidget extends StatelessWidget {
  final bool isSearching;
  final String searchQuery;
  final VoidCallback? onClearSearch;
  final VoidCallback? onAddPlant;

  const EmptyPlantsWidget({
    super.key,
    this.isSearching = false,
    this.searchQuery = '',
    this.onClearSearch,
    this.onAddPlant,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget.plants(
      isSearching: isSearching,
      searchQuery: searchQuery,
      onClearSearch: onClearSearch,
      onAddPlant: onAddPlant,
    );
  }
}
