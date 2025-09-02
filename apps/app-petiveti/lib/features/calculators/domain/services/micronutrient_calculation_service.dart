import 'dart:math' as math;

import '../entities/advanced_diet_input.dart';

/// Service responsible for vitamin and mineral calculations following SRP
/// 
/// Single responsibility: Calculate vitamin and mineral requirements
class MicronutrientCalculationService {
  /// Calculate vitamin requirements for the pet
  Map<String, double> calculateVitamins(AdvancedDietInput input) {
    final baseVitamins = _getBaseVitaminRequirements(input);
    final adjustedVitamins = _adjustVitaminsForConditions(baseVitamins, input);
    
    return adjustedVitamins;
  }

  /// Calculate mineral requirements for the pet
  Map<String, double> calculateMinerals(AdvancedDietInput input) {
    final baseMinerals = _getBaseMineralRequirements(input);
    final adjustedMinerals = _adjustMineralsForConditions(baseMinerals, input);
    
    return adjustedMinerals;
  }

  /// Get base vitamin requirements by species and weight
  Map<String, double> _getBaseVitaminRequirements(AdvancedDietInput input) {
    final weightFactor = _getWeightFactor(input.weight);
    final speciesMultiplier = input.species == AnimalSpecies.dog ? 1.0 : 0.8;
    
    return {
      'vitamin_a_iu': 5000 * weightFactor * speciesMultiplier,
      'vitamin_d_iu': 500 * weightFactor * speciesMultiplier,
      'vitamin_e_iu': 50 * weightFactor * speciesMultiplier,
      'vitamin_k_mg': 0.1 * weightFactor * speciesMultiplier,
      'thiamine_mg': 1.0 * weightFactor * speciesMultiplier,
      'riboflavin_mg': 2.2 * weightFactor * speciesMultiplier,
      'niacin_mg': 11.4 * weightFactor * speciesMultiplier,
      'pantothenic_acid_mg': 10.0 * weightFactor * speciesMultiplier,
      'pyridoxine_mg': 1.0 * weightFactor * speciesMultiplier,
      'folic_acid_mg': 0.18 * weightFactor * speciesMultiplier,
      'vitamin_b12_mg': 0.022 * weightFactor * speciesMultiplier,
      'biotin_mg': 0.1 * weightFactor * speciesMultiplier,
      'choline_mg': 1200 * weightFactor * speciesMultiplier,
      'vitamin_c_mg': input.species == AnimalSpecies.dog ? 0 : 30 * weightFactor, // Dogs synthesize their own
    };
  }

  /// Get base mineral requirements by species and weight
  Map<String, double> _getBaseMineralRequirements(AdvancedDietInput input) {
    final weightFactor = _getWeightFactor(input.weight);
    final speciesMultiplier = input.species == AnimalSpecies.dog ? 1.0 : 0.8;
    
    return {
      'calcium_mg': 1000 * weightFactor * speciesMultiplier,
      'phosphorus_mg': 750 * weightFactor * speciesMultiplier,
      'potassium_mg': 3500 * weightFactor * speciesMultiplier,
      'sodium_mg': 200 * weightFactor * speciesMultiplier,
      'chloride_mg': 300 * weightFactor * speciesMultiplier,
      'magnesium_mg': 150 * weightFactor * speciesMultiplier,
      'iron_mg': 7.3 * weightFactor * speciesMultiplier,
      'copper_mg': 1.5 * weightFactor * speciesMultiplier,
      'manganese_mg': 1.2 * weightFactor * speciesMultiplier,
      'zinc_mg': 15 * weightFactor * speciesMultiplier,
      'iodine_mg': 0.35 * weightFactor * speciesMultiplier,
      'selenium_mg': 0.087 * weightFactor * speciesMultiplier,
    };
  }

  /// Calculate weight factor for nutrient scaling
  double _getWeightFactor(double weight) {
    // Use metabolic weight (weight^0.75) for more accurate scaling
    return math.pow(weight, 0.75) / math.pow(10, 0.75); // Normalized to 10kg base
  }

