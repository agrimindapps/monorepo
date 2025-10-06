import 'package:core/core.dart' show Equatable;

class Weight extends Equatable {
  final String id;
  final String animalId;
  final double weight; // in kg
  final DateTime date;
  final String? notes;
  final int?
  bodyConditionScore; // 1-9 scale (1 = underweight, 5 = ideal, 9 = obese)
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Weight({
    required this.id,
    required this.animalId,
    required this.weight,
    required this.date,
    this.notes,
    this.bodyConditionScore,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Weight copyWith({
    String? id,
    String? animalId,
    double? weight,
    DateTime? date,
    String? notes,
    int? bodyConditionScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Weight(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      bodyConditionScore: bodyConditionScore ?? this.bodyConditionScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Retorna a condição corporal baseada no score
  BodyCondition get bodyCondition {
    if (bodyConditionScore == null) return BodyCondition.unknown;

    if (bodyConditionScore! <= 3) return BodyCondition.underweight;
    if (bodyConditionScore! <= 6) return BodyCondition.ideal;
    return BodyCondition.overweight;
  }

  /// Retorna o peso formatado com unidade
  String get formattedWeight {
    return '${weight.toStringAsFixed(2)} kg';
  }

  /// Retorna a data formatada
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Verifica se é um registro recente (últimos 7 dias)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    return difference <= 7;
  }

  /// Calcula a diferença em relação a um peso anterior
  WeightDifference? calculateDifference(Weight? previousWeight) {
    if (previousWeight == null) return null;

    final difference = weight - previousWeight.weight;
    final percentageChange = (difference / previousWeight.weight) * 100;
    final daysDifference = date.difference(previousWeight.date).inDays;

    return WeightDifference(
      difference: difference,
      percentageChange: percentageChange,
      daysDifference: daysDifference,
      trend:
          difference > 0
              ? WeightTrend.gaining
              : difference < 0
              ? WeightTrend.losing
              : WeightTrend.stable,
    );
  }

  /// Verifica se a variação de peso é significativa
  bool hasSignificantChange(Weight? previousWeight, {double threshold = 0.1}) {
    final diff = calculateDifference(previousWeight);
    if (diff == null) return false;

    return diff.difference.abs() >= threshold;
  }

  @override
  List<Object?> get props => [
    id,
    animalId,
    weight,
    date,
    notes,
    bodyConditionScore,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}

enum BodyCondition {
  underweight,
  ideal,
  overweight,
  unknown;

  String get displayName {
    switch (this) {
      case BodyCondition.underweight:
        return 'Abaixo do peso';
      case BodyCondition.ideal:
        return 'Peso ideal';
      case BodyCondition.overweight:
        return 'Acima do peso';
      case BodyCondition.unknown:
        return 'Não informado';
    }
  }

  String get description {
    switch (this) {
      case BodyCondition.underweight:
        return 'O animal está abaixo do peso ideal';
      case BodyCondition.ideal:
        return 'O animal está no peso ideal';
      case BodyCondition.overweight:
        return 'O animal está acima do peso ideal';
      case BodyCondition.unknown:
        return 'Condição corporal não avaliada';
    }
  }
}

enum WeightTrend {
  gaining,
  losing,
  stable;

  String get displayName {
    switch (this) {
      case WeightTrend.gaining:
        return 'Ganhando peso';
      case WeightTrend.losing:
        return 'Perdendo peso';
      case WeightTrend.stable:
        return 'Peso estável';
    }
  }

  String get emoji {
    switch (this) {
      case WeightTrend.gaining:
        return '📈';
      case WeightTrend.losing:
        return '📉';
      case WeightTrend.stable:
        return '➡️';
    }
  }
}

class WeightDifference {
  final double difference; // in kg
  final double percentageChange; // percentage
  final int daysDifference; // days between measurements
  final WeightTrend trend;

  const WeightDifference({
    required this.difference,
    required this.percentageChange,
    required this.daysDifference,
    required this.trend,
  });

  /// Retorna a diferença formatada
  String get formattedDifference {
    final sign = difference >= 0 ? '+' : '';
    return '$sign${difference.toStringAsFixed(2)} kg';
  }

  /// Retorna a porcentagem formatada
  String get formattedPercentage {
    final sign = percentageChange >= 0 ? '+' : '';
    return '$sign${percentageChange.toStringAsFixed(1)}%';
  }

  /// Retorna uma descrição amigável da mudança
  String get description {
    if (difference.abs() < 0.05) {
      return 'Peso mantido';
    }

    final changeDescription = difference > 0 ? 'ganhou' : 'perdeu';
    return 'O animal $changeDescription ${difference.abs().toStringAsFixed(2)} kg em $daysDifference dias';
  }

  /// Verifica se é uma mudança rápida (mais de 5% em menos de 30 dias)
  bool get isRapidChange {
    return percentageChange.abs() > 5 && daysDifference < 30;
  }

  /// Verifica se é uma mudança preocupante
  bool get isConcerning {
    return isRapidChange || percentageChange.abs() > 10;
  }
}
