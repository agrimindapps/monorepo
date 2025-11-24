import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/termo.dart';
import '../repositories/termos_repository.dart';

/// Use case for getting all favorited terms
class GetFavoritos {
  final TermosRepository repository;

  GetFavoritos(this.repository);

  Future<Either<Failure, List<Termo>>> call() async {
    return await repository.getFavoritos();
  }
}
