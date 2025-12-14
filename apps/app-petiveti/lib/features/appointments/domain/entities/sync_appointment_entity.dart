import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:core/core.dart';

/// Entity para sincronização de Appointments com Firebase
class AppointmentEntity extends BaseSyncEntity {
  final int animalId;
  final String title;
  final String? description;
  final DateTime appointmentDateTime;
  final String? veterinarian;
  final String? location;
  final String? notes;
  final String status; // scheduled, completed, cancelled

  // Firebase ID (diferente do ID local Drift)
  final String? firebaseId;

  const AppointmentEntity({
    required super.id,
    this.firebaseId,
    required super.userId,
    required this.animalId,
    required this.title,
    this.description,
    required this.appointmentDateTime,
    this.veterinarian,
    this.location,
    this.notes,
    required this.status,
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
    animalId,
    title,
    description,
    appointmentDateTime,
    veterinarian,
    location,
    notes,
    status,
    firebaseId,
  ];

  @override
  AppointmentEntity copyWith({
    String? id,
    String? firebaseId,
    String? userId,
    int? animalId,
    String? title,
    String? description,
    DateTime? appointmentDateTime,
    String? veterinarian,
    String? location,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? lastSyncAt,
    bool? isDirty,
    int? version,
    String? moduleName,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      animalId: animalId ?? this.animalId,
      title: title ?? this.title,
      description: description ?? this.description,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      veterinarian: veterinarian ?? this.veterinarian,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      status: status ?? this.status,
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
  AppointmentEntity markAsDirty() => copyWith(isDirty: true);

  @override
  AppointmentEntity markAsSynced({DateTime? syncTime}) => copyWith(
    isDirty: false,
    lastSyncAt: syncTime ?? DateTime.now(),
  );

  @override
  AppointmentEntity markAsDeleted() => copyWith(isDeleted: true, isDirty: true);

  @override
  AppointmentEntity incrementVersion() => copyWith(version: version + 1);

  @override
  AppointmentEntity withUserId(String userId) => copyWith(userId: userId);

  @override
  AppointmentEntity withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  Map<String, dynamic> toFirebaseMap() => toFirestore();

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
      'createdAt': createdAt != null ? fs.Timestamp.fromDate(createdAt!) : fs.Timestamp.now(),
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
      id: data['localId'] as String? ?? documentId,
      firebaseId: documentId,
      userId: data['userId'] as String? ?? '',
      animalId: data['animalId'] as int,
      title: data['title'] as String,
      description: data['description'] as String?,
      appointmentDateTime: (data['appointmentDateTime'] as fs.Timestamp).toDate(),
      veterinarian: data['veterinarian'] as String?,
      location: data['location'] as String?,
      notes: data['notes'] as String?,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as fs.Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as fs.Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
