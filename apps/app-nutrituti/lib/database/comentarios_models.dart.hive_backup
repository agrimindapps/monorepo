// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../core/models/base_model.dart';

part 'comentarios_models.g.dart';

@HiveType(typeId: 50)
class Comentarios extends BaseModel {
  @HiveField(0)
  @override
  final String? id;

  @HiveField(1)
  @override
  final DateTime? createdAt;

  @HiveField(2)
  @override
  final DateTime? updatedAt;

  @HiveField(7)
  final String titulo;

  @HiveField(8)
  final String conteudo;

  @HiveField(9)
  final String ferramenta;

  @HiveField(10)
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
