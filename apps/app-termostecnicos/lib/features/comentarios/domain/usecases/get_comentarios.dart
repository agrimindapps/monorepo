import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/comentario.dart';
import '../repositories/comentarios_repository.dart';

/// Use case for getting all comentarios
/// Following Single Responsibility Principle
@injectable
class GetComentarios {
  final ComentariosRepository _repository;

  const GetComentarios(this._repository);

  Future<Either<Failure, List<Comentario>>> call() async {
    return await _repository.getComentarios();
  }
}
