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
  final int applicationDateTimestamp;

  @HiveField(4)
  final int? nextDoseDateTimestamp;

  @HiveField(5)
  final String? veterinarianName;

  @HiveField(6)
  final String? batch;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final int status;

  @HiveField(9)
  final int createdAtTimestamp;

  @HiveField(10)
  final int updatedAtTimestamp;

  @HiveField(11)
  final bool isDeleted;

  VaccineModel({
    required this.id,
    required this.animalId,
    required this.name,
    required this.applicationDateTimestamp,
    this.nextDoseDateTimestamp,
    this.veterinarianName,
    this.batch,
    this.notes,
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
      applicationDate: DateTime.fromMillisecondsSinceEpoch(applicationDateTimestamp),
      nextDoseDate: nextDoseDateTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(nextDoseDateTimestamp!)
          : null,
      veterinarianName: veterinarianName,
      batch: batch,
      notes: notes,
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
      applicationDateTimestamp: vaccine.applicationDate.millisecondsSinceEpoch,
      nextDoseDateTimestamp: vaccine.nextDoseDate?.millisecondsSinceEpoch,
      veterinarianName: vaccine.veterinarianName,
      batch: vaccine.batch,
      notes: vaccine.notes,
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
      'dataAplicacao': applicationDateTimestamp,
      'proximaDose': nextDoseDateTimestamp ?? 0,
      'veterinario': veterinarianName,
      'lote': batch,
      'observacoes': notes,
      'status': status,
      'createdAt': createdAtTimestamp,
      'updatedAt': updatedAtTimestamp,
      'isDeleted': isDeleted,
    };
  }

  factory VaccineModel.fromMap(Map<String, dynamic> map) {
    return VaccineModel(
      id: map['id'] ?? '',
      animalId: map['animalId'] ?? '',
      name: map['nomeVacina'] ?? map['name'] ?? '',
      applicationDateTimestamp: map['dataAplicacao'] ?? map['applicationDateTimestamp'] ?? 0,
      nextDoseDateTimestamp: map['proximaDose'] == 0 ? null : (map['proximaDose'] ?? map['nextDoseDateTimestamp']),
      veterinarianName: map['veterinario'] ?? map['veterinarianName'],
      batch: map['lote'] ?? map['batch'],
      notes: map['observacoes'] ?? map['notes'],
      status: map['status'] ?? 0,
      createdAtTimestamp: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      updatedAtTimestamp: map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}