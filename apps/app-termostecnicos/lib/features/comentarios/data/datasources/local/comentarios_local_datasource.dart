// import 'package:drift/drift.dart' hide Column;

import '../../../../../core/error/exceptions.dart';
import '../../../../../database/termostecnicos_database.dart' as db;
import '../../models/comentario_model.dart';

/// Local data source interface for Comentarios
/// Following Interface Segregation Principle
abstract class ComentariosLocalDataSource {
  Future<List<ComentarioModel>> getComentarios();
  Future<List<ComentarioModel>> getComentariosByFerramenta(String ferramenta);
  Future<ComentarioModel> getComentarioById(String id);
  Future<void> addComentario(ComentarioModel comentario);
  Future<void> updateComentario(ComentarioModel comentario);
  Future<void> deleteComentario(String id);
  Future<void> deleteAllComentarios();
  Future<int> getComentariosCount();
}

/// Implementation of local data source using Drift/SQLite
class ComentariosLocalDataSourceImpl implements ComentariosLocalDataSource {
  final db.TermosTecnicosDatabase _database;

  // Default userId for single-user app
  static const _defaultUserId = 'local_user';

  ComentariosLocalDataSourceImpl(this._database);

  @override
  Future<List<ComentarioModel>> getComentarios() async {
    final comentarios = await _database.comentarioDao.getAllComentarios(
      _defaultUserId,
    );
    return comentarios.map((c) => ComentarioModel.fromDrift(c)).toList();
  }

  @override
  Future<List<ComentarioModel>> getComentariosByFerramenta(
    String ferramenta,
  ) async {
    // Database not available on web
    return [];
  }

  @override
  Future<ComentarioModel> getComentarioById(String id) async {
    // Database not available on web
    throw DataNotFoundException(
      message: 'Comentário com ID $id não encontrado',
    );
  }

  @override
  Future<void> addComentario(ComentarioModel comentario) async {
    // Database not available on web
  }

  @override
  Future<void> updateComentario(ComentarioModel comentario) async {
    // Database not available on web
  }

  @override
  Future<void> deleteComentario(String id) async {
    // Database not available on web
  }

  @override
  Future<void> deleteAllComentarios() async {
    // Database not available on web
  }

  @override
  Future<int> getComentariosCount() async {
    // Database not available on web
    return 0;
  }

  /// Converts Drift entity to Model
  // ComentarioModel _toModel(Comentario data) {
  //   return ComentarioModel(
  //     id: data.id.toString(),
  //     createdAt: data.createdAt,
  //     updatedAt: data.updatedAt ?? data.createdAt,
  //     status: data.status,
  //     idReg: data.idReg,
  //     titulo: data.titulo,
  //     conteudo: data.conteudo,
  //     ferramenta: data.ferramenta,
  //     pkIdentificador: data.pkIdentificador,
  //   );
  // }

  /// Converts Model to Drift companion
  // ComentariosCompanion _toCompanion(
  //   ComentarioModel model, {
  //   bool forUpdate = false,
  // }) {
  //   if (forUpdate) {
  //     // For updates, only include fields that should be updated
  //     return ComentariosCompanion(
  //       updatedAt: Value(DateTime.now()),
  //       status: Value(model.status),
  //       titulo: Value(model.titulo),
  //       conteudo: Value(model.conteudo),
  //       ferramenta: Value(model.ferramenta),
  //     );
  //   }

  //   // For inserts, include all fields
  //   return ComentariosCompanion.insert(
  //     userId: _defaultUserId,
  //     createdAt: Value(model.createdAt),
  //     updatedAt: Value(model.updatedAt),
  //     status: Value(model.status),
  //     idReg: model.idReg,
  //     titulo: model.titulo,
  //     conteudo: model.conteudo,
  //     ferramenta: model.ferramenta,
  //     pkIdentificador: model.pkIdentificador,
  //   );
  // }
}