  /// Adjust vitamins based on health conditions and life stage
  Map<String, double> _adjustVitaminsForConditions(Map<String, double> vitamins, AdvancedDietInput input) {
    Map<String, double> adjusted = Map.from(vitamins);
    
    // Life stage adjustments
    switch (input.lifeStage) {
      case LifeStage.puppy:
        adjusted = _multiplyValues(adjusted, 1.5);
        break;
      case LifeStage.senior:
        adjusted['vitamin_e_iu'] = adjusted['vitamin_e_iu']! * 1.3;
        adjusted['vitamin_c_mg'] = adjusted['vitamin_c_mg']! * 1.2;
        break;
      case LifeStage.geriatric:
        adjusted['vitamin_e_iu'] = adjusted['vitamin_e_iu']! * 1.5;
        adjusted['vitamin_c_mg'] = adjusted['vitamin_c_mg']! * 1.4;
        break;
      case LifeStage.adult:
        break;
    }
    
    // Health condition adjustments
    switch (input.healthCondition) {
      case HealthCondition.kidneyDisease:
        adjusted['vitamin_d_iu'] = adjusted['vitamin_d_iu']! * 0.8;
        adjusted['vitamin_b12_mg'] = adjusted['vitamin_b12_mg']! * 1.5;
        break;
        
      case HealthCondition.diabetes:
        adjusted['vitamin_e_iu'] = adjusted['vitamin_e_iu']! * 1.3;
        adjusted['vitamin_c_mg'] = adjusted['vitamin_c_mg']! * 1.2;
        break;
        
      case HealthCondition.heartDisease:
        adjusted['thiamine_mg'] = adjusted['thiamine_mg']! * 1.5;
        adjusted['vitamin_e_iu'] = adjusted['vitamin_e_iu']! * 1.3;
        break;
        
      case HealthCondition.liverDisease:
        adjusted['vitamin_k_mg'] = adjusted['vitamin_k_mg']! * 1.5;
        adjusted['vitamin_e_iu'] = adjusted['vitamin_e_iu']! * 1.4;
        break;
        
      case HealthCondition.cancer:
        adjusted['vitamin_e_iu'] = adjusted['vitamin_e_iu']! * 2.0;
        adjusted['vitamin_c_mg'] = adjusted['vitamin_c_mg']! * 1.8;
        break;
        
      case HealthCondition.healthy:
      case HealthCondition.allergies:
      case HealthCondition.gastrointestinal:
        break;
    }
    
    // Special conditions
    if (input.isPregnant || input.isLactating) {
      adjusted['folic_acid_mg'] = adjusted['folic_acid_mg']! * 2.0;
      adjusted['vitamin_b12_mg'] = adjusted['vitamin_b12_mg']! * 1.5;
    }
    
    return adjusted;
  }

  /// Adjust minerals based on health conditions and life stage
  Map<String, double> _adjustMineralsForConditions(Map<String, double> minerals, AdvancedDietInput input) {
    Map<String, double> adjusted = Map.from(minerals);
    
    // Life stage adjustments
    switch (input.lifeStage) {
      case LifeStage.puppy:
        adjusted['calcium_mg'] = adjusted['calcium_mg']! * 1.8;
        adjusted['phosphorus_mg'] = adjusted['phosphorus_mg']! * 1.6;
        adjusted['zinc_mg'] = adjusted['zinc_mg']! * 1.5;
        break;
      case LifeStage.senior:
      case LifeStage.geriatric:
        adjusted['zinc_mg'] = adjusted['zinc_mg']! * 1.2;
        break;
      case LifeStage.adult:
        break;
    }
    
    // Health condition adjustments
    switch (input.healthCondition) {
      case HealthCondition.kidneyDisease:
        adjusted['phosphorus_mg'] = adjusted['phosphorus_mg']! * 0.6;
        adjusted['sodium_mg'] = adjusted['sodium_mg']! * 0.7;
        break;
        
      case HealthCondition.heartDisease:
        adjusted['sodium_mg'] = adjusted['sodium_mg']! * 0.5;
        adjusted['potassium_mg'] = adjusted['potassium_mg']! * 1.2;
        break;
        
      case HealthCondition.diabetes:
        adjusted['zinc_mg'] = adjusted['zinc_mg']! * 1.3;
        adjusted['chromium_mg'] = (adjusted['chromium_mg'] ?? 0.05) * 2.0;
        break;
        
      case HealthCondition.liverDisease:
        adjusted['copper_mg'] = adjusted['copper_mg']! * 0.7;
        adjusted['zinc_mg'] = adjusted['zinc_mg']! * 1.4;
        break;
        
      case HealthCondition.healthy:
      case HealthCondition.allergies:
      case HealthCondition.gastrointestinal:
      case HealthCondition.cancer:
        break;
    }
    
    // Special conditions
    if (input.isPregnant || input.isLactating) {
      adjusted['calcium_mg'] = adjusted['calcium_mg']! * 1.5;
      adjusted['phosphorus_mg'] = adjusted['phosphorus_mg']! * 1.4;
      adjusted['iron_mg'] = adjusted['iron_mg']! * 1.3;
    }
    
    return adjusted;
  }

  /// Multiply all values in a map by a factor
  Map<String, double> _multiplyValues(Map<String, double> map, double factor) {
    return map.map((key, value) => MapEntry(key, value * factor));
  }
}

