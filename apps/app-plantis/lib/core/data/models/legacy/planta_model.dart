// ignore_for_file: overridden_fields

import 'package:hive/hive.dart';
import '../base_sync_model.dart';
import '../comentario_model.dart';

part 'planta_model.g.dart';

/// Planta model with Firebase sync support
/// TypeId: 2 - Sequential numbering
@HiveType(typeId: 2)
// ignore: must_be_immutable
class PlantaModel extends BaseSyncModel {
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

  // Planta specific fields
  @HiveField(10)
  final String? nome;
  @HiveField(11)
  final String? especie;
  @HiveField(12)
  final String? espacoId;
  @HiveField(13)
  final List<String>? imagePaths;
  @HiveField(14)
  final String? observacoes;
  @HiveField(15)
  final List<ComentarioModel>? comentarios;
  @HiveField(16)
  final DateTime? dataCadastro;
  @HiveField(17)
  final String? fotoBase64;

  PlantaModel({
    required this.id,
    this.createdAtMs,
    this.updatedAtMs,
    this.lastSyncAtMs,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
    this.userId,
    this.moduleName = 'plantis',
    this.nome,
    this.especie,
    this.espacoId,
    this.imagePaths,
    this.observacoes,
    this.comentarios,
    this.dataCadastro,
    this.fotoBase64,
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
       ) {
    // Assertions para validar invariants críticos
    assert(id.isNotEmpty, 'PlantaModel ID não pode ser vazio');
    assert(
      createdAtMs == null || createdAtMs! > 0,
      'createdAtMs deve ser um timestamp válido ou nulo',
    );
    assert(
      updatedAtMs == null || updatedAtMs! > 0,
      'updatedAtMs deve ser um timestamp válido ou nulo',
    );
  }

  @override
  String get collectionName => 'plantas';

  /// Factory constructor for creating new planta
  factory PlantaModel.create({
    String? id,
    String? userId,
    String? nome,
    String? especie,
    String? espacoId,
    List<String>? imagePaths,
    String? observacoes,
    List<ComentarioModel>? comentarios,
    DateTime? dataCadastro,
    String? fotoBase64,
  }) {
    final now = DateTime.now();
    final plantaId = id ?? now.millisecondsSinceEpoch.toString();

    return PlantaModel(
      id: plantaId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      nome: nome,
      especie: especie,
      espacoId: espacoId,
      imagePaths: imagePaths,
      observacoes: observacoes,
      comentarios: comentarios,
      dataCadastro: dataCadastro ?? now,
      fotoBase64: fotoBase64,
    );
  }

  /// Create from Hive map
  factory PlantaModel.fromHiveMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseHiveFields(map);

    return PlantaModel(
      id: baseFields['id'] as String,
      createdAtMs: map['createdAt'] as int?,
      updatedAtMs: map['updatedAt'] as int?,
      lastSyncAtMs: map['lastSyncAt'] as int?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      nome: map['nome']?.toString(),
      especie: map['especie']?.toString(),
      espacoId: map['espacoId']?.toString(),
      imagePaths:
          map['imagePaths'] != null
              ? List<String>.from(map['imagePaths'] as Iterable<dynamic>)
              : null,
      observacoes: map['observacoes']?.toString(),
      comentarios:
          map['comentarios'] != null
              ? (map['comentarios'] as List)
                  .map((c) => ComentarioModel.fromHiveMap(c as Map<String, dynamic>))
                  .toList()
              : null,
      dataCadastro:
          map['dataCadastro'] != null
              ? DateTime.parse(map['dataCadastro'] as String)
              : null,
      fotoBase64: map['fotoBase64']?.toString(),
    );
  }

