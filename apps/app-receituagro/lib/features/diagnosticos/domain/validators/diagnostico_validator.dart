import '../entities/diagnostico_entity.dart';

/// Validador para DiagnosticoEntity
/// Extrai toda lógica de validação da entity
/// Segue Single Responsibility Principle (SOLID)
class DiagnosticoValidator {
  const DiagnosticoValidator._();

  /// Valida se diagnóstico tem todos os IDs obrigatórios
  static bool isValid(DiagnosticoEntity diagnostico) {
    return diagnostico.id.isNotEmpty &&
        diagnostico.idDefensivo.isNotEmpty &&
        diagnostico.idCultura.isNotEmpty &&
        diagnostico.idPraga.isNotEmpty;
  }

  /// Verifica se tem informações de defensivo
  static bool hasDefensivoInfo(DiagnosticoEntity diagnostico) {
    return diagnostico.nomeDefensivo?.isNotEmpty == true;
  }

  /// Verifica se tem informações de cultura
  static bool hasCulturaInfo(DiagnosticoEntity diagnostico) {
    return diagnostico.nomeCultura?.isNotEmpty == true;
  }

  /// Verifica se tem informações de praga
  static bool hasPragaInfo(DiagnosticoEntity diagnostico) {
    return diagnostico.nomePraga?.isNotEmpty == true;
  }

  /// Verifica se está completo (tem info de defensivo, cultura e praga)
  static bool isComplete(DiagnosticoEntity diagnostico) {
    return hasDefensivoInfo(diagnostico) &&
        hasCulturaInfo(diagnostico) &&
        hasPragaInfo(diagnostico);
  }

  /// Verifica se dosagem é válida
  static bool hasDosagemValida(DiagnosticoEntity diagnostico) {
    return diagnostico.dosagem.isValid;
  }

  /// Verifica se aplicação é válida
  static bool hasAplicacaoValida(DiagnosticoEntity diagnostico) {
    return diagnostico.aplicacao.isValid;
  }

  /// Calcula nível de completude do diagnóstico
  ///
  /// Pontuação:
  /// - 5+ pontos: Completo
  /// - 3-4 pontos: Parcial
  /// - 0-2 pontos: Incompleto
  static DiagnosticoCompletude calculateCompletude(
    DiagnosticoEntity diagnostico,
  ) {
    int score = 0;

    if (hasDefensivoInfo(diagnostico)) score++;
    if (hasCulturaInfo(diagnostico)) score++;
    if (hasPragaInfo(diagnostico)) score++;
    if (hasDosagemValida(diagnostico)) score++;
    if (hasAplicacaoValida(diagnostico)) score++;

    if (score >= 4) return DiagnosticoCompletude.completo;
    if (score >= 3) return DiagnosticoCompletude.parcial;
    return DiagnosticoCompletude.incompleto;
  }
}
