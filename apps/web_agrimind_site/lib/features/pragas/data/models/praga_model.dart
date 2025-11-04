import '../../domain/entities/praga_entity.dart';

/// Praga data model
///
/// Data layer representation of a praga with JSON serialization
/// NOTE: This is a manual implementation without Freezed due to build_runner compatibility issues
class PragaModel {
  final String id;
  final String nome;
  final String? nomeComum;
  final String? nomeCientifico;
  final String? descricao;
  final String? cicloVida;
  final String? danosCausados;
  final String? culturasAfetadas;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PragaModel({
    required this.id,
    required this.nome,
    this.nomeComum,
    this.nomeCientifico,
    this.descricao,
    this.cicloVida,
    this.danosCausados,
    this.culturasAfetadas,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory PragaModel.fromJson(Map<String, dynamic> json) {
    return PragaModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      nomeComum: json['nome_comum'] as String?,
      nomeCientifico: json['nome_cientifico'] as String?,
      descricao: json['descricao'] as String?,
      cicloVida: json['ciclo_vida'] as String?,
      danosCausados: json['danos_causados'] as String?,
      culturasAfetadas: json['culturas_afetadas'] as String?,
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
      'ciclo_vida': cicloVida,
      'danos_causados': danosCausados,
      'culturas_afetadas': culturasAfetadas,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  PragaEntity toEntity() => PragaEntity(
        id: id,
        nome: nome,
        nomeComum: nomeComum,
        nomeCientifico: nomeCientifico,
        descricao: descricao,
        cicloVida: cicloVida,
        danosCausados: danosCausados,
        culturasAfetadas: culturasAfetadas,
        imageUrl: imageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Create from domain entity
  factory PragaModel.fromEntity(PragaEntity entity) => PragaModel(
        id: entity.id,
        nome: entity.nome,
        nomeComum: entity.nomeComum,
        nomeCientifico: entity.nomeCientifico,
        descricao: entity.descricao,
        cicloVida: entity.cicloVida,
        danosCausados: entity.danosCausados,
        culturasAfetadas: entity.culturasAfetadas,
        imageUrl: entity.imageUrl,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  /// copyWith method for immutability
  PragaModel copyWith({
    String? id,
    String? nome,
    String? nomeComum,
    String? nomeCientifico,
    String? descricao,
    String? cicloVida,
    String? danosCausados,
    String? culturasAfetadas,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PragaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      descricao: descricao ?? this.descricao,
      cicloVida: cicloVida ?? this.cicloVida,
      danosCausados: danosCausados ?? this.danosCausados,
      culturasAfetadas: culturasAfetadas ?? this.culturasAfetadas,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PragaModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PragaModel(id: $id, nome: $nome)';
}
