import '../../domain/entities/defensivo_entity.dart';

/// Defensivo data model
///
/// Data layer representation of a defensivo with JSON serialization
/// NOTE: This is a manual implementation without Freezed due to build_runner compatibility issues
class DefensivoModel {
  final String id;
  final String nome;
  final String? nomeComercial;
  final String? principioAtivo;
  final String? classe;
  final String? fabricante;
  final String? descricao;
  final String? modoAplicacao;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DefensivoModel({
    required this.id,
    required this.nome,
    this.nomeComercial,
    this.principioAtivo,
    this.classe,
    this.fabricante,
    this.descricao,
    this.modoAplicacao,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory DefensivoModel.fromJson(Map<String, dynamic> json) {
    return DefensivoModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      nomeComercial: json['nome_comercial'] as String?,
      principioAtivo: json['principio_ativo'] as String?,
      classe: json['classe'] as String?,
      fabricante: json['fabricante'] as String?,
      descricao: json['descricao'] as String?,
      modoAplicacao: json['modo_aplicacao'] as String?,
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
      'nome_comercial': nomeComercial,
      'principio_ativo': principioAtivo,
      'classe': classe,
      'fabricante': fabricante,
      'descricao': descricao,
      'modo_aplicacao': modoAplicacao,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  DefensivoEntity toEntity() => DefensivoEntity(
        id: id,
        nome: nome,
        nomeComercial: nomeComercial,
        principioAtivo: principioAtivo,
        classe: classe,
        fabricante: fabricante,
        descricao: descricao,
        modoAplicacao: modoAplicacao,
        imageUrl: imageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Create from domain entity
  factory DefensivoModel.fromEntity(DefensivoEntity entity) => DefensivoModel(
        id: entity.id,
        nome: entity.nome,
        nomeComercial: entity.nomeComercial,
        principioAtivo: entity.principioAtivo,
        classe: entity.classe,
        fabricante: entity.fabricante,
        descricao: entity.descricao,
        modoAplicacao: entity.modoAplicacao,
        imageUrl: entity.imageUrl,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  /// copyWith method for immutability
  DefensivoModel copyWith({
    String? id,
    String? nome,
    String? nomeComercial,
    String? principioAtivo,
    String? classe,
    String? fabricante,
    String? descricao,
    String? modoAplicacao,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DefensivoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      nomeComercial: nomeComercial ?? this.nomeComercial,
      principioAtivo: principioAtivo ?? this.principioAtivo,
      classe: classe ?? this.classe,
      fabricante: fabricante ?? this.fabricante,
      descricao: descricao ?? this.descricao,
      modoAplicacao: modoAplicacao ?? this.modoAplicacao,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefensivoModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DefensivoModel(id: $id, nome: $nome)';
}
