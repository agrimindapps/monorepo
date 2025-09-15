import '../../../comentarios/models/comentario_model.dart' as LegacyComentarioModel;
import '../../../comentarios/domain/entities/comentario_entity.dart';

/// Modelo de dados para Comentario
/// 
/// Esta classe implementa a conversão entre a entidade de domínio
/// e os dados externos (Hive, API, etc), seguindo Clean Architecture
class ComentarioModel extends ComentarioEntity {
  const ComentarioModel({
    required super.id,
    required super.idReg,
    required super.titulo,
    required super.conteudo,
    required super.ferramenta,
    required super.pkIdentificador,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Cria um ComentarioModel a partir do modelo legacy
  factory ComentarioModel.fromLegacyModel(LegacyComentarioModel.ComentarioModel legacy) {
    return ComentarioModel(
      id: legacy.id,
      idReg: legacy.idReg,
      titulo: legacy.titulo,
      conteudo: legacy.conteudo,
      ferramenta: legacy.ferramenta,
      pkIdentificador: legacy.pkIdentificador,
      status: legacy.status,
      createdAt: legacy.createdAt,
      updatedAt: legacy.updatedAt,
    );
  }

  /// Cria um ComentarioModel a partir de JSON (API)
  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
      id: json['id'] as String,
      idReg: json['idReg'] as String,
      titulo: json['titulo'] as String,
      conteudo: json['conteudo'] as String,
      ferramenta: json['ferramenta'] as String,
      pkIdentificador: json['pkIdentificador'] as String,
      status: json['status'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converte para JSON (para API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idReg': idReg,
      'titulo': titulo,
      'conteudo': conteudo,
      'ferramenta': ferramenta,
      'pkIdentificador': pkIdentificador,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converte para o modelo legacy (para compatibilidade)
  LegacyComentarioModel.ComentarioModel toLegacyModel() {
    return LegacyComentarioModel.ComentarioModel(
      id: id,
      idReg: idReg,
      titulo: titulo,
      conteudo: conteudo,
      ferramenta: ferramenta,
      pkIdentificador: pkIdentificador,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Cria um ComentarioModel a partir de uma entidade
  factory ComentarioModel.fromEntity(ComentarioEntity entity) {
    return ComentarioModel(
      id: entity.id,
      idReg: entity.idReg,
      titulo: entity.titulo,
      conteudo: entity.conteudo,
      ferramenta: entity.ferramenta,
      pkIdentificador: entity.pkIdentificador,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Cria uma cópia com alguns campos alterados
  @override
  ComentarioModel copyWith({
    String? id,
    String? idReg,
    String? titulo,
    String? conteudo,
    String? ferramenta,
    String? pkIdentificador,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComentarioModel(
      id: id ?? this.id,
      idReg: idReg ?? this.idReg,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      ferramenta: ferramenta ?? this.ferramenta,
      pkIdentificador: pkIdentificador ?? this.pkIdentificador,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}