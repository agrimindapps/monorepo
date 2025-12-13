import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:equatable/equatable.dart';

/// Entity para sincronização de Vaccines com Firebase
class VaccineEntity extends Equatable {
  final String? id; // Local ID
  final String? firebaseId;
  final String userId;
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

  // Metadata
  final int createdAtTimestamp;
  final int? updatedAtTimestamp;
  final bool isDeleted;

  // Sync fields
  final int? lastSyncAtTimestamp;
  final bool isDirty;
  final int version;

  const VaccineEntity({
    this.id,
    this.firebaseId,
    required this.userId,
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
    this.lastSyncAtTimestamp,
    this.isDirty = false,
    this.version = 1,
  });

  @override
  List<Object?> get props => [
    id,
    firebaseId,
    userId,
    animalId,
    name,
    veterinarian,
    dateTimestamp,
    nextDueDateTimestamp,
    batch,
    manufacturer,
    dosage,
    notes,
    isRequired,
    isCompleted,
    reminderDateTimestamp,
    status,
    createdAtTimestamp,
    updatedAtTimestamp,
    isDeleted,
    lastSyncAtTimestamp,
    isDirty,
    version,
  ];

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'animalId': animalId,
      'name': name,
      'veterinarian': veterinarian,
      'dateTimestamp': dateTimestamp,
      'nextDueDateTimestamp': nextDueDateTimestamp,
      'batch': batch,
      'manufacturer': manufacturer,
      'dosage': dosage,
      'notes': notes,
      'isRequired': isRequired,
      'isCompleted': isCompleted,
      'reminderDateTimestamp': reminderDateTimestamp,
      'status': status,
      'createdAtTimestamp': createdAtTimestamp,
      'updatedAtTimestamp': updatedAtTimestamp,
      'isDeleted': isDeleted,
      'lastSyncAtTimestamp': DateTime.now().millisecondsSinceEpoch,
      'version': version,
    };
  }

  factory VaccineEntity.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return VaccineEntity(
      id: null,
      firebaseId: documentId,
      userId: data['userId'] as String,
      animalId: data['animalId'] as int,
      name: data['name'] as String,
      veterinarian: data['veterinarian'] as String,
      dateTimestamp: data['dateTimestamp'] as int,
      nextDueDateTimestamp: data['nextDueDateTimestamp'] as int?,
      batch: data['batch'] as String?,
      manufacturer: data['manufacturer'] as String?,
      dosage: data['dosage'] as String?,
      notes: data['notes'] as String?,
      isRequired: data['isRequired'] as bool? ?? true,
      isCompleted: data['isCompleted'] as bool? ?? false,
      reminderDateTimestamp: data['reminderDateTimestamp'] as int?,
      status: data['status'] as int? ?? 0,
      createdAtTimestamp: data['createdAtTimestamp'] as int,
      updatedAtTimestamp: data['updatedAtTimestamp'] as int?,
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAtTimestamp: data['lastSyncAtTimestamp'] as int?,
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
