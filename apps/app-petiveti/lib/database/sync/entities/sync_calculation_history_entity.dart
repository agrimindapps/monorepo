import 'package:core/core.dart';

/// Entity for syncing CalculationHistory with Firestore
class SyncCalculationHistoryEntity extends BaseSyncEntity {
  final String calculatorType;
  final String inputData;
  final String result;
  final DateTime date;
  final String? firebaseId;

  const SyncCalculationHistoryEntity({
    required super.id,
    this.firebaseId,
    required super.userId,
    required this.calculatorType,
    required this.inputData,
    required this.result,
    required this.date,
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
    calculatorType,
    inputData,
    result,
    date,
    firebaseId,
  ];

  @override
  Map<String, dynamic> toFirebaseMap() => toFirestore();

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
      id: data['localId'] as String? ?? snapshot.id,
      firebaseId: snapshot.id,
      userId: data['userId'] as String? ?? '',
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

  @override
  SyncCalculationHistoryEntity copyWith({
    String? id,
    String? firebaseId,
    String? userId,
    String? calculatorType,
    String? inputData,
    String? result,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? lastSyncAt,
    bool? isDirty,
    int? version,
    String? moduleName,
  }) {
    return SyncCalculationHistoryEntity(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      calculatorType: calculatorType ?? this.calculatorType,
      inputData: inputData ?? this.inputData,
      result: result ?? this.result,
      date: date ?? this.date,
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
  SyncCalculationHistoryEntity markAsDirty() => copyWith(isDirty: true);

  @override
  SyncCalculationHistoryEntity markAsSynced({DateTime? syncTime}) => copyWith(
    isDirty: false,
    lastSyncAt: syncTime ?? DateTime.now(),
  );

  @override
  SyncCalculationHistoryEntity markAsDeleted() => copyWith(isDeleted: true, isDirty: true);

  @override
  SyncCalculationHistoryEntity incrementVersion() => copyWith(version: version + 1);

  @override
  SyncCalculationHistoryEntity withUserId(String userId) => copyWith(userId: userId);

  @override
  SyncCalculationHistoryEntity withModule(String moduleName) => copyWith(moduleName: moduleName);
}
