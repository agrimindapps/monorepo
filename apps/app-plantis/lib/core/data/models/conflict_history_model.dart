import 'base_sync_model.dart';

// ignore: must_be_immutable
class ConflictHistoryModel extends BaseSyncModel {
  @override
  final String id;

  final int? createdAtMs;

  final int? updatedAtMs;

  final String modelType;

  final String modelId;

  /// Versão local do registro no momento do conflito
  final int localVersion;

  /// Versão remota do registro no momento do conflito
  final int remoteVersion;

  /// Timestamp quando o conflito ocorreu (milliseconds)
  final int occurredAt;

  /// Timestamp quando o conflito foi resolvido (milliseconds), null se não resolvido
  final int? resolvedAt;

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
    required this.localVersion,
    required this.remoteVersion,
    required this.occurredAt,
    this.resolvedAt,
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
    required int localVersion,
    required int remoteVersion,
    required String resolutionStrategy,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
    required Map<String, dynamic> resolvedData,
    bool autoResolved = false,
    String? userId,
  }) {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;

    return ConflictHistoryModel(
      id: id ?? nowMs.toString(),
      createdAtMs: nowMs,
      updatedAtMs: nowMs,
      modelType: modelType,
      modelId: modelId,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
      occurredAt: nowMs,
      resolvedAt: null, // Null até ser resolvido
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
    'localVersion': localVersion,
    'remoteVersion': remoteVersion,
    'occurredAt': occurredAt,
    'resolvedAt': resolvedAt,
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
      'local_version': localVersion,
      'remote_version': remoteVersion,
      'occurred_at': occurredAt,
      'resolved_at': resolvedAt,
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
    int? localVersion,
    int? remoteVersion,
    int? occurredAt,
    int? resolvedAt,
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
      localVersion: localVersion ?? this.localVersion,
      remoteVersion: remoteVersion ?? this.remoteVersion,
      occurredAt: occurredAt ?? this.occurredAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
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
