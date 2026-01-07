/// Calculadora de Gordura Corporal
/// Método: Circunferências (US Navy Method)
/// Masculino: 495 / (1.0324 - 0.19077 * log10(cintura - pescoço) + 0.15456 * log10(altura)) - 450
/// Feminino: 495 / (1.29579 - 0.35004 * log10(cintura + quadril - pescoço) + 0.22100 * log10(altura)) - 450
library;

import 'dart:math';

enum BodyFatCategory {
  essential,
  athlete,
  fitness,
  average,
  obese,
}

class BodyFatResult {
  /// Percentual de gordura corporal
  final double bodyFatPercentage;

  /// Categoria
  final BodyFatCategory category;

  /// Texto da categoria
  final String categoryText;

  /// Massa gorda em kg
  final double fatMassKg;

  /// Massa magra em kg
  final double leanMassKg;

  /// Recomendação
  final String recommendation;

  const BodyFatResult({
    required this.bodyFatPercentage,
    required this.category,
    required this.categoryText,
    required this.fatMassKg,
    required this.leanMassKg,
    required this.recommendation,
  });
}

class BodyFatCalculator {
  /// Calcula gordura corporal pelo método US Navy
  /// Todas as medidas em cm, peso em kg
  static BodyFatResult calculate({
    required double weightKg,
    required double heightCm,
    required double waistCm, // Cintura
    required double neckCm, // Pescoço
    double? hipCm, // Quadril (obrigatório para mulheres)
    required bool isMale,
  }) {
    double bodyFatPercentage;

    if (isMale) {
      // Fórmula masculina
      bodyFatPercentage =
          495 /
              (1.0324 -
                  0.19077 * log10(waistCm - neckCm) +
                  0.15456 * log10(heightCm)) -
          450;
    } else {
      // Fórmula feminina (requer medida do quadril)
      final hip = hipCm ?? waistCm; // Fallback se não informado
      bodyFatPercentage =
          495 /
              (1.29579 -
                  0.35004 * log10(waistCm + hip - neckCm) +
                  0.22100 * log10(heightCm)) -
          450;
    }

    // Limitar a valores plausíveis
    bodyFatPercentage = bodyFatPercentage.clamp(2.0, 60.0);

    final fatMassKg = weightKg * (bodyFatPercentage / 100);
    final leanMassKg = weightKg - fatMassKg;

    final category = _getCategory(bodyFatPercentage, isMale);
    final categoryText = _getCategoryText(category);
    final recommendation = _getRecommendation(category, isMale);

    return BodyFatResult(
      bodyFatPercentage: double.parse(bodyFatPercentage.toStringAsFixed(1)),
      category: category,
      categoryText: categoryText,
      fatMassKg: double.parse(fatMassKg.toStringAsFixed(1)),
      leanMassKg: double.parse(leanMassKg.toStringAsFixed(1)),
      recommendation: recommendation,
    );
  }

  static double log10(double x) => log(x) / ln10;

  static BodyFatCategory _getCategory(double bf, bool isMale) {
    if (isMale) {
      if (bf < 6) return BodyFatCategory.essential;
      if (bf < 14) return BodyFatCategory.athlete;
      if (bf < 18) return BodyFatCategory.fitness;
      if (bf < 25) return BodyFatCategory.average;
      return BodyFatCategory.obese;
    } else {
      if (bf < 14) return BodyFatCategory.essential;
      if (bf < 21) return BodyFatCategory.athlete;
      if (bf < 25) return BodyFatCategory.fitness;
      if (bf < 32) return BodyFatCategory.average;
      return BodyFatCategory.obese;
    }
  }

  static String _getCategoryText(BodyFatCategory category) {
    return switch (category) {
      BodyFatCategory.essential => 'Gordura Essencial',
      BodyFatCategory.athlete => 'Atleta',
      BodyFatCategory.fitness => 'Fitness',
      BodyFatCategory.average => 'Média',
      BodyFatCategory.obese => 'Obesidade',
    };
  }

  static String _getRecommendation(BodyFatCategory category, bool isMale) {
    return switch (category) {
      BodyFatCategory.essential =>
        'Nível muito baixo de gordura. Pode ser prejudicial à saúde se mantido por muito tempo.',
      BodyFatCategory.athlete =>
        'Nível típico de atletas de alto desempenho. Excelente condição física!',
      BodyFatCategory.fitness =>
        'Ótimo nível de gordura corporal. Continue mantendo hábitos saudáveis.',
      BodyFatCategory.average =>
        'Nível aceitável para a população em geral. Pequenas mudanças podem melhorar.',
      BodyFatCategory.obese =>
        'Nível elevado de gordura. Recomenda-se acompanhamento profissional.',
    };
  }

  /// Faixas de referência por gênero
  static Map<String, (double, double)> getRanges(bool isMale) {
    if (isMale) {
      return {
        'Essencial': (2.0, 5.0),
        'Atleta': (6.0, 13.0),
        'Fitness': (14.0, 17.0),
        'Média': (18.0, 24.0),
        'Obesidade': (25.0, 60.0),
      };
    } else {
      return {
        'Essencial': (10.0, 13.0),
        'Atleta': (14.0, 20.0),
        'Fitness': (21.0, 24.0),
        'Média': (25.0, 31.0),
        'Obesidade': (32.0, 60.0),
      };
    }
  }
}
