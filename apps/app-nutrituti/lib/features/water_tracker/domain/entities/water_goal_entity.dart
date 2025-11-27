import 'package:equatable/equatable.dart';

/// Water Goal entity - smart hydration goals
class WaterGoalEntity extends Equatable {
  final String id;
  final int dailyGoalMl;
  final double? weightKg;
  final int? calculatedGoalMl;
  final bool useCalculatedGoal;
  final int activityAdjustmentMl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WaterGoalEntity({
    required this.id,
    required this.dailyGoalMl,
    this.weightKg,
    this.calculatedGoalMl,
    this.useCalculatedGoal = false,
    this.activityAdjustmentMl = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculates recommended water intake based on weight (30-35ml per kg)
  static int calculateFromWeight(double weightKg, {bool activeDay = false}) {
    final base = (weightKg * 32.5).round(); // Average of 30-35ml
    return activeDay ? (base * 1.2).round() : base;
  }

  /// Returns effective daily goal (calculated or manual)
  int get effectiveGoalMl {
    if (useCalculatedGoal && calculatedGoalMl != null) {
      return calculatedGoalMl! + activityAdjustmentMl;
    }
    return dailyGoalMl + activityAdjustmentMl;
  }

  WaterGoalEntity copyWith({
    String? id,
    int? dailyGoalMl,
    double? weightKg,
    int? calculatedGoalMl,
    bool? useCalculatedGoal,
    int? activityAdjustmentMl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterGoalEntity(
      id: id ?? this.id,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      weightKg: weightKg ?? this.weightKg,
      calculatedGoalMl: calculatedGoalMl ?? this.calculatedGoalMl,
      useCalculatedGoal: useCalculatedGoal ?? this.useCalculatedGoal,
      activityAdjustmentMl: activityAdjustmentMl ?? this.activityAdjustmentMl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WaterGoalEntity.defaultGoal() {
    final now = DateTime.now();
    return WaterGoalEntity(
      id: 'default_goal',
      dailyGoalMl: 2000,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dailyGoalMl,
        weightKg,
        calculatedGoalMl,
        useCalculatedGoal,
        activityAdjustmentMl,
        createdAt,
        updatedAt,
      ];
}
