import 'package:equatable/equatable.dart';

/// Defensivo entity
///
/// Represents an agricultural defensive product in the domain layer
class DefensivoEntity extends Equatable {
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

  const DefensivoEntity({
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

  @override
  List<Object?> get props => [
        id,
        nome,
        nomeComercial,
        principioAtivo,
        classe,
        fabricante,
        descricao,
        modoAplicacao,
        imageUrl,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() => 'DefensivoEntity(id: $id, nome: $nome)';
}
