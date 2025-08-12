// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../errors/gasometer_exceptions.dart';
import '../services/error_handler.dart';
import '../services/error_recovery.dart';
import '../types/result.dart';

/// Helper utilities para facilitar adoção do novo sistema de error handling
/// nos controllers e UI components
class ErrorHandlingHelper {
  
  // MARK: - Controller Helpers

  /// Executa operação com tratamento de erro completo
  /// 
  /// Ideal para uso em controllers GetX
  static Future<T?> safeExecute<T>({
    required Future<GasometerResult<T>> Function() operation,
    String? operationName,
    VoidCallback? onLoading,
    VoidCallback? onSuccess,
    Function(String)? onError,
    bool showSnackbar = true,
    bool useRetry = false,
    bool useCircuitBreaker = false,
    String? circuitBreakerKey,
    T? fallbackValue,
  }) async {
    try {
      onLoading?.call();
      
      var future = operation();
      
      // Aplica retry se solicitado
      if (useRetry) {
        future = future.withRetry(operationName: operationName);
      }
      
      // Aplica circuit breaker se solicitado
      if (useCircuitBreaker && circuitBreakerKey != null) {
        future = future.withCircuitBreaker(operationKey: circuitBreakerKey);
      }
      
      final result = await future;
      
      if (result.isSuccess) {
        onSuccess?.call();
        return result.data;
      } else {
        final error = result.error;
        final userMessage = GasometerErrorHandler.instance.formatUserMessage(error);
        
        onError?.call(userMessage);
        
        if (showSnackbar) {
          showErrorSnackbar(userMessage);
        }
        
        return fallbackValue;
      }
    } catch (e) {
      const userMessage = 'Erro inesperado. Tente novamente.';
      onError?.call(userMessage);
      
      if (showSnackbar) {
        showErrorSnackbar(userMessage);
      }
      
      return fallbackValue;
    }
  }

  /// Wrapper para operações que retornam bool (legado)
  static Future<bool> safeBoolOperation({
    required Future<GasometerResult<bool>> Function() operation,
    String? operationName,
    String? successMessage,
    bool showSnackbar = true,
  }) async {
    final result = await safeExecute(
      operation: operation,
      operationName: operationName,
      showSnackbar: showSnackbar,
      fallbackValue: false,
    );
    
    if (result == true && successMessage != null && showSnackbar) {
      showSuccessSnackbar(successMessage);
    }
    
    return result ?? false;
  }

  /// Wrapper para operações que retornam String? (legado)
  static Future<String?> safeStringOperation({
    required Future<GasometerResult<String?>> Function() operation,
    String? operationName,
    bool showSnackbar = true,
  }) async {
    final result = await operation();
    
    if (result.isSuccess) {
      return result.data;
    } else {
      if (showSnackbar) {
        final userMessage = GasometerErrorHandler.instance.formatUserMessage(result.error);
        showErrorSnackbar(userMessage);
      }
      return null;
    }
  }

  // MARK: - UI Helpers

  /// Mostra snackbar de erro padronizado
  static void showErrorSnackbar(String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        'Erro',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.red),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Mostra snackbar de sucesso padronizado
  static void showSuccessSnackbar(String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        'Sucesso',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Mostra snackbar de aviso
  static void showWarningSnackbar(String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        'Aviso',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        icon: const Icon(Icons.warning_outlined, color: Colors.orange),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Widget builder que trata estados de loading e erro
  static Widget resultBuilder<T>({
    required GasometerResult<T>? result,
    required Widget Function(T data) onSuccess,
    Widget? onLoading,
    Widget Function(GasometerException error)? onError,
    Widget? onEmpty,
  }) {
    if (result == null) {
      return onLoading ?? const Center(child: CircularProgressIndicator());
    }

    if (result.isSuccess) {
      return onSuccess(result.data);
    } else {
      final error = result.error;
      
      if (onError != null) {
        return onError(error);
      }
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              GasometerErrorHandler.instance.formatUserMessage(error),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }

  // MARK: - Migration Helpers

  /// Converte operação legada que retorna null em caso de erro
  static GasometerResult<T> fromNullableOperation<T>(
    T? result, {
    String? operationName,
    String? errorMessage,
  }) {
    if (result != null) {
      return GasometerResult.success(result);
    } else {
      return GasometerResult.failure(
        GenericGasometerException(
          errorMessage ?? 'Operação falhou',
          operation: operationName,
        ),
      );
    }
  }

  /// Converte operação legada que retorna String? como erro
  static GasometerResult<bool> fromStringErrorOperation(
    String? errorResult, {
    String? operationName,
  }) {
    if (errorResult == null) {
      return const GasometerResult.success(true);
    } else {
      return GasometerResult.failure(
        GenericGasometerException(
          errorResult,
          operation: operationName,
        ),
      );
    }
  }

  /// Converte Future que pode lançar exception
  static Future<GasometerResult<T>> fromThrowingOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      final result = await operation();
      return GasometerResult.success(result);
    } catch (e) {
      final wrappedException = wrapException(
        e is Exception ? e : Exception(e.toString()),
        operation: operationName,
      );
      
      return GasometerResult.failure(wrappedException);
    }
  }

  // MARK: - Validation Helpers

  /// Valida e cria Result baseado em condições
  static GasometerResult<T> validate<T>({
    required T value,
    required List<ValidationRule<T>> rules,
    String? operationName,
  }) {
    for (final rule in rules) {
      if (!rule.isValid(value)) {
        return GasometerResult.failure(
          GenericGasometerException(
            rule.errorMessage,
            operation: operationName,
          ),
        );
      }
    }
    
    return GasometerResult.success(value);
  }
}

/// Regra de validação
class ValidationRule<T> {
  final bool Function(T value) isValid;
  final String errorMessage;
  
  const ValidationRule({
    required this.isValid,
    required this.errorMessage,
  });
}

// MARK: - Extension Methods para facilitar uso

/// Extensions para controllers GetX
extension GetControllerErrorHandling on GetxController {
  /// Executa operação com loading state automático
  Future<T?> executeWithLoading<T>({
    required Future<GasometerResult<T>> Function() operation,
    String? operationName,
    RxBool? loadingState,
    bool showSnackbar = true,
  }) async {
    loadingState?.value = true;
    
    try {
      return await ErrorHandlingHelper.safeExecute(
        operation: operation,
        operationName: operationName,
        showSnackbar: showSnackbar,
      );
    } finally {
      loadingState?.value = false;
    }
  }
}

/// Extensions para Widget
extension WidgetErrorHandling on Widget {
  /// Envolve widget com tratamento de erro
  Widget handleErrors({
    required GasometerResult? result,
    Widget? onLoading,
    Widget Function(GasometerException error)? onError,
  }) {
    return ErrorHandlingHelper.resultBuilder(
      result: result,
      onSuccess: (_) => this,
      onLoading: onLoading,
      onError: onError,
    );
  }
}