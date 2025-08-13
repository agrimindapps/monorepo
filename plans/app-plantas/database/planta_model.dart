// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';
import 'comentario_model.dart';

part 'planta_model.g.dart';

@HiveType(typeId: 82)
class PlantaModel extends BaseModel {
  @HiveField(7)
  String? nome;
  @HiveField(8)
  String? especie;
  @HiveField(9)
  String? espacoId;
  @HiveField(28)
  List<String>? imagePaths;
  @HiveField(29)
  String? observacoes;
  @HiveField(30)
  List<ComentarioModel>? comentarios;
  @HiveField(31)
  DateTime? dataCadastro;
  @HiveField(32)
  String? fotoBase64;

  PlantaModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    this.nome,
    this.especie,
    this.espacoId,
    this.imagePaths,
    this.observacoes,
    this.comentarios,
    this.dataCadastro,
    this.fotoBase64,
  }) {
    // Assertions para validar invariants críticos
    assert(id.isNotEmpty, 'PlantaModel ID não pode ser vazio');
    assert(createdAt > 0, 'createdAt deve ser um timestamp válido');
    assert(updatedAt > 0, 'updatedAt deve ser um timestamp válido');
  }

  @override
  PlantaModel copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nome: nome ?? this.nome,
      especie: especie ?? this.especie,
      espacoId: espacoId ?? this.espacoId,
      imagePaths: imagePaths ?? this.imagePaths,
      observacoes: observacoes ?? this.observacoes,
      comentarios: comentarios ?? this.comentarios,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      fotoBase64: fotoBase64 ?? this.fotoBase64,
    )..updateBase(
        isDeleted: isDeleted,
        needsSync: needsSync,
        lastSyncAt: lastSyncAt,
        version: version,
      );
  }

  Map<String, dynamic> toJson() {
    final baseMap = super.toMap();
    baseMap.addAll({
      'nome': nome,
      'especie': especie,
      'espacoId': espacoId,
      // Null object pattern: garantir que listas não-nulas sejam serializadas
      'imagePaths': imagePaths ?? <String>[],
      'observacoes': observacoes,
      // Null object pattern: garantir que lista de comentários seja não-nula
      'comentarios': comentarios?.map((c) => c.toJson()).toList() ??
          <Map<String, dynamic>>[],
      'dataCadastro': dataCadastro?.toIso8601String(),
      'fotoBase64': fotoBase64,
    });
    return baseMap;
  }

  factory PlantaModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Null safety: garantir que dados críticos não sejam nulos
    assert(json['id'] != null, 'ID não pode ser nulo no JSON');

    return PlantaModel(
      id: json['id'] ?? '',
      createdAt: _extractTimestamp(json['createdAt']) ?? now,
      updatedAt: _extractTimestamp(json['updatedAt']) ?? now,
      nome: json['nome'],
      especie: json['especie'],
      espacoId: json['espacoId'],
      // Null object pattern: sempre retornar lista não-nula
      imagePaths: json['imagePaths'] != null
          ? List<String>.from(json['imagePaths'])
          : <String>[],
      observacoes: json['observacoes'],
      // Null object pattern: sempre retornar lista não-nula para comentários
      comentarios: json['comentarios'] != null
          ? (json['comentarios'] as List)
              .map((c) => ComentarioModel.fromJson(c))
              .toList()
          : <ComentarioModel>[],
      dataCadastro: json['dataCadastro'] != null
          ? DateTime.parse(json['dataCadastro'])
          : null,
      fotoBase64: json['fotoBase64'],
    );
  }

  /// Converte Timestamp do Firestore ou int para int
  static int? _extractTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    return null;
  }

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
}
