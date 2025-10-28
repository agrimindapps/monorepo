import 'package:equatable/equatable.dart';

/// Cultura (Crop) entity - Domain layer
class Cultura extends Equatable {
  final String id;
  final String nomeComum;
  final String nomeCientifico;
  final String familia;
  final String? descricao;
  final String? imageUrl;
  final List<String>? variedades;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cultura({
    required this.id,
    required this.nomeComum,
    required this.nomeCientifico,
    required this.familia,
    this.descricao,
    this.imageUrl,
    this.variedades,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nomeComum,
        nomeCientifico,
        familia,
        descricao,
        imageUrl,
        variedades,
        createdAt,
        updatedAt,
      ];

  /// Create a copy with updated fields
  Cultura copyWith({
    String? id,
    String? nomeComum,
    String? nomeCientifico,
    String? familia,
    String? descricao,
    String? imageUrl,
    List<String>? variedades,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cultura(
      id: id ?? this.id,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      familia: familia ?? this.familia,
      descricao: descricao ?? this.descricao,
      imageUrl: imageUrl ?? this.imageUrl,
      variedades: variedades ?? this.variedades,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
