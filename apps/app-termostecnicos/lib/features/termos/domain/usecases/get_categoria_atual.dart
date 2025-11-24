import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/categoria.dart';
import '../repositories/termos_repository.dart';

/// Use case for getting the currently selected category
class GetCategoriaAtual {
  final TermosRepository repository;

  GetCategoriaAtual(this.repository);

  Future<Either<Failure, Categoria>> call() async {
    return await repository.getCategoriaAtual();
  }
}
