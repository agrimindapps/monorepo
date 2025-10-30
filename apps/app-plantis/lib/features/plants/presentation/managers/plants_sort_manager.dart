import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/plants_providers.dart' show SortBy;

/// Manages sort options display and transitions
class PlantsSortManager {
  final Ref ref;

  PlantsSortManager(this.ref);

  /// Get display title for sort option
  String getSortTitle(SortBy sort) {
    switch (sort) {
      case SortBy.name:
        return 'Nome';
      case SortBy.newest:
        return 'Mais recentes';
      case SortBy.oldest:
        return 'Mais antigas';
      case SortBy.species:
        return 'Espécie';
    }
  }

  /// Get all available sort options
  List<SortBy> getAvailableSortOptions() => SortBy.values;

  /// Check if a sort option is current
  bool isSortActive(SortBy current, SortBy option) => current == option;

  /// Get description for sort option
  String getSortDescription(SortBy sort) {
    switch (sort) {
      case SortBy.name:
        return 'Ordenar alfabeticamente por nome';
      case SortBy.newest:
        return 'Plantas adicionadas recentemente primeiro';
      case SortBy.oldest:
        return 'Plantas adicionadas há mais tempo primeiro';
      case SortBy.species:
        return 'Ordenar por espécie';
    }
  }

  /// Get icon code for sort option
  int getSortIcon(SortBy sort) {
    // Material Icons unicode values
    switch (sort) {
      case SortBy.name:
        return 0xf0fa; // Icons.sort_by_alpha
      case SortBy.newest:
        return 0xe192; // Icons.arrow_downward
      case SortBy.oldest:
        return 0xe191; // Icons.arrow_upward
      case SortBy.species:
        return 0xe919; // Icons.category
    }
  }
}
