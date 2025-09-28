// ignore_for_file: overridden_fields

import 'package:core/core.dart';
import 'base_sync_model.dart';

part 'espaco_model.g.dart';

/// Espaco model with Firebase sync support
/// TypeId: 1 - Sequential numbering
@HiveType(typeId: 1)
// ignore: must_be_immutable
class EspacoModel extends BaseSyncModel {
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

  // Espaco specific fields
  @HiveField(10)
  final String nome;
  @HiveField(11)
  final String? descricao;
  @HiveField(12)
  final bool ativo;
  @HiveField(13)
  final DateTime? dataCriacao;

  EspacoModel({
    required this.id,
    this.createdAtMs,
    this.updatedAtMs,
    this.lastSyncAtMs,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
    this.userId,
    this.moduleName = 'plantis',
    required this.nome,
    this.descricao,
    this.ativo = true,
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
  String get collectionName => 'espacos';

  /// Factory constructor for creating new espaco
  factory EspacoModel.create({
    String? id,
    String? userId,
    required String nome,
    String? descricao,
    bool ativo = true,
    DateTime? dataCriacao,
  }) {
    final now = DateTime.now();
    final espacoId = id ?? now.millisecondsSinceEpoch.toString();

    return EspacoModel(
      id: espacoId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      nome: nome,
      descricao: descricao,
      ativo: ativo,
      dataCriacao: dataCriacao ?? now,
    );
  }

  /// Create from Hive map
  factory EspacoModel.fromHiveMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseHiveFields(map);

    return EspacoModel(
      id: baseFields['id'] as String,
      createdAtMs: map['createdAt'] as int?,
      updatedAtMs: map['updatedAt'] as int?,
      lastSyncAtMs: map['lastSyncAt'] as int?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      nome: map['nome']?.toString() ?? '',
      descricao: map['descricao']?.toString(),
      ativo: (map['ativo'] as bool?) ?? true,
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
      'nome': nome,
      'descricao': descricao,
      'ativo': ativo,
      'dataCriacao': dataCriacao?.toIso8601String(),
    });
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'nome': nome,
      'descricao': descricao,
      'ativo': ativo,
      'data_criacao': dataCriacao?.toIso8601String(),
    };
  }

  /// Create from Firebase map
  factory EspacoModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseFirebaseFields(map);
    final timestamps = BaseSyncModel.parseFirebaseTimestamps(map);

    return EspacoModel(
      id: baseFields['id'] as String,
      createdAtMs: timestamps['createdAt']?.millisecondsSinceEpoch,
      updatedAtMs: timestamps['updatedAt']?.millisecondsSinceEpoch,
      lastSyncAtMs: timestamps['lastSyncAt']?.millisecondsSinceEpoch,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      nome: map['nome']?.toString() ?? '',
      descricao: map['descricao']?.toString(),
      ativo: (map['ativo'] as bool?) ?? true,
      dataCriacao:
          map['data_criacao'] != null
              ? DateTime.parse(map['data_criacao'] as String)
              : null,
    );
  }

  /// copyWith method for immutability
  @override
  EspacoModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? nome,
    String? descricao,
    bool? ativo,
    DateTime? dataCriacao,
  }) {
    return EspacoModel(
      id: id ?? this.id,
      createdAtMs: createdAt?.millisecondsSinceEpoch ?? createdAtMs,
      updatedAtMs: updatedAt?.millisecondsSinceEpoch ?? updatedAtMs,
      lastSyncAtMs: lastSyncAt?.millisecondsSinceEpoch ?? lastSyncAtMs,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ativo: ativo ?? this.ativo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  // Legacy compatibility methods
  Map<String, dynamic> toMap() => toHiveMap();
  @override
  Map<String, dynamic> toJson() => toHiveMap();
  factory EspacoModel.fromMap(Map<String, dynamic> map) =>
      EspacoModel.fromHiveMap(map);
  factory EspacoModel.fromJson(Map<String, dynamic> json) =>
      EspacoModel.fromHiveMap(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EspacoModel &&
        other.id == id &&
        other.nome == nome &&
        other.descricao == descricao &&
        other.ativo == ativo &&
        other.dataCriacao == dataCriacao;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nome.hashCode ^
        descricao.hashCode ^
        ativo.hashCode ^
        dataCriacao.hashCode;
  }

  @override
  String toString() {
    return 'EspacoModel(id: $id, nome: $nome, descricao: $descricao, ativo: $ativo, dataCriacao: $dataCriacao)';
  }
}
