import 'package:core/core.dart' hide Column;

import '../../domain/entities/weight.dart';

part 'weight_model.g.dart';

@JsonSerializable()
class WeightModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'animal_id')
  final int animalId;

  @JsonKey(name: 'weight')
  final double weight;

  @JsonKey(name: 'date')
  final DateTime date;

  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'body_condition_score')
  final int? bodyConditionScore;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'is_deleted')
  final bool isDeleted;

  WeightModel({
    this.id,
    required this.animalId,
    required this.weight,
    required this.date,
    this.notes,
    this.bodyConditionScore,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  factory WeightModel.fromEntity(Weight weight) {
    return WeightModel(
      id: weight.id.isNotEmpty ? int.tryParse(weight.id) : null,
      animalId: int.tryParse(weight.animalId) ?? 0,
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
      id: id?.toString() ?? '',
      animalId: animalId.toString(),
      weight: weight,
      date: date,
      notes: notes,
      bodyConditionScore: bodyConditionScore,
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
      isDeleted: isDeleted,
    );
  }

  WeightModel copyWith({
    int? id,
    int? animalId,
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
