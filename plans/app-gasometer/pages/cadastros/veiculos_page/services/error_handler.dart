// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/veiculos_page_constants.dart';
import 'error_sanitizer.dart' as sanitizer;

// Flutter

// External packages

// Local imports

/// Enum for categorizing error types
enum ErrorType { network, validation, business, system, repository, unknown }

/// Enum for error severity levels
enum ErrorSeverity { low, medium, high, critical }

/// Class to represent a structured error with context
class StructuredError {
  final ErrorType type;
  final ErrorSeverity severity;
  final String technicalMessage;
  final String userMessage;
  final String? context;
  final String? suggestedAction;
  final Exception? originalException;

  const StructuredError({
    required this.type,
    required this.severity,
    required this.technicalMessage,
    required this.userMessage,
    this.context,
    this.suggestedAction,
    this.originalException,
  });
}

/// Centralized error handler for VeiculosPage
class VeiculosErrorHandler {
  static const String _logTag = 'VeiculosErrorHandler';

  /// Handle error with context and return structured error
  static StructuredError handleError(
    Exception exception,
    String context, {
    ErrorType? forceType,
  }) {
    // Use ErrorSanitizer for secure error handling
    final sanitizedError = sanitizer.ErrorSanitizer.sanitizeForUser(
      exception,
      context: context,
      severity: _mapErrorSeverity(forceType ?? _categorizeError(exception)),
    );

    final structuredError = StructuredError(
      type: forceType ?? _categorizeError(exception),
      severity: _mapToStructuredSeverity(sanitizedError.severity),
      technicalMessage: exception.toString(),
      userMessage: sanitizedError.userMessage,
      context: context,
      suggestedAction:
          _getSuggestedAction(forceType ?? _categorizeError(exception)),
      originalException: exception,
    );

    // Log error with appropriate level
    _logError(structuredError);

    return structuredError;
  }

  /// Categorize error based on exception type and message
  static ErrorType _categorizeError(Exception exception) {
    final message = exception.toString().toLowerCase();

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('socket')) {
      return ErrorType.network;
    }

    if (message.contains('validation') ||
        message.contains('invalid') ||
        message.contains('required') ||
        message.contains('format')) {
      return ErrorType.validation;
    }

    if (message.contains('limite') ||
        message.contains('negócio') ||
        message.contains('business') ||
        message.contains('regra')) {
      return ErrorType.business;
    }

    if (message.contains('repository') ||
        message.contains('database') ||
        message.contains('hive') ||
        message.contains('storage')) {
      return ErrorType.repository;
    }

    if (message.contains('system') ||
        message.contains('memory') ||
        message.contains('null')) {
      return ErrorType.system;
    }

