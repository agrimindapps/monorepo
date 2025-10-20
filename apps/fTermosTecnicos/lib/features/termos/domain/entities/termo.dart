import 'package:equatable/equatable.dart';

/// Domain entity representing a technical term
/// Immutable and contains only business logic
class Termo extends Equatable {
  final String id;
  final String termo;
  final String descricao;
  final String categoria;
  final bool favorito;

  const Termo({
    required this.id,
    required this.termo,
    required this.descricao,
    required this.categoria,
    this.favorito = false,
  });

  /// Create a copy of this Termo with modified fields
  Termo copyWith({
    String? id,
    String? termo,
    String? descricao,
    String? categoria,
    bool? favorito,
  }) {
    return Termo(
      id: id ?? this.id,
      termo: termo ?? this.termo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      favorito: favorito ?? this.favorito,
    );
  }

  @override
  List<Object?> get props => [id, termo, descricao, categoria, favorito];

  @override
  bool get stringify => true;
}
