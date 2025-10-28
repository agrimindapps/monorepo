import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/comentarios_repository.dart';

/// Use case for getting count of comentarios
@injectable
class GetComentariosCount {
  final ComentariosRepository _repository;

  const GetComentariosCount(this._repository);

  Future<Either<Failure, int>> call() async {
    return await _repository.getComentariosCount();
  }
}
