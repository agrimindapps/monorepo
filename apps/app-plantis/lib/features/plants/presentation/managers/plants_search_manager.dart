import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/plant.dart';

/// Manages plant search operations and state
class PlantsSearchManager {
  final Ref ref;

  PlantsSearchManager(this.ref);

  /// Performs local search on plants list
  List<Plant> searchLocally(
    List<Plant> plants,
    String query, {
    bool searchInNotes = true,
  }) {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.trim().toLowerCase();

    return plants.where((plant) {
      final name = plant.name.toLowerCase();
      final species = plant.species?.toLowerCase() ?? '';
      final notes = plant.notes?.toLowerCase() ?? '';

      final matchesName = name.contains(lowerQuery);
      final matchesSpecies = species.contains(lowerQuery);
      final matchesNotes = searchInNotes && notes.contains(lowerQuery);

      return matchesName || matchesSpecies || matchesNotes;
    }).toList();
  }

  /// Get search query display text
  String getSearchSummary(String query, int resultCount) {
    if (query.isEmpty) return '';
    return 'Procurando por "$query" - $resultCount resultado${resultCount != 1 ? 's' : ''}';
  }

  /// Check if search is active
  bool isSearchActive(String query) => query.trim().isNotEmpty;
}
