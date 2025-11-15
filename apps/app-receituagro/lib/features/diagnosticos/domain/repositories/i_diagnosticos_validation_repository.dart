import 'package:core/core.dart' hide Column;

/// Repository for validation operations
///
/// Responsibilities:
/// - Check if diagnostico exists
/// - Validate compatibility of defensivo-cultura-praga combination
///
/// Used by DiagnosticosValidationService for business logic validation.
///
/// Part of the Interface Segregation Principle refactoring.
abstract class IDiagnosticosValidationRepository {
  /// Verificar se diagnóstico existe
  ///
  /// Returns true if a diagnostico with the given ID exists.
  Future<Either<Failure, bool>> exists(String id);

  /// Validar compatibilidade de combinação
  ///
  /// Validates that the defensivo-cultura-praga combination is valid.
  /// Returns true if at least one diagnostico exists with this combination.
  Future<Either<Failure, bool>> validarCompatibilidade({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  });
}
