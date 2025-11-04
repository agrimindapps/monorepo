import '../../domain/entities/fitossanitario_entity.dart';

/// Fitossanitario data model
///
/// Data layer representation of a fitossanitario with JSON serialization
/// NOTE: This is a manual implementation without Freezed due to build_runner compatibility issues
class FitossanitarioModel {
  final String id;
  final String nome;
  final String? nomeComum;
  final String? nomeCientifico;
  final String? descricao;
  final String? composicao;
  final String? modoAplicacao;
  final String? dosagem;
  final String? intervaloSeguranca;
  final String? modoAcao;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FitossanitarioModel({
    required this.id,
    required this.nome,
    this.nomeComum,
    this.nomeCientifico,
    this.descricao,
    this.composicao,
    this.modoAplicacao,
    this.dosagem,
    this.intervaloSeguranca,
    this.modoAcao,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory FitossanitarioModel.fromJson(Map<String, dynamic> json) {
    return FitossanitarioModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      nomeComum: json['nome_comum'] as String?,
      nomeCientifico: json['nome_cientifico'] as String?,
      descricao: json['descricao'] as String?,
      composicao: json['composicao'] as String?,
      modoAplicacao: json['modo_aplicacao'] as String?,
      dosagem: json['dosagem'] as String?,
      intervaloSeguranca: json['intervalo_seguranca'] as String?,
      modoAcao: json['modo_acao'] as String?,
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
      'composicao': composicao,
      'modo_aplicacao': modoAplicacao,
      'dosagem': dosagem,
      'intervalo_seguranca': intervaloSeguranca,
      'modo_acao': modoAcao,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  FitossanitarioEntity toEntity() => FitossanitarioEntity(
        id: id,
        nome: nome,
        nomeComum: nomeComum,
        nomeCientifico: nomeCientifico,
        descricao: descricao,
        composicao: composicao,
        modoAplicacao: modoAplicacao,
        dosagem: dosagem,
        intervaloSeguranca: intervaloSeguranca,
        modoAcao: modoAcao,
        imageUrl: imageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Create from domain entity
  factory FitossanitarioModel.fromEntity(FitossanitarioEntity entity) =>
      FitossanitarioModel(
        id: entity.id,
        nome: entity.nome,
        nomeComum: entity.nomeComum,
        nomeCientifico: entity.nomeCientifico,
        descricao: entity.descricao,
        composicao: entity.composicao,
        modoAplicacao: entity.modoAplicacao,
        dosagem: entity.dosagem,
        intervaloSeguranca: entity.intervaloSeguranca,
        modoAcao: entity.modoAcao,
        imageUrl: entity.imageUrl,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  /// copyWith method for immutability
  FitossanitarioModel copyWith({
    String? id,
    String? nome,
    String? nomeComum,
    String? nomeCientifico,
    String? descricao,
    String? composicao,
    String? modoAplicacao,
    String? dosagem,
    String? intervaloSeguranca,
    String? modoAcao,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FitossanitarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      descricao: descricao ?? this.descricao,
      composicao: composicao ?? this.composicao,
      modoAplicacao: modoAplicacao ?? this.modoAplicacao,
      dosagem: dosagem ?? this.dosagem,
      intervaloSeguranca: intervaloSeguranca ?? this.intervaloSeguranca,
      modoAcao: modoAcao ?? this.modoAcao,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FitossanitarioModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FitossanitarioModel(id: $id, nome: $nome)';
}
