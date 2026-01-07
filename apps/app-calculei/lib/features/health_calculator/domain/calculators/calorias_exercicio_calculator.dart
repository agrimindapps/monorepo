/// Calculadora de Calorias por Exercício
/// Estima calorias queimadas baseado no tipo de exercício e duração
library;

enum ExerciseType {
  walking,
  running,
  cycling,
  swimming,
  weightTraining,
  yoga,
}

class ExerciseCaloriesResult {
  final double calories;
  final ExerciseType exerciseType;
  final String exerciseTypeName;
  final int durationMinutes;
  final double metValue;
  final String recommendation;

  const ExerciseCaloriesResult({
    required this.calories,
    required this.exerciseType,
    required this.exerciseTypeName,
    required this.durationMinutes,
    required this.metValue,
    required this.recommendation,
  });
}

class CaloriasExercicioCalculator {
  /// Calcula calorias queimadas baseado no tipo de exercício e duração (minutos)
  static ExerciseCaloriesResult calculate({
    required ExerciseType exerciseType,
    required int durationMinutes,
  }) {
    final metValue = _getMetValue(exerciseType);
    final calories = durationMinutes * metValue;

    return ExerciseCaloriesResult(
      calories: double.parse(calories.toStringAsFixed(1)),
      exerciseType: exerciseType,
      exerciseTypeName: _getExerciseTypeName(exerciseType),
      durationMinutes: durationMinutes,
      metValue: metValue,
      recommendation: _getRecommendation(exerciseType),
    );
  }

  static double _getMetValue(ExerciseType type) {
    return switch (type) {
      ExerciseType.walking => 3.5,
      ExerciseType.running => 10.0,
      ExerciseType.cycling => 8.0,
      ExerciseType.swimming => 7.0,
      ExerciseType.weightTraining => 5.0,
      ExerciseType.yoga => 2.5,
    };
  }

  static String _getExerciseTypeName(ExerciseType type) {
    return switch (type) {
      ExerciseType.walking => 'Caminhada',
      ExerciseType.running => 'Corrida',
      ExerciseType.cycling => 'Ciclismo',
      ExerciseType.swimming => 'Natação',
      ExerciseType.weightTraining => 'Musculação',
      ExerciseType.yoga => 'Yoga',
    };
  }

  static String _getRecommendation(ExerciseType type) {
    return switch (type) {
      ExerciseType.walking =>
        'Caminhe pelo menos 150 minutos por semana para manutenção da saúde.',
      ExerciseType.running =>
        'Alterne entre corrida e caminhada se estiver iniciando. Alongue antes e depois.',
      ExerciseType.cycling =>
        'Ajuste corretamente a altura do selim para evitar lesões nos joelhos.',
      ExerciseType.swimming =>
        'Excelente exercício de baixo impacto, ideal para todas as idades.',
      ExerciseType.weightTraining =>
        'Priorize a execução correta antes de aumentar a carga.',
      ExerciseType.yoga =>
        'Pratique regularmente para melhorar flexibilidade e reduzir estresse.',
    };
  }
}