    return ErrorType.unknown;
  }

  /// Create structured error with appropriate messages and actions
  static StructuredError _createStructuredError(
    Exception exception,
    String context,
    ErrorType type,
  ) {
    switch (type) {
      case ErrorType.network:
        return StructuredError(
          type: type,
          severity: ErrorSeverity.medium,
          technicalMessage:
              'Network error in $context: ${exception.toString()}',
          userMessage:
              'Erro de conexão. Verifique sua internet e tente novamente.',
          context: context,
          suggestedAction: 'Tentar novamente',
          originalException: exception,
        );

      case ErrorType.validation:
        return StructuredError(
          type: type,
          severity: ErrorSeverity.low,
          technicalMessage:
              'Validation error in $context: ${exception.toString()}',
          userMessage: 'Dados inválidos. Verifique as informações inseridas.',
          context: context,
          suggestedAction: 'Corrigir dados',
          originalException: exception,
        );

      case ErrorType.business:
        return StructuredError(
          type: type,
          severity: ErrorSeverity.medium,
          technicalMessage:
              'Business rule error in $context: ${exception.toString()}',
          userMessage: 'Operação não permitida pelas regras de negócio.',
          context: context,
          suggestedAction: 'Revisar operação',
          originalException: exception,
        );

      case ErrorType.repository:
        return StructuredError(
          type: type,
          severity: ErrorSeverity.high,
          technicalMessage:
              'Repository error in $context: ${exception.toString()}',
          userMessage:
              'Erro ao acessar dados. Tente novamente em alguns instantes.',
          context: context,
          suggestedAction: 'Tentar novamente',
          originalException: exception,
        );

      case ErrorType.system:
        return StructuredError(
          type: type,
          severity: ErrorSeverity.critical,
          technicalMessage: 'System error in $context: ${exception.toString()}',
          userMessage:
              'Erro interno do sistema. Entre em contato com o suporte.',
          context: context,
          suggestedAction: 'Contatar suporte',
          originalException: exception,
        );

      case ErrorType.unknown:
        return StructuredError(
          type: ErrorType.unknown,
          severity: ErrorSeverity.medium,
          technicalMessage:
              'Unknown error in $context: ${exception.toString()}',
          userMessage: 'Erro inesperado. Tente novamente.',
          context: context,
          suggestedAction: 'Tentar novamente',
          originalException: exception,
        );
    }
  }

  /// Log error with appropriate level based on severity
  static void _logError(StructuredError error) {
    final logMessage = '[$_logTag] ${error.context}: ${error.technicalMessage}';

    switch (error.severity) {
      case ErrorSeverity.low:
        debugPrint('[INFO] $logMessage');
        break;
      case ErrorSeverity.medium:
        debugPrint('[WARNING] $logMessage');
        break;
      case ErrorSeverity.high:
        debugPrint('[ERROR] $logMessage');
        // Para erros altos, sempre mostra no console
        // ignore: avoid_print
        debugPrint('[ERROR] $logMessage');
        break;
      case ErrorSeverity.critical:
        debugPrint('[CRITICAL] $logMessage');
        // Para erros críticos, sempre mostra no console
        // ignore: avoid_print
        debugPrint('[CRITICAL] $logMessage');
        // In production, this should also go to crash reporting
        break;
    }
  }

  /// Show user-friendly error message with optional retry action
  static void showErrorToUser(
    StructuredError error, {
    VoidCallback? onRetry,
  }) {
    Get.snackbar(
      _getErrorTitle(error.type),
      error.userMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _getErrorColor(error.severity),
      colorText: Get.theme.colorScheme.onError,
      duration: error.severity == ErrorSeverity.critical
          ? VeiculosPageConstants.snackbarCriticalDuration
          : VeiculosPageConstants.snackbarNormalDuration,
      mainButton: error.suggestedAction != null && onRetry != null
          ? TextButton(
              onPressed: onRetry,
              child: Text(
                error.suggestedAction!,
                style: TextStyle(
                  color: Get.theme.colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  /// Get appropriate title for error type
  static String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Erro de Conexão';
      case ErrorType.validation:
        return 'Dados Inválidos';
      case ErrorType.business:
        return 'Operação não Permitida';
      case ErrorType.repository:
        return 'Erro de Dados';
      case ErrorType.system:
        return 'Erro do Sistema';
      case ErrorType.unknown:
        return 'Erro';
    }
  }

  /// Get appropriate color for error severity
  static Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Get.theme.colorScheme.primary
            .withValues(alpha: VeiculosPageConstants.highOpacity);
      case ErrorSeverity.medium:
        return Get.theme.colorScheme.secondary
            .withValues(alpha: VeiculosPageConstants.highOpacity);
      case ErrorSeverity.high:
        return Get.theme.colorScheme.error
            .withValues(alpha: VeiculosPageConstants.highOpacity);
      case ErrorSeverity.critical:
        return Get.theme.colorScheme.error;
    }
  }

  /// Create specific error handlers for common scenarios

  /// Handle vehicle loading errors
  static StructuredError handleVehicleLoadError(Exception exception) {
    return handleError(exception, 'Carregamento de veículos');
  }

  /// Handle vehicle creation errors
  static StructuredError handleVehicleCreateError(Exception exception) {
    return handleError(exception, 'Criação de veículo');
  }

  /// Handle vehicle update errors
  static StructuredError handleVehicleUpdateError(Exception exception) {
    return handleError(exception, 'Atualização de veículo');
  }

  /// Handle vehicle deletion errors
  static StructuredError handleVehicleDeleteError(Exception exception) {
    return handleError(exception, 'Remoção de veículo');
  }

  /// Handle CSV export errors
  static StructuredError handleExportError(Exception exception) {
    return handleError(exception, 'Exportação CSV');
  }

  /// Handle dependency injection errors
  static StructuredError handleDependencyError(Exception exception) {
    return handleError(exception, 'Inicialização de dependências',
        forceType: ErrorType.system);
  }

  /// Handle odometer update errors
  static StructuredError handleOdometerUpdateError(Exception exception) {
    return handleError(exception, 'Atualização de odômetro');
  }

  /// Map ErrorType to ErrorSanitizer severity
  static sanitizer.ErrorSeverity _mapErrorSeverity(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.validation:
        return sanitizer.ErrorSeverity.low;
      case ErrorType.network:
      case ErrorType.business:
        return sanitizer.ErrorSeverity.medium;
      case ErrorType.repository:
      case ErrorType.system:
        return sanitizer.ErrorSeverity.high;
      case ErrorType.unknown:
        return sanitizer.ErrorSeverity.medium;
    }
  }

  /// Map ErrorSanitizer severity to structured severity
  static ErrorSeverity _mapToStructuredSeverity(
      sanitizer.ErrorSeverity sanitizerSeverity) {
    switch (sanitizerSeverity) {
      case sanitizer.ErrorSeverity.low:
        return ErrorSeverity.low;
      case sanitizer.ErrorSeverity.medium:
        return ErrorSeverity.medium;
      case sanitizer.ErrorSeverity.high:
        return ErrorSeverity.high;
      case sanitizer.ErrorSeverity.critical:
        return ErrorSeverity.critical;
    }
  }

  /// Get suggested action based on error type
  static String _getSuggestedAction(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return 'Verificar conexão e tentar novamente';
      case ErrorType.validation:
        return 'Corrigir os dados inseridos';
      case ErrorType.business:
        return 'Revisar a operação ou entrar em contato com o suporte';
      case ErrorType.repository:
        return 'Tentar novamente em alguns instantes';
      case ErrorType.system:
        return 'Reiniciar o aplicativo ou entrar em contato com o suporte';
      case ErrorType.unknown:
        return 'Tentar novamente';
    }
  }
}
