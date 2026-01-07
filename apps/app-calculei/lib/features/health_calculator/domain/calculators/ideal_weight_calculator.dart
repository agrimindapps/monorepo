/// Calculadora de Peso Ideal
/// Múltiplas fórmulas: Devine, Robinson, Miller, Hamwi
library;

enum IdealWeightFormula {
  devine, // Mais usada clinicamente
  robinson,
  miller,
  hamwi,
}

class IdealWeightResult {
  /// Peso ideal pela fórmula Devine (principal)
  final double devineWeight;

  /// Peso ideal pela fórmula Robinson
  final double robinsonWeight;

  /// Peso ideal pela fórmula Miller
  final double millerWeight;

  /// Peso ideal pela fórmula Hamwi
  final double hamwiWeight;

  /// Média das 4 fórmulas
  final double averageWeight;

  /// Faixa ideal (±10% da média)
  final double minRange;
  final double maxRange;

  /// Diferença do peso atual
  final double? differenceFromCurrent;
  final String? differenceText;

  const IdealWeightResult({
    required this.devineWeight,
    required this.robinsonWeight,
    required this.millerWeight,
    required this.hamwiWeight,
    required this.averageWeight,
    required this.minRange,
    required this.maxRange,
    this.differenceFromCurrent,
    this.differenceText,
  });
}

class IdealWeightCalculator {
  /// Calcula peso ideal usando múltiplas fórmulas
  /// Altura em cm, peso atual opcional em kg
  static IdealWeightResult calculate({
    required double heightCm,
    required bool isMale,
    double? currentWeightKg,
  }) {
    final heightInches = heightCm / 2.54;
    final inchesOver5Feet = heightInches - 60; // 5 feet = 60 inches

    double devine, robinson, miller, hamwi;

    if (isMale) {
      // Fórmulas masculinas (em kg)
      devine = 50.0 + 2.3 * inchesOver5Feet;
      robinson = 52.0 + 1.9 * inchesOver5Feet;
      miller = 56.2 + 1.41 * inchesOver5Feet;
      hamwi = 48.0 + 2.7 * inchesOver5Feet;
    } else {
      // Fórmulas femininas (em kg)
      devine = 45.5 + 2.3 * inchesOver5Feet;
      robinson = 49.0 + 1.7 * inchesOver5Feet;
      miller = 53.1 + 1.36 * inchesOver5Feet;
      hamwi = 45.5 + 2.2 * inchesOver5Feet;
    }

    // Garantir valores mínimos (para alturas muito baixas)
    devine = devine.clamp(40.0, 200.0);
    robinson = robinson.clamp(40.0, 200.0);
    miller = miller.clamp(40.0, 200.0);
    hamwi = hamwi.clamp(40.0, 200.0);

    final average = (devine + robinson + miller + hamwi) / 4;
    final minRange = average * 0.9;
    final maxRange = average * 1.1;

    double? difference;
    String? differenceText;

    if (currentWeightKg != null) {
      difference = currentWeightKg - average;
      if (difference.abs() < 1) {
        differenceText = 'Você está no peso ideal!';
      } else if (difference > 0) {
        differenceText =
            'Você está ${difference.abs().toStringAsFixed(1)} kg acima do ideal';
      } else {
        differenceText =
            'Você está ${difference.abs().toStringAsFixed(1)} kg abaixo do ideal';
      }
    }

    return IdealWeightResult(
      devineWeight: double.parse(devine.toStringAsFixed(1)),
      robinsonWeight: double.parse(robinson.toStringAsFixed(1)),
      millerWeight: double.parse(miller.toStringAsFixed(1)),
      hamwiWeight: double.parse(hamwi.toStringAsFixed(1)),
      averageWeight: double.parse(average.toStringAsFixed(1)),
      minRange: double.parse(minRange.toStringAsFixed(1)),
      maxRange: double.parse(maxRange.toStringAsFixed(1)),
      differenceFromCurrent:
          difference != null
              ? double.parse(difference.toStringAsFixed(1))
              : null,
      differenceText: differenceText,
    );
  }

  /// Descrição das fórmulas
  static String getFormulaDescription(IdealWeightFormula formula) {
    return switch (formula) {
      IdealWeightFormula.devine =>
        'Devine (1974) - Mais usada clinicamente para dosagem de medicamentos',
      IdealWeightFormula.robinson =>
        'Robinson (1983) - Baseada em estudos de mortalidade',
      IdealWeightFormula.miller =>
        'Miller (1983) - Atualização da fórmula Devine',
      IdealWeightFormula.hamwi =>
        'Hamwi (1964) - Uma das fórmulas originais',
    };
  }
}
