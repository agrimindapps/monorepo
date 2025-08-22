import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/medication.dart';

part 'medication_model.g.dart';

@HiveType(typeId: 15)
@JsonSerializable()
class MedicationModel extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'animal_id')
  final String animalId;

  @HiveField(2)
  @JsonKey(name: 'name')
  final String name;

  @HiveField(3)
  @JsonKey(name: 'dosage')
  final String dosage;

  @HiveField(4)
  @JsonKey(name: 'frequency')
  final String frequency;

  @HiveField(5)
  @JsonKey(name: 'duration')
  final String? duration;

  @HiveField(6)
  @JsonKey(name: 'start_date')
  final DateTime startDate;

  @HiveField(7)
  @JsonKey(name: 'end_date')
  final DateTime endDate;

  @HiveField(8)
  @JsonKey(name: 'notes')
  final String? notes;

  @HiveField(9)
  @JsonKey(name: 'prescribed_by')
  final String? prescribedBy;

  @HiveField(10)
  @JsonKey(name: 'type')
  final String type; // Store as string to maintain compatibility

  @HiveField(11)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(12)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @HiveField(13)
  @JsonKey(name: 'is_deleted')
  final bool isDeleted;

  @HiveField(14)
  @JsonKey(name: 'discontinued_reason')
  final String? discontinuedReason;

  @HiveField(15)
  @JsonKey(name: 'discontinued_at')
  final DateTime? discontinuedAt;

  MedicationModel({
    required this.id,
    required this.animalId,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.duration,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.prescribedBy,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.discontinuedReason,
    this.discontinuedAt,
  });

  factory MedicationModel.fromEntity(Medication medication) {
    return MedicationModel(
      id: medication.id,
      animalId: medication.animalId,
      name: medication.name,
      dosage: medication.dosage,
      frequency: medication.frequency,
      duration: medication.duration,
      startDate: medication.startDate,
      endDate: medication.endDate,
      notes: medication.notes,
      prescribedBy: medication.prescribedBy,
      type: medication.type.name, // Convert enum to string
      createdAt: medication.createdAt,
      updatedAt: medication.updatedAt,
      isDeleted: medication.isDeleted,
    );
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationModelToJson(this);

  Medication toEntity() {
    return Medication(
      id: id,
      animalId: animalId,
      name: name,
      dosage: dosage,
      frequency: frequency,
      duration: duration,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
      prescribedBy: prescribedBy,
      type: _stringToMedicationType(type),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  MedicationModel copyWith({
    String? id,
    String? animalId,
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? prescribedBy,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    String? discontinuedReason,
    DateTime? discontinuedAt,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      discontinuedReason: discontinuedReason ?? this.discontinuedReason,
      discontinuedAt: discontinuedAt ?? this.discontinuedAt,
    );
  }

  /// Convert string to MedicationType enum
  MedicationType _stringToMedicationType(String typeString) {
    switch (typeString) {
      case 'antibiotic':
        return MedicationType.antibiotic;
      case 'antiInflammatory':
        return MedicationType.antiInflammatory;
      case 'painkiller':
        return MedicationType.painkiller;
      case 'vitamin':
        return MedicationType.vitamin;
      case 'supplement':
        return MedicationType.supplement;
      case 'antifungal':
        return MedicationType.antifungal;
      case 'antiparasitic':
        return MedicationType.antiparasitic;
      case 'vaccine':
        return MedicationType.vaccine;
      default:
        return MedicationType.other;
    }
  }
}