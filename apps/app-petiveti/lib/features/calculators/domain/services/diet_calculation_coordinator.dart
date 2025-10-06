import '../entities/advanced_diet_input.dart';
import '../entities/calculation_result.dart';
import 'calorie_calculation_service.dart';
import 'macronutrient_calculation_service.dart';
import 'micronutrient_calculation_service.dart';

/// Coordinator service that orchestrates all diet calculations
/// 
/// Follows the Facade pattern and Single Responsibility Principle
/// - Coordinates between different calculation services
/// - Provides a unified interface for complex diet calculations
/// - Maintains separation of concerns between different calculation types
class DietCalculationCoordinator {
  final CalorieCalculationService _calorieService;
  final MacronutrientCalculationService _macronutrientService;
  final MicronutrientCalculationService _micronutrientService;

  DietCalculationCoordinator({
    CalorieCalculationService? calorieService,
    MacronutrientCalculationService? macronutrientService,
    MicronutrientCalculationService? micronutrientService,
  })  : _calorieService = calorieService ?? CalorieCalculationService(),
        _macronutrientService = macronutrientService ?? MacronutrientCalculationService(),
        _micronutrientService = micronutrientService ?? MicronutrientCalculationService();

  /// Calculate complete diet plan for the pet
  AdvancedDietResult calculateDietPlan(AdvancedDietInput input) {
    final dailyCalories = _calorieService.calculateDailyCalories(input);
    final macronutrients = _macronutrientService.calculateMacronutrients(input, dailyCalories);
    final vitamins = _micronutrientService.calculateVitamins(input);
    final minerals = _micronutrientService.calculateMinerals(input);
    final waterRequirement = _calculateWaterRequirement(input);
    final feedingRecommendations = _calculateFeedingRecommendations(input, dailyCalories);
    final dietaryRecommendations = _generateDietaryRecommendations(input);
    
    return AdvancedDietResult(
      dailyCalories: dailyCalories,
      macronutrients: macronutrients,
      vitamins: vitamins,
      minerals: minerals,
      waterRequirement: waterRequirement,
      feedingRecommendations: feedingRecommendations,
      dietaryRecommendations: dietaryRecommendations,
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculate water requirement based on various factors
  double _calculateWaterRequirement(AdvancedDietInput input) {
    double baseWater = input.weight * 55;
    final activityMultiplier = _getActivityWaterMultiplier(input.activityLevel);
    baseWater *= activityMultiplier;
    switch (input.healthCondition) {
      case HealthCondition.kidneyDisease:
        baseWater *= 1.5; // Increase water intake
        break;
      case HealthCondition.diabetes:
        baseWater *= 1.3; // Diabetic animals often need more water
        break;
      case HealthCondition.heartDisease:
        baseWater *= 0.9; // May need fluid restriction
        break;
      default:
        break;
    }
    if (input.isLactating) {
      baseWater *= 1.8; // Lactating animals need significantly more water
    } else if (input.isPregnant) {
      baseWater *= 1.3;
    }
    switch (input.dietType) {
      case DietType.raw:
        baseWater *= 0.7; // Raw diets have higher moisture content
        break;
      case DietType.commercial:
        baseWater *= 1.0; // Standard commercial dry food
        break;
      case DietType.homemade:
        baseWater *= 0.8; // Usually higher moisture than commercial
        break;
      case DietType.mixed:
        baseWater *= 0.9;
        break;
    }
    
    return baseWater.roundToDouble();
  }

  double _getActivityWaterMultiplier(ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return 0.9;
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

  /// Calculate feeding recommendations
  Map<String, dynamic> _calculateFeedingRecommendations(AdvancedDietInput input, double dailyCalories) {
    int mealsPerDay;
    switch (input.lifeStage) {
      case LifeStage.puppy:
        mealsPerDay = input.weight < 5 ? 4 : 3;
        break;
      case LifeStage.adult:
        mealsPerDay = 2;
        break;
      case LifeStage.senior:
      case LifeStage.geriatric:
        mealsPerDay = 3; // Easier digestion with smaller meals
        break;
    }
    double caloriesPerMeal = dailyCalories / mealsPerDay;
    double averageCaloriesPerGram = _getAverageCaloriesPerGram(input.dietType);
    double gramsPerMeal = caloriesPerMeal / averageCaloriesPerGram;
    
    return {
      'meals_per_day': mealsPerDay,
      'calories_per_meal': caloriesPerMeal.round(),
      'grams_per_meal': gramsPerMeal.round(),
      'total_daily_grams': (gramsPerMeal * mealsPerDay).round(),
      'feeding_schedule': _generateFeedingSchedule(mealsPerDay),
    };
  }

  double _getAverageCaloriesPerGram(DietType dietType) {
    switch (dietType) {
      case DietType.commercial:
        return 3.5; // kcal/g for average dry commercial food
      case DietType.homemade:
        return 2.8; // Usually lower caloric density
      case DietType.raw:
        return 2.5; // High moisture, lower caloric density
      case DietType.mixed:
        return 3.0; // Average between types
    }
  }

  List<String> _generateFeedingSchedule(int mealsPerDay) {
    switch (mealsPerDay) {
      case 2:
        return ['8:00 AM', '6:00 PM'];
      case 3:
        return ['7:00 AM', '1:00 PM', '7:00 PM'];
      case 4:
        return ['7:00 AM', '12:00 PM', '4:00 PM', '8:00 PM'];
      default:
        return ['8:00 AM', '6:00 PM'];
    }
  }

  /// Generate dietary recommendations based on input
  List<String> _generateDietaryRecommendations(AdvancedDietInput input) {
    List<String> recommendations = [];
    switch (input.lifeStage) {
      case LifeStage.puppy:
        recommendations.add('Use puppy-specific food with higher protein and fat content');
        recommendations.add('Feed more frequently (3-4 times daily) for better digestion');
        break;
      case LifeStage.senior:
        recommendations.add('Consider senior formula with joint support supplements');
        recommendations.add('Monitor weight closely as metabolism slows');
        break;
      case LifeStage.geriatric:
        recommendations.add('Use easily digestible proteins');
        recommendations.add('Consider antioxidant supplements');
        break;
      case LifeStage.adult:
        recommendations.add('Maintain consistent feeding schedule');
        break;
    }
    switch (input.healthCondition) {
      case HealthCondition.kidneyDisease:
        recommendations.add('Use therapeutic kidney diet with restricted phosphorus');
        recommendations.add('Increase water intake significantly');
        break;
      case HealthCondition.diabetes:
        recommendations.add('Use high-fiber, low-glycemic diet');
        recommendations.add('Feed at same times daily to match insulin schedule');
        break;
      case HealthCondition.heartDisease:
        recommendations.add('Use low-sodium diet');
        recommendations.add('Monitor fluid intake carefully');
        break;
      case HealthCondition.allergies:
        recommendations.add('Use hypoallergenic or limited ingredient diet');
        recommendations.add('Avoid common allergens identified in history');
        break;
      default:
        break;
    }
    switch (input.bodyCondition) {
      case BodyCondition.underweight:
        recommendations.add('Increase caloric density and feeding frequency');
        recommendations.add('Monitor weight gain weekly');
        break;
      case BodyCondition.overweight:
      case BodyCondition.obese:
        recommendations.add('Use weight management formula');
        recommendations.add('Implement controlled portion sizes');
        recommendations.add('Increase exercise gradually');
        break;
      default:
        break;
    }
    if (input.isPregnant) {
      recommendations.add('Switch to puppy/kitten food for higher nutrition');
      recommendations.add('Allow free-choice feeding in later pregnancy');
    }
    
    if (input.isLactating) {
      recommendations.add('Provide unlimited access to high-quality food');
      recommendations.add('Ensure constant access to fresh water');
    }
    
    return recommendations;
  }
}

/// Result class for advanced diet calculations
class AdvancedDietResult extends CalculationResult {
  final double dailyCalories;
  final Map<String, double> macronutrients;
  final Map<String, double> vitamins;
  final Map<String, double> minerals;
  final double waterRequirement;
  final Map<String, dynamic> feedingRecommendations;
  final List<String> dietaryRecommendations;

  AdvancedDietResult({
    required this.dailyCalories,
    required this.macronutrients,
    required this.vitamins,
    required this.minerals,
    required this.waterRequirement,
    required this.feedingRecommendations,
    required this.dietaryRecommendations,
    required DateTime calculatedAt,
  }) : super(
          calculatorId: 'advanced_diet_calculator',
          results: const [],
          calculatedAt: calculatedAt,
          summary: 'Daily Calories: ${dailyCalories.toStringAsFixed(0)} kcal',
        );

  String get detailedResults => '''
Daily Caloric Needs: ${dailyCalories.toStringAsFixed(0)} kcal
Protein: ${macronutrients['protein_grams']?.toStringAsFixed(1)} g (${macronutrients['protein_percentage']?.toStringAsFixed(1)}%)
Fat: ${macronutrients['fat_grams']?.toStringAsFixed(1)} g (${macronutrients['fat_percentage']?.toStringAsFixed(1)}%)
Carbs: ${macronutrients['carbs_grams']?.toStringAsFixed(1)} g (${macronutrients['carbs_percentage']?.toStringAsFixed(1)}%)
Water: ${waterRequirement.toStringAsFixed(0)} ml/day
Meals: ${feedingRecommendations['meals_per_day']} per day
Portion: ${feedingRecommendations['grams_per_meal']} g per meal
''';

  @override
  List<Object?> get props => [
        ...super.props,
        dailyCalories,
        macronutrients,
        vitamins,
        minerals,
        waterRequirement,
        feedingRecommendations,
        dietaryRecommendations,
      ];
}
