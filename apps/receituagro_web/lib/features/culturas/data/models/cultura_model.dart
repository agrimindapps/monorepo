import '../../domain/entities/cultura.dart';

/// Cultura model - Data layer
class CulturaModel extends Cultura {
  const CulturaModel({
    required super.id,
    required super.nomeComum,
    required super.nomeCientifico,
    required super.familia,
    super.descricao,
    super.imageUrl,
    super.variedades,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON
  factory CulturaModel.fromJson(Map<String, dynamic> json) {
    return CulturaModel(
      id: json['id'] as String,
      nomeComum: json['nome_comum'] as String,
      nomeCientifico: json['nome_cientifico'] as String,
      familia: json['familia'] as String,
      descricao: json['descricao'] as String?,
      imageUrl: json['image_url'] as String?,
      variedades: json['variedades'] != null
          ? List<String>.from(json['variedades'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_comum': nomeComum,
      'nome_cientifico': nomeCientifico,
      'familia': familia,
      'descricao': descricao,
      'image_url': imageUrl,
      'variedades': variedades,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create model from entity
  factory CulturaModel.fromEntity(Cultura cultura) {
    return CulturaModel(
      id: cultura.id,
      nomeComum: cultura.nomeComum,
      nomeCientifico: cultura.nomeCientifico,
      familia: cultura.familia,
      descricao: cultura.descricao,
      imageUrl: cultura.imageUrl,
      variedades: cultura.variedades,
      createdAt: cultura.createdAt,
      updatedAt: cultura.updatedAt,
    );
  }
}
