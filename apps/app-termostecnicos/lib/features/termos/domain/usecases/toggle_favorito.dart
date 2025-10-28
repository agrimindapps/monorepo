import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/termos_repository.dart';

/// Use case for toggling favorite status of a term
@injectable
class ToggleFavorito {
  final TermosRepository repository;

  ToggleFavorito(this.repository);

  Future<Either<Failure, bool>> call(String termoId) async {
    return await repository.toggleFavorito(termoId);
  }
}
