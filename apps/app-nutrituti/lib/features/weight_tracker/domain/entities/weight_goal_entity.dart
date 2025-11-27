import 'package:equatable/equatable.dart';

/// BMI Categories based on WHO standards
enum BmiCategory {
  underweight('underweight'),
  normal('normal'),
  overweight('overweight'),
  obese('obese');

  final String value;
  const BmiCategory(this.value);

  static BmiCategory fromString(String value) {
    return BmiCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BmiCategory.normal,
    );
  }

  static BmiCategory fromBmi(double bmi) {
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25) return BmiCategory.normal;
    if (bmi < 30) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  String get displayName {
    switch (this) {
      case BmiCategory.underweight:
        return 'Abaixo do peso';
      case BmiCategory.normal:
        return 'Normal';
      case BmiCategory.overweight:
        return 'Sobrepeso';
      case BmiCategory.obese:
        return 'Obesidade';
    }
  }

  String get emoji {
    switch (this) {
      case BmiCategory.underweight:
        return '⚠️';
      case BmiCategory.normal:
        return '💚';
      case BmiCategory.overweight:
        return '⚠️';
      case BmiCategory.obese:
        return '🔴';
    }
  }
}

/// Weight Goal entity - target weight and tracking settings
class WeightGoalEntity extends Equatable {
  final String id;
  final double targetWeight;
  final double initialWeight;
  final double heightCm;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WeightGoalEntity({
    required this.id,
    required this.targetWeight,
    required this.initialWeight,
    required this.heightCm,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate BMI from weight and height
  double calculateBmi(double weightKg) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category
  BmiCategory getBmiCategory(double weightKg) {
    return BmiCategory.fromBmi(calculateBmi(weightKg));
  }

  /// Check if target is to lose weight
  bool get isLosingWeight => targetWeight < initialWeight;

  /// Total weight change needed
  double get totalWeightChange => (initialWeight - targetWeight).abs();

  /// Calculate progress percentage based on current weight
  double calculateProgress(double currentWeight) {
    if (totalWeightChange == 0) return 100;

    final changeFromStart = (initialWeight - currentWeight).abs();
    final progress = (changeFromStart / totalWeightChange * 100).clamp(0.0, 100.0);

    // If losing weight, positive change means progress
    // If gaining weight, negative change means progress
    if (isLosingWeight) {
      return currentWeight <= initialWeight ? progress : 0;
    } else {
      return currentWeight >= initialWeight ? progress : 0;
    }
  }

  /// Calculate remaining weight to target
  double calculateRemaining(double currentWeight) {
    return (currentWeight - targetWeight).abs();
  }

  /// Calculate estimated days to reach goal based on average daily change
  int? calculateEstimatedDays(double currentWeight, double avgDailyChange) {
    if (avgDailyChange == 0) return null;

    final remaining = calculateRemaining(currentWeight);
    final daysNeeded = (remaining / avgDailyChange.abs()).ceil();
    return daysNeeded > 0 ? daysNeeded : null;
  }

  /// Days until deadline
  int? get daysUntilDeadline {
    if (deadline == null) return null;
    final now = DateTime.now();
    return deadline!.difference(now).inDays;
  }

  /// Required daily change to meet deadline
  double? requiredDailyChangeForDeadline(double currentWeight) {
    if (deadline == null) return null;
    final days = daysUntilDeadline;
    if (days == null || days <= 0) return null;

    final remaining = calculateRemaining(currentWeight);
    return remaining / days;
  }

  WeightGoalEntity copyWith({
    String? id,
    double? targetWeight,
    double? initialWeight,
    double? heightCm,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightGoalEntity(
      id: id ?? this.id,
      targetWeight: targetWeight ?? this.targetWeight,
      initialWeight: initialWeight ?? this.initialWeight,
      heightCm: heightCm ?? this.heightCm,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WeightGoalEntity.defaultGoal() {
    final now = DateTime.now();
    return WeightGoalEntity(
      id: 'default_goal',
      targetWeight: 70.0,
      initialWeight: 80.0,
      heightCm: 170.0,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
        id,
        targetWeight,
        initialWeight,
        heightCm,
        deadline,
        createdAt,
        updatedAt,
      ];
}
