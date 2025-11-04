import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fitossanitario_entity.dart';

/// Fitossanitarios repository interface
///
/// Defines the contract for fitossanitarios data operations
abstract class IFitossanitariosRepository {
  /// Get all fitossanitarios
  ///
  /// Returns [Right<List<FitossanitarioEntity>>] on success
  /// Returns [Left<Failure>] on error
  Future<Either<Failure, List<FitossanitarioEntity>>> getFitossanitarios();

  /// Get fitossanitario by ID
  ///
  /// Returns [Right<FitossanitarioEntity>] on success
  /// Returns [Left<Failure>] on error
  Future<Either<Failure, FitossanitarioEntity>> getFitossanitarioById(
      String id);
}
