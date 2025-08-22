import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/calculator_entity.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/entities/calculation_history.dart';
import '../../domain/repositories/calculator_repository.dart';
import '../datasources/calculator_local_datasource.dart';

/// Implementação do repositório de calculadoras
/// 
/// Segue padrão clean architecture com local-first strategy
/// Integra com Hive para armazenamento local de histórico e favoritos
@LazySingleton(as: CalculatorRepository)
class CalculatorRepositoryImpl implements CalculatorRepository {
  final CalculatorLocalDataSource _localDataSource;

  const CalculatorRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<CalculatorEntity>>> getAllCalculators() async {
    try {
      final calculators = await _localDataSource.getAllCalculators();
      return Right(calculators);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar calculadoras: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CalculatorEntity>>> getCalculatorsByCategory(
    CalculatorCategory category,
  ) async {
    try {
      final calculators = await _localDataSource.getCalculatorsByCategory(category);
      return Right(calculators);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar calculadoras por categoria: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CalculatorEntity>> getCalculatorById(String id) async {
    try {
      final calculator = await _localDataSource.getCalculatorById(id);
      if (calculator != null) {
        return Right(calculator);
      } else {
        return const Left(NotFoundFailure('Calculadora não encontrada'));
      }
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar calculadora: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CalculatorEntity>>> searchCalculators(
    String searchTerm,
  ) async {
    try {
      final calculators = await _localDataSource.searchCalculators(searchTerm);
      return Right(calculators);
    } catch (e) {
      return Left(CacheFailure('Erro na busca: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CalculationResult>> executeCalculation(
    String calculatorId,
    Map<String, dynamic> inputs,
  ) async {
    try {
      final calculator = await _localDataSource.getCalculatorById(calculatorId);
      if (calculator == null) {
        return const Left(NotFoundFailure('Calculadora não encontrada'));
      }

      // Executa o cálculo usando o método da entidade
      final result = calculator.executeCalculation(inputs);
      
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Erro no cálculo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CalculationHistory>>> getCalculationHistory() async {
    try {
      final history = await _localDataSource.getCalculationHistory();
      return Right(history);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar histórico: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCalculationToHistory(
    CalculationHistory historyItem,
  ) async {
    try {
      await _localDataSource.saveCalculationToHistory(historyItem);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar no histórico: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFromHistory(String historyId) async {
    try {
      await _localDataSource.removeFromHistory(historyId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover do histórico: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearHistory() async {
    try {
      await _localDataSource.clearHistory();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar histórico: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFavoriteCalculators() async {
    try {
      final favorites = await _localDataSource.getFavoriteCalculators();
      return Right(favorites);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar favoritos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addToFavorites(String calculatorId) async {
    try {
      await _localDataSource.addToFavorites(calculatorId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Erro ao adicionar favorito: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFromFavorites(String calculatorId) async {
    try {
      await _localDataSource.removeFromFavorites(calculatorId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover favorito: ${e.toString()}'));
    }
  }
}