import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/repositories/calculator_repository.dart';
import '../datasources/calculator_local_datasource.dart';

/// Implementação do repositório de calculadoras
/// 
/// Segue padrão clean architecture com local-first strategy
/// Integra com Hive para armazenamento local de histórico e favoritos
@LazySingleton(as: CalculatorRepository)
class CalculatorRepositoryImpl implements CalculatorRepository {
  final CalculatorLocalDataSource _localDataSource;
  final FirebaseAnalyticsService _analyticsService;

  CalculatorRepositoryImpl(
    this._localDataSource,
  ) : _analyticsService = FirebaseAnalyticsService();

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
    final startTime = DateTime.now();
    
    try {
      await _analyticsService.logEvent(
        'calculator_repository_execution_start',
        parameters: {
          'calculator_id': calculatorId,
          'input_count': inputs.length,
          'timestamp': startTime.toIso8601String(),
        },
      );
      
      final calculator = await _localDataSource.getCalculatorById(calculatorId);
      if (calculator == null) {
        await _analyticsService.logEvent(
          'calculator_not_found',
          parameters: {
            'calculator_id': calculatorId,
          },
        );
        return const Left(NotFoundFailure('Calculadora não encontrada'));
      }
      final result = calculator.executeCalculation(inputs);
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      await _analyticsService.logEvent(
        'calculator_repository_execution_success',
        parameters: {
          'calculator_id': calculatorId,
          'duration_ms': duration,
          'result_count': result.results.length,
          'is_valid': result.isValid,
        },
      );
      await _storePerformanceMetric(
        'calculation_execution',
        calculatorId,
        duration,
      );
      
      return Right(result);
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      await _analyticsService.logEvent(
        'calculator_repository_execution_error',
        parameters: {
          'calculator_id': calculatorId,
          'error': e.toString(),
          'duration_ms': duration,
          'stack_trace': stackTrace.toString().substring(0, 500), // Limit stack trace
        },
      );
      
      debugPrint('CalculatorRepositoryImpl: Erro na execução - $e');
      debugPrint('StackTrace: $stackTrace');
      
      return Left(ServerFailure('Erro no cálculo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CalculationHistory>>> getCalculationHistory() async {
    final startTime = DateTime.now();
    
    try {
      final history = await _localDataSource.getCalculationHistory();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      await _analyticsService.logEvent(
        'calculation_history_loaded',
        parameters: {
          'history_count': history.length,
          'duration_ms': duration,
        },
      );
      
      return Right(history);
    } catch (e, stackTrace) {
      await _analyticsService.logEvent(
        'calculation_history_load_error',
        parameters: {
          'error': e.toString(),
        },
      );
      
      debugPrint('CalculatorRepositoryImpl: Erro ao carregar histórico - $e');
      debugPrint('StackTrace: $stackTrace');
      
      return Left(CacheFailure('Erro ao carregar histórico: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCalculationToHistory(
    CalculationHistory historyItem,
  ) async {
    final startTime = DateTime.now();
    
    try {
      await _localDataSource.saveCalculationToHistory(historyItem);
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      await _analyticsService.logEvent(
        'calculation_history_saved',
        parameters: {
          'calculator_id': historyItem.calculatorId,
          'user_id': historyItem.userId,
          'duration_ms': duration,
          'has_notes': historyItem.notes != null,
          'tag_count': historyItem.tags?.length ?? 0,
        },
      );
      
      return const Right(unit);
    } catch (e, stackTrace) {
      await _analyticsService.logEvent(
        'calculation_history_save_error',
        parameters: {
          'calculator_id': historyItem.calculatorId,
          'user_id': historyItem.userId,
          'error': e.toString(),
        },
      );
      
      debugPrint('CalculatorRepositoryImpl: Erro ao salvar histórico - $e');
      debugPrint('StackTrace: $stackTrace');
      
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
  
  /// Store performance metrics for monitoring
  Future<void> _storePerformanceMetric(
    String operation,
    String calculatorId,
    int durationMs,
  ) async {
    try {
      // TODO: Implement performance metrics storage with Drift
      // final metricKey = 'performance_${operation}_$calculatorId';
      // final metric = {
      //   'operation': operation,
      //   'calculator_id': calculatorId,
      //   'duration_ms': durationMs,
      //   'timestamp': DateTime.now().toIso8601String(),
      // };
      // await _hiveStorageService.put(
      //   box: 'performance_metrics',
      //   key: metricKey,
      //   data: metric,
      // );
    } catch (e) {
      debugPrint('Error storing performance metric: $e');
    }
  }
}
