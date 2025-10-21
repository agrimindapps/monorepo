import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/overtime_calculation.dart';
import '../../domain/repositories/overtime_repository.dart';
import '../datasources/overtime_local_datasource.dart';
import '../models/overtime_calculation_model.dart';

@Injectable(as: OvertimeRepository)
class OvertimeRepositoryImpl implements OvertimeRepository {
  final OvertimeLocalDataSource _localDataSource;
  OvertimeRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, OvertimeCalculation>> saveCalculation(OvertimeCalculation calculation) async {
    try {
      final model = OvertimeCalculationModel.fromEntity(calculation);
      final saved = await _localDataSource.save(model);
      return Right(saved.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar cálculo: $e'));
    }
  }

  @override
  Future<Either<Failure, List<OvertimeCalculation>>> getCalculationHistory({int limit = 10}) async {
    try {
      final models = await _localDataSource.getAll(limit: limit);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao recuperar histórico: $e'));
    }
  }

  @override
  Future<Either<Failure, OvertimeCalculation>> getCalculationById(String id) async {
    try {
      final model = await _localDataSource.getById(id);
      if (model == null) {
        return const Left(CacheFailure('Cálculo não encontrado'));
      }
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
