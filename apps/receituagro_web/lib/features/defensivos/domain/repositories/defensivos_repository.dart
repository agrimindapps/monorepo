import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/defensivo.dart';

/// Defensivos repository contract (interface)
abstract class DefensivosRepository {
  /// Get all defensivos from data source
  Future<Either<Failure, List<Defensivo>>> getAllDefensivos();

  /// Get a single defensivo by ID
  Future<Either<Failure, Defensivo>> getDefensivoById(String id);

  /// Search defensivos by query (name or active ingredient)
  Future<Either<Failure, List<Defensivo>>> searchDefensivos(String query);

  /// Create a new defensivo
  Future<Either<Failure, Defensivo>> createDefensivo(Defensivo defensivo);

  /// Update an existing defensivo
  Future<Either<Failure, Defensivo>> updateDefensivo(Defensivo defensivo);

  /// Delete a defensivo by ID
  Future<Either<Failure, Unit>> deleteDefensivo(String id);
}
