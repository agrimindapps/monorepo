import '../../../database/receituagro_database.dart';

/// Wrapper que enriquece Diagnostico (Drift) com dados relacionados e avisos
///
/// Fornece acesso seguro a entidades relacionadas (defensivo, praga, cultura)
/// e lista de avisos quando referências não são encontradas.
///
/// Uso:
/// ```dart
/// final enriched = DiagnosticoWithWarningsDrift(
///   diagnostico: diagnostico,
///   defensivo: fitossanitario,
///   praga: praga,
///   cultura: cultura,
/// );
///
/// if (enriched.hasWarnings) {
///   debugPrint('Avisos: ${enriched.warnings.join(", ")}');
/// }
/// ```
class DiagnosticoWithWarningsDrift {
  /// Dados do diagnóstico original
  final Diagnostico diagnostico;

  /// Entidade relacionada: Defensivo/Fitossanitário
  final Fitossanitario? defensivo;

  /// Entidade relacionada: Praga
  final Praga? praga;

  /// Entidade relacionada: Cultura
  final Cultura? cultura;

  /// Lista de avisos de integridade referencial
  ///
  /// Exemplo: ["Defensivo não encontrado", "Praga não encontrada"]
  final List<String> warnings;

  const DiagnosticoWithWarningsDrift({
    required this.diagnostico,
    this.defensivo,
    this.praga,
    this.cultura,
    List<String>? warnings,
  }) : warnings = warnings ?? const [];

  /// Indica se há avisos de integridade
  bool get hasWarnings => warnings.isNotEmpty;

  /// Indica se todos os dados relacionados foram encontrados
  bool get isComplete => warnings.isEmpty;

  /// Nome do defensivo (com fallback seguro)
  String get nomeDefensivo =>
      defensivo?.nomeComum ?? defensivo?.nome ?? 'Defensivo não encontrado';

  /// Nome técnico do defensivo (com fallback)
  String get nomeTecnicoDefensivo =>
      defensivo?.nome ?? 'Nome técnico não disponível';

  /// Nome da praga (com fallback seguro)
  String get nomePraga => praga?.nome ?? 'Praga não encontrada';

  /// Nome científico da praga (com fallback)
  String get nomeCientificoPraga =>
      praga?.nomeLatino ?? 'Nome científico não disponível';

  /// Nome da cultura (com fallback seguro)
  String get nomeCultura => cultura?.nome ?? 'Cultura não encontrada';

  /// Nome científico da cultura (com fallback)
  String get nomeCientificoCultura =>
      cultura?.nomeLatino ?? 'Nome científico não disponível';

  /// Classe do defensivo (com fallback)
  String get classeDefensivo => defensivo?.classe ?? 'Classe não especificada';

  /// Fabricante do defensivo (com fallback)
  String get fabricanteDefensivo =>
      defensivo?.fabricante ?? 'Fabricante não informado';

  /// Tipo da praga (com fallback)
  String get tipoPraga => praga?.tipo ?? 'Tipo não especificado';

  /// Família da cultura (com fallback)
  String get familiaCultura => cultura?.familia ?? 'Família não especificada';
}
