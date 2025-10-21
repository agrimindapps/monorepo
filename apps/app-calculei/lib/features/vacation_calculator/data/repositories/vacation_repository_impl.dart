import 'package:core/core.dart';

import '../../domain/entities/vacation_calculation.dart';
import '../../domain/repositories/vacation_repository.dart';
import '../datasources/vacation_local_datasource.dart';
import '../models/vacation_calculation_model.dart';

/// Implementation of VacationRepository using Hive local storage
@Injectable(as: VacationRepository)
class VacationRepositoryImpl implements VacationRepository {
  final VacationLocalDataSource localDataSource;

  const VacationRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, VacationCalculation>> saveCalculation(
    VacationCalculation calculation,
  ) async {
    try {
      final model = VacationCalculationModel.fromEntity(calculation);
      await localDataSource.saveCalculation(model);
      return Right(calculation);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar cálculo: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VacationCalculation>>> getCalculationHistory({
    int limit = 10,
  }) async {
    try {
      final models = await localDataSource.getCalculations(limit: limit);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar histórico: $e'));
    }
  }

  @override
  Future<Either<Failure, VacationCalculation>> getCalculationById(
    String id,
  ) async {
    try {
      final model = await localDataSource.getCalculationById(id);

      if (model == null) {
        return const Left(CacheFailure('Cálculo não encontrado'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar cálculo: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCalculation(String id) async {
    try {
      await localDataSource.deleteCalculation(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar cálculo: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar histórico: $e'));
    }
  }
}
