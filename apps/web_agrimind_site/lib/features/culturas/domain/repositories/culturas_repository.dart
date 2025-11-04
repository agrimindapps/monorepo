import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cultura_entity.dart';

/// Culturas repository interface
///
/// Domain layer contract for culturas data operations
abstract class ICulturasRepository {
  /// Get all culturas
  ///
  /// Returns [Right] with list of culturas on success
  /// Returns [Left] with [Failure] on error
  Future<Either<Failure, List<CulturaEntity>>> getCulturas();

  /// Get a single cultura by id
  ///
  /// Returns [Right] with cultura entity on success
  /// Returns [Left] with [NotFoundFailure] if cultura doesn't exist
  /// Returns [Left] with [Failure] on other errors
  Future<Either<Failure, CulturaEntity>> getCulturaById(String id);
}
