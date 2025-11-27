import 'package:equatable/equatable.dart';

/// Daily Progress entity - aggregated daily data
class WaterDailyProgressEntity extends Equatable {
  final String id;
  final DateTime date;
  final int totalMl;
  final int goalMl;
  final bool goalAchieved;
  final int recordCount;
  final DateTime? firstRecordTime;
  final DateTime? lastRecordTime;
  final DateTime updatedAt;

  const WaterDailyProgressEntity({
    required this.id,
    required this.date,
    this.totalMl = 0,
    required this.goalMl,
    this.goalAchieved = false,
    this.recordCount = 0,
    this.firstRecordTime,
    this.lastRecordTime,
    required this.updatedAt,
  });

  /// Progress percentage (0-100+)
  double get progressPercentage {
    if (goalMl == 0) return 0;
    return (totalMl / goalMl * 100);
  }

  /// Remaining ml to reach goal
  int get remainingMl {
    final remaining = goalMl - totalMl;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if goal was exceeded
  bool get goalExceeded => totalMl > goalMl;

  /// How much over the goal (percentage)
  double get overGoalPercentage {
    if (!goalExceeded) return 0;
    return ((totalMl - goalMl) / goalMl * 100);
  }

  WaterDailyProgressEntity copyWith({
    String? id,
    DateTime? date,
    int? totalMl,
    int? goalMl,
    bool? goalAchieved,
    int? recordCount,
    DateTime? firstRecordTime,
    DateTime? lastRecordTime,
    DateTime? updatedAt,
  }) {
    return WaterDailyProgressEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      totalMl: totalMl ?? this.totalMl,
      goalMl: goalMl ?? this.goalMl,
      goalAchieved: goalAchieved ?? this.goalAchieved,
      recordCount: recordCount ?? this.recordCount,
      firstRecordTime: firstRecordTime ?? this.firstRecordTime,
      lastRecordTime: lastRecordTime ?? this.lastRecordTime,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WaterDailyProgressEntity.empty(DateTime date, int goalMl) {
    return WaterDailyProgressEntity(
      id: 'progress_${date.toIso8601String().split('T')[0]}',
      date: date,
      goalMl: goalMl,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        totalMl,
        goalMl,
        goalAchieved,
        recordCount,
        firstRecordTime,
        lastRecordTime,
        updatedAt,
      ];
}
