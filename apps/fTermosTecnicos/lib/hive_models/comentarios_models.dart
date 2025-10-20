import 'package:hive/hive.dart';

part 'comentarios_models.g.dart';

@HiveType(typeId: 0)
class Comentarios extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  DateTime updatedAt;

  @HiveField(3)
  bool status;

  @HiveField(4)
  String idReg;

  @HiveField(5)
  String titulo;

  @HiveField(6)
  String conteudo;

  @HiveField(7)
  String ferramenta;

  @HiveField(8)
  String pkIdentificador;

  Comentarios({
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
}
