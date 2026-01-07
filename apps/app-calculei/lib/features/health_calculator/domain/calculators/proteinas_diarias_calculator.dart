/// Calculadora de Proteínas Diárias
/// Calcula a quantidade ideal de proteína baseada no peso e nível de atividade
library;

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  veryActive,
  extreme,
}

class DailyProteinResult {
  final double minProtein;
  final double maxProtein;
  final ActivityLevel activityLevel;
  final String activityLevelText;
  final String recommendation;

  const DailyProteinResult({
    required this.minProtein,
    required this.maxProtein,
    required this.activityLevel,
    required this.activityLevelText,
    required this.recommendation,
  });
}

class ProteinarDiariasCalculator {
  /// Calcula a necessidade diária de proteínas baseado no peso (kg) e nível de atividade
  static DailyProteinResult calculate({
    required double weightKg,
    required ActivityLevel activityLevel,
  }) {
    final activityFactor = _getActivityFactor(activityLevel);
    final minProtein = weightKg * activityFactor;
    final maxProtein = minProtein + (weightKg * 0.4);

    return DailyProteinResult(
      minProtein: double.parse(minProtein.toStringAsFixed(1)),
      maxProtein: double.parse(maxProtein.toStringAsFixed(1)),
      activityLevel: activityLevel,
      activityLevelText: _getActivityLevelText(activityLevel),
      recommendation: _getRecommendation(activityLevel),
    );
  }

  static double _getActivityFactor(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => 0.8,
      ActivityLevel.light => 1.0,
      ActivityLevel.moderate => 1.2,
      ActivityLevel.veryActive => 1.6,
      ActivityLevel.extreme => 2.0,
    };
  }

  static String _getActivityLevelText(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => 'Sedentário',
      ActivityLevel.light => 'Atividade Leve',
      ActivityLevel.moderate => 'Atividade Moderada',
      ActivityLevel.veryActive => 'Muito Ativo',
      ActivityLevel.extreme => 'Atividade Extrema',
    };
  }

  static String _getRecommendation(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary =>
        'Distribua a proteína em 3-4 refeições ao dia para melhor absorção.',
      ActivityLevel.light =>
        'Inclua fontes de proteína magra em todas as principais refeições.',
      ActivityLevel.moderate =>
        'Consuma proteína logo após o treino para melhor recuperação muscular.',
      ActivityLevel.veryActive =>
        'Considere suplementação se tiver dificuldade em atingir a meta com alimentos.',
      ActivityLevel.extreme =>
        'Acompanhamento nutricional é essencial para atletas de alto rendimento.',
    };
  }
}
