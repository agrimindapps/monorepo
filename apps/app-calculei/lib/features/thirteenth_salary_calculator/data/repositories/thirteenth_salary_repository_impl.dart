// Package imports:
import 'package:core/core.dart';

// Project imports:
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/thirteenth_salary_calculation.dart';
import '../../domain/repositories/thirteenth_salary_repository.dart';
import '../datasources/thirteenth_salary_local_datasource.dart';
import '../models/thirteenth_salary_calculation_model.dart';

/// Implementation of ThirteenthSalaryRepository
///
/// Follows Dependency Inversion Principle (DIP):
/// - Implements domain repository interface
/// - Depends on datasource abstraction, not concrete implementation
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for coordinating data operations
/// - Converts between entities and models
/// - Handles error mapping to domain failures
class ThirteenthSalaryRepositoryImpl implements ThirteenthSalaryRepository {
  final ThirteenthSalaryLocalDataSource _localDataSource;

  ThirteenthSalaryRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, ThirteenthSalaryCalculation>> saveCalculation(
    ThirteenthSalaryCalculation calculation,
  ) async {
    try {
      // Convert entity to model
      final model = ThirteenthSalaryCalculationModel.fromEntity(calculation);

      // Save to local storage
      final savedModel = await _localDataSource.save(model);

      // Convert model back to entity
      return Right(savedModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar cálculo: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ThirteenthSalaryCalculation>>>
      getCalculationHistory({
    int limit = 10,
  }) async {
    try {
      // Retrieve from local storage
      final models = await _localDataSource.getAll(limit: limit);

      // Convert models to entities
      final entities = models.map((model) => model.toEntity()).toList();

      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao recuperar histórico: $e'));
    }
  }

  @override
  Future<Either<Failure, ThirteenthSalaryCalculation>> getCalculationById(
    String id,
  ) async {
    try {
      // Retrieve from local storage
      final model = await _localDataSource.getById(id);

      if (model == null) {
        return const Left(CacheFailure('Cálculo não encontrado'));
      }

      // Convert model to entity
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao recuperar cálculo: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCalculation(String id) async {
    try {
      await _localDataSource.delete(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar cálculo: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await _localDataSource.clearAll();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar histórico: $e'));
    }
  }
}
