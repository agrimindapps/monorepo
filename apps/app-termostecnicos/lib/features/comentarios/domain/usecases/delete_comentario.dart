import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/comentarios_repository.dart';

/// Use case for deleting a comentario
class DeleteComentario {
  final ComentariosRepository _repository;

  const DeleteComentario(this._repository);

  Future<Either<Failure, Unit>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID não pode estar vazio'),
      );
    }

    return await _repository.deleteComentario(id);
  }
}
