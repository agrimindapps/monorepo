import '../entities/plant.dart';

/// Care status for plants
enum CareStatus {
  needsWater,
  soonWater,
  needsFertilizer,
  soonFertilizer,
  good,
  unknown,
}

/// Service responsible for plant care analytics
/// Extracted from PlantsProvider to follow Single Responsibility Principle
class PlantsCareService {
  /// Get plants that need watering soon (next 2 days)
  List<Plant> getPlantsNeedingWater(List<Plant> plants) {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 2));

    return plants.where((plant) {
      final config = plant.config;
      if (config == null) return false;

      // Check if watering care is enabled and has valid interval
      if (config.enableWateringCare == true &&
          config.wateringIntervalDays != null) {
        final lastWatering = config.lastWateringDate ?? plant.createdAt ?? now;
        final nextWatering = lastWatering.add(
          Duration(days: config.wateringIntervalDays!),
        );

        return nextWatering.isBefore(threshold) ||
            nextWatering.isAtSameMomentAs(threshold);
      }

      // Fallback to old logic for backward compatibility
      if (config.wateringIntervalDays != null) {
        final lastWatering = plant.updatedAt ?? plant.createdAt ?? now;
        final nextWatering = lastWatering.add(
          Duration(days: config.wateringIntervalDays!),
        );

        return nextWatering.isBefore(threshold) ||
            nextWatering.isAtSameMomentAs(threshold);
      }

      return false;
    }).toList();
  }

  /// Get plants that need fertilizer soon (next 2 days)
  List<Plant> getPlantsNeedingFertilizer(List<Plant> plants) {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 2));

    return plants.where((plant) {
      final config = plant.config;
      if (config == null) return false;

      // Check if fertilizer care is enabled and has valid interval
      if (config.enableFertilizerCare == true &&
          config.fertilizingIntervalDays != null) {
        final lastFertilizer =
            config.lastFertilizerDate ?? plant.createdAt ?? now;
        final nextFertilizer = lastFertilizer.add(
          Duration(days: config.fertilizingIntervalDays!),
        );

        return nextFertilizer.isBefore(threshold) ||
            nextFertilizer.isAtSameMomentAs(threshold);
      }

      // Fallback to old logic for backward compatibility
      if (config.fertilizingIntervalDays != null) {
        final lastFertilizer = plant.updatedAt ?? plant.createdAt ?? now;
        final nextFertilizer = lastFertilizer.add(
          Duration(days: config.fertilizingIntervalDays!),
        );

        return nextFertilizer.isBefore(threshold) ||
            nextFertilizer.isAtSameMomentAs(threshold);
      }

      return false;
    }).toList();
  }

  /// Get plants by care status
  List<Plant> getPlantsByCareStatus(List<Plant> plants, CareStatus status) {
    final now = DateTime.now();

    return plants.where((plant) {
      final config = plant.config;
      if (config == null) {
        return status == CareStatus.unknown;
      }

      switch (status) {
        case CareStatus.needsWater:
          return _checkWaterStatus(plant, now, 0);
        case CareStatus.soonWater:
          return _checkWaterStatus(plant, now, 2);
        case CareStatus.needsFertilizer:
          return _checkFertilizerStatus(plant, now, 0);
        case CareStatus.soonFertilizer:
          return _checkFertilizerStatus(plant, now, 2);
        case CareStatus.good:
          return _isPlantInGoodCondition(plant, now);
        case CareStatus.unknown:
          return config.wateringIntervalDays == null &&
              config.fertilizingIntervalDays == null;
      }
    }).toList();
  }

  /// Check water status for a plant
  bool _checkWaterStatus(Plant plant, DateTime now, int dayThreshold) {
    final config = plant.config;
    if (config == null) return false;

    // Use new care system if enabled
    if (config.enableWateringCare == true &&
        config.wateringIntervalDays != null) {
      final lastWatering = config.lastWateringDate ?? plant.createdAt ?? now;
      final nextWatering = lastWatering.add(
        Duration(days: config.wateringIntervalDays!),
      );
      final daysDifference = nextWatering.difference(now).inDays;

      return dayThreshold == 0
          ? daysDifference <= 0
          : daysDifference > 0 && daysDifference <= dayThreshold;
    }

    // Fallback to old system
    if (config.wateringIntervalDays != null) {
      final lastWatering = plant.updatedAt ?? plant.createdAt ?? now;
      final nextWatering = lastWatering.add(
        Duration(days: config.wateringIntervalDays!),
      );
      final daysDifference = nextWatering.difference(now).inDays;

      return dayThreshold == 0
          ? daysDifference <= 0
          : daysDifference > 0 && daysDifference <= dayThreshold;
    }

    return false;
  }

  /// Check fertilizer status for a plant
  bool _checkFertilizerStatus(Plant plant, DateTime now, int dayThreshold) {
    final config = plant.config;
    if (config == null) return false;

    // Use new care system if enabled
    if (config.enableFertilizerCare == true &&
        config.fertilizingIntervalDays != null) {
      final lastFertilizer =
          config.lastFertilizerDate ?? plant.createdAt ?? now;
      final nextFertilizer = lastFertilizer.add(
        Duration(days: config.fertilizingIntervalDays!),
      );
      final daysDifference = nextFertilizer.difference(now).inDays;

      return dayThreshold == 0
          ? daysDifference <= 0
          : daysDifference > 0 && daysDifference <= dayThreshold;
    }

    // Fallback to old system
    if (config.fertilizingIntervalDays != null) {
      final lastFertilizer = plant.updatedAt ?? plant.createdAt ?? now;
      final nextFertilizer = lastFertilizer.add(
        Duration(days: config.fertilizingIntervalDays!),
      );
      final daysDifference = nextFertilizer.difference(now).inDays;

      return dayThreshold == 0
          ? daysDifference <= 0
          : daysDifference > 0 && daysDifference <= dayThreshold;
    }

    return false;
  }

  /// Check if plant is in good condition
  bool _isPlantInGoodCondition(Plant plant, DateTime now) {
    final waterGood =
        !_checkWaterStatus(plant, now, 0) && !_checkWaterStatus(plant, now, 2);
    final fertilizerGood =
        !_checkFertilizerStatus(plant, now, 0) &&
        !_checkFertilizerStatus(plant, now, 2);

    final config = plant.config;
    final hasWaterCare =
        config?.enableWateringCare == true ||
        config?.wateringIntervalDays != null;
    final hasFertilizerCare =
        config?.enableFertilizerCare == true ||
        config?.fertilizingIntervalDays != null;

    // Plant is good if it doesn't need water or fertilizer within 2 days
    return (hasWaterCare ? waterGood : true) &&
        (hasFertilizerCare ? fertilizerGood : true);
  }
}
