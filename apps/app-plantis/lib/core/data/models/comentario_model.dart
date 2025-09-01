import 'package:hive/hive.dart';
import 'base_sync_model.dart';

part 'comentario_model.g.dart';

/// Comentario model with Firebase sync support
/// TypeId: 0 - Sequential numbering
@HiveType(typeId: 0)
// ignore: must_be_immutable
// ignore_for_file: overridden_fields
class ComentarioModel extends BaseSyncModel {
  // Sync fields from BaseSyncModel (stored as milliseconds for Hive)
  @override
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int? createdAtMs;
  @HiveField(2)
  final int? updatedAtMs;
  @HiveField(3)
  final int? lastSyncAtMs;
  @override
  @HiveField(4)
  final bool isDirty;
  @override
  @HiveField(5)
  final bool isDeleted;
  @override
  @HiveField(6)
  final int version;
  @override
  @HiveField(7)
  final String? userId;
  @override
  @HiveField(8)
  final String? moduleName;

  // Comentario specific fields
  @HiveField(10)
  final String conteudo;
  @HiveField(11)
  final DateTime? dataAtualizacao;
  @HiveField(12)
  final DateTime? dataCriacao;

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

  @override
  String get collectionName => 'comentarios';

  /// Factory constructor for creating new comentario
  factory ComentarioModel.create({
    String? id,
    String? userId,
    required String conteudo,
    DateTime? dataAtualizacao,
    DateTime? dataCriacao,
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
    );
  }

  /// Create from Hive map
  factory ComentarioModel.fromHiveMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseHiveFields(map);

    return ComentarioModel(
      id: baseFields['id'] as String,
      createdAtMs: map['createdAt'] as int?,
      updatedAtMs: map['updatedAt'] as int?,
      lastSyncAtMs: map['lastSyncAt'] as int?,
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
    );
  }

  /// Convert to Hive map
  @override
  Map<String, dynamic> toHiveMap() {
    return super.toHiveMap()..addAll({
      'conteudo': conteudo,
      'dataAtualizacao': dataAtualizacao?.toIso8601String(),
      'dataCriacao': dataCriacao?.toIso8601String(),
    });
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'conteudo': conteudo,
      'data_atualizacao': dataAtualizacao?.toIso8601String(),
      'data_criacao': dataCriacao?.toIso8601String(),
    };
  }

  /// Create from Firebase map
  factory ComentarioModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseFirebaseFields(map);
    final timestamps = BaseSyncModel.parseFirebaseTimestamps(map);

    return ComentarioModel(
      id: baseFields['id'] as String,
      createdAtMs: timestamps['createdAt']?.millisecondsSinceEpoch,
      updatedAtMs: timestamps['updatedAt']?.millisecondsSinceEpoch,
      lastSyncAtMs: timestamps['lastSyncAt']?.millisecondsSinceEpoch,
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
    );
  }

  // Legacy compatibility methods
  Map<String, dynamic> toMap() => toHiveMap();
  @override
  Map<String, dynamic> toJson() => toHiveMap();
  factory ComentarioModel.fromMap(Map<String, dynamic> map) =>
      ComentarioModel.fromHiveMap(map);
  factory ComentarioModel.fromJson(Map<String, dynamic> json) =>
      ComentarioModel.fromHiveMap(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComentarioModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ComentarioModel(id: $id, conteudo: $conteudo, dataCriacao: $dataCriacao)';
  }
}
