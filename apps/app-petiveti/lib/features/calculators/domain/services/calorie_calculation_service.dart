import 'dart:math' as math;

import '../entities/advanced_diet_input.dart';

/// Service responsible for calorie calculations following SRP
/// 
/// Single responsibility: Calculate daily caloric needs for pets
class CalorieCalculationService {
  /// Calculate daily caloric needs based on pet characteristics
  double calculateDailyCalories(AdvancedDietInput input) {
    // Base metabolic rate calculation
    double rer = _calculateRestingEnergyRequirement(input.weight);
    
    // Apply life stage multiplier
    double lifeStageMultiplier = _getLifeStageMultiplier(input.lifeStage, input.species);
    
    // Apply activity level multiplier
    double activityMultiplier = _getActivityMultiplier(input.activityLevel);
    
    // Apply body condition adjustment
    double bodyConditionMultiplier = _getBodyConditionMultiplier(input.bodyCondition);
    
    // Apply health condition adjustment
    double healthMultiplier = _getHealthConditionMultiplier(input.healthCondition);
    
    // Apply special conditions (pregnancy, lactation, neutered)
    double specialMultiplier = _getSpecialConditionMultiplier(input);
    
    double totalCalories = rer * 
                          lifeStageMultiplier * 
                          activityMultiplier * 
                          bodyConditionMultiplier * 
                          healthMultiplier * 
                          specialMultiplier;
    
    // Apply weight management adjustment if needed
    if (input.bodyCondition == BodyCondition.overweight || 
        input.bodyCondition == BodyCondition.obese) {
      totalCalories = _applyWeightManagementAdjustment(totalCalories, input);
    }
    
    return totalCalories.roundToDouble();
  }

  /// Calculate Resting Energy Requirement using standard formula
  double _calculateRestingEnergyRequirement(double weight) {
    if (weight <= 2) {
      return 70 * math.pow(weight, 0.75);
    } else {
      return 30 * weight + 70;
    }
  }

  double _getLifeStageMultiplier(LifeStage lifeStage, AnimalSpecies species) {
    switch (lifeStage) {
      case LifeStage.puppy:
        return species == AnimalSpecies.dog ? 2.0 : 2.5; // Higher for kittens
      case LifeStage.adult:
        return 1.8;
      case LifeStage.senior:
        return 1.4;
      case LifeStage.geriatric:
        return 1.2;
    }
  }

  double _getActivityMultiplier(ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return 0.8;
      case ActivityLevel.light:
        return 1.0;
      case ActivityLevel.moderate:
        return 1.2;
      case ActivityLevel.active:
        return 1.4;
      case ActivityLevel.veryActive:
        return 1.6;
      case ActivityLevel.working:
        return 2.0;
    }
  }

  double _getBodyConditionMultiplier(BodyCondition bodyCondition) {
    switch (bodyCondition) {
      case BodyCondition.underweight:
        return 1.3; // Need more calories to gain weight
      case BodyCondition.ideal:
        return 1.0;
      case BodyCondition.overweight:
        return 0.8; // Reduce calories for weight loss
      case BodyCondition.obese:
        return 0.6; // Significant calorie restriction
    }
  }

  double _getHealthConditionMultiplier(HealthCondition healthCondition) {
    switch (healthCondition) {
      case HealthCondition.healthy:
        return 1.0;
      case HealthCondition.kidneyDisease:
        return 0.9; // Slight reduction
      case HealthCondition.diabetes:
        return 0.95; // Controlled calorie intake
      case HealthCondition.heartDisease:
        return 0.9; // Reduced to prevent weight gain
      case HealthCondition.liverDisease:
        return 0.85; // Metabolic adjustments
      case HealthCondition.allergies:
        return 1.0; // No calorie adjustment
      case HealthCondition.gastrointestinal:
        return 0.9; // May have absorption issues
      case HealthCondition.cancer:
        return 1.1; // Often need more calories
    }
  }

  double _getSpecialConditionMultiplier(AdvancedDietInput input) {
    double multiplier = 1.0;
    
    if (input.isNeutered) {
      multiplier *= 0.9; // Neutered animals have lower metabolic rate
    }
    
    if (input.isPregnant) {
      multiplier *= 1.5; // Pregnant animals need more calories
    }
    
    if (input.isLactating) {
      int puppies = input.numberOfPuppies ?? 4;
      multiplier *= (1.0 + (puppies * 0.25)); // Additional calories per puppy
    }
    
    return multiplier;
  }

  double _applyWeightManagementAdjustment(double calories, AdvancedDietInput input) {
    if (input.idealWeight == null) return calories;
    
    double currentWeight = input.weight;
    double idealWeight = input.idealWeight!;
    
    if (currentWeight > idealWeight) {
      // Calculate calories based on ideal weight for weight loss
      double idealRER = _calculateRestingEnergyRequirement(idealWeight);
      return idealRER * 1.4; // Conservative weight loss calories
    }
    
    return calories;
  }
}