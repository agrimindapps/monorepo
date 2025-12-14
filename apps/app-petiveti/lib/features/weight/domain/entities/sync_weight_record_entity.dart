import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:core/core.dart';

/// Entity para sincronização de Weight Records com Firebase
class WeightRecordEntity extends BaseSyncEntity {
  final String? firebaseId;
  final int animalId;
  final double weight;
  final String unit;
  final DateTime date;
  final String? notes;

  const WeightRecordEntity({
    required super.id,
    this.firebaseId,
    required super.userId,
    required this.animalId,
    required this.weight,
    this.unit = 'kg',
    required this.date,
    this.notes,
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
    weight,
    unit,
    date,
    notes,
  ];

  @override
  WeightRecordEntity copyWith({
    String? id,
    String? firebaseId,
    String? userId,
    int? animalId,
    double? weight,
    String? unit,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? lastSyncAt,
    bool? isDirty,
    int? version,
    String? moduleName,
  }) {
    return WeightRecordEntity(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      animalId: animalId ?? this.animalId,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      notes: notes ?? this.notes,
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
  WeightRecordEntity markAsDirty() => copyWith(isDirty: true);

  @override
  WeightRecordEntity markAsSynced({DateTime? syncTime}) => copyWith(
    isDirty: false,
    lastSyncAt: syncTime ?? DateTime.now(),
  );

  @override
  WeightRecordEntity markAsDeleted() => copyWith(isDeleted: true, isDirty: true);

  @override
  WeightRecordEntity incrementVersion() => copyWith(version: version + 1);

  @override
  WeightRecordEntity withUserId(String userId) => copyWith(userId: userId);

  @override
  WeightRecordEntity withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  Map<String, dynamic> toFirebaseMap() => toFirestore();

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'animalId': animalId,
      'weight': weight,
      'unit': unit,
      'date': fs.Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': createdAt != null ? fs.Timestamp.fromDate(createdAt!) : fs.Timestamp.now(),
      'isDeleted': isDeleted,
      'lastSyncAt': fs.Timestamp.now(),
      'version': version,
    };
  }

  factory WeightRecordEntity.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return WeightRecordEntity(
      id: data['localId'] as String? ?? documentId,
      firebaseId: documentId,
      userId: data['userId'] as String? ?? '',
      animalId: data['animalId'] as int,
      weight: (data['weight'] as num).toDouble(),
      unit: data['unit'] as String? ?? 'kg',
      date: (data['date'] as fs.Timestamp).toDate(),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as fs.Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
