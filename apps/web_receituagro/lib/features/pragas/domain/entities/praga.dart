import 'package:equatable/equatable.dart';

/// Praga (Pest) entity - Domain layer
class Praga extends Equatable {
  final String id;
  final String nomeComum;
  final String nomeCientifico;
  final String ordem;
  final String familia;
  final String? descricao;
  final String? imageUrl;
  final List<String>? culturasAfetadas;
  final String? danos;
  final String? controle;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Praga({
    required this.id,
    required this.nomeComum,
    required this.nomeCientifico,
    required this.ordem,
    required this.familia,
    this.descricao,
    this.imageUrl,
    this.culturasAfetadas,
    this.danos,
    this.controle,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nomeComum,
        nomeCientifico,
        ordem,
        familia,
        descricao,
        imageUrl,
        culturasAfetadas,
        danos,
        controle,
        createdAt,
        updatedAt,
      ];

  /// Create a copy with updated fields
  Praga copyWith({
    String? id,
    String? nomeComum,
    String? nomeCientifico,
    String? ordem,
    String? familia,
    String? descricao,
    String? imageUrl,
    List<String>? culturasAfetadas,
    String? danos,
    String? controle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Praga(
      id: id ?? this.id,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      ordem: ordem ?? this.ordem,
      familia: familia ?? this.familia,
      descricao: descricao ?? this.descricao,
      imageUrl: imageUrl ?? this.imageUrl,
      culturasAfetadas: culturasAfetadas ?? this.culturasAfetadas,
      danos: danos ?? this.danos,
      controle: controle ?? this.controle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
