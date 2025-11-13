import 'package:drift/drift.dart' hide Column;
import 'package:injectable/injectable.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../database/termostecnicos_database.dart';
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
@LazySingleton(as: ComentariosLocalDataSource)
class ComentariosLocalDataSourceImpl implements ComentariosLocalDataSource {
  final TermosTecnicosDatabase _database;

  // Default userId for single-user app
  static const _defaultUserId = 'local_user';

  ComentariosLocalDataSourceImpl(this._database);

  @override
  Future<List<ComentarioModel>> getComentarios() async {
    try {
      final results = await _database.comentarioDao.getAllComentarios(
        _defaultUserId,
      );
      return results.map(_toModel).toList();
    } catch (e) {
      throw StorageException(
        message: 'Erro ao buscar comentários: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ComentarioModel>> getComentariosByFerramenta(
    String ferramenta,
  ) async {
    try {
      final results = await _database.comentarioDao.getComentariosByFerramenta(
        _defaultUserId,
        ferramenta,
      );
      return results.map(_toModel).toList();
    } catch (e) {
      throw StorageException(
        message: 'Erro ao buscar comentários por ferramenta: ${e.toString()}',
      );
    }
  }

  @override
  Future<ComentarioModel> getComentarioById(String id) async {
    try {
      final result = await _database.comentarioDao.getComentarioById(
        int.parse(id),
      );

      if (result == null) {
        throw DataNotFoundException(
          message: 'Comentário com ID $id não encontrado',
        );
      }

      return _toModel(result);
    } catch (e) {
      if (e is DataNotFoundException) rethrow;
      throw StorageException(
        message: 'Erro ao buscar comentário: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addComentario(ComentarioModel comentario) async {
    try {
      await _database.comentarioDao.createComentario(
        _toCompanion(comentario),
      );
    } catch (e) {
      throw StorageException(
        message: 'Erro ao adicionar comentário: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateComentario(ComentarioModel comentario) async {
    try {
      final id = int.parse(comentario.id);

      // Check if exists
      final exists = await _database.comentarioDao.getComentarioById(id);
      if (exists == null) {
        throw DataNotFoundException(
          message: 'Comentário com ID ${comentario.id} não encontrado',
        );
      }

      await _database.comentarioDao.updateComentario(
        id,
        _toCompanion(comentario, forUpdate: true),
      );
    } catch (e) {
      if (e is DataNotFoundException) rethrow;
      throw StorageException(
        message: 'Erro ao atualizar comentário: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteComentario(String id) async {
    try {
      final intId = int.parse(id);

      // Check if exists
      final exists = await _database.comentarioDao.getComentarioById(intId);
      if (exists == null) {
        throw DataNotFoundException(
          message: 'Comentário com ID $id não encontrado',
        );
      }

      await _database.comentarioDao.deleteComentario(intId);
    } catch (e) {
      if (e is DataNotFoundException) rethrow;
      throw StorageException(
        message: 'Erro ao deletar comentário: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteAllComentarios() async {
    try {
      await _database.comentarioDao.deleteAllComentarios(_defaultUserId);
    } catch (e) {
      throw StorageException(
        message: 'Erro ao deletar todos os comentários: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> getComentariosCount() async {
    try {
      return await _database.comentarioDao.getComentariosCount(
        _defaultUserId,
      );
    } catch (e) {
      throw StorageException(
        message: 'Erro ao contar comentários: ${e.toString()}',
      );
    }
  }

  /// Converts Drift entity to Model
  ComentarioModel _toModel(Comentario data) {
    return ComentarioModel(
      id: data.id.toString(),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt ?? data.createdAt,
      status: data.status,
      idReg: data.idReg,
      titulo: data.titulo,
      conteudo: data.conteudo,
      ferramenta: data.ferramenta,
      pkIdentificador: data.pkIdentificador,
    );
  }

  /// Converts Model to Drift companion
  ComentariosCompanion _toCompanion(
    ComentarioModel model, {
    bool forUpdate = false,
  }) {
    if (forUpdate) {
      // For updates, only include fields that should be updated
      return ComentariosCompanion(
        updatedAt: Value(DateTime.now()),
        status: Value(model.status),
        titulo: Value(model.titulo),
        conteudo: Value(model.conteudo),
        ferramenta: Value(model.ferramenta),
      );
    }

    // For inserts, include all fields
    return ComentariosCompanion.insert(
      userId: _defaultUserId,
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      status: Value(model.status),
      idReg: model.idReg,
      titulo: model.titulo,
      conteudo: model.conteudo,
      ferramenta: model.ferramenta,
      pkIdentificador: model.pkIdentificador,
    );
  }
}
