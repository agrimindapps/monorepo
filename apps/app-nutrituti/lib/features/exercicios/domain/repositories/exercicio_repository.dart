import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/exercicio.dart';

/// Abstract repository for exercise operations
abstract class ExercicioRepository {
  /// Get all exercises
  Future<Either<Failure, List<Exercicio>>> getAllExercicios();

  /// Get exercise by ID
  Future<Either<Failure, Exercicio?>> getExercicioById(String id);

  /// Add a new exercise
  Future<Either<Failure, Exercicio>> addExercicio(Exercicio exercicio);

  /// Update an existing exercise
  Future<Either<Failure, Exercicio>> updateExercicio(Exercicio exercicio);

  /// Delete an exercise
  Future<Either<Failure, void>> deleteExercicio(String id);

  /// Get exercises by date range
  Future<Either<Failure, List<Exercicio>>> getExerciciosByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Get exercises by category
  Future<Either<Failure, List<Exercicio>>> getExerciciosByCategoria(
    String categoria,
  );

  /// Get total calories by date range
  Future<Either<Failure, double>> getTotalCaloriasByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Sync exercises with remote
  Future<Either<Failure, void>> syncExercicios();
}
