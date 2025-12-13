import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:equatable/equatable.dart';

/// Entity para sincronização de Weight Records com Firebase
class WeightRecordEntity extends Equatable {
  final String? id; // Local ID
  final String? firebaseId;
  final String userId;
  final int animalId;
  final double weight;
  final String unit;
  final DateTime date;
  final String? notes;

  // Metadata
  final DateTime createdAt;
  final bool isDeleted;

  // Sync fields
  final DateTime? lastSyncAt;
  final bool isDirty;
  final int version;

  const WeightRecordEntity({
    this.id,
    this.firebaseId,
    required this.userId,
    required this.animalId,
    required this.weight,
    this.unit = 'kg',
    required this.date,
    this.notes,
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
    weight,
    unit,
    date,
    notes,
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
      'weight': weight,
      'unit': unit,
      'date': fs.Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': fs.Timestamp.fromDate(createdAt),
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
      id: null,
      firebaseId: documentId,
      userId: data['userId'] as String,
      animalId: data['animalId'] as int,
      weight: (data['weight'] as num).toDouble(),
      unit: data['unit'] as String? ?? 'kg',
      date: (data['date'] as fs.Timestamp).toDate(),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as fs.Timestamp).toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
