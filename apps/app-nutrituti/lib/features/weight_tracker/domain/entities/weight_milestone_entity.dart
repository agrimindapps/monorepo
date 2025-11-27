import 'package:equatable/equatable.dart';

/// Weight Milestone entity - intermediate goals
class WeightMilestoneEntity extends Equatable {
  final String id;
  final double targetWeight;
  final String title;
  final bool isAchieved;
  final DateTime? achievedAt;
  final int sortOrder;
  final DateTime createdAt;

  const WeightMilestoneEntity({
    required this.id,
    required this.targetWeight,
    required this.title,
    this.isAchieved = false,
    this.achievedAt,
    this.sortOrder = 0,
    required this.createdAt,
  });

  WeightMilestoneEntity copyWith({
    String? id,
    double? targetWeight,
    String? title,
    bool? isAchieved,
    DateTime? achievedAt,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return WeightMilestoneEntity(
      id: id ?? this.id,
      targetWeight: targetWeight ?? this.targetWeight,
      title: title ?? this.title,
      isAchieved: isAchieved ?? this.isAchieved,
      achievedAt: achievedAt ?? this.achievedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        targetWeight,
        title,
        isAchieved,
        achievedAt,
        sortOrder,
        createdAt,
      ];
}
