import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:equatable/equatable.dart';

/// Entity para sincronização de Reminders com Firebase
class ReminderEntity extends Equatable {
  final String? id; // Local ID
  final String? firebaseId;
  final String userId;
  final int? animalId;
  final String title;
  final String? description;
  final DateTime reminderDateTime;
  final String? frequency;
  final bool isCompleted;
  final bool notificationEnabled;

  // Metadata
  final DateTime createdAt;
  final bool isDeleted;

  // Sync fields
  final DateTime? lastSyncAt;
  final bool isDirty;
  final int version;

  const ReminderEntity({
    this.id,
    this.firebaseId,
    required this.userId,
    this.animalId,
    required this.title,
    this.description,
    required this.reminderDateTime,
    this.frequency,
    this.isCompleted = false,
    this.notificationEnabled = true,
    required this.createdAt,
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
    reminderDateTime,
    frequency,
    isCompleted,
    notificationEnabled,
    createdAt,
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
      'reminderDateTime': fs.Timestamp.fromDate(reminderDateTime),
      'frequency': frequency,
      'isCompleted': isCompleted,
      'notificationEnabled': notificationEnabled,
      'createdAt': fs.Timestamp.fromDate(createdAt),
      'isDeleted': isDeleted,
      'lastSyncAt': fs.Timestamp.now(),
      'version': version,
    };
  }

  factory ReminderEntity.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ReminderEntity(
      id: null,
      firebaseId: documentId,
      userId: data['userId'] as String,
      animalId: data['animalId'] as int?,
      title: data['title'] as String,
      description: data['description'] as String?,
      reminderDateTime: (data['reminderDateTime'] as fs.Timestamp).toDate(),
      frequency: data['frequency'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      notificationEnabled: data['notificationEnabled'] as bool? ?? true,
      createdAt: (data['createdAt'] as fs.Timestamp).toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
