import 'package:core/core.dart';

part 'comentario_model.g.dart';

/// Comentario model with Firebase sync support
/// TypeId: 0 - Sequential numbering
@HiveType(typeId: 0)
class ComentarioModel extends BaseSyncEntity {
  @HiveField(0)
  @override
  final String id;
  @HiveField(1)
  final int? createdAtMs;
  @HiveField(2)
  final int? updatedAtMs;
  @HiveField(3)
  final int? lastSyncAtMs;
  @HiveField(4)
  @override
  final bool isDirty;
  @HiveField(5)
  @override
  final bool isDeleted;
  @HiveField(6)
  @override
  final int version;
  @HiveField(7)
  @override
  final String? userId;
  @HiveField(8)
  @override
  final String? moduleName;
  @HiveField(10)
  final String conteudo;
  @HiveField(11)
  final DateTime? dataAtualizacao;
  @HiveField(12)
  final DateTime? dataCriacao;
  @HiveField(13)
  final String? plantId;
  @override
  DateTime? get createdAt =>
      createdAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(createdAtMs!)
          : null;

  @override
  DateTime? get updatedAt =>
      updatedAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtMs!)
          : null;

  @override
  DateTime? get lastSyncAt =>
      lastSyncAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncAtMs!)
          : null;

  ComentarioModel({
    required this.id,
    this.createdAtMs,
    this.updatedAtMs,
    this.lastSyncAtMs,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
    this.userId,
    this.moduleName = 'plantis',
    required this.conteudo,
    this.dataAtualizacao,
    this.dataCriacao,
    this.plantId,
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
         lastSyncAt:
             lastSyncAtMs != null
                 ? DateTime.fromMillisecondsSinceEpoch(lastSyncAtMs)
                 : null,
         isDirty: isDirty,
         isDeleted: isDeleted,
         version: version,
         userId: userId,
         moduleName: moduleName,
       );

  /// Factory constructor for creating new comentario
  factory ComentarioModel.create({
    String? id,
    String? userId,
    required String conteudo,
    DateTime? dataAtualizacao,
    DateTime? dataCriacao,
    String? plantId,
  }) {
    final now = DateTime.now();
    final comentarioId = id ?? now.millisecondsSinceEpoch.toString();

    return ComentarioModel(
      id: comentarioId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      conteudo: conteudo,
      dataAtualizacao: dataAtualizacao ?? now,
      dataCriacao: dataCriacao ?? now,
      plantId: plantId,
    );
  }

  /// Create from Hive map
  factory ComentarioModel.fromHiveMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

    return ComentarioModel(
      id: baseFields['id'] as String,
      createdAtMs:
          (baseFields['createdAt'] as DateTime?)?.millisecondsSinceEpoch,
      updatedAtMs:
          (baseFields['updatedAt'] as DateTime?)?.millisecondsSinceEpoch,
      lastSyncAtMs:
          (baseFields['lastSyncAt'] as DateTime?)?.millisecondsSinceEpoch,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      conteudo: map['conteudo']?.toString() ?? '',
      dataAtualizacao:
          map['dataAtualizacao'] != null
              ? DateTime.parse(map['dataAtualizacao'] as String)
              : null,
      dataCriacao:
          map['dataCriacao'] != null
              ? DateTime.parse(map['dataCriacao'] as String)
              : null,
      plantId: map['plantId'] as String?,
    );
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'conteudo': conteudo,
      'data_atualizacao': dataAtualizacao?.toIso8601String(),
      'data_criacao': dataCriacao?.toIso8601String(),
      'plant_id': plantId,
    };
  }

  /// Create from Firebase map
  factory ComentarioModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

    return ComentarioModel(
      id: baseFields['id'] as String,
      createdAtMs:
          (baseFields['createdAt'] as DateTime?)?.millisecondsSinceEpoch,
      updatedAtMs:
          (baseFields['updatedAt'] as DateTime?)?.millisecondsSinceEpoch,
      lastSyncAtMs:
          (baseFields['lastSyncAt'] as DateTime?)?.millisecondsSinceEpoch,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      conteudo: map['conteudo']?.toString() ?? '',
      dataAtualizacao:
          map['data_atualizacao'] != null
              ? DateTime.parse(map['data_atualizacao'] as String)
              : null,
      dataCriacao:
          map['data_criacao'] != null
              ? DateTime.parse(map['data_criacao'] as String)
              : null,
      plantId: map['plant_id'] as String?,
    );
  }

  /// copyWith method for immutability
  @override
  ComentarioModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? conteudo,
    DateTime? dataAtualizacao,
    DateTime? dataCriacao,
    String? plantId,
  }) {
    return ComentarioModel(
      id: id ?? this.id,
      createdAtMs: createdAt?.millisecondsSinceEpoch ?? createdAtMs,
      updatedAtMs: updatedAt?.millisecondsSinceEpoch ?? updatedAtMs,
      lastSyncAtMs: lastSyncAt?.millisecondsSinceEpoch ?? lastSyncAtMs,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      conteudo: conteudo ?? this.conteudo,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      plantId: plantId ?? this.plantId,
    );
  }

  @override
  ComentarioModel markAsDirty() {
    return copyWith(isDirty: true, updatedAt: DateTime.now());
  }

  @override
  ComentarioModel markAsSynced({DateTime? syncTime}) {
    return copyWith(isDirty: false, lastSyncAt: syncTime ?? DateTime.now());
  }

  @override
  ComentarioModel markAsDeleted() {
    return copyWith(isDeleted: true, isDirty: true, updatedAt: DateTime.now());
  }

  @override
  ComentarioModel incrementVersion() {
    return copyWith(
      version: version + 1,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  ComentarioModel withUserId(String userId) {
    return copyWith(userId: userId, isDirty: true, updatedAt: DateTime.now());
  }

  @override
  ComentarioModel withModule(String moduleName) {
    return copyWith(
      moduleName: moduleName,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => toFirebaseMap();
  factory ComentarioModel.fromJson(Map<String, dynamic> json) =>
      ComentarioModel.fromFirebaseMap(json);

  @override
  String toString() {
    return 'ComentarioModel(id: $id, conteudo: $conteudo, dataCriacao: $dataCriacao)';
  }
}
