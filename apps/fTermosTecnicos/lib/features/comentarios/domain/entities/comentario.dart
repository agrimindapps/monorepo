import 'package:equatable/equatable.dart';

/// Domain entity for Comentario
/// Following Clean Architecture - independent of data layer
class Comentario extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool status;
  final String idReg;
  final String titulo;
  final String conteudo;
  final String ferramenta;
  final String pkIdentificador;

  const Comentario({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.idReg,
    required this.titulo,
    required this.conteudo,
    required this.ferramenta,
    required this.pkIdentificador,
  });

  /// Creates a copy with modified fields
  Comentario copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? status,
    String? idReg,
    String? titulo,
    String? conteudo,
    String? ferramenta,
    String? pkIdentificador,
  }) {
    return Comentario(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      idReg: idReg ?? this.idReg,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      ferramenta: ferramenta ?? this.ferramenta,
      pkIdentificador: pkIdentificador ?? this.pkIdentificador,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        status,
        idReg,
        titulo,
        conteudo,
        ferramenta,
        pkIdentificador,
      ];
}
