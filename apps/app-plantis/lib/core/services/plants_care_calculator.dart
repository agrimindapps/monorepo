import '../../features/plants/domain/entities/plant.dart';

/// Serviço responsável APENAS por cálculos de cuidados e status das plantas
/// Resolve violação SRP - separando lógica de cálculos do estado UI
class PlantsCareCalculator {
  /// Calcula o status de cuidado de uma planta
  PlantCareStatus calculateCareStatus(Plant plant) {
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
  
  /// Calcula dias restantes até próxima rega
  int calculateDaysUntilNextWatering(Plant plant) {
    if (plant.lastWatered == null || plant.wateringFrequency == null) {
      return 0;
    }
    
    final daysSinceLastWatering = DateTime.now().difference(plant.lastWatered!).inDays;
    final frequency = plant.wateringFrequency!;
    
    return frequency - daysSinceLastWatering;
  }
  
  /// Calcula data da próxima rega
  DateTime? calculateNextWateringDate(Plant plant) {
    if (plant.lastWatered == null || plant.wateringFrequency == null) {
      return null;
    }
    
    return plant.lastWatered!.add(Duration(days: plant.wateringFrequency!));
  }
  
  /// Verifica se a planta precisa de rega hoje
  bool needsWateringToday(Plant plant) {
    final daysUntilNext = calculateDaysUntilNextWatering(plant);
    return daysUntilNext <= 0;
  }
  
  /// Verifica se a planta está atrasada na rega
  bool isWateringOverdue(Plant plant) {
    final daysUntilNext = calculateDaysUntilNextWatering(plant);
    return daysUntilNext < -1; // Mais de 1 dia atrasado
  }
  
  /// Calcula score de saúde da planta (0-100)
  int calculateHealthScore(Plant plant) {
    if (plant.lastWatered == null || plant.wateringFrequency == null) {
      return 50; // Score neutro para plantas sem dados
    }
    
    final status = calculateCareStatus(plant);
    
    switch (status) {
      case PlantCareStatus.healthy:
        return 100;
      case PlantCareStatus.soon:
        return 75;
      case PlantCareStatus.needsWater:
        return 50;
      case PlantCareStatus.critical:
        return 25;
      case PlantCareStatus.unknown:
        return 50;
    }
  }
  
  /// Calcula estatísticas gerais de cuidado para uma lista de plantas
  PlantCareStatistics calculateCareStatistics(List<Plant> plants) {
    if (plants.isEmpty) {
      return PlantCareStatistics.empty();
    }
    
    int healthy = 0;
    int needWater = 0;
    int critical = 0;
    int unknown = 0;
    int totalHealthScore = 0;
    
    for (final plant in plants) {
      final status = calculateCareStatus(plant);
      final healthScore = calculateHealthScore(plant);
      
      totalHealthScore += healthScore;
      
      switch (status) {
        case PlantCareStatus.healthy:
        case PlantCareStatus.soon:
          healthy++;
          break;
        case PlantCareStatus.needsWater:
          needWater++;
          break;
        case PlantCareStatus.critical:
          critical++;
          break;
        case PlantCareStatus.unknown:
          unknown++;
          break;
      }
    }
    
    return PlantCareStatistics(
      totalPlants: plants.length,
      healthyPlants: healthy,
      plantsNeedingWater: needWater,
      criticalPlants: critical,
      unknownStatusPlants: unknown,
      averageHealthScore: totalHealthScore ~/ plants.length,
    );
  }
  
  /// Calcula plantas que precisam de rega nos próximos N dias
  List<Plant> getPlantsNeedingWaterSoon(List<Plant> plants, int days) {
    return plants.where((plant) {
      final daysUntilNext = calculateDaysUntilNextWatering(plant);
      return daysUntilNext <= days && daysUntilNext >= 0;
    }).toList();
  }
  
  /// Calcula histórico de cuidados (últimos N dias)
  PlantCareHistory calculateCareHistory(Plant plant, int days) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final List<DateTime> wateringDates = [];
    
    if (plant.lastWatered != null && plant.wateringFrequency != null) {
      var currentDate = plant.lastWatered!;
      while (currentDate.isAfter(startDate)) {
        if (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
          wateringDates.add(currentDate);
        }
        currentDate = currentDate.subtract(Duration(days: plant.wateringFrequency!));
      }
    }
    
    return PlantCareHistory(
      plantId: plant.id,
      wateringDates: wateringDates.reversed.toList(),
      periodDays: days,
      totalWaterings: wateringDates.length,
    );
  }
  
  /// Sugere próxima data ideal para rega
  DateTime? suggestNextWateringDate(Plant plant) {
    if (plant.wateringFrequency == null) return null;
    
    final now = DateTime.now();
    
    if (plant.lastWatered == null) {
      return now;
    }
    
    final nextDate = calculateNextWateringDate(plant);
    if (nextDate != null && nextDate.isBefore(now)) {
      return now;
    }
    
    return nextDate;
  }
}

/// Enum para status de cuidado (duplicado aqui para manter independência)
enum PlantCareStatus {
  critical,
  needsWater,
  soon,
  healthy,
  unknown,
}

/// Classe para estatísticas de cuidado
class PlantCareStatistics {
  final int totalPlants;
  final int healthyPlants;
  final int plantsNeedingWater;
  final int criticalPlants;
  final int unknownStatusPlants;
  final int averageHealthScore;
  
  const PlantCareStatistics({
    required this.totalPlants,
    required this.healthyPlants,
    required this.plantsNeedingWater,
    required this.criticalPlants,
    required this.unknownStatusPlants,
    required this.averageHealthScore,
  });
  
  factory PlantCareStatistics.empty() {
    return const PlantCareStatistics(
      totalPlants: 0,
      healthyPlants: 0,
      plantsNeedingWater: 0,
      criticalPlants: 0,
      unknownStatusPlants: 0,
      averageHealthScore: 0,
    );
  }
  
  double get healthyPercentage => totalPlants > 0 ? (healthyPlants / totalPlants) * 100 : 0;
  double get needsWaterPercentage => totalPlants > 0 ? (plantsNeedingWater / totalPlants) * 100 : 0;
  double get criticalPercentage => totalPlants > 0 ? (criticalPlants / totalPlants) * 100 : 0;
}

/// Classe para histórico de cuidados
class PlantCareHistory {
  final String plantId;
  final List<DateTime> wateringDates;
  final int periodDays;
  final int totalWaterings;
  
  const PlantCareHistory({
    required this.plantId,
    required this.wateringDates,
    required this.periodDays,
    required this.totalWaterings,
  });
  
  double get averageWateringInterval {
    if (wateringDates.length < 2) return 0;
    
    int totalDays = 0;
    for (int i = 1; i < wateringDates.length; i++) {
      totalDays += wateringDates[i].difference(wateringDates[i - 1]).inDays;
    }
    
    return totalDays / (wateringDates.length - 1);
  }
}