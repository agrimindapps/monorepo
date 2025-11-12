
/// Wrapper que enriquece Diagnostico com dados relacionados e avisos
///
/// Fornece acesso seguro a entidades relacionadas (defensivo, praga, cultura)
/// e lista de avisos quando referências não são encontradas.
///
/// Uso:
/// ```dart
/// final enriched = DiagnosticoWithWarnings(
///   data: diagnostico,
///   defensivo: fitossanitario,
///   praga: praga,
///   cultura: cultura,
/// );
///
/// if (enriched.hasWarnings) {
///   print('Avisos: ${enriched.warnings.join(", ")}');
/// }
/// ```
class DiagnosticoWithWarnings {
  /// Dados do diagnóstico original
  final Diagnostico data;

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

  const DiagnosticoWithWarnings({
    required this.data,
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
      defensivo?.nomeComum ?? data.nomeDefensivo ?? 'Defensivo não encontrado';

  /// Nome técnico do defensivo (com fallback)
  String get nomeTecnicoDefensivo =>
      defensivo?.nomeTecnico ?? 'Nome técnico não disponível';

  /// Nome da praga (com fallback seguro)
  String get nomePraga =>
      praga?.nomeComum ?? data.nomePraga ?? 'Praga não encontrada';

  /// Nome científico da praga (com fallback)
  String get nomeCientificoPraga =>
      praga?.nomeCientifico ?? 'Nome científico não disponível';

  /// Nome da cultura (com fallback seguro)
  String get nomeCultura =>
      cultura?.cultura ?? data.nomeCultura ?? 'Cultura não encontrada';

  /// Classe agronômica do defensivo (com fallback)
  String get classeAgronomica =>
      defensivo?.classeAgronomica ?? 'Não especificada';

  /// Modo de ação do defensivo (com fallback)
  String get modoAcao => defensivo?.modoAcao ?? 'Não especificado';

  /// Ingrediente ativo do defensivo (com fallback)
  String get ingredienteAtivo =>
      defensivo?.ingredienteAtivo ?? 'Não especificado';

  /// Tipo de praga (com fallback)
  String get tipoPraga => praga?.tipoPraga ?? 'Não especificado';

  /// Dose mínima com unidade de medida
  String get doseMinima {
    final min = data.dsMin;
    if (min == null || min.isEmpty) return 'Não especificada';
    return '$min ${data.um}';
  }

  /// Dose máxima com unidade de medida
  String get doseMaxima {
    final max = data.dsMax;
    if (max.isEmpty) return 'Não especificada';
    return '$max ${data.um}';
  }

  /// Intervalo de aplicação formatado
  String get intervaloAplicacao {
    if (data.intervalo == null || data.intervalo!.isEmpty) {
      return 'Não especificado';
    }
    return '${data.intervalo} dias';
  }

  /// Época de aplicação (com fallback)
  String get epocaAplicacao => data.epocaAplicacao ?? 'Não especificada';

  /// Cria uma cópia com warnings atualizados
  DiagnosticoWithWarnings copyWith({
    Diagnostico? data,
    Fitossanitario? defensivo,
    Praga? praga,
    Cultura? cultura,
    List<String>? warnings,
  }) {
    return DiagnosticoWithWarnings(
      data: data ?? this.data,
      defensivo: defensivo ?? this.defensivo,
      praga: praga ?? this.praga,
      cultura: cultura ?? this.cultura,
      warnings: warnings ?? this.warnings,
    );
  }

  /// Converte para Map (útil para logging/debugging)
  Map<String, dynamic> toMap() {
    return {
      'diagnosticoId': data.idReg,
      'nomeDefensivo': nomeDefensivo,
      'nomePraga': nomePraga,
      'nomeCultura': nomeCultura,
      'hasWarnings': hasWarnings,
      'warnings': warnings,
      'isComplete': isComplete,
      'doseMinima': doseMinima,
      'doseMaxima': doseMaxima,
    };
  }

  @override
  String toString() {
    return 'DiagnosticoWithWarnings{id: ${data.idReg}, '
        'defensivo: $nomeDefensivo, praga: $nomePraga, cultura: $nomeCultura, '
        'warnings: ${warnings.length}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DiagnosticoWithWarnings && other.data.idReg == data.idReg;
  }

  @override
  int get hashCode => data.idReg.hashCode;
}
