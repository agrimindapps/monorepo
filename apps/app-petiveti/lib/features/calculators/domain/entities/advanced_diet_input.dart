import 'calculator_input.dart';

enum AnimalSpecies {
  dog,
  cat,
}

enum LifeStage {
  puppy, // 0-12 meses
  adult, // 1-7 anos
  senior, // 7+ anos
  geriatric, // 10+ anos
}

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive,
  working,
}

enum BodyCondition {
  underweight, // BCS 1-3
  ideal, // BCS 4-5
  overweight, // BCS 6-7
  obese, // BCS 8-9
}

enum DietType {
  commercial,
  homemade,
  raw,
  mixed,
}

enum HealthCondition {
  healthy,
  kidneyDisease,
  diabetes,
  heartDisease,
  liverDisease,
  allergies,
  gastrointestinal,
  cancer,
}

class AdvancedDietInput extends CalculatorInput {
  final AnimalSpecies species;
  final double weight;
  final double? idealWeight;
  final LifeStage lifeStage;
  final ActivityLevel activityLevel;
  final BodyCondition bodyCondition;
  final DietType dietType;
  final HealthCondition healthCondition;
  final bool isNeutered;
  final bool isPregnant;
  final bool isLactating;
  final int? numberOfPuppies;
  final double? currentDailyCalories;
  final List<String>? allergies;
  final List<String>? medications;

  const AdvancedDietInput({
    required this.species,
    required this.weight,
    this.idealWeight,
    required this.lifeStage,
    required this.activityLevel,
    required this.bodyCondition,
    required this.dietType,
    required this.healthCondition,
    this.isNeutered = false,
    this.isPregnant = false,
    this.isLactating = false,
    this.numberOfPuppies,
    this.currentDailyCalories,
    this.allergies,
    this.medications,
  });

  @override
  List<Object?> get props => [
        species,
        weight,
        idealWeight,
        lifeStage,
        activityLevel,
        bodyCondition,
        dietType,
        healthCondition,
        isNeutered,
        isPregnant,
        isLactating,
        numberOfPuppies,
        currentDailyCalories,
        allergies,
        medications,
      ];

  @override
  Map<String, dynamic> toMap() {
    return {
      'species': species.index,
      'weight': weight,
      'idealWeight': idealWeight,
      'lifeStage': lifeStage.index,
      'activityLevel': activityLevel.index,
      'bodyCondition': bodyCondition.index,
      'dietType': dietType.index,
      'healthCondition': healthCondition.index,
      'isNeutered': isNeutered,
      'isPregnant': isPregnant,
      'isLactating': isLactating,
      'numberOfPuppies': numberOfPuppies,
      'currentDailyCalories': currentDailyCalories,
      'allergies': allergies,
      'medications': medications,
    };
  }

  @override
  AdvancedDietInput copyWith({
    AnimalSpecies? species,
    double? weight,
    double? idealWeight,
    LifeStage? lifeStage,
    ActivityLevel? activityLevel,
    BodyCondition? bodyCondition,
    DietType? dietType,
    HealthCondition? healthCondition,
    bool? isNeutered,
    bool? isPregnant,
    bool? isLactating,
    int? numberOfPuppies,
    double? currentDailyCalories,
    List<String>? allergies,
    List<String>? medications,
  }) {
    return AdvancedDietInput(
      species: species ?? this.species,
      weight: weight ?? this.weight,
      idealWeight: idealWeight ?? this.idealWeight,
      lifeStage: lifeStage ?? this.lifeStage,
      activityLevel: activityLevel ?? this.activityLevel,
      bodyCondition: bodyCondition ?? this.bodyCondition,
      dietType: dietType ?? this.dietType,
      healthCondition: healthCondition ?? this.healthCondition,
      isNeutered: isNeutered ?? this.isNeutered,
      isPregnant: isPregnant ?? this.isPregnant,
      isLactating: isLactating ?? this.isLactating,
      numberOfPuppies: numberOfPuppies ?? this.numberOfPuppies,
      currentDailyCalories: currentDailyCalories ?? this.currentDailyCalories,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
    );
  }
}
