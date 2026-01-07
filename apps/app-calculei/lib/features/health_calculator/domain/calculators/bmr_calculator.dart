/// Calculadora de TMB (Taxa Metabólica Basal)
/// Fórmula: Mifflin-St Jeor
/// Masculino: TMB = 13.397 × peso + 4.799 × altura - 5.677 × idade + 88.362
/// Feminino: TMB = 9.247 × peso + 3.098 × altura - 4.330 × idade + 447.593
library;

enum ActivityLevel {
  sedentary, // 1.2
  lightlyActive, // 1.375
  moderatelyActive, // 1.55
  veryActive, // 1.725
  extraActive, // 1.9
}

class BmrResult {
  /// Taxa Metabólica Basal (calorias/dia em repouso)
  final double bmr;

  /// Gasto Energético Total (BMR × fator de atividade)
  final double tdee;

  /// Nível de atividade usado
  final ActivityLevel activityLevel;

  /// Calorias para perder peso (~500 kcal deficit)
  final double caloriesForWeightLoss;

  /// Calorias para ganhar peso (~500 kcal surplus)
  final double caloriesForWeightGain;

  const BmrResult({
    required this.bmr,
    required this.tdee,
    required this.activityLevel,
    required this.caloriesForWeightLoss,
    required this.caloriesForWeightGain,
  });
}

class BmrCalculator {
  static const Map<ActivityLevel, double> activityFactors = {
    ActivityLevel.sedentary: 1.2,
    ActivityLevel.lightlyActive: 1.375,
    ActivityLevel.moderatelyActive: 1.55,
    ActivityLevel.veryActive: 1.725,
    ActivityLevel.extraActive: 1.9,
  };

  static const Map<ActivityLevel, String> activityDescriptions = {
    ActivityLevel.sedentary: 'Sedentário (pouco ou nenhum exercício)',
    ActivityLevel.lightlyActive: 'Levemente ativo (1-3 dias/semana)',
    ActivityLevel.moderatelyActive: 'Moderadamente ativo (3-5 dias/semana)',
    ActivityLevel.veryActive: 'Muito ativo (6-7 dias/semana)',
    ActivityLevel.extraActive: 'Extra ativo (exercício intenso diário)',
  };

  /// Calcula TMB e GET usando a fórmula Mifflin-St Jeor
  static BmrResult calculate({
    required double weightKg,
    required double heightCm,
    required int ageYears,
    required bool isMale,
    required ActivityLevel activityLevel,
  }) {
    double bmr;

    if (isMale) {
      bmr = 13.397 * weightKg + 4.799 * heightCm - 5.677 * ageYears + 88.362;
    } else {
      bmr = 9.247 * weightKg + 3.098 * heightCm - 4.330 * ageYears + 447.593;
    }

    final factor = activityFactors[activityLevel]!;
    final tdee = bmr * factor;

    return BmrResult(
      bmr: double.parse(bmr.toStringAsFixed(0)),
      tdee: double.parse(tdee.toStringAsFixed(0)),
      activityLevel: activityLevel,
      caloriesForWeightLoss: double.parse((tdee - 500).toStringAsFixed(0)),
      caloriesForWeightGain: double.parse((tdee + 500).toStringAsFixed(0)),
    );
  }

  static String getActivityDescription(ActivityLevel level) {
    return activityDescriptions[level]!;
  }
}
