import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/weight.dart';

part 'weight_model.g.dart';

@HiveType(typeId: 17)
@JsonSerializable()
class WeightModel extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'animal_id')
  final String animalId;

  @HiveField(2)
  @JsonKey(name: 'weight')
  final double weight;

  @HiveField(3)
  @JsonKey(name: 'date')
  final DateTime date;

  @HiveField(4)
  @JsonKey(name: 'notes')
  final String? notes;

  @HiveField(5)
  @JsonKey(name: 'body_condition_score')
  final int? bodyConditionScore;

  @HiveField(6)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(7)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @HiveField(8)
  @JsonKey(name: 'is_deleted')
  final bool isDeleted;

  WeightModel({
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

  factory WeightModel.fromEntity(Weight weight) {
    return WeightModel(
      id: weight.id,
      animalId: weight.animalId,
      weight: weight.weight,
      date: weight.date,
      notes: weight.notes,
      bodyConditionScore: weight.bodyConditionScore,
      createdAt: weight.createdAt,
      updatedAt: weight.updatedAt,
      isDeleted: weight.isDeleted,
    );
  }

  factory WeightModel.fromJson(Map<String, dynamic> json) =>
      _$WeightModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeightModelToJson(this);

  Weight toEntity() {
    return Weight(
      id: id,
      animalId: animalId,
      weight: weight,
      date: date,
      notes: notes,
      bodyConditionScore: bodyConditionScore,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  WeightModel copyWith({
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
    return WeightModel(
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
}