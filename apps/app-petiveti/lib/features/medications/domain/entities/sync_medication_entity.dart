import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:equatable/equatable.dart';

/// Entity para sincronização de Medications com Firebase
class MedicationEntity extends Equatable {
  final String? id; // Local ID
  final String? firebaseId;
  final String userId;
  final int animalId;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final String? veterinarian;

  // Metadata
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  // Sync fields
  final DateTime? lastSyncAt;
  final bool isDirty;
  final int version;

  const MedicationEntity({
    this.id,
    this.firebaseId,
    required this.userId,
    required this.animalId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
    this.veterinarian,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.lastSyncAt,
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
    dosage,
    frequency,
    startDate,
    endDate,
    notes,
    veterinarian,
    createdAt,
    updatedAt,
    isDeleted,
    lastSyncAt,
    isDirty,
    version,
  ];

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'animalId': animalId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': fs.Timestamp.fromDate(startDate),
      'endDate': endDate != null ? fs.Timestamp.fromDate(endDate!) : null,
      'notes': notes,
      'veterinarian': veterinarian,
      'createdAt': fs.Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? fs.Timestamp.fromDate(updatedAt!) : null,
      'isDeleted': isDeleted,
      'lastSyncAt': fs.Timestamp.now(),
      'version': version,
    };
  }

  factory MedicationEntity.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return MedicationEntity(
      id: null,
      firebaseId: documentId,
      userId: data['userId'] as String,
      animalId: data['animalId'] as int,
      name: data['name'] as String,
      dosage: data['dosage'] as String,
      frequency: data['frequency'] as String,
      startDate: (data['startDate'] as fs.Timestamp).toDate(),
      endDate: (data['endDate'] as fs.Timestamp?)?.toDate(),
      notes: data['notes'] as String?,
      veterinarian: data['veterinarian'] as String?,
      createdAt: (data['createdAt'] as fs.Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as fs.Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
