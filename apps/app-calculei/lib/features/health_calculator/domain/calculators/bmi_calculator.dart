/// Calculadora de IMC (Índice de Massa Corporal)
/// Fórmula: IMC = peso (kg) / altura (m)²
library;

enum Gender { male, female }

enum BmiClassification {
  underweight,
  normal,
  overweightI,
  overweightII,
  overweightIII,
}

class BmiResult {
  final double bmi;
  final BmiClassification classification;
  final String classificationText;
  final String recommendation;
  final double minIdealWeight;
  final double maxIdealWeight;

  const BmiResult({
    required this.bmi,
    required this.classification,
    required this.classificationText,
    required this.recommendation,
    required this.minIdealWeight,
    required this.maxIdealWeight,
  });
}

class BmiCalculator {
  /// Calcula o IMC baseado no peso (kg) e altura (cm)
  static BmiResult calculate({
    required double weightKg,
    required double heightCm,
    required Gender gender,
  }) {
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    final roundedBmi = double.parse(bmi.toStringAsFixed(2));

    final classification = _getClassification(roundedBmi, gender);
    final classificationText = _getClassificationText(classification);
    final recommendation = _getRecommendation(classification);

    // Calcula peso ideal baseado na faixa normal de IMC
    final (minImc, maxImc) = _getNormalRange(gender);
    final minIdealWeight = minImc * heightM * heightM;
    final maxIdealWeight = maxImc * heightM * heightM;

    return BmiResult(
      bmi: roundedBmi,
      classification: classification,
      classificationText: classificationText,
      recommendation: recommendation,
      minIdealWeight: double.parse(minIdealWeight.toStringAsFixed(1)),
      maxIdealWeight: double.parse(maxIdealWeight.toStringAsFixed(1)),
    );
  }

  static BmiClassification _getClassification(double bmi, Gender gender) {
    if (gender == Gender.male) {
      if (bmi < 20.7) return BmiClassification.underweight;
      if (bmi <= 26.4) return BmiClassification.normal;
      if (bmi <= 27.8) return BmiClassification.overweightI;
      if (bmi <= 31.1) return BmiClassification.overweightII;
      return BmiClassification.overweightIII;
    } else {
      if (bmi < 19.1) return BmiClassification.underweight;
      if (bmi <= 25.8) return BmiClassification.normal;
      if (bmi <= 27.3) return BmiClassification.overweightI;
      if (bmi <= 32.3) return BmiClassification.overweightII;
      return BmiClassification.overweightIII;
    }
  }

  static (double, double) _getNormalRange(Gender gender) {
    return gender == Gender.male ? (20.7, 26.4) : (19.1, 25.8);
  }

  static String _getClassificationText(BmiClassification classification) {
    return switch (classification) {
      BmiClassification.underweight => 'Abaixo do Peso',
      BmiClassification.normal => 'Peso Ideal',
      BmiClassification.overweightI => 'Sobrepeso Grau I',
      BmiClassification.overweightII => 'Sobrepeso Grau II',
      BmiClassification.overweightIII => 'Obesidade',
    };
  }

  static String _getRecommendation(BmiClassification classification) {
    return switch (classification) {
      BmiClassification.underweight =>
        'Considere aumentar a ingestão calórica com alimentos nutritivos. Consulte um nutricionista.',
      BmiClassification.normal =>
        'Parabéns! Mantenha uma alimentação equilibrada e pratique exercícios regularmente.',
      BmiClassification.overweightI =>
        'Pequenos ajustes na alimentação e mais atividade física podem ajudar.',
      BmiClassification.overweightII =>
        'Recomenda-se acompanhamento nutricional e programa de exercícios.',
      BmiClassification.overweightIII =>
        'É importante buscar orientação médica e nutricional especializada.',
    };
  }
}
