import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/comentario.dart';

/// Repository interface for Comentarios
/// Following Repository Pattern and Dependency Inversion Principle
abstract class ComentariosRepository {
  /// Get all comentarios
  Future<Either<Failure, List<Comentario>>> getComentarios();

  /// Get comentarios by ferramenta (category)
  Future<Either<Failure, List<Comentario>>> getComentariosByFerramenta(
    String ferramenta,
  );

  /// Get comentario by ID
  Future<Either<Failure, Comentario>> getComentarioById(String id);

  /// Add new comentario
  Future<Either<Failure, Unit>> addComentario(Comentario comentario);

  /// Update existing comentario
  Future<Either<Failure, Unit>> updateComentario(Comentario comentario);

  /// Delete comentario by ID
  Future<Either<Failure, Unit>> deleteComentario(String id);

  /// Delete all comentarios
  Future<Either<Failure, Unit>> deleteAllComentarios();

  /// Get count of comentarios
  Future<Either<Failure, int>> getComentariosCount();
}
