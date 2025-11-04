import 'package:equatable/equatable.dart';

/// Praga entity
///
/// Represents a pest in the domain layer
class PragaEntity extends Equatable {
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

  const PragaEntity({
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

  @override
  List<Object?> get props => [
        id,
        nome,
        nomeComum,
        nomeCientifico,
        descricao,
        cicloVida,
        danosCausados,
        culturasAfetadas,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}
