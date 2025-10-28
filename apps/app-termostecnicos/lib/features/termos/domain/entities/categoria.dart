import 'package:equatable/equatable.dart';

/// Domain entity representing a category of technical terms
class Categoria extends Equatable {
  final int id;
  final String descricao;
  final String keytermo;
  final String keydecripy;
  final String image;

  const Categoria({
    required this.id,
    required this.descricao,
    required this.keytermo,
    required this.keydecripy,
    required this.image,
  });

  Categoria copyWith({
    int? id,
    String? descricao,
    String? keytermo,
    String? keydecripy,
    String? image,
  }) {
    return Categoria(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      keytermo: keytermo ?? this.keytermo,
      keydecripy: keydecripy ?? this.keydecripy,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [id, descricao, keytermo, keydecripy, image];

  @override
  bool get stringify => true;
}
