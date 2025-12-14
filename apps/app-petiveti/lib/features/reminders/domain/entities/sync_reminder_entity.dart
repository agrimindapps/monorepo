import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:core/core.dart';

/// Entity para sincronização de Reminders com Firebase
class ReminderEntity extends BaseSyncEntity {
  final String? firebaseId;
  final int? animalId;
  final String title;
  final String? description;
  final DateTime reminderDateTime;
  final String? frequency;
  final bool isCompleted;
  final bool notificationEnabled;

  const ReminderEntity({
    required super.id,
    this.firebaseId,
    required super.userId,
    this.animalId,
    required this.title,
    this.description,
    required this.reminderDateTime,
    this.frequency,
    this.isCompleted = false,
    this.notificationEnabled = true,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.lastSyncAt,
    super.isDirty = false,
    super.version = 1,
    super.moduleName,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    firebaseId,
    animalId,
    title,
    description,
    reminderDateTime,
    frequency,
    isCompleted,
    notificationEnabled,
  ];

  @override
  ReminderEntity copyWith({
    String? id,
    String? firebaseId,
    String? userId,
    int? animalId,
    String? title,
    String? description,
    DateTime? reminderDateTime,
    String? frequency,
    bool? isCompleted,
    bool? notificationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? lastSyncAt,
    bool? isDirty,
    int? version,
    String? moduleName,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      animalId: animalId ?? this.animalId,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      frequency: frequency ?? this.frequency,
      isCompleted: isCompleted ?? this.isCompleted,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      version: version ?? this.version,
      moduleName: moduleName ?? this.moduleName,
    );
  }

  @override
  ReminderEntity markAsDirty() => copyWith(isDirty: true);

  @override
  ReminderEntity markAsSynced({DateTime? syncTime}) => copyWith(
    isDirty: false,
    lastSyncAt: syncTime ?? DateTime.now(),
  );

  @override
  ReminderEntity markAsDeleted() => copyWith(isDeleted: true, isDirty: true);

  @override
  ReminderEntity incrementVersion() => copyWith(version: version + 1);

  @override
  ReminderEntity withUserId(String userId) => copyWith(userId: userId);

  @override
  ReminderEntity withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  Map<String, dynamic> toFirebaseMap() => toFirestore();

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
      'createdAt': createdAt != null ? fs.Timestamp.fromDate(createdAt!) : fs.Timestamp.now(),
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
      id: data['localId'] as String? ?? documentId,
      firebaseId: documentId,
      userId: data['userId'] as String? ?? '',
      animalId: data['animalId'] as int?,
      title: data['title'] as String,
      description: data['description'] as String?,
      reminderDateTime: (data['reminderDateTime'] as fs.Timestamp).toDate(),
      frequency: data['frequency'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      notificationEnabled: data['notificationEnabled'] as bool? ?? true,
      createdAt: (data['createdAt'] as fs.Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
