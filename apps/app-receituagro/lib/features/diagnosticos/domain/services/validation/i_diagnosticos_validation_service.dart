import 'package:core/core.dart';

import '../../entities/diagnostico_entity.dart';

/// Interface for validation operations on diagnosticos
/// Follows Single Responsibility Principle (SOLID)
///
/// This service handles all validation logic including
/// existence checks, compatibility verification, and
/// completeness validation.
abstract class IDiagnosticosValidationService {
  /// Check if a diagnostico exists by ID
  ///
  /// Useful for:
  /// - Pre-validation before operations
  /// - Existence checks in forms
  /// - Navigation guards
  ///
  /// Returns true if diagnostico exists, false otherwise.
  Future<Either<Failure, bool>> exists(String id);

  /// Validate compatibility between defensivo, cultura, and praga
  ///
  /// Checks if the combination is valid and registered in the system.
  /// This is useful for:
  /// - Form validation
  /// - Pre-submission checks
  /// - Business rule enforcement
  ///
  /// Returns true if combination exists, false otherwise.
  Future<Either<Failure, bool>> validateCompatibility({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  });

  /// Validate completeness of a diagnostico entity
  ///
  /// Checks if diagnostico has all required information:
  /// - Valid IDs for defensivo, cultura, praga
  /// - Name information available
  /// - Valid dosage data
  /// - Valid application data
  ///
  /// Returns validation result with details about missing/invalid fields.
  Either<Failure, DiagnosticoValidationResult> validateDiagnosticoCompleteness(
    DiagnosticoEntity diagnostico,
  );

  /// Validate dosage range values
  ///
  /// Checks if dosage range is valid:
  /// - Both values are positive
  /// - Minimum is less than maximum
  /// - Values are within reasonable bounds
  ///
  /// Returns true if range is valid, false otherwise.
  Either<Failure, bool> validateDosageRange({
    required double min,
    required double max,
  });
}

/// Value object for diagnostico validation result
class DiagnosticoValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final DiagnosticoCompletude completude;

  const DiagnosticoValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.completude,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  factory DiagnosticoValidationResult.valid({
    List<String> warnings = const [],
  }) {
    return DiagnosticoValidationResult(
      isValid: true,
      errors: const [],
      warnings: warnings,
      completude: DiagnosticoCompletude.completo,
    );
  }

  factory DiagnosticoValidationResult.invalid({
    required List<String> errors,
    List<String> warnings = const [],
    DiagnosticoCompletude completude = DiagnosticoCompletude.incompleto,
  }) {
    return DiagnosticoValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
      completude: completude,
    );
  }
}
