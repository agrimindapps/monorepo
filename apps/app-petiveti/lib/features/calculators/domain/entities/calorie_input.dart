import 'calculator_input.dart';

/// Espécies suportadas para cálculo calórico
enum AnimalSpecies {
  dog('Cão', 'dog'),
  cat('Gato', 'cat');

  const AnimalSpecies(this.displayName, this.code);
  
  final String displayName;
  final String code;
}

/// Estados fisiológicos que afetam necessidades calóricas
enum PhysiologicalState {
  normal('Normal', 'normal', 1.6),
  neutered('Castrado/Esterilizado', 'neutered', 1.4),
  pregnancy1st('Gestação 1º Trimestre', 'pregnancy_1st', 1.8),
  pregnancy2nd('Gestação 2º Trimestre', 'pregnancy_2nd', 2.2),
  pregnancy3rd('Gestação 3º Trimestre', 'pregnancy_3rd', 2.6),
  lactating('Lactação', 'lactating', 2.0), // + 0.25 × número de filhotes
  growth('Crescimento (<4 meses)', 'growth_young', 3.0),
  juvenile('Crescimento (4-12 meses)', 'growth_juvenile', 2.0),
  senior('Idoso/Senior', 'senior', 1.2),
  working('Trabalho/Competição', 'working', 2.5);

  const PhysiologicalState(this.displayName, this.code, this.baseFactor);
  
  final String displayName;
  final String code;
  final double baseFactor;
}

/// Níveis de atividade física
enum ActivityLevel {
  sedentary('Sedentário', 'sedentary', 0.8),
  light('Leve', 'light', 1.0),
  moderate('Moderado', 'moderate', 1.2),
  active('Ativo', 'active', 1.6),
  veryActive('Muito Ativo', 'very_active', 2.0),
  extreme('Extremo', 'extreme', 3.0);

  const ActivityLevel(this.displayName, this.code, this.factor);
  
  final String displayName;
  final String code;
  final double factor;
}

/// Condições corporais que impactam necessidades calóricas
enum BodyConditionScore {
  underweight('Abaixo do Peso (BCS 1-3)', 'underweight', 1.2),
  ideal('Peso Ideal (BCS 4-5)', 'ideal', 1.0),
  overweight('Sobrepeso (BCS 6-7)', 'overweight', 0.8),
  obese('Obeso (BCS 8-9)', 'obese', 0.6);

  const BodyConditionScore(this.displayName, this.code, this.factor);
  
  final String displayName;
  final String code;
  final double factor;
}

/// Condições ambientais que afetam metabolismo
enum EnvironmentalCondition {
  normal('Normal (18-22°C)', 'normal', 1.0),
  cold('Frio (<10°C)', 'cold', 1.25),
  hot('Calor (>30°C)', 'hot', 0.9),
  highAltitude('Alta Altitude', 'high_altitude', 1.1);

  const EnvironmentalCondition(this.displayName, this.code, this.factor);
  
  final String displayName;
  final String code;
  final double factor;
}

/// Condições médicas especiais que requerem ajustes calóricos
enum MedicalCondition {
  none('Nenhuma', 'none', 1.0),
  diabetes('Diabetes', 'diabetes', 0.95),
  kidneyDisease('Doença Renal', 'kidney_disease', 0.9),
  heartDisease('Doença Cardíaca', 'heart_disease', 0.9),
  liverDisease('Doença Hepática', 'liver_disease', 0.85),
  hyperthyroidism('Hipertireoidismo', 'hyperthyroidism', 1.4),
  hypothyroidism('Hipotireoidismo', 'hypothyroidism', 0.8),
  cancer('Câncer', 'cancer', 1.1),
  recovery('Recuperação Pós-Cirúrgica', 'recovery', 1.3);

  const MedicalCondition(this.displayName, this.code, this.factor);
  
  final String displayName;
  final String code;
  final double factor;
}

/// Entrada tipada para cálculo de necessidades calóricas
class CalorieInput extends CalculatorInput {
  const CalorieInput({
    required this.species,
    required this.weight,
    required this.age,
    required this.physiologicalState,
    required this.activityLevel,
    required this.bodyConditionScore,
    this.idealWeight,
    this.environmentalCondition = EnvironmentalCondition.normal,
    this.medicalCondition = MedicalCondition.none,
    this.numberOfOffspring,
    this.breed,
    this.notes,
  });

  /// Espécie do animal
  final AnimalSpecies species;
  
  /// Peso atual em quilogramas
  final double weight;
  
  /// Peso ideal em quilogramas (se conhecido)
  final double? idealWeight;
  
  /// Idade em meses
  final int age;
  
  /// Estado fisiológico atual
  final PhysiologicalState physiologicalState;
  
  /// Nível de atividade física
  final ActivityLevel activityLevel;
  
  /// Pontuação da condição corporal (BCS)
  final BodyConditionScore bodyConditionScore;
  
