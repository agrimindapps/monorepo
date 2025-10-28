import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/praga.dart';

/// Pragas repository interface - Domain layer
abstract class PragasRepository {
  Future<Either<Failure, List<Praga>>> getAllPragas();
  Future<Either<Failure, Praga>> getPragaById(String id);
  Future<Either<Failure, List<Praga>>> searchPragas(String query);
  Future<Either<Failure, Praga>> createPraga(Praga praga);
  Future<Either<Failure, Praga>> updatePraga(Praga praga);
  Future<Either<Failure, void>> deletePraga(String id);
}
