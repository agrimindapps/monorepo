import 'package:equatable/equatable.dart';

import 'weight_goal_entity.dart';

/// Trend direction for weight change
enum WeightTrend {
  losing(-1),
  stable(0),
  gaining(1);

  final int value;
  const WeightTrend(this.value);

  String get displayName {
    switch (this) {
      case WeightTrend.losing:
        return 'Perdendo';
      case WeightTrend.stable:
        return 'Estável';
      case WeightTrend.gaining:
        return 'Ganhando';
    }
  }

  String get emoji {
    switch (this) {
      case WeightTrend.losing:
        return '↘️';
      case WeightTrend.stable:
        return '→';
      case WeightTrend.gaining:
        return '↗️';
    }
  }
}

/// Weight Statistics entity for insights and analytics
class WeightStatisticsEntity extends Equatable {
  final double? currentWeight;
  final double? initialWeight;
  final double? targetWeight;
  final double? minWeight;
  final double? maxWeight;
  final double? weeklyAverage;
  final double? monthlyAverage;
  final double? weeklyChange;
  final double? monthlyChange;
  final double? totalChange;
  final int totalRecordsCount;
  final int daysTracked;
  final int consecutiveDays;
  final double? currentBmi;
  final BmiCategory? bmiCategory;
  final WeightTrend trend;
  final int? estimatedDaysToGoal;
  final double? progressPercentage;
  final List<MapEntry<DateTime, double>> weeklyData;
  final List<MapEntry<DateTime, double>> monthlyData;

  const WeightStatisticsEntity({
    this.currentWeight,
    this.initialWeight,
    this.targetWeight,
    this.minWeight,
    this.maxWeight,
    this.weeklyAverage,
    this.monthlyAverage,
    this.weeklyChange,
    this.monthlyChange,
    this.totalChange,
    this.totalRecordsCount = 0,
    this.daysTracked = 0,
    this.consecutiveDays = 0,
    this.currentBmi,
    this.bmiCategory,
    this.trend = WeightTrend.stable,
    this.estimatedDaysToGoal,
    this.progressPercentage,
    this.weeklyData = const [],
    this.monthlyData = const [],
  });

  /// Generate insight message based on current stats
  String? get insight {
    if (weeklyChange == null) return null;

    if (weeklyChange! < -1.0) {
      return 'Você perdeu ${weeklyChange!.abs().toStringAsFixed(1)}kg esta semana! 🎉';
    } else if (weeklyChange! < -0.5) {
      return 'Bom progresso! ${weeklyChange!.abs().toStringAsFixed(1)}kg perdidos esta semana.';
    } else if (weeklyChange!.abs() <= 0.5) {
      return 'Peso estável esta semana. Continue assim!';
    } else if (weeklyChange! > 1.0) {
      return 'Atenção: ${weeklyChange!.toStringAsFixed(1)}kg ganhos esta semana.';
    }
    return null;
  }

  /// Trend color for UI
  WeightTrend calculateTrend({bool isLosingWeight = true}) {
    if (weeklyChange == null || weeklyChange!.abs() < 0.3) {
      return WeightTrend.stable;
    }

    if (isLosingWeight) {
      return weeklyChange! < 0 ? WeightTrend.losing : WeightTrend.gaining;
    } else {
      return weeklyChange! > 0 ? WeightTrend.gaining : WeightTrend.losing;
    }
  }

  WeightStatisticsEntity copyWith({
    double? currentWeight,
    double? initialWeight,
    double? targetWeight,
    double? minWeight,
    double? maxWeight,
    double? weeklyAverage,
    double? monthlyAverage,
    double? weeklyChange,
    double? monthlyChange,
    double? totalChange,
    int? totalRecordsCount,
    int? daysTracked,
    int? consecutiveDays,
    double? currentBmi,
    BmiCategory? bmiCategory,
    WeightTrend? trend,
    int? estimatedDaysToGoal,
    double? progressPercentage,
    List<MapEntry<DateTime, double>>? weeklyData,
    List<MapEntry<DateTime, double>>? monthlyData,
  }) {
    return WeightStatisticsEntity(
      currentWeight: currentWeight ?? this.currentWeight,
      initialWeight: initialWeight ?? this.initialWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      minWeight: minWeight ?? this.minWeight,
      maxWeight: maxWeight ?? this.maxWeight,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      monthlyAverage: monthlyAverage ?? this.monthlyAverage,
      weeklyChange: weeklyChange ?? this.weeklyChange,
      monthlyChange: monthlyChange ?? this.monthlyChange,
      totalChange: totalChange ?? this.totalChange,
      totalRecordsCount: totalRecordsCount ?? this.totalRecordsCount,
      daysTracked: daysTracked ?? this.daysTracked,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      currentBmi: currentBmi ?? this.currentBmi,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      trend: trend ?? this.trend,
      estimatedDaysToGoal: estimatedDaysToGoal ?? this.estimatedDaysToGoal,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      weeklyData: weeklyData ?? this.weeklyData,
      monthlyData: monthlyData ?? this.monthlyData,
    );
  }

  @override
  List<Object?> get props => [
        currentWeight,
        initialWeight,
        targetWeight,
        minWeight,
        maxWeight,
        weeklyAverage,
        monthlyAverage,
        weeklyChange,
        monthlyChange,
        totalChange,
        totalRecordsCount,
        daysTracked,
        consecutiveDays,
        currentBmi,
        bmiCategory,
        trend,
        estimatedDaysToGoal,
        progressPercentage,
        weeklyData,
        monthlyData,
      ];
}
