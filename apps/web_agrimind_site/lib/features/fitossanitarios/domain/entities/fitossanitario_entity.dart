import 'package:equatable/equatable.dart';

/// Fitossanitario entity
///
/// Represents a phytosanitary product in the domain layer
class FitossanitarioEntity extends Equatable {
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

  const FitossanitarioEntity({
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

  @override
  List<Object?> get props => [
        id,
        nome,
        nomeComum,
        nomeCientifico,
        descricao,
        composicao,
        modoAplicacao,
        dosagem,
        intervaloSeguranca,
        modoAcao,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}
