import 'calculator_input.dart';

/// Enums para tipagem forte e validação

enum AnimalSpecies {
  dog('dog', 'Cão'),
  cat('cat', 'Gato');

  const AnimalSpecies(this.code, this.displayName);
  final String code;
  final String displayName;
}

enum BcsScale {
  ninelevel('9level', 'Escala 1-9 (Padrão)'),
  fivelevel('5level', 'Escala 1-5 (Simplificada)');

  const BcsScale(this.code, this.displayName);
  final String code;
  final String displayName;
}

enum RibPalpation {
  veryDifficult(1, 'Muito difícil de palpar'),
  difficult(2, 'Difícil de palpar'),
  moderatePressure(3, 'Palpável com pressão moderada'),
  easy(4, 'Facilmente palpável'),
  veryEasy(5, 'Muito facilmente palpável');

  const RibPalpation(this.score, this.description);
  final int score;
  final String description;
}

enum WaistVisibility {
  notVisible(1, 'Não visível'),
  barelyVisible(2, 'Pouco visível'),
  moderatelyVisible(3, 'Moderadamente visível'),
  wellVisible(4, 'Bem visível'),
  veryPronounced(5, 'Muito pronunciada');

  const WaistVisibility(this.score, this.description);
  final int score;
  final String description;
}

enum AbdominalProfile {
  pendular(1, 'Pendular/Caído'),
  slightlyBulging(2, 'Ligeiramente abaulado'),
  straight(3, 'Reto'),
  slightlyRetracted(4, 'Ligeiramente retraído'),
  veryRetracted(5, 'Muito retraído');

  const AbdominalProfile(this.score, this.description);
  final int score;
  final String description;
}

/// Input para cálculo de condição corporal
/// Segue princípios de Clean Architecture e type safety
class BodyConditionInput extends CalculatorInput {
  const BodyConditionInput({
    required this.species,
    required this.currentWeight,
    required this.ribPalpation,
    required this.waistVisibility,
    required this.abdominalProfile,
    this.idealWeight,
    this.bcsScale = BcsScale.ninelevel,
    this.observations,
    this.animalAge,
    this.animalBreed,
    this.isNeutered = false,
    this.hasMetabolicConditions = false,
    this.metabolicConditions,
  });

  /// Parâmetros obrigatórios
  final AnimalSpecies species;
  final double currentWeight; // kg
  final RibPalpation ribPalpation;
  final WaistVisibility waistVisibility;
  final AbdominalProfile abdominalProfile;
  
  /// Parâmetros opcionais
  final double? idealWeight; // kg
  final BcsScale bcsScale;
  final String? observations;
  final int? animalAge; // meses
  final String? animalBreed;
  final bool isNeutered;
  final bool hasMetabolicConditions;
  final List<String>? metabolicConditions;

  @override
  Map<String, dynamic> toMap() {
    return {
      'species': species.code,
      'currentWeight': currentWeight,
      'ribPalpation': ribPalpation.score,
      'waistVisibility': waistVisibility.score,
      'abdominalProfile': abdominalProfile.score,
      'idealWeight': idealWeight,
      'bcsScale': bcsScale.code,
      'observations': observations,
      'animalAge': animalAge,
      'animalBreed': animalBreed,
      'isNeutered': isNeutered,
      'hasMetabolicConditions': hasMetabolicConditions,
      'metabolicConditions': metabolicConditions,
    };
  }

  static BodyConditionInput fromMap(Map<String, dynamic> map) {
    return BodyConditionInput(
      species: AnimalSpecies.values.firstWhere((e) => e.code == map['species']),
      currentWeight: (map['currentWeight'] as num?)?.toDouble() ?? 0.0,
      ribPalpation: RibPalpation.values.firstWhere((e) => e.score == map['ribPalpation']),
      waistVisibility: WaistVisibility.values.firstWhere((e) => e.score == map['waistVisibility']),
      abdominalProfile: AbdominalProfile.values.firstWhere((e) => e.score == map['abdominalProfile']),
      idealWeight: (map['idealWeight'] as num?)?.toDouble(),
      bcsScale: BcsScale.values.firstWhere((e) => e.code == map['bcsScale'], orElse: () => BcsScale.ninelevel),
      observations: map['observations'] as String?,
      animalAge: (map['animalAge'] as num?)?.toInt(),
      animalBreed: map['animalBreed'] as String?,
      isNeutered: (map['isNeutered'] as bool?) ?? false,
      hasMetabolicConditions: (map['hasMetabolicConditions'] as bool?) ?? false,
      metabolicConditions: (map['metabolicConditions'] as List<dynamic>?)?.cast<String>(),
    );
  }

  @override
  List<String> validate() {
    final errors = <String>[];
    
    if (currentWeight <= 0) {
      errors.add('Peso atual deve ser maior que zero');
    }
    if (currentWeight > 200) {
      errors.add('Peso atual parece excessivamente alto (máximo 200kg)');
    }
    if (idealWeight != null && idealWeight! <= 0) {
      errors.add('Peso ideal deve ser maior que zero');
    }
    if (idealWeight != null && (idealWeight! / currentWeight > 2 || currentWeight / idealWeight! > 2)) {
      errors.add('Diferença entre peso atual e ideal parece excessiva');
    }
    
    return errors;
  }

  /// Validação de entrada (mantido para compatibilidade)
  @override
  bool get isValid => validate().isEmpty;

  /// Lista de erros de validação (mantido para compatibilidade)
  List<String> get validationErrors => validate();

  /// Cópia com alterações
  @override
  BodyConditionInput copyWith({
    AnimalSpecies? species,
    double? currentWeight,
    RibPalpation? ribPalpation,
    WaistVisibility? waistVisibility,
    AbdominalProfile? abdominalProfile,
    double? idealWeight,
    BcsScale? bcsScale,
    String? observations,
    int? animalAge,
    String? animalBreed,
    bool? isNeutered,
    bool? hasMetabolicConditions,
    List<String>? metabolicConditions,
  }) {
    return BodyConditionInput(
      species: species ?? this.species,
      currentWeight: currentWeight ?? this.currentWeight,
      ribPalpation: ribPalpation ?? this.ribPalpation,
      waistVisibility: waistVisibility ?? this.waistVisibility,
      abdominalProfile: abdominalProfile ?? this.abdominalProfile,
      idealWeight: idealWeight ?? this.idealWeight,
      bcsScale: bcsScale ?? this.bcsScale,
      observations: observations ?? this.observations,
      animalAge: animalAge ?? this.animalAge,
      animalBreed: animalBreed ?? this.animalBreed,
      isNeutered: isNeutered ?? this.isNeutered,
      hasMetabolicConditions: hasMetabolicConditions ?? this.hasMetabolicConditions,
      metabolicConditions: metabolicConditions ?? this.metabolicConditions,
    );
  }

  @override
  List<Object?> get props => [
    species,
    currentWeight,
    ribPalpation,
    waistVisibility,
    abdominalProfile,
    idealWeight,
    bcsScale,
    observations,
    animalAge,
    animalBreed,
    isNeutered,
    hasMetabolicConditions,
    metabolicConditions,
  ];
}
