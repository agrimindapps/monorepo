import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/termo.dart';
import '../repositories/termos_repository.dart';

/// Use case for loading all technical terms
class CarregarTermos {
  final TermosRepository repository;

  CarregarTermos(this.repository);

  Future<Either<Failure, List<Termo>>> call() async {
    return await repository.carregarTermos();
  }
}
