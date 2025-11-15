import '../../domain/entities/comentario.dart';
import '../../../../database/termostecnicos_database.dart' as db;
import 'package:drift/drift.dart';

/// Data model for Comentario
/// Handles conversion between Domain Entity and Drift persistence
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

  // Default userId for single-user app
  static const _defaultUserId = 'local_user';

  /// Creates model from Drift entity
  factory ComentarioModel.fromDrift(db.Comentario driftEntity) {
    return ComentarioModel(
      id: driftEntity.id.toString(),
      createdAt: driftEntity.createdAt,
      updatedAt: driftEntity.updatedAt ?? driftEntity.createdAt,
      status: driftEntity.status,
      idReg: driftEntity.idReg,
      titulo: driftEntity.titulo,
      conteudo: driftEntity.conteudo,
      ferramenta: driftEntity.ferramenta,
      pkIdentificador: driftEntity.pkIdentificador,
    );
  }

  /// Converts to Drift companion for inserts
  db.ComentariosCompanion toDriftCompanion() {
    return db.ComentariosCompanion.insert(
      userId: _defaultUserId,
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      status: Value(status),
      idReg: idReg,
      titulo: titulo,
      conteudo: conteudo,
      ferramenta: ferramenta,
      pkIdentificador: pkIdentificador,
    );
  }

  /// Converts model to domain entity
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
