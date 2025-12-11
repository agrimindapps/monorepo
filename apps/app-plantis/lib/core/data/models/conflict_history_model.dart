import 'base_sync_model.dart';

// ignore: must_be_immutable
class ConflictHistoryModel extends BaseSyncModel {
  @override
  final String id;

  final int? createdAtMs;

  final int? updatedAtMs;

  final String modelType;

  final String modelId;

  final String resolutionStrategy;

  final Map<String, dynamic> localData;

  final Map<String, dynamic> remoteData;

  final Map<String, dynamic> resolvedData;

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
         createdAt: createdAtMs != null
             ? DateTime.fromMillisecondsSinceEpoch(createdAtMs)
             : null,
         updatedAt: updatedAtMs != null
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

  @override
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
