import 'package:core/core.dart';
import '../../../features/comentarios/models/comentario_model.dart';

part 'comentario_hive.g.dart';

@HiveType(typeId: 108)
class ComentarioHive extends HiveObject {
  @HiveField(0)
  String? objectId;

  @HiveField(1)
  int? createdAt;

  @HiveField(2)
  int? updatedAt;

  @HiveField(3)
  String idReg;

  @HiveField(4)
  bool status;

  @HiveField(5)
  String titulo;

  @HiveField(6)
  String conteudo;

  @HiveField(7)
  String ferramenta;

  @HiveField(8)
  String pkIdentificador;

  @HiveField(9)
  String userId; // ID do usuário que criou o comentário

  ComentarioHive({
    this.objectId,
    this.createdAt,
    this.updatedAt,
    required this.idReg,
    required this.status,
    required this.titulo,
    required this.conteudo,
    required this.ferramenta,
    required this.pkIdentificador,
    required this.userId,
  });

  factory ComentarioHive.fromJson(Map<String, dynamic> json) {
    return ComentarioHive(
      objectId: json['objectId'] as String?,
      createdAt: json['createdAt'] != null ? int.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? int.tryParse(json['updatedAt'].toString()) : null,
      idReg: (json['idReg'] as String?) ?? '',
      status: json['status'] != null ? json['status'] as bool : true,
      titulo: (json['titulo'] as String?) ?? '',
      conteudo: (json['conteudo'] as String?) ?? '',
      ferramenta: (json['ferramenta'] as String?) ?? '',
      pkIdentificador: (json['pkIdentificador'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
      'status': status,
      'titulo': titulo,
      'conteudo': conteudo,
      'ferramenta': ferramenta,
      'pkIdentificador': pkIdentificador,
      'userId': userId,
    };
  }

  /// Converte para o modelo usado pelo módulo de comentários
  ComentarioModel toComentarioModel() {
    return ComentarioModel(
      id: idReg,
      idReg: idReg,
      titulo: titulo,
      conteudo: conteudo,
      ferramenta: ferramenta,
      pkIdentificador: pkIdentificador,
      status: status,
      createdAt: createdAt != null 
          ? DateTime.fromMillisecondsSinceEpoch(createdAt!)
          : DateTime.now(),
      updatedAt: updatedAt != null 
          ? DateTime.fromMillisecondsSinceEpoch(updatedAt!)
          : DateTime.now(),
    );
  }

  /// Cria um ComentarioHive a partir do ComentarioModel
  static ComentarioHive fromComentarioModel(ComentarioModel model, String userId) {
    return ComentarioHive(
      objectId: model.id,
      idReg: model.idReg,
      titulo: model.titulo,
      conteudo: model.conteudo,
      ferramenta: model.ferramenta,
      pkIdentificador: model.pkIdentificador,
      status: model.status,
      userId: userId,
      createdAt: model.createdAt.millisecondsSinceEpoch,
      updatedAt: model.updatedAt.millisecondsSinceEpoch,
    );
  }

  @override
  String toString() {
    return 'ComentarioHive(idReg: $idReg, conteudo: ${conteudo.length > 50 ? "${conteudo.substring(0, 50)}..." : conteudo})';
  }
}