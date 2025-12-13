import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:equatable/equatable.dart';

/// Entity para sincronização de Appointments com Firebase
class AppointmentEntity extends Equatable {
  final String? id; // Local ID
  final String? firebaseId;
  final String userId;
  final int animalId;
  final String title;
  final String? description;
  final DateTime appointmentDateTime;
  final String? veterinarian;
  final String? location;
  final String? notes;
  final String status; // scheduled, completed, cancelled

  // Metadata
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  // Sync fields
  final DateTime? lastSyncAt;
  final bool isDirty;
  final int version;

  const AppointmentEntity({
    this.id,
    this.firebaseId,
    required this.userId,
    required this.animalId,
    required this.title,
    this.description,
    required this.appointmentDateTime,
    this.veterinarian,
    this.location,
    this.notes,
    required this.status,
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
    title,
    description,
    appointmentDateTime,
    veterinarian,
    location,
    notes,
    status,
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
      'title': title,
      'description': description,
      'appointmentDateTime': fs.Timestamp.fromDate(appointmentDateTime),
      'veterinarian': veterinarian,
      'location': location,
      'notes': notes,
      'status': status,
      'createdAt': fs.Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? fs.Timestamp.fromDate(updatedAt!) : null,
      'isDeleted': isDeleted,
      'lastSyncAt': fs.Timestamp.now(),
      'version': version,
    };
  }

  factory AppointmentEntity.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return AppointmentEntity(
      id: null,
      firebaseId: documentId,
      userId: data['userId'] as String,
      animalId: data['animalId'] as int,
      title: data['title'] as String,
      description: data['description'] as String?,
      appointmentDateTime: (data['appointmentDateTime'] as fs.Timestamp)
          .toDate(),
      veterinarian: data['veterinarian'] as String?,
      location: data['location'] as String?,
      notes: data['notes'] as String?,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as fs.Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as fs.Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
