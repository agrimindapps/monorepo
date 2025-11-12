
import '../../../features/diagnosticos/domain/entities/diagnostico_entity.dart';
import '../../../features/defensivos/domain/entities/defensivo_entity.dart';
import '../../../features/pragas/domain/entities/praga_entity.dart';
import '../../../features/culturas/domain/entities/cultura_entity.dart';

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
  final DiagnosticoEntity data;

  /// Entidade relacionada: Defensivo/Fitossanitário
  final DefensivoEntity? defensivo;

  /// Entidade relacionada: Praga
  final PragaEntity? praga;

  /// Entidade relacionada: Cultura
  final CulturaEntity? cultura;

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
      defensivo?.nome ?? 'Nome técnico não disponível';

  /// Nome da praga (com fallback seguro)
  String get nomePraga =>
      praga?.nomeComum ?? data.nomePraga ?? 'Praga não encontrada';

  /// Nome científico da praga (com fallback)
  String get nomeCientificoPraga =>
      praga?.nomeCientifico ?? 'Nome científico não disponível';

  /// Nome da cultura (com fallback seguro)
  String get nomeCultura =>
      cultura?.nome ?? data.nomeCultura ?? 'Cultura não encontrada';

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
    final min = data.dosagem.dosagemMinima;
    if (min == null) return 'Não especificada';
    return '$min ${data.dosagem.unidadeMedida}';
  }

  /// Dose máxima com unidade de medida
  String get doseMaxima {
    final max = data.dosagem.dosagemMaxima;
    return '$max ${data.dosagem.unidadeMedida}';
  }

  /// Intervalo de aplicação formatado
  String get intervaloAplicacao {
    if (data.aplicacao.intervaloReaplicacao == null || 
        data.aplicacao.intervaloReaplicacao!.isEmpty) {
      return 'Não especificado';
    }
    return '${data.aplicacao.intervaloReaplicacao} dias';
  }

  /// Época de aplicação (com fallback)
  String get epocaAplicacao => data.aplicacao.epocaAplicacao ?? 'Não especificada';

  /// Cria uma cópia com warnings atualizados
  DiagnosticoWithWarnings copyWith({
    DiagnosticoEntity? data,
    DefensivoEntity? defensivo,
    PragaEntity? praga,
    CulturaEntity? cultura,
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
      'diagnosticoId': data.id,
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
    return 'DiagnosticoWithWarnings{id: ${data.id}, '
        'defensivo: $nomeDefensivo, praga: $nomePraga, cultura: $nomeCultura, '
        'warnings: ${warnings.length}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DiagnosticoWithWarnings && other.data.id == data.id;
  }

  @override
  int get hashCode => data.id.hashCode;
}
