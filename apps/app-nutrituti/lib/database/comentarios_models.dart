// Project imports:
import '../../../core/models/base_model.dart';

class Comentarios extends BaseModel {
  @override
  final String? id;

  @override
  final DateTime? createdAt;

  @override
  final DateTime? updatedAt;

  final String titulo;

  final String conteudo;

  final String ferramenta;

  final String pkIdentificador;

  const Comentarios({
    this.id,
    this.createdAt,
    this.updatedAt,
    required this.titulo,
    required this.conteudo,
    required this.ferramenta,
    required this.pkIdentificador,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'titulo': titulo,
      'conteudo': conteudo,
      'ferramenta': ferramenta,
      'pkIdentificador': pkIdentificador,
    };
  }

  factory Comentarios.fromMap(Map<String, dynamic> map) {
    return Comentarios(
      id: map['id'] as String?,
      createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'] as String)
        : null,
      updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'] as String)
        : null,
      titulo: map['titulo'] as String? ?? '',
      conteudo: map['conteudo'] as String? ?? '',
      ferramenta: map['ferramenta'] as String? ?? '',
      pkIdentificador: map['pkIdentificador'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
