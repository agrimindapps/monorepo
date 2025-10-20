import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/categoria.dart';
import '../repositories/termos_repository.dart';

/// Use case for setting the selected category
@injectable
class SetCategoria {
  final TermosRepository repository;

  SetCategoria(this.repository);

  Future<Either<Failure, Unit>> call(Categoria categoria) async {
    return await repository.setCategoria(categoria);
  }
}
