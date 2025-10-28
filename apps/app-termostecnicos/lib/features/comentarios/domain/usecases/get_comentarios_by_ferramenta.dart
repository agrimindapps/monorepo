import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/comentario.dart';
import '../repositories/comentarios_repository.dart';

/// Use case for getting comentarios by ferramenta
@injectable
class GetComentariosByFerramenta {
  final ComentariosRepository _repository;

  const GetComentariosByFerramenta(this._repository);

  Future<Either<Failure, List<Comentario>>> call(String ferramenta) async {
    if (ferramenta.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Ferramenta não pode estar vazia'),
      );
    }

    return await _repository.getComentariosByFerramenta(ferramenta);
  }
}
