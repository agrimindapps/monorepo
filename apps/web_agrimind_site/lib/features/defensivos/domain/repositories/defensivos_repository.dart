import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/defensivo_entity.dart';

/// Defensivos repository interface
///
/// Domain layer contract for defensivos data operations
abstract class IDefensivosRepository {
  /// Get all defensivos
  ///
  /// Returns [Right] with list of defensivos on success
  /// Returns [Left] with [Failure] on error
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivos();

  /// Get a single defensivo by id
  ///
  /// Returns [Right] with defensivo entity on success
  /// Returns [Left] with [NotFoundFailure] if defensivo doesn't exist
  /// Returns [Left] with [Failure] on other errors
  Future<Either<Failure, DefensivoEntity>> getDefensivoById(String id);
}
