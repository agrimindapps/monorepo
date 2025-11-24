import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/comentario.dart';
import '../../domain/repositories/comentarios_repository.dart';
import '../datasources/local/comentarios_local_datasource.dart';
import '../models/comentario_model.dart';

/// Implementation of ComentariosRepository
/// Following Repository Pattern and Clean Architecture
class ComentariosRepositoryImpl implements ComentariosRepository {
  final ComentariosLocalDataSource _localDataSource;

  const ComentariosRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Comentario>>> getComentarios() async {
    try {
      final models = await _localDataSource.getComentarios();

      // Sort by createdAt descending (most recent first)
      models.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Convert models to entities
      final entities = models.map((model) => model.toEntity()).toList();

      return Right(entities);
    } on StorageException catch (e) {
      return Left(StorageReadFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao buscar comentários: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Comentario>>> getComentariosByFerramenta(
    String ferramenta,
  ) async {
    try {
      final models =
          await _localDataSource.getComentariosByFerramenta(ferramenta);

      // Sort by createdAt descending
      models.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final entities = models.map((model) => model.toEntity()).toList();

      return Right(entities);
    } on StorageException catch (e) {
      return Left(StorageReadFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao buscar comentários por ferramenta: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Comentario>> getComentarioById(String id) async {
    try {
      final model = await _localDataSource.getComentarioById(id);
      return Right(model.toEntity());
    } on DataNotFoundException catch (e) {
      return Left(DataNotFoundFailure(message: e.message));
    } on StorageException catch (e) {
      return Left(StorageReadFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao buscar comentário: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> addComentario(Comentario comentario) async {
    try {
      final model = ComentarioModel.fromEntity(comentario);
      await _localDataSource.addComentario(model);
      return const Right(unit);
    } on StorageException catch (e) {
      return Left(StorageWriteFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao adicionar comentário: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateComentario(
    Comentario comentario,
  ) async {
    try {
      final model = ComentarioModel.fromEntity(comentario);
      await _localDataSource.updateComentario(model);
      return const Right(unit);
    } on DataNotFoundException catch (e) {
      return Left(DataNotFoundFailure(message: e.message));
    } on StorageException catch (e) {
      return Left(StorageWriteFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao atualizar comentário: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComentario(String id) async {
    try {
      await _localDataSource.deleteComentario(id);
      return const Right(unit);
    } on DataNotFoundException catch (e) {
      return Left(DataNotFoundFailure(message: e.message));
    } on StorageException catch (e) {
      return Left(StorageDeleteFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao deletar comentário: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllComentarios() async {
    try {
      await _localDataSource.deleteAllComentarios();
      return const Right(unit);
    } on StorageException catch (e) {
      return Left(StorageDeleteFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao deletar todos os comentários: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getComentariosCount() async {
    try {
      final count = await _localDataSource.getComentariosCount();
      return Right(count);
    } on StorageException catch (e) {
      return Left(StorageReadFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao contar comentários: ${e.toString()}',
        ),
      );
    }
  }
}
