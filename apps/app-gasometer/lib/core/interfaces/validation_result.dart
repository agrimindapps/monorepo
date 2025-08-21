/// Resultado de validação com suporte para mensagens de erro e aviso
/// Usado em todo o sistema de validação do app
class ValidationResult {
  final bool isValid;
  final String message;
  final ValidationSeverity severity;

  const ValidationResult._({
    required this.isValid,
    required this.message,
    required this.severity,
  });

  /// Creates a successful validation result
  factory ValidationResult.success() {
    return const ValidationResult._(
      isValid: true,
      message: '',
      severity: ValidationSeverity.none,
    );
  }

  /// Creates an error validation result
  factory ValidationResult.error(String message) {
    return ValidationResult._(
      isValid: false,
      message: message,
      severity: ValidationSeverity.error,
    );
  }

  /// Creates a warning validation result (valid but with warning)
  factory ValidationResult.warning(String message) {
    return ValidationResult._(
      isValid: true,
      message: message,
      severity: ValidationSeverity.warning,
    );
  }

  /// Creates an info validation result
  factory ValidationResult.info(String message) {
    return ValidationResult._(
      isValid: true,
      message: message,
      severity: ValidationSeverity.info,
    );
  }

  /// Check if result has a warning
  bool get isWarning => severity == ValidationSeverity.warning;

  /// Check if result has an error
  bool get isError => severity == ValidationSeverity.error;

  /// Check if result has info
  bool get isInfo => severity == ValidationSeverity.info;

  /// Check if result has any message
  bool get hasMessage => message.isNotEmpty;

  /// Combines multiple validation results
  /// Returns first error found, or first warning if no errors, or success
  static ValidationResult combine(List<ValidationResult> results) {
    // Find first error
    for (final result in results) {
      if (!result.isValid) {
        return result;
      }
    }

    // Find first warning
    for (final result in results) {
      if (result.isWarning) {
        return result;
      }
    }

    // All successful
    return ValidationResult.success();
  }

  /// Combines multiple validation results into a list of all messages
  static ValidationResult combineAll(List<ValidationResult> results) {
    final errors = <String>[];
    final warnings = <String>[];
    final infos = <String>[];

    for (final result in results) {
      if (result.isError && result.message.isNotEmpty) {
        errors.add(result.message);
      } else if (result.isWarning && result.message.isNotEmpty) {
        warnings.add(result.message);
      } else if (result.isInfo && result.message.isNotEmpty) {
        infos.add(result.message);
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.error(errors.join(', '));
    } else if (warnings.isNotEmpty) {
      return ValidationResult.warning(warnings.join(', '));
    } else if (infos.isNotEmpty) {
      return ValidationResult.info(infos.join(', '));
    }

    return ValidationResult.success();
  }

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, message: "$message", severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationResult &&
        other.isValid == isValid &&
        other.message == message &&
        other.severity == severity;
  }

  @override
  int get hashCode {
    return isValid.hashCode ^ message.hashCode ^ severity.hashCode;
  }
}

/// Severity levels for validation results
enum ValidationSeverity {
  none,
  info,
  warning,
  error,
}

/// Extensions for ValidationSeverity
extension ValidationSeverityExtension on ValidationSeverity {
  /// Get display name for severity
  String get displayName {
    switch (this) {
      case ValidationSeverity.none:
        return 'None';
      case ValidationSeverity.info:
        return 'Info';
      case ValidationSeverity.warning:
        return 'Warning';
      case ValidationSeverity.error:
        return 'Error';
    }
  }

  /// Get icon for severity
  String get icon {
    switch (this) {
      case ValidationSeverity.none:
        return '';
      case ValidationSeverity.info:
        return 'ℹ️';
      case ValidationSeverity.warning:
        return '⚠️';
      case ValidationSeverity.error:
        return '❌';
    }
  }
}