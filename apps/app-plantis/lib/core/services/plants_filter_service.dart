import '../../features/plants/domain/entities/plant.dart';

/// Serviço responsável APENAS por filtros, busca e ordenação de plantas
/// Resolve violação SRP - separando lógica de filtros do estado UI
class PlantsFilterService {
  /// Filtra plantas por termo de busca
  List<Plant> filterBySearchTerm(List<Plant> plants, String searchTerm) {
    if (searchTerm.isEmpty) return plants;
    
    final lowerSearchTerm = searchTerm.toLowerCase();
    
    return plants.where((plant) {
      final nameMatches = plant.name.toLowerCase().contains(lowerSearchTerm);
      final speciesMatches = plant.species?.toLowerCase().contains(lowerSearchTerm) ?? false;
      final notesMatches = plant.notes?.toLowerCase().contains(lowerSearchTerm) ?? false;
      
      return nameMatches || speciesMatches || notesMatches;
    }).toList();
  }
  
  /// Filtra plantas por espaço
  List<Plant> filterBySpace(List<Plant> plants, String? spaceId) {
    if (spaceId == null || spaceId.isEmpty) return plants;
    
    return plants.where((plant) => plant.spaceId == spaceId).toList();
  }
  
  /// Filtra plantas por status de cuidado
  List<Plant> filterByCareStatus(List<Plant> plants, PlantCareStatus status) {
    return plants.where((plant) => _getPlantCareStatus(plant) == status).toList();
  }
  
  /// Filtra plantas que precisam de rega hoje
  List<Plant> filterNeedingWaterToday(List<Plant> plants) {
    final today = DateTime.now();
    
    return plants.where((plant) {
      if (plant.lastWatered == null || plant.wateringFrequency == null) {
        return false;
      }
      
      final daysSinceLastWatering = today.difference(plant.lastWatered!).inDays;
      return daysSinceLastWatering >= plant.wateringFrequency!;
    }).toList();
  }
  
  /// Filtra plantas favoritas
  List<Plant> filterFavorites(List<Plant> plants) {
    return plants.where((plant) => plant.isFavorite).toList();
  }
  
  /// Ordena plantas por critério
  List<Plant> sortPlants(List<Plant> plants, PlantSortOption sortOption) {
    final plantsCopy = List<Plant>.from(plants);
    
    switch (sortOption) {
      case PlantSortOption.nameAZ:
        plantsCopy.sort((a, b) => a.name.compareTo(b.name));
        break;
      case PlantSortOption.nameZA:
        plantsCopy.sort((a, b) => b.name.compareTo(a.name));
        break;
      case PlantSortOption.dateNewest:
        plantsCopy.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        break;
      case PlantSortOption.dateOldest:
        plantsCopy.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
        break;
      case PlantSortOption.careUrgency:
        plantsCopy.sort((a, b) => _compareByCareUrgency(a, b));
        break;
      case PlantSortOption.lastWatered:
        plantsCopy.sort((a, b) => _compareByLastWatered(a, b));
        break;
    }
    
    return plantsCopy;
  }
  
  /// Busca plantas com filtros múltiplos
  List<Plant> searchWithFilters({
    required List<Plant> plants,
    String? searchTerm,
    String? spaceId,
    PlantCareStatus? careStatus,
    bool onlyFavorites = false,
    bool onlyNeedingWater = false,
    PlantSortOption sortOption = PlantSortOption.nameAZ,
  }) {
    var result = plants;
    if (searchTerm != null && searchTerm.isNotEmpty) {
      result = filterBySearchTerm(result, searchTerm);
    }
    
    if (spaceId != null) {
      result = filterBySpace(result, spaceId);
    }
    
    if (careStatus != null) {
      result = filterByCareStatus(result, careStatus);
    }
    
    if (onlyFavorites) {
      result = filterFavorites(result);
    }
    
    if (onlyNeedingWater) {
      result = filterNeedingWaterToday(result);
    }
    result = sortPlants(result, sortOption);
    
    return result;
  }
  
  /// Helper: Obtém status de cuidado da planta
  PlantCareStatus _getPlantCareStatus(Plant plant) {
    if (plant.lastWatered == null || plant.wateringFrequency == null) {
      return PlantCareStatus.unknown;
    }
    
    final daysSinceLastWatering = DateTime.now().difference(plant.lastWatered!).inDays;
    final frequency = plant.wateringFrequency!;
    
    if (daysSinceLastWatering >= frequency + 2) {
      return PlantCareStatus.critical;
    } else if (daysSinceLastWatering >= frequency) {
      return PlantCareStatus.needsWater;
    } else if (daysSinceLastWatering >= frequency - 1) {
      return PlantCareStatus.soon;
    } else {
      return PlantCareStatus.healthy;
    }
  }
  
  /// Helper: Compara plantas por urgência de cuidado
  int _compareByCareUrgency(Plant a, Plant b) {
    final statusA = _getPlantCareStatus(a);
    final statusB = _getPlantCareStatus(b);
    const priorityOrder = {
      PlantCareStatus.critical: 0,
      PlantCareStatus.needsWater: 1,
      PlantCareStatus.soon: 2,
      PlantCareStatus.healthy: 3,
      PlantCareStatus.unknown: 4,
    };
    
    final priorityA = priorityOrder[statusA] ?? 5;
    final priorityB = priorityOrder[statusB] ?? 5;
    
    return priorityA.compareTo(priorityB);
  }
  
  /// Helper: Compara plantas por data da última rega
  int _compareByLastWatered(Plant a, Plant b) {
    if (a.lastWatered == null && b.lastWatered == null) return 0;
    if (a.lastWatered == null) return 1; // a vem depois (nunca regada)
    if (b.lastWatered == null) return -1; // b vem depois (nunca regada)
    
    return a.lastWatered!.compareTo(b.lastWatered!);
  }
}

/// Enum para opções de ordenação
enum PlantSortOption {
  nameAZ,
  nameZA,
  dateNewest,
  dateOldest,
  careUrgency,
  lastWatered,
}

/// Enum para status de cuidado
enum PlantCareStatus {
  critical,
  needsWater,
  soon,
  healthy,
  unknown,
}
