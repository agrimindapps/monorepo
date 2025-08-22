import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/calculation_result.dart';
import '../entities/calculation_history.dart';
import '../repositories/calculator_repository.dart';

/// Parâmetros para execução de cálculo
class ExecuteCalculationParams {
  final String calculatorId;
  final Map<String, dynamic> inputs;
  final bool saveToHistory;
  final String? userId;
  final String? notes;
  final Map<String, String>? tags;

  const ExecuteCalculationParams({
    required this.calculatorId,
    required this.inputs,
    this.saveToHistory = false,
    this.userId,
    this.notes,
    this.tags,
  });
}

class ExecuteCalculation {
  final CalculatorRepository repository;

  ExecuteCalculation(this.repository);

  /// Executa cálculo simples sem parâmetros
  Future<Either<Failure, CalculationResult>> call(
    String calculatorId,
    Map<String, dynamic> inputs,
  ) async {
    return await repository.executeCalculation(calculatorId, inputs);
  }

  /// Executa cálculo com parâmetros completos
  Future<Either<Failure, CalculationResult>> execute(
    ExecuteCalculationParams params,
  ) async {
    return await repository.executeCalculation(
      params.calculatorId,
      params.inputs,
    );
  }
}

class ExecuteCalculationWithHistory {
  final CalculatorRepository repository;

  ExecuteCalculationWithHistory(this.repository);

  Future<Either<Failure, CalculationResult>> call({
    required String calculatorId,
    required String calculatorName,
    required String userId,
    required Map<String, dynamic> inputs,
    String? notes,
    Map<String, String>? tags,
  }) async {
    // Executa o cálculo
    final calculationResult = await repository.executeCalculation(
      calculatorId,
      inputs,
    );

    return calculationResult.fold(
      (failure) => Left(failure),
      (result) async {
        // Se o cálculo foi bem-sucedido, salva no histórico
        if (result.isValid) {
          final history = CalculationHistory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            calculatorId: calculatorId,
            calculatorName: calculatorName,
            createdAt: DateTime.now(),
            result: result,
            notes: notes,
            tags: tags,
          );

          final saveResult = await repository.saveCalculationToHistory(history);
          
          // Mesmo se falhar ao salvar no histórico, retorna o resultado do cálculo
          saveResult.fold(
            (failure) => {
              // Log do erro, mas não falha a operação principal
            },
            (_) => {},
          );
        }

        return Right(result);
      },
    );
  }
}