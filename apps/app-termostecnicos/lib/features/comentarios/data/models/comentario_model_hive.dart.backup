import '../../../../hive_models/comentarios_models.dart';
import '../../domain/entities/comentario.dart';

/// Data model for Comentario
/// Handles conversion between Domain Entity and Hive persistence
class ComentarioModel extends Comentario {
  const ComentarioModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.status,
    required super.idReg,
    required super.titulo,
    required super.conteudo,
    required super.ferramenta,
    required super.pkIdentificador,
  });

  /// Creates model from domain entity
  factory ComentarioModel.fromEntity(Comentario entity) {
    return ComentarioModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      status: entity.status,
      idReg: entity.idReg,
      titulo: entity.titulo,
      conteudo: entity.conteudo,
      ferramenta: entity.ferramenta,
      pkIdentificador: entity.pkIdentificador,
    );
  }

  /// Converts to domain entity
  Comentario toEntity() {
    return Comentario(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      idReg: idReg,
      titulo: titulo,
      conteudo: conteudo,
      ferramenta: ferramenta,
      pkIdentificador: pkIdentificador,
    );
  }

  /// Creates model from Hive object (legacy compatibility)
  factory ComentarioModel.fromHive(Comentarios hiveObject) {
    return ComentarioModel(
      id: hiveObject.id,
      createdAt: hiveObject.createdAt,
      updatedAt: hiveObject.updatedAt,
      status: hiveObject.status,
      idReg: hiveObject.idReg,
      titulo: hiveObject.titulo,
      conteudo: hiveObject.conteudo,
      ferramenta: hiveObject.ferramenta,
      pkIdentificador: hiveObject.pkIdentificador,
    );
  }

  /// Converts to Hive object for persistence
  Comentarios toHive() {
    return Comentarios(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      idReg: idReg,
      titulo: titulo,
      conteudo: conteudo,
      ferramenta: ferramenta,
      pkIdentificador: pkIdentificador,
    );
  }

  /// Creates model from JSON (if needed for future API integration)
  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status: json['status'] as bool,
      idReg: json['idReg'] as String,
      titulo: json['titulo'] as String,
      conteudo: json['conteudo'] as String,
      ferramenta: json['ferramenta'] as String,
      pkIdentificador: json['pkIdentificador'] as String,
    );
  }

  /// Converts to JSON (if needed for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
      'idReg': idReg,
      'titulo': titulo,
      'conteudo': conteudo,
      'ferramenta': ferramenta,
      'pkIdentificador': pkIdentificador,
    };
  }

  @override
  ComentarioModel copyWith({
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
    return ComentarioModel(
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
}
