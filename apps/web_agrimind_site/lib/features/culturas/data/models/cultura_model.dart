import '../../domain/entities/cultura_entity.dart';

/// Cultura data model
///
/// Data layer representation of a cultura with JSON serialization
/// NOTE: This is a manual implementation without Freezed due to build_runner compatibility issues
class CulturaModel {
  final String id;
  final String nome;
  final String? nomeComum;
  final String? nomeCientifico;
  final String? descricao;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CulturaModel({
    required this.id,
    required this.nome,
    this.nomeComum,
    this.nomeCientifico,
    this.descricao,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory CulturaModel.fromJson(Map<String, dynamic> json) {
    return CulturaModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      nomeComum: json['nome_comum'] as String?,
      nomeCientifico: json['nome_cientifico'] as String?,
      descricao: json['descricao'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'nome_comum': nomeComum,
      'nome_cientifico': nomeCientifico,
      'descricao': descricao,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  CulturaEntity toEntity() => CulturaEntity(
        id: id,
        nome: nome,
        nomeComum: nomeComum,
        nomeCientifico: nomeCientifico,
        descricao: descricao,
        imageUrl: imageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Create from domain entity
  factory CulturaModel.fromEntity(CulturaEntity entity) => CulturaModel(
        id: entity.id,
        nome: entity.nome,
        nomeComum: entity.nomeComum,
        nomeCientifico: entity.nomeCientifico,
        descricao: entity.descricao,
        imageUrl: entity.imageUrl,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  /// copyWith method for immutability
  CulturaModel copyWith({
    String? id,
    String? nome,
    String? nomeComum,
    String? nomeCientifico,
    String? descricao,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CulturaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      descricao: descricao ?? this.descricao,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CulturaModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CulturaModel(id: $id, nome: $nome)';
}
