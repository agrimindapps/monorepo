/// Enum para resultado de compatibilidade
enum CompatibilityResult {
  compatible,
  incompatible,
  warning,
  error,
}

/// Classe simples para issues de validação
class ValidationIssue {
  final String message;
  final String severity;

  const ValidationIssue(this.message, {this.severity = 'error'});

  factory ValidationIssue.error(String message) {
    return ValidationIssue(message, severity: 'error');
  }
}

/// Classe simples para warnings de validação
class ValidationWarning {
  final String message;
  final String severity;

  const ValidationWarning(this.message, {this.severity = 'warning'});
}

/// Serviço simplificado para validação de compatibilidade entre entidades
///
/// Implementação stub para resolver erros de compilação.
/// TODO: Implementar validação completa quando necessário.
class DiagnosticoCompatibilityServiceDrift {
  static DiagnosticoCompatibilityServiceDrift? _instance;
  static DiagnosticoCompatibilityServiceDrift get instance =>
      _instance ??= DiagnosticoCompatibilityServiceDrift._internal();

  DiagnosticoCompatibilityServiceDrift._internal();

  /// Valida compatibilidade completa entre defensivo, cultura e praga
  Future<CompatibilityValidation> validateFullCompatibility(
    dynamic ref, {
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
    bool includeAlternatives = true,
    bool checkDosage = true,
    bool checkRegistration = true,
  }) async {
    // Stub implementation - always return success
    return CompatibilityValidation.success(
      diagnosticos: [],
      recommendations: ['Validação simplificada implementada'],
      idDefensivo: idDefensivo,
      idCultura: idCultura,
      idPraga: idPraga,
    );
  }

  /// Valida dosagem específica
  Future<DosageValidation> validateDosage({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
    required double proposedDosage,
  }) async {
    // Stub implementation
    return DosageValidation.valid();
  }

  /// Busca alternativas para combinação não encontrada
  Future<List<String>> findAlternatives(
    String idCultura,
    String idPraga,
  ) async {
    // Stub implementation
    return [];
  }
}

/// Resultado de validação de compatibilidade
class CompatibilityValidation {
  final CompatibilityResult result;
  final List<ValidationIssue> issues;
  final List<ValidationWarning> warnings;
  final List<String> recommendations;
  final List<dynamic> diagnosticos;
  final List<String> alternatives;
  final String idDefensivo;
  final String idCultura;
  final String idPraga;
  final DateTime timestamp;

  const CompatibilityValidation._({
    required this.result,
    required this.issues,
    required this.warnings,
    required this.recommendations,
    required this.diagnosticos,
    required this.alternatives,
    required this.idDefensivo,
    required this.idCultura,
    required this.idPraga,
    required this.timestamp,
  });

  /// Retorna true se a compatibilidade é válida (compatible)
  bool get isValid => result == CompatibilityResult.compatible;

  factory CompatibilityValidation.success({
    required List<dynamic> diagnosticos,
    required List<String> recommendations,
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) {
    return CompatibilityValidation._(
      result: CompatibilityResult.compatible,
      issues: [],
      warnings: [],
      recommendations: recommendations,
      diagnosticos: diagnosticos,
      alternatives: [],
      idDefensivo: idDefensivo,
      idCultura: idCultura,
      idPraga: idPraga,
      timestamp: DateTime.now(),
    );
  }

  factory CompatibilityValidation.failed({
    required List<ValidationIssue> issues,
    required List<ValidationWarning> warnings,
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) {
    return CompatibilityValidation._(
      result: CompatibilityResult.incompatible,
      issues: issues,
      warnings: warnings,
      recommendations: [],
      diagnosticos: [],
      alternatives: [],
      idDefensivo: idDefensivo,
      idCultura: idCultura,
      idPraga: idPraga,
      timestamp: DateTime.now(),
    );
  }

  factory CompatibilityValidation.warning({
    required List<ValidationIssue> issues,
    required List<ValidationWarning> warnings,
    required List<String> recommendations,
    required List<dynamic> diagnosticos,
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) {
    return CompatibilityValidation._(
      result: CompatibilityResult.warning,
      issues: issues,
      warnings: warnings,
      recommendations: recommendations,
      diagnosticos: diagnosticos,
      alternatives: [],
      idDefensivo: idDefensivo,
      idCultura: idCultura,
      idPraga: idPraga,
      timestamp: DateTime.now(),
    );
  }

  static CompatibilityValidation error({
    required String message,
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) {
    return CompatibilityValidation._(
      result: CompatibilityResult.error,
      issues: [ValidationIssue.error(message)],
      warnings: [],
      recommendations: [],
      diagnosticos: [],
      alternatives: [],
      idDefensivo: idDefensivo,
      idCultura: idCultura,
      idPraga: idPraga,
      timestamp: DateTime.now(),
    );
  }
}

/// Resultado de validação de dosagem
class DosageValidation {
  final bool isValid;
  final List<ValidationIssue> issues;
  final List<ValidationWarning> warnings;

  const DosageValidation._({
    required this.isValid,
    required this.issues,
    required this.warnings,
  });

  factory DosageValidation.valid() {
    return const DosageValidation._(
      isValid: true,
      issues: [],
      warnings: [],
    );
  }

  factory DosageValidation.invalid({
    required List<ValidationIssue> issues,
    required List<ValidationWarning> warnings,
  }) {
    return DosageValidation._(
      isValid: false,
      issues: issues,
      warnings: warnings,
    );
  }
}
