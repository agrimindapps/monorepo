import 'package:core/core.dart' hide Column;

import '../../domain/entities/medication.dart';

part 'medication_model.g.dart';

@JsonSerializable()
class MedicationModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'animal_id')
  final int animalId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'dosage')
  final String dosage;

  @JsonKey(name: 'frequency')
  final String frequency;

  @JsonKey(name: 'duration')
  final String? duration;

  @JsonKey(name: 'start_date')
  final DateTime startDate;

  @JsonKey(name: 'end_date')
  final DateTime? endDate;

  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'prescribed_by')
  final String? veterinarian;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'is_deleted')
  final bool isDeleted;

  MedicationModel({
    this.id,
    required this.animalId,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.duration,
    required this.startDate,
    this.endDate,
    this.notes,
    this.veterinarian,
    required this.type,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  factory MedicationModel.fromEntity(Medication medication) {
    return MedicationModel(
      id: medication.id.isNotEmpty ? int.tryParse(medication.id) : null,
      animalId: int.tryParse(medication.animalId) ?? 0,
      name: medication.name,
      dosage: medication.dosage,
      frequency: medication.frequency,
      duration: medication.duration,
      startDate: medication.startDate,
      endDate: medication.endDate,
      notes: medication.notes,
      veterinarian: medication.prescribedBy,
      type: medication.type.name,
      userId: '', // Will be set by repository
      createdAt: medication.createdAt,
      updatedAt: medication.updatedAt,
      isDeleted: medication.isDeleted,
    );
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationModelToJson(this);

  static MedicationModel fromMap(Map<String, dynamic> map) {
    return MedicationModel.fromJson(map);
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  Medication toEntity() {
    return Medication(
      id: id?.toString() ?? '',
      animalId: animalId.toString(),
      name: name,
      dosage: dosage,
      frequency: frequency,
      duration: duration,
      startDate: startDate,
      endDate: endDate ?? DateTime.now(),
      notes: notes,
      prescribedBy: veterinarian,
      type: _stringToMedicationType(type),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isDeleted: isDeleted,
    );
  }

  MedicationModel copyWith({
    int? id,
    int? animalId,
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? veterinarian,
    String? type,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
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
      veterinarian: veterinarian ?? this.veterinarian,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
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
