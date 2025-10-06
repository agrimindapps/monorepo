import '../entities/plant.dart';

/// Service responsible for filtering and searching plants
/// Extracted from PlantsProvider to follow Single Responsibility Principle
class PlantsFilterService {
  /// Filter plants by space ID
  List<Plant> filterBySpace(List<Plant> plants, String? spaceId) {
    if (spaceId == null) return plants;
    return plants.where((plant) => plant.spaceId == spaceId).toList();
  }

  /// Search plants by query (name, species, notes)
  List<Plant> searchPlants(List<Plant> plants, String query) {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase().trim();

    return plants.where((plant) {
      if (plant.name.toLowerCase().contains(lowerQuery)) return true;
      if (plant.species != null &&
          plant.species!.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      if (plant.notes != null &&
          plant.notes!.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      return false;
    }).toList();
  }

  /// Group plants by spaces
  Map<String?, List<Plant>> groupPlantsBySpaces(List<Plant> plants) {
    final Map<String?, List<Plant>> groupedPlants = {};

    for (final plant in plants) {
      final spaceId = plant.spaceId;
      if (!groupedPlants.containsKey(spaceId)) {
        groupedPlants[spaceId] = [];
      }
      groupedPlants[spaceId]!.add(plant);
    }

    return groupedPlants;
  }

  /// Get plant counts by space
  Map<String?, int> getPlantCountsBySpace(List<Plant> plants) {
    final grouped = groupPlantsBySpaces(plants);
    return grouped.map((spaceId, plants) => MapEntry(spaceId, plants.length));
  }

  /// Check if data has changed (for optimization)
  bool hasDataChanged(List<Plant> oldPlants, List<Plant> newPlants) {
    if (oldPlants.length != newPlants.length) {
      return true;
    }
    for (int i = 0; i < oldPlants.length; i++) {
      final currentPlant = oldPlants[i];
      Plant? newPlant;
      try {
        newPlant = newPlants.firstWhere((p) => p.id == currentPlant.id);
      } catch (e) {
        return true;
      }
      if (currentPlant.updatedAt != newPlant.updatedAt) {
        return true;
      }
    }

    return false;
  }
}
