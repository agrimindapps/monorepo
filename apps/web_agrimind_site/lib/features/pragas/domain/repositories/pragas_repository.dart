import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/praga_entity.dart';

/// Pragas repository interface
///
/// Defines the contract for pragas data operations
abstract class IPragasRepository {
  /// Get all pragas
  ///
  /// Returns [Right<List<PragaEntity>>] on success
  /// Returns [Left<Failure>] on error
  Future<Either<Failure, List<PragaEntity>>> getPragas();

  /// Get praga by ID
  ///
  /// Returns [Right<PragaEntity>] on success
  /// Returns [Left<Failure>] on error
  Future<Either<Failure, PragaEntity>> getPragaById(String id);
}
