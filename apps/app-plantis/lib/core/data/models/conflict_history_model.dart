// ignore_for_file: overridden_fields

import 'package:core/core.dart';
import 'base_sync_model.dart';

// Note: Hive adapter not generated yet - TypeId 10 reserved
@HiveType(typeId: 10)
// ignore: must_be_immutable
class ConflictHistoryModel extends BaseSyncModel {
  @override
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int? createdAtMs;

  @HiveField(2)
  final int? updatedAtMs;

  @HiveField(3)
  final String modelType;

  @HiveField(4)
  final String modelId;

  @HiveField(5)
  final String resolutionStrategy;

  @HiveField(6)
  final Map<String, dynamic> localData;

  @HiveField(7)
  final Map<String, dynamic> remoteData;

  @HiveField(8)
  final Map<String, dynamic> resolvedData;

  @HiveField(9)
  final bool autoResolved;

  ConflictHistoryModel({
    required this.id,
    this.createdAtMs,
    this.updatedAtMs,
    required this.modelType,
    required this.modelId,
    required this.resolutionStrategy,
    required this.localData,
    required this.remoteData,
    required this.resolvedData,
    this.autoResolved = false,
    int? version,
    super.userId,
    String? moduleName,
  }) : super(
         id: id,
         createdAt:
             createdAtMs != null
                 ? DateTime.fromMillisecondsSinceEpoch(createdAtMs)
                 : null,
         updatedAt:
             updatedAtMs != null
                 ? DateTime.fromMillisecondsSinceEpoch(updatedAtMs)
                 : null,
         version: version ?? 1,
         moduleName: moduleName ?? 'plantis',
       );

  factory ConflictHistoryModel.create({
    String? id,
    required String modelType,
    required String modelId,
    required String resolutionStrategy,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
    required Map<String, dynamic> resolvedData,
    bool autoResolved = false,
    String? userId,
  }) {
    final now = DateTime.now();
    return ConflictHistoryModel(
      id: id ?? now.millisecondsSinceEpoch.toString(),
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      modelType: modelType,
      modelId: modelId,
      resolutionStrategy: resolutionStrategy,
      localData: localData,
      remoteData: remoteData,
      resolvedData: resolvedData,
      autoResolved: autoResolved,
      userId: userId,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'modelType': modelType,
    'modelId': modelId,
    'resolutionStrategy': resolutionStrategy,
    'localData': localData,
    'remoteData': remoteData,
    'resolvedData': resolvedData,
    'autoResolved': autoResolved,
  };

  @override
  String get collectionName => 'conflict_history';

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...firebaseTimestampFields,
      'model_type': modelType,
      'model_id': modelId,
      'resolution_strategy': resolutionStrategy,
      'local_data': localData,
      'remote_data': remoteData,
      'resolved_data': resolvedData,
      'auto_resolved': autoResolved,
    };
  }

  @override
  ConflictHistoryModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? modelType,
    String? modelId,
    String? resolutionStrategy,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    Map<String, dynamic>? resolvedData,
    bool? autoResolved,
  }) {
    return ConflictHistoryModel(
      id: id ?? this.id,
      createdAtMs: (createdAt ?? this.createdAt)?.millisecondsSinceEpoch,
      updatedAtMs: (updatedAt ?? this.updatedAt)?.millisecondsSinceEpoch,
      modelType: modelType ?? this.modelType,
      modelId: modelId ?? this.modelId,
      resolutionStrategy: resolutionStrategy ?? this.resolutionStrategy,
      localData: localData ?? this.localData,
      remoteData: remoteData ?? this.remoteData,
      resolvedData: resolvedData ?? this.resolvedData,
      autoResolved: autoResolved ?? this.autoResolved,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
    );
  }
}
