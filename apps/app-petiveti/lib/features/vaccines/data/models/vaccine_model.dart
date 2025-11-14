import 'package:core/core.dart' hide Column;

import '../../domain/entities/vaccine.dart';

part 'vaccine_model.g.dart';

@JsonSerializable()
class VaccineModel {
  final int? id;

  final int animalId;

  final String name;

  final String veterinarian;

  final int dateTimestamp;

  final int? nextDueDateTimestamp;

  final String? batch;

  final String? manufacturer;

  final String? dosage;

  final String? notes;

  final bool isRequired;

  final bool isCompleted;

  final int? reminderDateTimestamp;

  final int status;

  final int createdAtTimestamp;

  final int? updatedAtTimestamp;

  final bool isDeleted;

  VaccineModel({
    this.id,
    required this.animalId,
    required this.name,
    required this.veterinarian,
    required this.dateTimestamp,
    this.nextDueDateTimestamp,
    this.batch,
    this.manufacturer,
    this.dosage,
    this.notes,
    this.isRequired = true,
    this.isCompleted = false,
    this.reminderDateTimestamp,
    this.status = 0,
    required this.createdAtTimestamp,
    this.updatedAtTimestamp,
    this.isDeleted = false,
  });

  Vaccine toEntity() {
    return Vaccine(
      id: id?.toString() ?? '',
      animalId: animalId.toString(),
      name: name,
      veterinarian: veterinarian,
      date: DateTime.fromMillisecondsSinceEpoch(dateTimestamp),
      nextDueDate:
          nextDueDateTimestamp != null
              ? DateTime.fromMillisecondsSinceEpoch(nextDueDateTimestamp!)
              : null,
      batch: batch,
      manufacturer: manufacturer,
      dosage: dosage,
      notes: notes,
      isRequired: isRequired,
      isCompleted: isCompleted,
      reminderDate:
          reminderDateTimestamp != null
              ? DateTime.fromMillisecondsSinceEpoch(reminderDateTimestamp!)
              : null,
      status: VaccineStatus.values[status],
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtTimestamp),
      updatedAt: updatedAtTimestamp != null 
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtTimestamp!)
          : DateTime.fromMillisecondsSinceEpoch(createdAtTimestamp),
      isDeleted: isDeleted,
    );
  }

  factory VaccineModel.fromEntity(Vaccine vaccine) {
    return VaccineModel(
      id: vaccine.id.isNotEmpty ? int.tryParse(vaccine.id) : null,
      animalId: int.tryParse(vaccine.animalId) ?? 0,
      name: vaccine.name,
      veterinarian: vaccine.veterinarian,
      dateTimestamp: vaccine.date.millisecondsSinceEpoch,
      nextDueDateTimestamp: vaccine.nextDueDate?.millisecondsSinceEpoch,
      batch: vaccine.batch,
      manufacturer: vaccine.manufacturer,
      dosage: vaccine.dosage,
      notes: vaccine.notes,
      isRequired: vaccine.isRequired,
      isCompleted: vaccine.isCompleted,
      reminderDateTimestamp: vaccine.reminderDate?.millisecondsSinceEpoch,
      status: vaccine.status.index,
      createdAtTimestamp: vaccine.createdAt.millisecondsSinceEpoch,
      updatedAtTimestamp: vaccine.updatedAt.millisecondsSinceEpoch,
      isDeleted: vaccine.isDeleted,
    );
  }

  factory VaccineModel.fromJson(Map<String, dynamic> json) =>
      _$VaccineModelFromJson(json);

  Map<String, dynamic> toJson() => _$VaccineModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'nomeVacina': name,
      'veterinario': veterinarian,
      'dataAplicacao': dateTimestamp,
      'proximaDose': nextDueDateTimestamp ?? 0,
      'lote': batch,
      'fabricante': manufacturer,
      'dosagem': dosage,
      'observacoes': notes,
      'obrigatoria': isRequired,
      'concluida': isCompleted,
      'dataLembrete': reminderDateTimestamp ?? 0,
      'status': status,
      'createdAt': createdAtTimestamp,
      'updatedAt': updatedAtTimestamp,
      'isDeleted': isDeleted,
    };
  }

  factory VaccineModel.fromMap(Map<String, dynamic> map) {
    return VaccineModel(
      id: map['id'] as int?,
      animalId: (map['animalId'] as int?) ?? 0,
      name: (map['nomeVacina'] as String?) ?? (map['name'] as String?) ?? '',
      veterinarian:
          (map['veterinario'] as String?) ??
          (map['veterinarian'] as String?) ??
          '',
      dateTimestamp:
          (map['dataAplicacao'] as int?) ??
          (map['dateTimestamp'] as int?) ??
          DateTime.now().millisecondsSinceEpoch,
      nextDueDateTimestamp:
          map['proximaDose'] == 0
              ? null
              : ((map['proximaDose'] ?? map['nextDueDateTimestamp']) as int?),
      batch: (map['lote'] as String?) ?? (map['batch'] as String?),
      manufacturer:
          (map['fabricante'] as String?) ?? (map['manufacturer'] as String?),
      dosage: (map['dosagem'] as String?) ?? (map['dosage'] as String?),
      notes: (map['observacoes'] as String?) ?? (map['notes'] as String?),
      isRequired:
          (map['obrigatoria'] as bool?) ?? (map['isRequired'] as bool?) ?? true,
      isCompleted:
          (map['concluida'] as bool?) ?? (map['isCompleted'] as bool?) ?? false,
      reminderDateTimestamp:
          map['dataLembrete'] == 0
              ? null
              : ((map['dataLembrete'] ?? map['reminderDateTimestamp']) as int?),
      status: (map['status'] as int?) ?? 0,
      createdAtTimestamp:
          (map['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      updatedAtTimestamp:
          (map['updatedAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      isDeleted: (map['isDeleted'] as bool?) ?? false,
    );
  }
}