  /// Convert to Hive map
  @override
  Map<String, dynamic> toHiveMap() {
    return super.toHiveMap()..addAll({
      'nome': nome,
      'especie': especie,
      'espacoId': espacoId,
      'imagePaths': imagePaths,
      'observacoes': observacoes,
      'comentarios': comentarios?.map((c) => c.toHiveMap()).toList(),
      'dataCadastro': dataCadastro?.toIso8601String(),
      'fotoBase64': fotoBase64,
    });
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'nome': nome,
      'especie': especie,
      'espaco_id': espacoId,
      'image_paths': imagePaths,
      'observacoes': observacoes,
      'comentarios': comentarios?.map((c) => c.toFirebaseMap()).toList(),
      'data_cadastro': dataCadastro?.toIso8601String(),
      'foto_base64': fotoBase64,
    };
  }

  /// Create from Firebase map
  factory PlantaModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseFirebaseFields(map);
    final timestamps = BaseSyncModel.parseFirebaseTimestamps(map);

    return PlantaModel(
      id: baseFields['id'] as String,
      createdAtMs: timestamps['createdAt']?.millisecondsSinceEpoch,
      updatedAtMs: timestamps['updatedAt']?.millisecondsSinceEpoch,
      lastSyncAtMs: timestamps['lastSyncAt']?.millisecondsSinceEpoch,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      nome: map['nome']?.toString(),
      especie: map['especie']?.toString(),
      espacoId: map['espaco_id']?.toString(),
      imagePaths:
          map['image_paths'] != null
              ? List<String>.from(map['image_paths'] as Iterable<dynamic>)
              : null,
      observacoes: map['observacoes']?.toString(),
      comentarios:
          map['comentarios'] != null
              ? (map['comentarios'] as List)
                  .map((c) => ComentarioModel.fromFirebaseMap(c as Map<String, dynamic>))
                  .toList()
              : null,
      dataCadastro:
          map['data_cadastro'] != null
              ? DateTime.parse(map['data_cadastro'] as String)
              : null,
      fotoBase64: map['foto_base64']?.toString(),
    );
  }

  /// copyWith method for immutability
  @override
  PlantaModel copyWith({
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
    String? especie,
    String? espacoId,
    List<String>? imagePaths,
    String? observacoes,
    List<ComentarioModel>? comentarios,
    DateTime? dataCadastro,
    String? fotoBase64,
  }) {
    return PlantaModel(
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
      especie: especie ?? this.especie,
      espacoId: espacoId ?? this.espacoId,
      imagePaths: imagePaths ?? this.imagePaths,
      observacoes: observacoes ?? this.observacoes,
      comentarios: comentarios ?? this.comentarios,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      fotoBase64: fotoBase64 ?? this.fotoBase64,
    );
  }

  // Legacy compatibility methods
  Map<String, dynamic> toMap() => toHiveMap();
  @override
  Map<String, dynamic> toJson() => toHiveMap();
  factory PlantaModel.fromMap(Map<String, dynamic> map) =>
      PlantaModel.fromHiveMap(map);
  factory PlantaModel.fromJson(Map<String, dynamic> json) =>
      PlantaModel.fromHiveMap(json);

  // ========================================
  // NULL OBJECT PATTERN METHODS
  // ========================================

  /// Retorna lista de imagens não-nula (null object pattern)
  List<String> get safeImagePaths => imagePaths ?? <String>[];

  /// Retorna lista de comentários não-nula (null object pattern)
  List<ComentarioModel> get safeComentarios =>
      comentarios ?? <ComentarioModel>[];

  /// Retorna nome seguro não-nulo (null object pattern)
  String get safeNome => nome ?? '';

  /// Retorna espécie segura não-nula (null object pattern)
  String get safeEspecie => especie ?? '';

  /// Retorna observações seguras não-nulas (null object pattern)
  String get safeObservacoes => observacoes ?? '';

  /// Verifica se a planta tem nome válido
  bool get hasValidNome => nome != null && nome!.trim().isNotEmpty;

  /// Verifica se a planta tem imagens
  bool get hasImages => safeImagePaths.isNotEmpty;

  /// Verifica se a planta tem comentários
  bool get hasComentarios => safeComentarios.isNotEmpty;

  /// Verifica se a planta tem observações
  bool get hasObservacoes =>
      observacoes != null && observacoes!.trim().isNotEmpty;

  // Compatibility getters for different naming conventions
  String? get name => nome;
  String? get species => especie;
  String? get notes => observacoes;

  /// Getter descricao para compatibilidade com facade queries
  /// Retorna combinação de nome e espécie ou observações como descrição
  String get descricao {
    final parts = <String>[];

    if (hasValidNome) {
      parts.add(nome!);
    }

    if (especie != null && especie!.trim().isNotEmpty) {
      parts.add('($especie)');
    }

    if (parts.isEmpty && hasObservacoes) {
      return observacoes!.trim();
    }

    return parts.join(' ').trim();
  }

  @override
  String toString() {
    return 'PlantaModel(id: $id, nome: $nome, especie: $especie, espacoId: $espacoId)';
  }
}
