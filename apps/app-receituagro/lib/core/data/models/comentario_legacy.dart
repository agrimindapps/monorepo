/// DEPRECATED: Legacy Hive model - Use Drift ComentarioData instead
/// Maintained for backward compatibility during migration phase

import 'package:core/core.dart' hide Column;
import '../../../features/comentarios/data/comentario_model.dart';

// part 'comentario_hive.g.dart';

class ComentarioHive {
  String? sync_objectId;

  int? sync_createdAt;

  int? sync_updatedAt;

  String idReg;

  bool sync_deleted; // true = deleted, false = active (inverted from old 'status')

  String titulo;

  String conteudo;

  String ferramenta;

  String pkIdentificador;

  String userId; // ID do usuário que criou o comentário

  ComentarioHive({
    this.sync_objectId,
    this.sync_createdAt,
    this.sync_updatedAt,
    required this.idReg,
    required this.sync_deleted,
    required this.titulo,
    required this.conteudo,
    required this.ferramenta,
    required this.pkIdentificador,
    required this.userId,
  });

  factory ComentarioHive.fromJson(Map<String, dynamic> json) {
    return ComentarioHive(
      sync_objectId: json['sync_objectId'] as String?,
      sync_createdAt: json['sync_createdAt'] != null
          ? int.tryParse(json['sync_createdAt'].toString())
          : null,
      sync_updatedAt: json['sync_updatedAt'] != null
          ? int.tryParse(json['sync_updatedAt'].toString())
          : null,
      idReg: (json['idReg'] as String?) ?? '',
      sync_deleted: json['sync_deleted'] != null
          ? json['sync_deleted'] as bool
          : false,
      titulo: (json['titulo'] as String?) ?? '',
      conteudo: (json['conteudo'] as String?) ?? '',
      ferramenta: (json['ferramenta'] as String?) ?? '',
      pkIdentificador: (json['pkIdentificador'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sync_objectId': sync_objectId,
      'sync_createdAt': sync_createdAt,
      'sync_updatedAt': sync_updatedAt,
      'idReg': idReg,
      'sync_deleted': sync_deleted,
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
      status:
          !sync_deleted, // Invert: sync_deleted=false means active (status=true)
      createdAt: sync_createdAt != null
          ? DateTime.fromMillisecondsSinceEpoch(sync_createdAt!)
          : DateTime.now(),
      updatedAt: sync_updatedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(sync_updatedAt!)
          : DateTime.now(),
    );
  }

  /// Cria um ComentarioHive a partir do ComentarioModel
  static ComentarioHive fromComentarioModel(
    ComentarioModel model,
    String userId,
  ) {
    return ComentarioHive(
      sync_objectId: model.id,
      idReg: model.idReg,
      titulo: model.titulo,
      conteudo: model.conteudo,
      ferramenta: model.ferramenta,
      pkIdentificador: model.pkIdentificador,
      sync_deleted:
          !model.status, // Invert: status=true means sync_deleted=false
      userId: userId,
      sync_createdAt: model.createdAt.millisecondsSinceEpoch,
      sync_updatedAt: model.updatedAt.millisecondsSinceEpoch,
    );
  }

  @override
  String toString() {
    return 'ComentarioHive(idReg: $idReg, conteudo: ${conteudo.length > 50 ? "${conteudo.substring(0, 50)}..." : conteudo})';
  }
}
