import 'package:injectable/injectable.dart';

/// Service responsible for onboarding-specific error messages
/// Centralizes error text for i18n readiness and consistency
/// Follows SRP by managing only error message logic
@lazySingleton
class OnboardingErrorMessageService {
  OnboardingErrorMessageService();

  /// Error messages registry
  /// Maps error types to user-friendly messages
  static const Map<String, String> _errorMessages = {
    'load': 'Erro ao carregar onboarding',
    'complete': 'Erro ao completar etapa',
    'skip': 'Erro ao pular etapa',
    'reset': 'Erro ao resetar onboarding',
    'unknown': 'Erro desconhecido no onboarding',
  };

  /// Get error message for loading failures
  /// Used when onboarding data cannot be loaded
  String getLoadError([String? details]) {
    return _formatError('load', details);
  }

  /// Get error message for step completion failures
  /// Used when a step cannot be marked as completed
  String getCompleteStepError([String? details]) {
    return _formatError('complete', details);
  }

  /// Get error message for step skip failures
  /// Used when an optional step cannot be skipped
  String getSkipStepError([String? details]) {
    return _formatError('skip', details);
  }

  /// Get error message for reset failures
  /// Used when onboarding state cannot be reset
  String getResetError([String? details]) {
    return _formatError('reset', details);
  }

  /// Get generic error message with optional details
  /// Fallback for unexpected errors
  String getGenericError([String? details]) {
    return _formatError('unknown', details);
  }

  /// Format error message with optional details
  /// Appends details if provided
  String _formatError(String errorType, String? details) {
    final baseMessage = _errorMessages[errorType] ?? _errorMessages['unknown']!;

    if (details != null && details.isNotEmpty) {
      return '$baseMessage: $details';
    }

    return baseMessage;
  }

  /// Check if an error type is registered
  /// Useful for validation
  bool hasErrorType(String errorType) {
    return _errorMessages.containsKey(errorType);
  }

  /// Get all registered error types
  /// Useful for testing or documentation
  List<String> getRegisteredErrorTypes() {
    return _errorMessages.keys.toList();
  }
}
