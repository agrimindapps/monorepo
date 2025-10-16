import '../../domain/entities/praga.dart';

/// Praga model - Data layer
class PragaModel extends Praga {
  const PragaModel({
    required super.id,
    required super.nomeComum,
    required super.nomeCientifico,
    required super.ordem,
    required super.familia,
    super.descricao,
    super.imageUrl,
    super.culturasAfetadas,
    super.danos,
    super.controle,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON
  factory PragaModel.fromJson(Map<String, dynamic> json) {
    return PragaModel(
      id: json['id'] as String,
      nomeComum: json['nome_comum'] as String,
      nomeCientifico: json['nome_cientifico'] as String,
      ordem: json['ordem'] as String,
      familia: json['familia'] as String,
      descricao: json['descricao'] as String?,
      imageUrl: json['image_url'] as String?,
      culturasAfetadas: json['culturas_afetadas'] != null
          ? List<String>.from(json['culturas_afetadas'] as List)
          : null,
      danos: json['danos'] as String?,
      controle: json['controle'] as String?,
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
      'ordem': ordem,
      'familia': familia,
      'descricao': descricao,
      'image_url': imageUrl,
      'culturas_afetadas': culturasAfetadas,
      'danos': danos,
      'controle': controle,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create model from entity
  factory PragaModel.fromEntity(Praga praga) {
    return PragaModel(
      id: praga.id,
      nomeComum: praga.nomeComum,
      nomeCientifico: praga.nomeCientifico,
      ordem: praga.ordem,
      familia: praga.familia,
      descricao: praga.descricao,
      imageUrl: praga.imageUrl,
      culturasAfetadas: praga.culturasAfetadas,
      danos: praga.danos,
      controle: praga.controle,
      createdAt: praga.createdAt,
      updatedAt: praga.updatedAt,
    );
  }
}
