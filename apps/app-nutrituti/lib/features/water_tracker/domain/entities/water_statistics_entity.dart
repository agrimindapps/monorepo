import 'package:equatable/equatable.dart';

/// Statistics entity for insights and analytics
class WaterStatisticsEntity extends Equatable {
  final double weeklyAverageMl;
  final double monthlyAverageMl;
  final int totalRecordsCount;
  final int totalDaysTracked;
  final int daysGoalAchieved;
  final int currentStreak;
  final int bestStreak;
  final DateTime? bestDay; // Day with most water intake
  final int bestDayAmount;
  final List<MapEntry<DateTime, int>> weeklyData;
  final double weekOverWeekChange; // Percentage change vs last week

  const WaterStatisticsEntity({
    this.weeklyAverageMl = 0,
    this.monthlyAverageMl = 0,
    this.totalRecordsCount = 0,
    this.totalDaysTracked = 0,
    this.daysGoalAchieved = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.bestDay,
    this.bestDayAmount = 0,
    this.weeklyData = const [],
    this.weekOverWeekChange = 0,
  });

  /// Goal achievement rate percentage
  double get achievementRate {
    if (totalDaysTracked == 0) return 0;
    return (daysGoalAchieved / totalDaysTracked * 100);
  }

  /// Trend indicator (-1: down, 0: stable, 1: up)
  int get trend {
    if (weekOverWeekChange > 5) return 1;
    if (weekOverWeekChange < -5) return -1;
    return 0;
  }

  WaterStatisticsEntity copyWith({
    double? weeklyAverageMl,
    double? monthlyAverageMl,
    int? totalRecordsCount,
    int? totalDaysTracked,
    int? daysGoalAchieved,
    int? currentStreak,
    int? bestStreak,
    DateTime? bestDay,
    int? bestDayAmount,
    List<MapEntry<DateTime, int>>? weeklyData,
    double? weekOverWeekChange,
  }) {
    return WaterStatisticsEntity(
      weeklyAverageMl: weeklyAverageMl ?? this.weeklyAverageMl,
      monthlyAverageMl: monthlyAverageMl ?? this.monthlyAverageMl,
      totalRecordsCount: totalRecordsCount ?? this.totalRecordsCount,
      totalDaysTracked: totalDaysTracked ?? this.totalDaysTracked,
      daysGoalAchieved: daysGoalAchieved ?? this.daysGoalAchieved,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      bestDay: bestDay ?? this.bestDay,
      bestDayAmount: bestDayAmount ?? this.bestDayAmount,
      weeklyData: weeklyData ?? this.weeklyData,
      weekOverWeekChange: weekOverWeekChange ?? this.weekOverWeekChange,
    );
  }

  @override
  List<Object?> get props => [
        weeklyAverageMl,
        monthlyAverageMl,
        totalRecordsCount,
        totalDaysTracked,
        daysGoalAchieved,
        currentStreak,
        bestStreak,
        bestDay,
        bestDayAmount,
        weeklyData,
        weekOverWeekChange,
      ];
}
