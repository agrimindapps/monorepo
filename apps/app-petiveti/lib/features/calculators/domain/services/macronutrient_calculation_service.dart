import '../entities/advanced_diet_input.dart';

/// Service responsible for macronutrient calculations following SRP
/// 
/// Single responsibility: Calculate protein, fat, and carbohydrate requirements
class MacronutrientCalculationService {
  /// Calculate macronutrient distribution for the pet
  Map<String, double> calculateMacronutrients(AdvancedDietInput input, double totalCalories) {
    final baseRatios = _getBaseMacronutrientRatios(input);
    final adjustedRatios = _adjustForHealthConditions(baseRatios, input);
    final finalRatios = _adjustForLifeStage(adjustedRatios, input);
    final proteinCalories = totalCalories * finalRatios['protein']!;
    final fatCalories = totalCalories * finalRatios['fat']!;
    final carbCalories = totalCalories * finalRatios['carbs']!;
    
    return {
      'protein_grams': proteinCalories / 4.0, // 4 kcal per gram protein
      'fat_grams': fatCalories / 9.0, // 9 kcal per gram fat
      'carbs_grams': carbCalories / 4.0, // 4 kcal per gram carbohydrate
      'protein_percentage': finalRatios['protein']! * 100,
      'fat_percentage': finalRatios['fat']! * 100,
      'carbs_percentage': finalRatios['carbs']! * 100,
      'fiber_grams': _calculateFiberRequirement(input, totalCalories),
    };
  }

  /// Get base macronutrient ratios by species and diet type
  Map<String, double> _getBaseMacronutrientRatios(AdvancedDietInput input) {
    switch (input.species) {
      case AnimalSpecies.dog:
        return _getDogMacronutrientRatios(input.dietType);
      case AnimalSpecies.cat:
        return _getCatMacronutrientRatios(input.dietType);
    }
  }

  Map<String, double> _getDogMacronutrientRatios(DietType dietType) {
    switch (dietType) {
      case DietType.commercial:
        return {'protein': 0.25, 'fat': 0.15, 'carbs': 0.60};
      case DietType.homemade:
        return {'protein': 0.30, 'fat': 0.20, 'carbs': 0.50};
      case DietType.raw:
        return {'protein': 0.45, 'fat': 0.25, 'carbs': 0.30};
      case DietType.mixed:
        return {'protein': 0.35, 'fat': 0.20, 'carbs': 0.45};
    }
  }

  Map<String, double> _getCatMacronutrientRatios(DietType dietType) {
    switch (dietType) {
      case DietType.commercial:
        return {'protein': 0.35, 'fat': 0.20, 'carbs': 0.45};
      case DietType.homemade:
        return {'protein': 0.45, 'fat': 0.25, 'carbs': 0.30};
      case DietType.raw:
        return {'protein': 0.55, 'fat': 0.30, 'carbs': 0.15};
      case DietType.mixed:
        return {'protein': 0.40, 'fat': 0.25, 'carbs': 0.35};
    }
  }

  /// Adjust macronutrient ratios based on health conditions
  Map<String, double> _adjustForHealthConditions(Map<String, double> ratios, AdvancedDietInput input) {
    Map<String, double> adjusted = Map.from(ratios);
    
    switch (input.healthCondition) {
      case HealthCondition.kidneyDisease:
        adjusted['protein'] = adjusted['protein']! * 0.7;
        adjusted['fat'] = adjusted['fat']! * 1.3;
        break;
        
      case HealthCondition.diabetes:
        adjusted['carbs'] = adjusted['carbs']! * 0.6;
        adjusted['protein'] = adjusted['protein']! * 1.2;
        break;
        
      case HealthCondition.heartDisease:
        adjusted['protein'] = adjusted['protein']! * 0.9;
        break;
        
      case HealthCondition.liverDisease:
        adjusted['protein'] = adjusted['protein']! * 0.8;
        break;
        
      case HealthCondition.gastrointestinal:
        adjusted['fat'] = adjusted['fat']! * 0.7;
        adjusted['carbs'] = adjusted['carbs']! * 1.1;
        break;
        
      case HealthCondition.cancer:
        adjusted['protein'] = adjusted['protein']! * 1.3;
        adjusted['fat'] = adjusted['fat']! * 1.2;
        adjusted['carbs'] = adjusted['carbs']! * 0.8;
        break;
        
      case HealthCondition.healthy:
      case HealthCondition.allergies:
        break;
    }
    return _normalizeRatios(adjusted);
  }

  /// Adjust macronutrient ratios based on life stage
  Map<String, double> _adjustForLifeStage(Map<String, double> ratios, AdvancedDietInput input) {
    Map<String, double> adjusted = Map.from(ratios);
    
    switch (input.lifeStage) {
      case LifeStage.puppy:
        adjusted['protein'] = adjusted['protein']! * 1.4;
        adjusted['fat'] = adjusted['fat']! * 1.3;
        break;
        
      case LifeStage.senior:
        adjusted['protein'] = adjusted['protein']! * 1.1;
        adjusted['fat'] = adjusted['fat']! * 0.9;
        break;
        
      case LifeStage.geriatric:
        adjusted['protein'] = adjusted['protein']! * 1.2;
        adjusted['fat'] = adjusted['fat']! * 0.8;
        break;
        
      case LifeStage.adult:
        break;
    }
    if (input.isPregnant || input.isLactating) {
      adjusted['protein'] = adjusted['protein']! * 1.5;
      adjusted['fat'] = adjusted['fat']! * 1.4;
    }
    
    return _normalizeRatios(adjusted);
  }

  /// Normalize ratios to sum to 1.0
  Map<String, double> _normalizeRatios(Map<String, double> ratios) {
    double total = ratios['protein']! + ratios['fat']! + ratios['carbs']!;
    
    return {
      'protein': ratios['protein']! / total,
      'fat': ratios['fat']! / total,
      'carbs': ratios['carbs']! / total,
    };
  }

  /// Calculate fiber requirement
  double _calculateFiberRequirement(AdvancedDietInput input, double totalCalories) {
    double basePercentage = input.species == AnimalSpecies.dog ? 0.03 : 0.025;
    if (input.healthCondition == HealthCondition.diabetes ||
        input.healthCondition == HealthCondition.gastrointestinal) {
      basePercentage *= 1.5;
    }
    double estimatedDryWeight = totalCalories / 3.75; // kcal per gram
    
    return estimatedDryWeight * basePercentage;
  }
}