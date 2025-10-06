import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:core/core.dart' hide Failure, ValidationFailure;

import '../entities/calculation_history.dart';
import '../entities/calculation_result.dart';
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
  final FirebaseAnalyticsService _analyticsService;
  final RevenueCatService _revenueCatService;

  ExecuteCalculation(this.repository)
      : _analyticsService = FirebaseAnalyticsService(),
        _revenueCatService = RevenueCatService();

  /// Executa cálculo simples sem parâmetros
  Future<Either<Failure, CalculationResult>> call(
    String calculatorId,
    Map<String, dynamic> inputs,
  ) async {
    final startTime = DateTime.now();
    
    try {
      final isPremiumCalculator = _isPremiumCalculator(calculatorId);
      
      if (isPremiumCalculator) {
        final hasAccessResult = await _revenueCatService.hasActiveSubscription();
        final hasAccess = hasAccessResult.fold((l) => false, (r) => r);
        if (!hasAccess) {
          await _analyticsService.logEvent(
            'premium_calculator_blocked',
            parameters: {
              'calculator_id': calculatorId,
              'input_count': inputs.length,
            },
          );
          return const Left(ValidationFailure(message: 'Esta calculadora requer assinatura premium'));
        }
      }
      await _analyticsService.logEvent(
        'calculation_attempt',
        parameters: {
          'calculator_id': calculatorId,
          'input_count': inputs.length,
          'is_premium': isPremiumCalculator,
        },
      );
      
      final result = await repository.executeCalculation(calculatorId, inputs);
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      await result.fold(
        (failure) async {
          await _analyticsService.logEvent(
            'calculation_failed',
            parameters: {
              'calculator_id': calculatorId,
              'error_type': failure.runtimeType.toString(),
              'duration_ms': duration,
            },
          );
        },
        (calcResult) async {
          await _analyticsService.logEvent(
            'calculation_success',
            parameters: {
              'calculator_id': calculatorId,
              'duration_ms': duration,
              'is_valid': calcResult.isValid,
              'result_count': calcResult.results.length,
            },
          );
        },
      );
      
      return result;
    } catch (e) {
      await _analyticsService.logEvent(
        'calculation_unexpected_error',
        parameters: {
          'calculator_id': calculatorId,
          'error': e.toString(),
        },
      );
      rethrow;
    }
  }
  
  /// Verifica se a calculadora requer acesso premium
  bool _isPremiumCalculator(String calculatorId) {
    const premiumCalculators = {
      'advanced_irrigation',
      'livestock_nutrition_optimizer',
      'yield_prediction_ai',
      'pest_management_advanced',
      'financial_analyzer',
      'weather_impact_calculator',
    };
    return premiumCalculators.contains(calculatorId);
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
  final FirebaseAnalyticsService _analyticsService;
  final RevenueCatService _revenueCatService;

  ExecuteCalculationWithHistory(this.repository)
      : _analyticsService = FirebaseAnalyticsService(),
        _revenueCatService = RevenueCatService();

  Future<Either<Failure, CalculationResult>> call({
    required String calculatorId,
    required String calculatorName,
    required String userId,
    required Map<String, dynamic> inputs,
    String? notes,
    Map<String, String>? tags,
  }) async {
    final startTime = DateTime.now();
    
    try {
      final isPremiumCalculator = _isPremiumCalculator(calculatorId);
      
      if (isPremiumCalculator) {
        final hasAccessResult = await _revenueCatService.hasActiveSubscription();
        final hasAccess = hasAccessResult.fold((l) => false, (r) => r);
        if (!hasAccess) {
          await _analyticsService.logEvent(
            'premium_calculator_blocked_with_history',
            parameters: {
              'calculator_id': calculatorId,
              'calculator_name': calculatorName,
              'user_id': userId,
            },
          );
          return const Left(ValidationFailure(message: 'Esta calculadora requer assinatura premium'));
        }
      }
      await _analyticsService.logEvent(
        'calculation_with_history_attempt',
        parameters: {
          'calculator_id': calculatorId,
          'calculator_name': calculatorName,
          'user_id': userId,
          'input_count': inputs.length,
          'has_notes': notes != null,
          'tag_count': tags?.length ?? 0,
          'is_premium': isPremiumCalculator,
        },
      );
      final calculationResult = await repository.executeCalculation(
        calculatorId,
        inputs,
      );

      return calculationResult.fold(
        (failure) async {
          await _analyticsService.logEvent(
            'calculation_with_history_failed',
            parameters: {
              'calculator_id': calculatorId,
              'error_type': failure.runtimeType.toString(),
              'user_id': userId,
            },
          );
          return Left(failure);
        },
        (result) async {
          final duration = DateTime.now().difference(startTime).inMilliseconds;
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
            await saveResult.fold(
              (failure) async {
                await _analyticsService.logEvent(
                  'calculation_history_save_failed',
                  parameters: {
                    'calculator_id': calculatorId,
                    'user_id': userId,
                    'error_type': failure.runtimeType.toString(),
                  },
                );
              },
              (_) async {
                await _analyticsService.logEvent(
                  'calculation_history_saved',
                  parameters: {
                    'calculator_id': calculatorId,
                    'user_id': userId,
                  },
                );
              },
            );
          }
          await _analyticsService.logEvent(
            'calculation_with_history_success',
            parameters: {
              'calculator_id': calculatorId,
              'calculator_name': calculatorName,
              'user_id': userId,
              'duration_ms': duration,
              'is_valid': result.isValid,
              'result_count': result.results.length,
              'saved_to_history': result.isValid,
            },
          );

          return Right(result);
        },
      );
    } catch (e) {
      await _analyticsService.logEvent(
        'calculation_with_history_unexpected_error',
        parameters: {
          'calculator_id': calculatorId,
          'user_id': userId,
          'error': e.toString(),
        },
      );
      rethrow;
    }
  }
  
  /// Verifica se a calculadora requer acesso premium
  bool _isPremiumCalculator(String calculatorId) {
    const premiumCalculators = {
      'advanced_irrigation',
      'livestock_nutrition_optimizer',
      'yield_prediction_ai',
      'pest_management_advanced',
      'financial_analyzer',
      'weather_impact_calculator',
    };
    return premiumCalculators.contains(calculatorId);
  }
}