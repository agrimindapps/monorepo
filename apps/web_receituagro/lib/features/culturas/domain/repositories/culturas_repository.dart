import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cultura.dart';

/// Culturas repository interface - Domain layer
abstract class CulturasRepository {
  /// Get all culturas
  Future<Either<Failure, List<Cultura>>> getAllCulturas();

  /// Get cultura by id
  Future<Either<Failure, Cultura>> getCulturaById(String id);

  /// Search culturas by query
  Future<Either<Failure, List<Cultura>>> searchCulturas(String query);

  /// Create new cultura
  Future<Either<Failure, Cultura>> createCultura(Cultura cultura);

  /// Update cultura
  Future<Either<Failure, Cultura>> updateCultura(Cultura cultura);

  /// Delete cultura
  Future<Either<Failure, void>> deleteCultura(String id);
}
