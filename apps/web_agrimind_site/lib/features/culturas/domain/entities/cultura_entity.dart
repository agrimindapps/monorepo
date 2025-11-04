import 'package:equatable/equatable.dart';

/// Cultura entity
///
/// Represents a crop/culture in the domain layer
class CulturaEntity extends Equatable {
  final String id;
  final String nome;
  final String? nomeComum;
  final String? nomeCientifico;
  final String? descricao;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CulturaEntity({
    required this.id,
    required this.nome,
    this.nomeComum,
    this.nomeCientifico,
    this.descricao,
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
        imageUrl,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() => 'CulturaEntity(id: $id, nome: $nome)';
}
