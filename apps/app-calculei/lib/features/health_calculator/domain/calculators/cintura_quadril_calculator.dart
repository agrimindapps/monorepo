/// Calculadora de Relação Cintura-Quadril (RCQ)
/// Avalia a distribuição de gordura corporal
library;

import 'bmi_calculator.dart' show Gender;

enum WhrClassification {
  low,
  moderate,
  high,
  veryHigh,
}

class WaistHipRatioResult {
  final double whr;
  final WhrClassification classification;
  final String classificationText;
  final String healthRisk;
  final String recommendation;

  const WaistHipRatioResult({
    required this.whr,
    required this.classification,
    required this.classificationText,
    required this.healthRisk,
    required this.recommendation,
  });
}

class CinturaQuadrilCalculator {
  /// Calcula a relação cintura-quadril baseado nas medidas (cm) e gênero
  static WaistHipRatioResult calculate({
    required double waistCm,
    required double hipCm,
    required Gender gender,
  }) {
    final whr = waistCm / hipCm;
    final roundedWhr = double.parse(whr.toStringAsFixed(2));

    final classification = _getClassification(roundedWhr, gender);
    final classificationText = _getClassificationText(classification);
    final healthRisk = _getHealthRisk(classification);
    final recommendation = _getRecommendation(classification);

    return WaistHipRatioResult(
      whr: roundedWhr,
      classification: classification,
      classificationText: classificationText,
      healthRisk: healthRisk,
      recommendation: recommendation,
    );
  }

  static WhrClassification _getClassification(double whr, Gender gender) {
    if (gender == Gender.male) {
      if (whr < 0.83) {
        return WhrClassification.low;
      }
      if (whr <= 0.88) {
        return WhrClassification.moderate;
      }
      if (whr <= 0.94) {
        return WhrClassification.high;
      }
      return WhrClassification.veryHigh;
    } else {
      if (whr < 0.71) {
        return WhrClassification.low;
      }
      if (whr <= 0.77) {
        return WhrClassification.moderate;
      }
      if (whr <= 0.82) {
        return WhrClassification.high;
      }
      return WhrClassification.veryHigh;
    }
  }

  static String _getClassificationText(WhrClassification classification) {
    return switch (classification) {
      WhrClassification.low => 'Risco Baixo',
      WhrClassification.moderate => 'Risco Moderado',
      WhrClassification.high => 'Risco Alto',
      WhrClassification.veryHigh => 'Risco Muito Alto',
    };
  }

  static String _getHealthRisk(WhrClassification classification) {
    return switch (classification) {
      WhrClassification.low => 'Baixo risco de doenças cardiovasculares',
      WhrClassification.moderate =>
        'Risco moderado - atenção à alimentação e exercícios',
      WhrClassification.high =>
        'Risco aumentado de diabetes e doenças cardíacas',
      WhrClassification.veryHigh =>
        'Alto risco metabólico - consulte um médico',
    };
  }

  static String _getRecommendation(WhrClassification classification) {
    return switch (classification) {
      WhrClassification.low =>
        'Mantenha hábitos saudáveis com alimentação equilibrada e exercícios regulares.',
      WhrClassification.moderate =>
        'Aumente a atividade física aeróbica e reduza carboidratos refinados.',
      WhrClassification.high =>
        'Consulte um nutricionista e médico para programa personalizado de emagrecimento.',
      WhrClassification.veryHigh =>
        'Busque orientação médica urgente. A gordura abdominal aumenta riscos à saúde.',
    };
  }
}
