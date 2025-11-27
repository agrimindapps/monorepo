import 'package:equatable/equatable.dart';

/// Water Streak entity - tracking consecutive days
class WaterStreakEntity extends Equatable {
  final String id;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastRecordDate;
  final DateTime? streakStartDate;
  final bool canRecover;
  final DateTime updatedAt;

  const WaterStreakEntity({
    required this.id,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastRecordDate,
    this.streakStartDate,
    this.canRecover = false,
    required this.updatedAt,
  });

  /// Check if streak is at risk (no record today and last was yesterday)
  bool get isAtRisk {
    if (lastRecordDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastRecordDate!.year,
      lastRecordDate!.month,
      lastRecordDate!.day,
    );
    final yesterday = today.subtract(const Duration(days: 1));
    return lastDate == yesterday;
  }

  /// Check if streak was broken (last record was more than 1 day ago)
  bool get isBroken {
    if (lastRecordDate == null) return currentStreak > 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastRecordDate!.year,
      lastRecordDate!.month,
      lastRecordDate!.day,
    );
    final daysSinceRecord = today.difference(lastDate).inDays;
    return daysSinceRecord > 1;
  }

  /// Days until next milestone
  int get daysToNextMilestone {
    const milestones = [7, 14, 30, 60, 90, 180, 365];
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone - currentStreak;
      }
    }
    return 365 - (currentStreak % 365);
  }

  WaterStreakEntity copyWith({
    String? id,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastRecordDate,
    DateTime? streakStartDate,
    bool? canRecover,
    DateTime? updatedAt,
  }) {
    return WaterStreakEntity(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastRecordDate: lastRecordDate ?? this.lastRecordDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      canRecover: canRecover ?? this.canRecover,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WaterStreakEntity.empty() {
    return WaterStreakEntity(
      id: 'default_streak',
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        currentStreak,
        bestStreak,
        lastRecordDate,
        streakStartDate,
        canRecover,
        updatedAt,
      ];
}
