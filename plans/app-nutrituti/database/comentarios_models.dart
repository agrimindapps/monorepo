// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../core/models/base_model.dart';

part 'comentarios_models.g.dart';

@HiveType(typeId: 50)
class Comentarios extends BaseModel {
  @HiveField(7)
  String titulo;

  @HiveField(8)
  String conteudo;

  @HiveField(9)
  String ferramenta;

  @HiveField(10)
  String pkIdentificador;

  Comentarios({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.titulo,
    required this.conteudo,
    required this.ferramenta,
    required this.pkIdentificador,
  });

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'titulo': titulo,
      'conteudo': conteudo,
      'ferramenta': ferramenta,
      'pkIdentificador': pkIdentificador,
    });
  }

  factory Comentarios.fromMap(Map<String, dynamic> map) {
    return Comentarios(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      titulo: map['titulo'] ?? '',
      conteudo: map['conteudo'] ?? '',
      ferramenta: map['ferramenta'] ?? '',
      pkIdentificador: map['pkIdentificador'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
