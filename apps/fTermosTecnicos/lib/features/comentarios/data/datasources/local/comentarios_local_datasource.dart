import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../hive_models/comentarios_models.dart';
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

/// Implementation of local data source using Hive
/// Maintains compatibility with existing Hive model
@LazySingleton(as: ComentariosLocalDataSource)
class ComentariosLocalDataSourceImpl implements ComentariosLocalDataSource {
  Future<Box<Comentarios>> _openBox() async {
    try {
      return await Hive.openBox<Comentarios>(AppConstants.comentariosBox);
    } catch (e) {
      throw StorageException(
        message: 'Erro ao abrir box de comentários: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ComentarioModel>> getComentarios() async {
    try {
      final box = await _openBox();
      final hiveComments = box.values.toList();

      // Convert Hive objects to models
      return hiveComments
          .map((hive) => ComentarioModel.fromHive(hive))
          .toList();
    } catch (e) {
      if (e is StorageException) rethrow;
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
      final box = await _openBox();
      final hiveComments = box.values
          .where((c) => c.ferramenta.contains(ferramenta))
          .toList();

      return hiveComments
          .map((hive) => ComentarioModel.fromHive(hive))
          .toList();
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Erro ao buscar comentários por ferramenta: ${e.toString()}',
      );
    }
  }

  @override
  Future<ComentarioModel> getComentarioById(String id) async {
    try {
      final box = await _openBox();
      final hiveComment = box.get(id);

      if (hiveComment == null) {
        throw DataNotFoundException(
          message: 'Comentário com ID $id não encontrado',
        );
      }

      return ComentarioModel.fromHive(hiveComment);
    } catch (e) {
      if (e is StorageException || e is DataNotFoundException) rethrow;
      throw StorageException(
        message: 'Erro ao buscar comentário: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addComentario(ComentarioModel comentario) async {
    try {
      final box = await _openBox();
      await box.put(comentario.id, comentario.toHive());
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Erro ao adicionar comentário: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateComentario(ComentarioModel comentario) async {
    try {
      final box = await _openBox();

      // Check if exists
      if (!box.containsKey(comentario.id)) {
        throw DataNotFoundException(
          message: 'Comentário com ID ${comentario.id} não encontrado',
        );
      }

      await box.put(comentario.id, comentario.toHive());
    } catch (e) {
      if (e is StorageException || e is DataNotFoundException) rethrow;
      throw StorageException(
        message: 'Erro ao atualizar comentário: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteComentario(String id) async {
    try {
      final box = await _openBox();

      // Check if exists
      if (!box.containsKey(id)) {
        throw DataNotFoundException(
          message: 'Comentário com ID $id não encontrado',
        );
      }

      await box.delete(id);
    } catch (e) {
      if (e is StorageException || e is DataNotFoundException) rethrow;
      throw StorageException(
        message: 'Erro ao deletar comentário: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteAllComentarios() async {
    try {
      final box = await _openBox();
      await box.clear();
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Erro ao deletar todos os comentários: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> getComentariosCount() async {
    try {
      final box = await _openBox();
      return box.length;
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Erro ao contar comentários: ${e.toString()}',
      );
    }
  }
}
