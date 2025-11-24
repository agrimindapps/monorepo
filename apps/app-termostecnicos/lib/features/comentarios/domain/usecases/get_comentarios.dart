import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/comentario.dart';
import '../repositories/comentarios_repository.dart';

/// Use case for getting all comentarios
/// Following Single Responsibility Principle
class GetComentarios {
  final ComentariosRepository _repository;

  const GetComentarios(this._repository);

  Future<Either<Failure, List<Comentario>>> call() async {
    return await _repository.getComentarios();
  }
}
