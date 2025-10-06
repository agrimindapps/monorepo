import 'package:core/core.dart'
    show HiveType, JsonSerializable, HiveObject, HiveField;

import '../../domain/entities/appointment.dart';

part 'appointment_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 12)
class AppointmentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String animalId;

  @HiveField(2)
  final String veterinarianName;

  @HiveField(3)
  final int dateTimestamp; // stored as milliseconds since epoch

  @HiveField(4)
  final String reason;

  @HiveField(5)
  final String? diagnosis;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final int status; // stored as enum index

  @HiveField(8)
  final double? cost;

  @HiveField(9)
  final int createdAtTimestamp;

  @HiveField(10)
  final int updatedAtTimestamp;

  @HiveField(11)
  final bool isDeleted;

  AppointmentModel({
    required this.id,
    required this.animalId,
    required this.veterinarianName,
    required this.dateTimestamp,
    required this.reason,
    this.diagnosis,
    this.notes,
    this.status = 0, // AppointmentStatus.scheduled
    this.cost,
    required this.createdAtTimestamp,
    required this.updatedAtTimestamp,
    this.isDeleted = false,
  });

  // Convert to domain entity
  Appointment toEntity() {
    return Appointment(
      id: id,
      animalId: animalId,
      veterinarianName: veterinarianName,
      date: DateTime.fromMillisecondsSinceEpoch(dateTimestamp),
      reason: reason,
      diagnosis: diagnosis,
      notes: notes,
      status: AppointmentStatus.values[status],
      cost: cost,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtTimestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtTimestamp),
      isDeleted: isDeleted,
    );
  }

  // Create from domain entity
  factory AppointmentModel.fromEntity(Appointment appointment) {
    return AppointmentModel(
      id: appointment.id,
      animalId: appointment.animalId,
      veterinarianName: appointment.veterinarianName,
      dateTimestamp: appointment.date.millisecondsSinceEpoch,
      reason: appointment.reason,
      diagnosis: appointment.diagnosis,
      notes: appointment.notes,
      status: appointment.status.index,
      cost: appointment.cost,
      createdAtTimestamp: appointment.createdAt.millisecondsSinceEpoch,
      updatedAtTimestamp: appointment.updatedAt.millisecondsSinceEpoch,
      isDeleted: appointment.isDeleted,
    );
  }

  // JSON serialization
  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  // Firebase/Map conversion (for compatibility with existing structure)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'veterinario': veterinarianName, // matches existing structure
      'dataConsulta': dateTimestamp,
      'motivo': reason,
      'diagnostico': diagnosis ?? '',
      'observacoes': notes,
      'valor': cost ?? 0.0,
      'status': status,
      'createdAt': createdAtTimestamp,
      'updatedAt': updatedAtTimestamp,
      'isDeleted': isDeleted,
      'needsSync': true,
      'lastSyncAt': null,
      'version': 1,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: (map['id'] as String?) ?? '',
      animalId: (map['animalId'] as String?) ?? '',
      veterinarianName:
          (map['veterinario'] as String?) ??
          (map['veterinarianName'] as String?) ??
          '',
      dateTimestamp:
          (map['dataConsulta'] as int?) ?? (map['dateTimestamp'] as int?) ?? 0,
      reason: (map['motivo'] as String?) ?? (map['reason'] as String?) ?? '',
      diagnosis:
          (map['diagnostico'] as String?) ?? (map['diagnosis'] as String?),
      notes: (map['observacoes'] as String?) ?? (map['notes'] as String?),
      status: (map['status'] as int?) ?? 0,
      cost: ((map['valor'] ?? map['cost']) as num?)?.toDouble(),
      createdAtTimestamp:
          (map['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      updatedAtTimestamp:
          (map['updatedAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      isDeleted: (map['isDeleted'] as bool?) ?? false,
    );
  }

  AppointmentModel copyWith({
    String? id,
    String? animalId,
    String? veterinarianName,
    int? dateTimestamp,
    String? reason,
    String? diagnosis,
    String? notes,
    int? status,
    double? cost,
    int? createdAtTimestamp,
    int? updatedAtTimestamp,
    bool? isDeleted,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      dateTimestamp: dateTimestamp ?? this.dateTimestamp,
      reason: reason ?? this.reason,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      cost: cost ?? this.cost,
      createdAtTimestamp: createdAtTimestamp ?? this.createdAtTimestamp,
      updatedAtTimestamp: updatedAtTimestamp ?? this.updatedAtTimestamp,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppointmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
