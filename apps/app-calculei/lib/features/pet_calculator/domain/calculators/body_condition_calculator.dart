/// Calculadora de Escore de Condição Corporal (ECC)
/// Avalia o peso ideal do pet através de parâmetros físicos
library;

enum PetSpecies { dog, cat }

enum BcsClassification { underweight, ideal, overweight, obese }

class BodyConditionResult {
  /// Escore de Condição Corporal (1-9)
  final double bcs;

  /// Classificação do peso
  final BcsClassification classification;

  /// Texto descritivo da classificação
  final String classificationText;

  /// Descrição da condição corporal
  final String description;

  /// Recomendações de cuidados
  final List<String> recommendations;

  /// Score ponderado usado no cálculo
  final double weightedScore;

  const BodyConditionResult({
    required this.bcs,
    required this.classification,
    required this.classificationText,
    required this.description,
    required this.recommendations,
    required this.weightedScore,
  });
}

class BodyConditionCalculator {
  /// Pesos dos parâmetros no cálculo (soma = 1.0)
  static const double _ribWeight = 0.4;
  static const double _waistWeight = 0.35;
  static const double _abdominalWeight = 0.25;

  /// Calcula o Escore de Condição Corporal
  static BodyConditionResult calculate({
    required PetSpecies species,
    required int ribPalpation,
    required int waistVisibility,
    required int abdominalProfile,
  }) {
    // Validação dos parâmetros
    if (ribPalpation < 1 || ribPalpation > 5) {
      throw ArgumentError('ribPalpation deve estar entre 1 e 5');
    }
    if (waistVisibility < 1 || waistVisibility > 5) {
      throw ArgumentError('waistVisibility deve estar entre 1 e 5');
    }
    if (abdominalProfile < 1 || abdominalProfile > 5) {
      throw ArgumentError('abdominalProfile deve estar entre 1 e 5');
    }

    // Cálculo do score ponderado
    final weightedScore =
        (ribPalpation * _ribWeight) +
        (waistVisibility * _waistWeight) +
        (abdominalProfile * _abdominalWeight);

    // Conversão para escala BCS 1-9
    final bcs = ((weightedScore - 1) * 2) + 1;

    final classification = _getClassification(bcs);
    final classificationText = _getClassificationText(classification);
    final description = _getDescription(classification, species);
    final recommendations = _getRecommendations(classification, species);

    return BodyConditionResult(
      bcs: bcs,
      classification: classification,
      classificationText: classificationText,
      description: description,
      recommendations: recommendations,
      weightedScore: weightedScore,
    );
  }

  static BcsClassification _getClassification(double bcs) {
    if (bcs < 4) return BcsClassification.underweight;
    if (bcs < 6) return BcsClassification.ideal;
    if (bcs < 8) return BcsClassification.overweight;
    return BcsClassification.obese;
  }

  static String _getClassificationText(BcsClassification classification) {
    return switch (classification) {
      BcsClassification.underweight => 'Abaixo do Peso',
      BcsClassification.ideal => 'Peso Ideal',
      BcsClassification.overweight => 'Sobrepeso',
      BcsClassification.obese => 'Obesidade',
    };
  }

  static String _getDescription(
    BcsClassification classification,
    PetSpecies species,
  ) {
    final pet = species == PetSpecies.dog ? 'cão' : 'gato';

    return switch (classification) {
      BcsClassification.underweight =>
        'Seu $pet está abaixo do peso ideal. Costelas, vértebras e ossos pélvicos facilmente visíveis.',
      BcsClassification.ideal =>
        'Seu $pet está no peso ideal! Costelas palpáveis com leve camada de gordura, cintura visível.',
      BcsClassification.overweight =>
        'Seu $pet está com sobrepeso. Costelas palpáveis com dificuldade, cintura pouco definida.',
      BcsClassification.obese =>
        'Seu $pet está em obesidade. Costelas não palpáveis, sem cintura definida, abdômen penduloso.',
    };
  }

  static List<String> _getRecommendations(
    BcsClassification classification,
    PetSpecies species,
  ) {
    return switch (classification) {
      BcsClassification.underweight => [
        'Consulte um veterinário para investigar causas',
        'Aumente a frequência das refeições',
        'Considere ração hipercalórica',
        'Verifique parasitas intestinais',
        'Avalie problemas dentários que dificultem alimentação',
      ],
      BcsClassification.ideal => [
        'Mantenha a dieta atual',
        'Continue os exercícios regulares',
        'Monitore o peso mensalmente',
        'Ração de qualidade adequada à idade',
        'Check-up veterinário anual',
      ],
      BcsClassification.overweight => [
        'Reduza a quantidade de ração em 10-15%',
        'Evite petiscos entre refeições',
        'Aumente gradualmente a atividade física',
        'Consulte veterinário para dieta balanceada',
        'Meça as porções com copo medidor',
      ],
      BcsClassification.obese => [
        'Consulte veterinário urgentemente',
        'Plano de perda de peso supervisionado',
        'Ração light ou terapêutica',
        'Exercícios leves e progressivos',
        'Controle rigoroso de petiscos e extras',
        'Avalie doenças associadas (diabetes, artrite)',
      ],
    };
  }

  /// Descrições dos parâmetros de avaliação
  static const Map<String, List<String>> parameterDescriptions = {
    'ribPalpation': [
      '1 - Costelas muito visíveis e salientes',
      '2 - Costelas facilmente visíveis',
      '3 - Costelas palpáveis com leve pressão',
      '4 - Costelas palpáveis com pressão moderada',
      '5 - Costelas não palpáveis (cobertas por gordura)',
    ],
    'waistVisibility': [
      '1 - Cintura muito pronunciada (côncava)',
      '2 - Cintura bem visível de cima',
      '3 - Cintura levemente visível',
      '4 - Cintura pouco definida',
      '5 - Sem cintura visível (formato retilíneo)',
    ],
    'abdominalProfile': [
      '1 - Abdômen muito retraído (côncavo)',
      '2 - Abdômen retraído',
      '3 - Abdômen reto (linha reta do peito ao quadril)',
      '4 - Abdômen levemente distendido',
      '5 - Abdômen muito distendido (penduloso)',
    ],
  };
}
