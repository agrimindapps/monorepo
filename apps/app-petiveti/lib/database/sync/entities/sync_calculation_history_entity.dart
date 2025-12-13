import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Entity for syncing CalculationHistory with Firestore
class SyncCalculationHistoryEntity extends Equatable {
  final int? id;
  final String? firebaseId;
  final String userId;
  final String calculatorType;
  final String inputData;
  final String result;
  final DateTime date;
  final bool isDeleted;
  final DateTime? lastSyncAt;
  final bool isDirty;
  final int version;

  const SyncCalculationHistoryEntity({
    this.id,
    this.firebaseId,
    required this.userId,
    required this.calculatorType,
    required this.inputData,
    required this.result,
    required this.date,
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
    calculatorType,
    inputData,
    result,
    date,
    isDeleted,
    lastSyncAt,
    isDirty,
    version,
  ];

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'calculatorType': calculatorType,
      'inputData': inputData,
      'result': result,
      'date': Timestamp.fromDate(date),
      'isDeleted': isDeleted,
      'lastSyncAt': lastSyncAt != null ? Timestamp.fromDate(lastSyncAt!) : null,
      'isDirty': isDirty,
      'version': version,
    };
  }

  /// Create from Firestore document
  factory SyncCalculationHistoryEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return SyncCalculationHistoryEntity(
      firebaseId: snapshot.id,
      userId: data['userId'] as String,
      calculatorType: data['calculatorType'] as String,
      inputData: data['inputData'] as String,
      result: data['result'] as String,
      date: (data['date'] as Timestamp).toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: data['lastSyncAt'] != null
          ? (data['lastSyncAt'] as Timestamp).toDate()
          : null,
      isDirty: data['isDirty'] as bool? ?? false,
      version: data['version'] as int? ?? 1,
    );
  }

  SyncCalculationHistoryEntity copyWith({
    int? id,
    String? firebaseId,
    String? userId,
    String? calculatorType,
    String? inputData,
    String? result,
    DateTime? date,
    bool? isDeleted,
    DateTime? lastSyncAt,
    bool? isDirty,
    int? version,
  }) {
    return SyncCalculationHistoryEntity(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      calculatorType: calculatorType ?? this.calculatorType,
      inputData: inputData ?? this.inputData,
      result: result ?? this.result,
      date: date ?? this.date,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      version: version ?? this.version,
    );
  }
}
