/// Calculadora de Álcool no Sangue (BAC - Blood Alcohol Concentration)
/// Estima a concentração de álcool no sangue usando a fórmula de Widmark
library;

import 'bmi_calculator.dart' show Gender;

enum DrinkType {
  beer,
  wine,
  spirits,
}

enum BacLevel {
  sober,
  mild,
  moderate,
  high,
  veryHigh,
}

class BloodAlcoholResult {
  final double bac;
  final BacLevel level;
  final String levelText;
  final String effects;
  final String warning;
  final bool canDrive;

  const BloodAlcoholResult({
    required this.bac,
    required this.level,
    required this.levelText,
    required this.effects,
    required this.warning,
    required this.canDrive,
  });
}

class AlcoolSangueCalculator {
  /// Calcula BAC baseado no peso (kg), quantidade de bebidas, tipo, horas e gênero
  static BloodAlcoholResult calculate({
    required double weightKg,
    required int drinksCount,
    required DrinkType drinkType,
    required double hoursSinceDrinking,
    required Gender gender,
  }) {
    // Gramas de álcool por bebida
    final alcoholGrams = drinksCount * _getAlcoholGramsPerDrink(drinkType);

    // Fator de distribuição (Widmark r)
    final r = gender == Gender.male ? 0.68 : 0.55;

    // Cálculo do BAC usando fórmula de Widmark
    final bac = (alcoholGrams / (weightKg * r * 10)) - (0.015 * hoursSinceDrinking);
    final roundedBac = double.parse((bac > 0 ? bac : 0).toStringAsFixed(3));

    final level = _getBacLevel(roundedBac);
    final levelText = _getLevelText(level);
    final effects = _getEffects(level);
    final warning = _getWarning(level);
    final canDrive = roundedBac < 0.02; // Limite legal no Brasil: 0.02 g/dL

    return BloodAlcoholResult(
      bac: roundedBac,
      level: level,
      levelText: levelText,
      effects: effects,
      warning: warning,
      canDrive: canDrive,
    );
  }

  static double _getAlcoholGramsPerDrink(DrinkType type) {
    return switch (type) {
      DrinkType.beer => 14.0, // 350ml
      DrinkType.wine => 14.0, // 150ml
      DrinkType.spirits => 14.0, // 45ml
    };
  }

  static BacLevel _getBacLevel(double bac) {
    if (bac < 0.02) return BacLevel.sober;
    if (bac < 0.06) return BacLevel.mild;
    if (bac < 0.10) return BacLevel.moderate;
    if (bac < 0.20) return BacLevel.high;
    return BacLevel.veryHigh;
  }

  static String _getLevelText(BacLevel level) {
    return switch (level) {
      BacLevel.sober => 'Sóbrio',
      BacLevel.mild => 'Leve',
      BacLevel.moderate => 'Moderado',
      BacLevel.high => 'Alto',
      BacLevel.veryHigh => 'Muito Alto',
    };
  }

  static String _getEffects(BacLevel level) {
    return switch (level) {
      BacLevel.sober => 'Sem efeitos aparentes',
      BacLevel.mild =>
        'Relaxamento leve, leve diminuição de coordenação',
      BacLevel.moderate =>
        'Fala arrastada, equilíbrio comprometido, julgamento prejudicado',
      BacLevel.high =>
        'Confusão, desorientação, dificuldade de ficar em pé',
      BacLevel.veryHigh =>
        'Risco de intoxicação severa, possível perda de consciência',
    };
  }

  static String _getWarning(BacLevel level) {
    return switch (level) {
      BacLevel.sober =>
        'Você está abaixo do limite legal para dirigir.',
      BacLevel.mild =>
        '⚠️ NUNCA dirija após consumir álcool. Mesmo pequenas quantidades afetam reflexos.',
      BacLevel.moderate =>
        '⚠️ PROIBIDO DIRIGIR. Chame táxi/Uber ou peça carona.',
      BacLevel.high =>
        '🚨 RISCO ALTO. Não dirija e evite atividades perigosas.',
      BacLevel.veryHigh =>
        '🚨 EMERGÊNCIA. Procure atendimento médico se houver sintomas graves.',
    };
  }
}