  /// Condição ambiental
  final EnvironmentalCondition environmentalCondition;
  
  /// Condição médica especial
  final MedicalCondition medicalCondition;
  
  /// Número de filhotes (para lactação)
  final int? numberOfOffspring;
  
  /// Raça específica (opcional)
  final String? breed;
  
  /// Notas adicionais
  final String? notes;

  /// Retorna true se é um animal em lactação
  bool get isLactating => physiologicalState == PhysiologicalState.lactating;
  
  /// Retorna true se é um animal gestante
  bool get isPregnant => [
    PhysiologicalState.pregnancy1st,
    PhysiologicalState.pregnancy2nd,
    PhysiologicalState.pregnancy3rd,
  ].contains(physiologicalState);
  
  /// Retorna true se é um filhote/juvenil
  bool get isYoung => [
    PhysiologicalState.growth,
    PhysiologicalState.juvenile,
  ].contains(physiologicalState);
  
  /// Retorna true se é um animal idoso
  bool get isSenior => physiologicalState == PhysiologicalState.senior;
  
  /// Retorna true se é castrado/esterilizado
  bool get isNeutered => physiologicalState == PhysiologicalState.neutered;

  /// Retorna o peso alvo para cálculos (ideal se disponível, senão atual)
  double get targetWeight => idealWeight ?? weight;

  @override
  List<Object?> get props => [
        species,
        weight,
        idealWeight,
        age,
        physiologicalState,
        activityLevel,
        bodyConditionScore,
        environmentalCondition,
        medicalCondition,
        numberOfOffspring,
        breed,
        notes,
      ];

  /// Cria uma cópia com parâmetros modificados
  @override
  CalorieInput copyWith({
    AnimalSpecies? species,
    double? weight,
    double? idealWeight,
    int? age,
    PhysiologicalState? physiologicalState,
    ActivityLevel? activityLevel,
    BodyConditionScore? bodyConditionScore,
    EnvironmentalCondition? environmentalCondition,
    MedicalCondition? medicalCondition,
    int? numberOfOffspring,
    String? breed,
    String? notes,
  }) {
    return CalorieInput(
      species: species ?? this.species,
      weight: weight ?? this.weight,
      idealWeight: idealWeight ?? this.idealWeight,
      age: age ?? this.age,
      physiologicalState: physiologicalState ?? this.physiologicalState,
      activityLevel: activityLevel ?? this.activityLevel,
      bodyConditionScore: bodyConditionScore ?? this.bodyConditionScore,
      environmentalCondition: environmentalCondition ?? this.environmentalCondition,
      medicalCondition: medicalCondition ?? this.medicalCondition,
      numberOfOffspring: numberOfOffspring ?? this.numberOfOffspring,
      breed: breed ?? this.breed,
      notes: notes ?? this.notes,
    );
  }

  /// Converte para Map (implementação requerida por CalculatorInput)
  @override
  Map<String, dynamic> toMap() => toJson();

  /// Converte para Map para serialização
  Map<String, dynamic> toJson() {
    return {
      'species': species.code,
      'weight': weight,
      'idealWeight': idealWeight,
      'age': age,
      'physiologicalState': physiologicalState.code,
      'activityLevel': activityLevel.code,
      'bodyConditionScore': bodyConditionScore.code,
      'environmentalCondition': environmentalCondition.code,
      'medicalCondition': medicalCondition.code,
      'numberOfOffspring': numberOfOffspring,
      'breed': breed,
      'notes': notes,
    };
  }

  /// Cria instância a partir de Map
  factory CalorieInput.fromJson(Map<String, dynamic> json) {
    return CalorieInput(
      species: AnimalSpecies.values.firstWhere(
        (e) => e.code == json['species'],
        orElse: () => AnimalSpecies.dog,
      ),
      weight: (json['weight'] as num).toDouble(),
      idealWeight: json['idealWeight'] != null 
          ? (json['idealWeight'] as num).toDouble() 
          : null,
      age: json['age'] as int,
      physiologicalState: PhysiologicalState.values.firstWhere(
        (e) => e.code == json['physiologicalState'],
        orElse: () => PhysiologicalState.normal,
      ),
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.code == json['activityLevel'],
        orElse: () => ActivityLevel.moderate,
      ),
      bodyConditionScore: BodyConditionScore.values.firstWhere(
        (e) => e.code == json['bodyConditionScore'],
        orElse: () => BodyConditionScore.ideal,
      ),
      environmentalCondition: EnvironmentalCondition.values.firstWhere(
        (e) => e.code == json['environmentalCondition'],
        orElse: () => EnvironmentalCondition.normal,
      ),
      medicalCondition: MedicalCondition.values.firstWhere(
        (e) => e.code == json['medicalCondition'],
        orElse: () => MedicalCondition.none,
      ),
      numberOfOffspring: json['numberOfOffspring'] as int?,
      breed: json['breed'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
