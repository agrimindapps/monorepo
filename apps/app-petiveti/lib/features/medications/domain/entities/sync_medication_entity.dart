import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:core/core.dart';

/// Entity para sincronização de Medications com Firebase
class MedicationEntity extends BaseSyncEntity {
  final String? firebaseId;
  final int animalId;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final String? veterinarian;

  const MedicationEntity({
    required super.id,
    this.firebaseId,
    required super.userId,
    required this.animalId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
    this.veterinarian,
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
    name,
    dosage,
    frequency,
    startDate,
    endDate,
    notes,
    veterinarian,
  ];

  @override
  MedicationEntity copyWith({
    String? id,
    String? firebaseId,
    String? userId,
    int? animalId,
    String? name,
    String? dosage,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? veterinarian,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? lastSyncAt,
    bool? isDirty,
    int? version,
    String? moduleName,
  }) {
    return MedicationEntity(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      animalId: animalId ?? this.animalId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      veterinarian: veterinarian ?? this.veterinarian,
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
  MedicationEntity markAsDirty() => copyWith(isDirty: true);

  @override
  MedicationEntity markAsSynced({DateTime? syncTime}) => copyWith(
    isDirty: false,
    lastSyncAt: syncTime ?? DateTime.now(),
  );

  @override
  MedicationEntity markAsDeleted() => copyWith(isDeleted: true, isDirty: true);

  @override
  MedicationEntity incrementVersion() => copyWith(version: version + 1);

  @override
  MedicationEntity withUserId(String userId) => copyWith(userId: userId);

  @override
  MedicationEntity withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  Map<String, dynamic> toFirebaseMap() => toFirestore();

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
      'createdAt': createdAt != null ? fs.Timestamp.fromDate(createdAt!) : fs.Timestamp.now(),
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
      id: data['localId'] as String? ?? documentId,
      firebaseId: documentId,
      userId: data['userId'] as String? ?? '',
      animalId: data['animalId'] as int,
      name: data['name'] as String,
      dosage: data['dosage'] as String,
      frequency: data['frequency'] as String,
      startDate: (data['startDate'] as fs.Timestamp).toDate(),
      endDate: (data['endDate'] as fs.Timestamp?)?.toDate(),
      notes: data['notes'] as String?,
      veterinarian: data['veterinarian'] as String?,
      createdAt: (data['createdAt'] as fs.Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as fs.Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
