import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/comentario.dart';
import '../repositories/comentarios_repository.dart';

/// Use case for adding a new comentario
/// Includes business validation rules
class AddComentario {
  final ComentariosRepository _repository;

  const AddComentario(this._repository);

  Future<Either<Failure, Unit>> call(Comentario comentario) async {
    // Business validation
    final validationError = _validate(comentario);
    if (validationError != null) {
      return Left(validationError);
    }

    return await _repository.addComentario(comentario);
  }

  ValidationFailure? _validate(Comentario comentario) {
    if (comentario.id.trim().isEmpty) {
      return const ValidationFailure(message: 'ID não pode estar vazio');
    }

    if (comentario.conteudo.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Conteúdo não pode estar vazio',
      );
    }

    if (comentario.conteudo.trim().length < 5) {
      return const ValidationFailure(
        message: 'Comentário deve ter pelo menos 5 caracteres',
      );
    }

    if (comentario.conteudo.length > 200) {
      return const ValidationFailure(
        message: 'Comentário não pode ter mais de 200 caracteres',
      );
    }

    if (comentario.ferramenta.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Ferramenta não pode estar vazia',
      );
    }

    if (comentario.pkIdentificador.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Identificador não pode estar vazio',
      );
    }

    return null;
  }
}
