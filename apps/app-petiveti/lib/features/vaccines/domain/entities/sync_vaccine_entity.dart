import 'package:core/core.dart';

/// Entity para sincronização de Vaccines com Firebase
class VaccineEntity extends BaseSyncEntity {
  final String? firebaseId;
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
  final int? lastSyncAtTimestamp;

  const VaccineEntity({
    required super.id,
    this.firebaseId,
    required super.userId,
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
    super.isDeleted = false,
    this.lastSyncAtTimestamp,
    super.isDirty = false,
    super.version = 1,
    super.moduleName,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    firebaseId,
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
    lastSyncAtTimestamp,
  ];

  @override
  VaccineEntity copyWith({
    String? id,
    String? firebaseId,
    String? userId,
    int? animalId,
    String? name,
    String? veterinarian,
    int? dateTimestamp,
    int? nextDueDateTimestamp,
    String? batch,
    String? manufacturer,
    String? dosage,
    String? notes,
    bool? isRequired,
    bool? isCompleted,
    int? reminderDateTimestamp,
    int? status,
    int? createdAtTimestamp,
    int? updatedAtTimestamp,
    bool? isDeleted,
    int? lastSyncAtTimestamp,
    bool? isDirty,
    int? version,
    String? moduleName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
  }) {
    return VaccineEntity(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      animalId: animalId ?? this.animalId,
      name: name ?? this.name,
      veterinarian: veterinarian ?? this.veterinarian,
      dateTimestamp: dateTimestamp ?? this.dateTimestamp,
      nextDueDateTimestamp: nextDueDateTimestamp ?? this.nextDueDateTimestamp,
      batch: batch ?? this.batch,
      manufacturer: manufacturer ?? this.manufacturer,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderDateTimestamp:
          reminderDateTimestamp ?? this.reminderDateTimestamp,
      status: status ?? this.status,
      createdAtTimestamp: createdAtTimestamp ?? this.createdAtTimestamp,
      updatedAtTimestamp: updatedAtTimestamp ?? this.updatedAtTimestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncAtTimestamp: lastSyncAtTimestamp ?? this.lastSyncAtTimestamp,
      isDirty: isDirty ?? this.isDirty,
      version: version ?? this.version,
      moduleName: moduleName ?? this.moduleName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  VaccineEntity markAsDirty() => copyWith(isDirty: true);

  @override
  VaccineEntity markAsSynced({DateTime? syncTime}) => copyWith(
    isDirty: false,
    lastSyncAt: syncTime ?? DateTime.now(),
    lastSyncAtTimestamp: (syncTime ?? DateTime.now()).millisecondsSinceEpoch,
  );

  @override
  VaccineEntity markAsDeleted() => copyWith(isDeleted: true, isDirty: true);

  @override
  VaccineEntity incrementVersion() => copyWith(version: version + 1);

  @override
  VaccineEntity withUserId(String userId) => copyWith(userId: userId);

  @override
  VaccineEntity withModule(String moduleName) =>
      copyWith(moduleName: moduleName);

  @override
  Map<String, dynamic> toFirebaseMap() => toFirestore();

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
      id: data['localId'] as String? ?? documentId,
      firebaseId: documentId,
      userId: data['userId'] as String? ?? '',
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
