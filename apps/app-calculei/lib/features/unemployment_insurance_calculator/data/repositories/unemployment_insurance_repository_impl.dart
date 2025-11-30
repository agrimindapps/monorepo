import 'package:core/core.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/unemployment_insurance_calculation.dart';
import '../../domain/repositories/unemployment_insurance_repository.dart';
import '../datasources/unemployment_insurance_local_datasource.dart';
import '../models/unemployment_insurance_calculation_model.dart';

class UnemploymentInsuranceRepositoryImpl
    implements UnemploymentInsuranceRepository {
  final UnemploymentInsuranceLocalDataSource _localDataSource;

  UnemploymentInsuranceRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, UnemploymentInsuranceCalculation>> saveCalculation(
      UnemploymentInsuranceCalculation calculation) async {
    try {
      final model =
          UnemploymentInsuranceCalculationModel.fromEntity(calculation);
      final saved = await _localDataSource.save(model);
      return Right(saved.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar cálculo: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UnemploymentInsuranceCalculation>>>
      getCalculationHistory({int limit = 10}) async {
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
  Future<Either<Failure, UnemploymentInsuranceCalculation>> getCalculationById(
      String id) async {
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
