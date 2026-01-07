/// Calculadora de Déficit/Superávit Calórico
/// Calcula as calorias diárias necessárias para atingir meta de peso
library;

enum WeightGoal {
  loss,
  maintenance,
  gain,
}

class CaloricBalanceResult {
  final double dailyCalories;
  final double dailyChange;
  final WeightGoal goal;
  final String goalText;
  final double weeklyWeightChange;
  final String recommendation;
  final bool isHealthy;
  final String warning;

  const CaloricBalanceResult({
    required this.dailyCalories,
    required this.dailyChange,
    required this.goal,
    required this.goalText,
    required this.weeklyWeightChange,
    required this.recommendation,
    required this.isHealthy,
    required this.warning,
  });
}

class DeficitSuperavitCalculator {
  /// Calcula déficit/superávit calórico baseado em peso atual, meta, prazo e TDEE
  static CaloricBalanceResult calculate({
    required double currentWeightKg,
    required double targetWeightKg,
    required int weeks,
    required double tdee,
  }) {
    final weightDifference = currentWeightKg - targetWeightKg;
    final goal = _determineGoal(weightDifference);

    // 1 kg de gordura = ~7700 kcal
    final totalCaloriesNeeded = weightDifference * 7700;
    final dailyChange = totalCaloriesNeeded / (weeks * 7);

    // Calorias diárias = TDEE - déficit (ou + superávit)
    final dailyCalories = tdee - dailyChange;

    final weeklyWeightChange = (dailyChange * 7) / 7700;

    final isHealthy = _isHealthyRate(weeklyWeightChange.abs(), goal);
    final warning = _getWarning(weeklyWeightChange, goal, isHealthy);
    final recommendation = _getRecommendation(goal, isHealthy);

    return CaloricBalanceResult(
      dailyCalories: double.parse(dailyCalories.toStringAsFixed(0)),
      dailyChange: double.parse(dailyChange.abs().toStringAsFixed(0)),
      goal: goal,
      goalText: _getGoalText(goal),
      weeklyWeightChange: double.parse(weeklyWeightChange.abs().toStringAsFixed(2)),
      recommendation: recommendation,
      isHealthy: isHealthy,
      warning: warning,
    );
  }

  static WeightGoal _determineGoal(double weightDifference) {
    if (weightDifference > 0.5) {
      return WeightGoal.loss;
    }
    if (weightDifference < -0.5) {
      return WeightGoal.gain;
    }
    return WeightGoal.maintenance;
  }

  static String _getGoalText(WeightGoal goal) {
    return switch (goal) {
      WeightGoal.loss => 'Perda de Peso',
      WeightGoal.maintenance => 'Manutenção',
      WeightGoal.gain => 'Ganho de Peso',
    };
  }

  static bool _isHealthyRate(double weeklyChange, WeightGoal goal) {
    if (goal == WeightGoal.maintenance) {
      return true;
    }
    if (goal == WeightGoal.loss) {
      return weeklyChange >= 0.25 && weeklyChange <= 1.0;
    } else {
      return weeklyChange >= 0.25 && weeklyChange <= 0.75;
    }
  }

  static String _getWarning(
    double weeklyChange,
    WeightGoal goal,
    bool isHealthy,
  ) {
    if (isHealthy) {
      return 'Taxa de mudança saudável e sustentável.';
    }

    final absChange = weeklyChange.abs();

    if (goal == WeightGoal.loss) {
      if (absChange < 0.25) {
        return '⚠️ Perda muito lenta. Considere reduzir mais 200-300 kcal/dia.';
      } else {
        return '⚠️ Perda muito rápida! Risco de perda muscular e deficiências nutricionais.';
      }
    } else if (goal == WeightGoal.gain) {
      if (absChange < 0.25) {
        return '⚠️ Ganho muito lento. Aumente gradualmente as calorias.';
      } else {
        return '⚠️ Ganho muito rápido! Pode acumular muita gordura ao invés de músculo.';
      }
    }

    return '';
  }

  static String _getRecommendation(WeightGoal goal, bool isHealthy) {
    if (goal == WeightGoal.loss) {
      return isHealthy
          ? 'Combine déficit calórico com treino de força para preservar massa muscular. '
              'Priorize proteínas (1.6-2.2g/kg).'
          : 'Ajuste o déficit para perder 0.5-1kg por semana. Muito rápido causa perda muscular.';
    } else if (goal == WeightGoal.gain) {
      return isHealthy
          ? 'Faça treino de força intenso e consuma proteína suficiente para ganho de massa magra.'
          : 'Ajuste o superávit para ganhar 0.25-0.5kg por semana. Muito rápido gera mais gordura.';
    } else {
      return 'Mantenha dieta equilibrada e pratique exercícios para manutenção da saúde.';
    }
  }
}
