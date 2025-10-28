import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/comentario.dart';
import '../repositories/comentarios_repository.dart';

/// Use case for updating an existing comentario
/// Includes business validation rules
@injectable
class UpdateComentario {
  final ComentariosRepository _repository;

  const UpdateComentario(this._repository);

  Future<Either<Failure, Unit>> call(Comentario comentario) async {
    // Business validation
    final validationError = _validate(comentario);
    if (validationError != null) {
      return Left(validationError);
    }

    // Check if comentario exists
    final existingResult = await _repository.getComentarioById(comentario.id);

    return existingResult.fold(
      (failure) => Left(failure),
      (existing) async {
        // Update with current timestamp
        final updated = comentario.copyWith(updatedAt: DateTime.now());
        return await _repository.updateComentario(updated);
      },
    );
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

    return null;
  }
}
