import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/vaccine.dart';

part 'vaccine_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 16)
class VaccineModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String animalId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String veterinarian;

  @HiveField(4)
  final int dateTimestamp;

  @HiveField(5)
  final int? nextDueDateTimestamp;

  @HiveField(6)
  final String? batch;

  @HiveField(7)
  final String? manufacturer;

  @HiveField(8)
  final String? dosage;

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final bool isRequired;

  @HiveField(11)
  final bool isCompleted;

  @HiveField(12)
  final int? reminderDateTimestamp;

  @HiveField(13)
  final int status;

  @HiveField(14)
  final int createdAtTimestamp;

  @HiveField(15)
  final int updatedAtTimestamp;

  @HiveField(16)
  final bool isDeleted;

  VaccineModel({
    required this.id,
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
    required this.updatedAtTimestamp,
    this.isDeleted = false,
  });

  Vaccine toEntity() {
    return Vaccine(
      id: id,
      animalId: animalId,
      name: name,
      veterinarian: veterinarian,
      date: DateTime.fromMillisecondsSinceEpoch(dateTimestamp),
      nextDueDate: nextDueDateTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(nextDueDateTimestamp!)
          : null,
      batch: batch,
      manufacturer: manufacturer,
      dosage: dosage,
      notes: notes,
      isRequired: isRequired,
      isCompleted: isCompleted,
      reminderDate: reminderDateTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(reminderDateTimestamp!)
          : null,
      status: VaccineStatus.values[status],
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtTimestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtTimestamp),
      isDeleted: isDeleted,
    );
  }

  factory VaccineModel.fromEntity(Vaccine vaccine) {
    return VaccineModel(
      id: vaccine.id,
      animalId: vaccine.animalId,
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
      id: (map['id'] as String?) ?? '',
      animalId: (map['animalId'] as String?) ?? '',
      name: (map['nomeVacina'] as String?) ?? (map['name'] as String?) ?? '',
      veterinarian: (map['veterinario'] as String?) ?? (map['veterinarian'] as String?) ?? '',
      dateTimestamp: (map['dataAplicacao'] as int?) ?? (map['dateTimestamp'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      nextDueDateTimestamp: map['proximaDose'] == 0 ? null : ((map['proximaDose'] ?? map['nextDueDateTimestamp']) as int?),
      batch: (map['lote'] as String?) ?? (map['batch'] as String?),
      manufacturer: (map['fabricante'] as String?) ?? (map['manufacturer'] as String?),
      dosage: (map['dosagem'] as String?) ?? (map['dosage'] as String?),
      notes: (map['observacoes'] as String?) ?? (map['notes'] as String?),
      isRequired: (map['obrigatoria'] as bool?) ?? (map['isRequired'] as bool?) ?? true,
      isCompleted: (map['concluida'] as bool?) ?? (map['isCompleted'] as bool?) ?? false,
      reminderDateTimestamp: map['dataLembrete'] == 0 ? null : ((map['dataLembrete'] ?? map['reminderDateTimestamp']) as int?),
      status: (map['status'] as int?) ?? 0,
      createdAtTimestamp: (map['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      updatedAtTimestamp: (map['updatedAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      isDeleted: (map['isDeleted'] as bool?) ?? false,
    );
  }
}