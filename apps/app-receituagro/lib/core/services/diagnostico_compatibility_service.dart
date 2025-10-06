import 'package:flutter/foundation.dart';

import '../../features/diagnosticos/domain/entities/diagnostico_entity.dart';
import '../../features/diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../data/repositories/cultura_hive_repository.dart';
import '../data/repositories/fitossanitario_hive_repository.dart';
import '../data/repositories/pragas_hive_repository.dart';
import '../di/injection_container.dart';

/// Serviço avançado para validação de compatibilidade entre entidades
/// 
/// Fornece validação robusta de compatibilidade entre defensivos, culturas e pragas,
/// incluindo validações de segurança, eficácia e regulamentação.
/// 
/// **Funcionalidades:**
/// - Validação de compatibilidade tripla (defensivo-cultura-praga)
/// - Verificação de registro MAPA
/// - Validação de dosagens recomendadas
/// - Análise de conflitos e restrições
/// - Sugestões de alternativas
/// - Cache de validações frequentes
/// - Métricas de qualidade dos dados
class DiagnosticoCompatibilityService {
  static DiagnosticoCompatibilityService? _instance;
  static DiagnosticoCompatibilityService get instance => 
      _instance ??= DiagnosticoCompatibilityService._internal();
  
  DiagnosticoCompatibilityService._internal();
  late final IDiagnosticosRepository _diagnosticosRepository = sl<IDiagnosticosRepository>();
  late final CulturaHiveRepository _culturaRepository = sl<CulturaHiveRepository>();
  late final FitossanitarioHiveRepository _defensivoRepository = sl<FitossanitarioHiveRepository>();
  late final PragasHiveRepository _pragasRepository = sl<PragasHiveRepository>();
  final Map<String, CompatibilityValidation> _validationCache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheTTL = Duration(hours: 1);

  /// Verifica se o cache está válido
  bool get _isCacheValid {
    return _lastCacheUpdate != null && 
           DateTime.now().difference(_lastCacheUpdate!) < _cacheTTL;
  }

  /// Valida compatibilidade completa entre defensivo, cultura e praga
  Future<CompatibilityValidation> validateFullCompatibility({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
    bool includeAlternatives = true,
    bool checkDosage = true,
    bool checkRegistration = true,
  }) async {
    final cacheKey = '$idDefensivo:$idCultura:$idPraga';
    if (_isCacheValid && _validationCache.containsKey(cacheKey)) {
      return _validationCache[cacheKey]!;
    }

    try {
      final validation = await _performFullValidation(
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
        includeAlternatives: includeAlternatives,
        checkDosage: checkDosage,
        checkRegistration: checkRegistration,
      );
      _validationCache[cacheKey] = validation;
      _lastCacheUpdate = DateTime.now();

      return validation;
    } catch (e) {
      debugPrint('❌ Erro na validação de compatibilidade: $e');
      return CompatibilityValidation.error(
        message: 'Erro ao validar compatibilidade: $e',
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
      );
    }
  }

  /// Executa validação completa
  Future<CompatibilityValidation> _performFullValidation({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
    required bool includeAlternatives,
    required bool checkDosage,
    required bool checkRegistration,
  }) async {
    final List<ValidationIssue> issues = [];
    final List<ValidationWarning> warnings = [];
    final List<String> recommendations = [];
    final entityValidation = await _validateEntitiesExist(
      idDefensivo, idCultura, idPraga);
    issues.addAll(entityValidation.issues);

    if (entityValidation.hasBlockingIssues) {
      return CompatibilityValidation.failed(
        issues: issues,
        warnings: warnings,
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
      );
    }
    final diagnosticosResult = await _diagnosticosRepository.getByTriplaCombinacao(
      idDefensivo: idDefensivo,
      idCultura: idCultura,
      idPraga: idPraga,
    );

    List<DiagnosticoEntity> diagnosticos = [];
    diagnosticosResult.fold(
      (failure) => issues.add(ValidationIssue.error(
        'Erro ao buscar diagnósticos: ${failure.toString()}')),
      (data) => diagnosticos = data,
    );
    if (diagnosticos.isEmpty) {
      issues.add(ValidationIssue.warning(
        'Nenhum diagnóstico encontrado para esta combinação'));
      if (includeAlternatives) {
        final alternatives = await _findAlternatives(idCultura, idPraga);
        recommendations.addAll(alternatives);
      }
    } else {
      final diagValidation = await _validateDiagnosticos(
        diagnosticos, checkDosage, checkRegistration);
      issues.addAll(diagValidation.issues);
      warnings.addAll(diagValidation.warnings);
      recommendations.addAll(diagValidation.recommendations);
    }
    if (checkRegistration) {
      final regValidation = await _validateRegistration(idDefensivo);
      issues.addAll(regValidation.issues);
      warnings.addAll(regValidation.warnings);
    }
    final hasErrors = issues.any((i) => i.severity == IssueSeverity.error);
    final hasWarnings = issues.any((i) => i.severity == IssueSeverity.warning) ||
                       warnings.isNotEmpty;

    if (hasErrors) {
      return CompatibilityValidation.failed(
        issues: issues,
        warnings: warnings,
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
        alternatives: includeAlternatives ? await _findAlternatives(idCultura, idPraga) : [],
      );
    } else if (hasWarnings) {
      return CompatibilityValidation.warning(
        issues: issues,
        warnings: warnings,
        recommendations: recommendations,
        diagnosticos: diagnosticos,
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
      );
    } else {
      return CompatibilityValidation.success(
        diagnosticos: diagnosticos,
        recommendations: recommendations,
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
      );
    }
  }

  /// Valida se as entidades existem nos repositórios
  Future<EntityValidationResult> _validateEntitiesExist(
    String idDefensivo, String idCultura, String idPraga) async {
    final issues = <ValidationIssue>[];
    final defensivo = await _defensivoRepository.getById(idDefensivo);
    if (defensivo == null) {
      issues.add(ValidationIssue.error(
        'Defensivo com ID $idDefensivo não encontrado'));
    } else if (!defensivo.status) {
      issues.add(ValidationIssue.warning(
        'Defensivo ${defensivo.nomeComum} está inativo'));
    }
    final cultura = await _culturaRepository.getById(idCultura);
    if (cultura == null) {
      issues.add(ValidationIssue.error(
        'Cultura com ID $idCultura não encontrada'));
    }
    final praga = await _pragasRepository.getById(idPraga);
    if (praga == null) {
      issues.add(ValidationIssue.error(
        'Praga com ID $idPraga não encontrada'));
    }

    return EntityValidationResult(
      issues: issues,
      hasBlockingIssues: issues.any((i) => i.severity == IssueSeverity.error),
    );
  }

  /// Valida diagnósticos encontrados
  Future<DiagnosticosValidationResult> _validateDiagnosticos(
    List<DiagnosticoEntity> diagnosticos, bool checkDosage, bool checkRegistration) async {
    final issues = <ValidationIssue>[];
    final warnings = <ValidationWarning>[];
    final recommendations = <String>[];

    for (final diagnostico in diagnosticos) {
      if (!diagnostico.isComplete) {
        warnings.add(ValidationWarning(
          'Diagnóstico ${diagnostico.id} tem dados incompletos (${diagnostico.completude.displayName})',
          severity: WarningSevetiry.medium,
        ));
      }
      if (checkDosage && !diagnostico.hasDosagemValida) {
        issues.add(ValidationIssue.warning(
          'Dosagem inválida no diagnóstico ${diagnostico.id}'));
      }
      if (!diagnostico.hasAplicacaoValida) {
        warnings.add(ValidationWarning(
          'Informações de aplicação incompletas no diagnóstico ${diagnostico.id}',
          severity: WarningSevetiry.low,
        ));
      }
      if (diagnostico.completude == DiagnosticoCompletude.completo) {
        recommendations.add(
          'Diagnóstico ${diagnostico.id} tem dados completos e confiáveis');
      }
    }
    if (diagnosticos.length > 1) {
      final dosagens = diagnosticos
          .map((d) => d.dosagem.dosageAverage)
          .where((d) => d > 0)
          .toList();
      
      if (dosagens.isNotEmpty) {
        final variance = _calculateVariance(dosagens);
        if (variance > 50) { // Alta variância nas dosagens
          warnings.add(ValidationWarning(
            'Grande variação nas dosagens recomendadas (${variance.toStringAsFixed(1)}% variância)',
            severity: WarningSevetiry.medium,
          ));
        }
      }
    }

    return DiagnosticosValidationResult(
      issues: issues,
      warnings: warnings,
      recommendations: recommendations,
    );
  }

  /// Valida registro MAPA
  Future<RegistrationValidationResult> _validateRegistration(String idDefensivo) async {
    final issues = <ValidationIssue>[];
    final warnings = <ValidationWarning>[];

    final defensivo = await _defensivoRepository.getById(idDefensivo);
    if (defensivo != null) {
      if (defensivo.comercializado != 1) {
        issues.add(ValidationIssue.warning(
          'Defensivo ${defensivo.nomeComum} não está sendo comercializado'));
      }
      if (!defensivo.elegivel) {
        warnings.add(ValidationWarning(
          'Defensivo ${defensivo.nomeComum} pode ter restrições de uso',
          severity: WarningSevetiry.medium,
        ));
      }
      if (defensivo.classeAgronomica?.isEmpty != false) {
        warnings.add(ValidationWarning(
          'Classe agronômica não especificada para ${defensivo.nomeComum}',
          severity: WarningSevetiry.low,
        ));
      }
    }

    return RegistrationValidationResult(
      issues: issues,
      warnings: warnings,
    );
  }

  /// Busca alternativas para uma combinação cultura-praga
  Future<List<String>> _findAlternatives(String idCultura, String idPraga) async {
    final alternatives = <String>[];

    try {
      final alternativesResult = await _diagnosticosRepository.getRecomendacoesPara(
        idCultura: idCultura,
        idPraga: idPraga,
        limit: 5,
      );

      alternativesResult.fold(
        (failure) => debugPrint('Erro ao buscar alternativas: $failure'),
        (diagnosticos) {
          for (final diag in diagnosticos) {
            if (diag.nomeDefensivo?.isNotEmpty == true) {
              alternatives.add(
                'Considere usar ${diag.nomeDefensivo} com dosagem ${diag.dosagem.displayDosagem}');
            }
          }
        },
      );

      if (alternatives.isEmpty) {
        alternatives.add('Consulte um engenheiro agrônomo para recomendações específicas');
      }
    } catch (e) {
      debugPrint('Erro ao buscar alternativas: $e');
      alternatives.add('Não foi possível buscar alternativas no momento');
    }

    return alternatives;
  }

  /// Calcula variância de uma lista de valores
  double _calculateVariance(List<double> values) {
    if (values.length < 2) return 0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
        .map((x) => (x - mean) * (x - mean))
        .reduce((a, b) => a + b) / values.length;

    return (variance / mean) * 100; // Retorna como percentual
  }

  /// Valida dosagem específica para uma combinação
  Future<DosageValidation> validateDosage({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
    required double proposedDosage,
    required String unit,
  }) async {
    try {
      final diagnosticosResult = await _diagnosticosRepository.getByTriplaCombinacao(
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
      );

      return diagnosticosResult.fold(
        (failure) => DosageValidation.error('Erro ao validar dosagem: $failure'),
        (diagnosticos) {
          if (diagnosticos.isEmpty) {
            return DosageValidation.warning('Nenhuma referência de dosagem encontrada');
          }

          final validDosages = diagnosticos
              .where((d) => d.dosagem.isValid && d.dosagem.unidade == unit)
              .toList();

          if (validDosages.isEmpty) {
            return DosageValidation.warning('Nenhuma dosagem válida encontrada para a unidade $unit');
          }
          final dosages = validDosages.map((d) => d.dosagem.dosageAverage).toList();
          final minRecommended = dosages.reduce((a, b) => a < b ? a : b);
          final maxRecommended = dosages.reduce((a, b) => a > b ? a : b);

          if (proposedDosage < minRecommended) {
            return DosageValidation.warning(
              'Dosagem proposta ($proposedDosage $unit) está abaixo do recomendado '
              '(${minRecommended.toStringAsFixed(2)} - ${maxRecommended.toStringAsFixed(2)} $unit)');
          } else if (proposedDosage > maxRecommended) {
            return DosageValidation.warning(
              'Dosagem proposta ($proposedDosage $unit) está acima do recomendado '
              '(${minRecommended.toStringAsFixed(2)} - ${maxRecommended.toStringAsFixed(2)} $unit)');
          } else {
            return DosageValidation.success(
              'Dosagem está dentro da faixa recomendada '
              '(${minRecommended.toStringAsFixed(2)} - ${maxRecommended.toStringAsFixed(2)} $unit)');
          }
        },
      );
    } catch (e) {
      return DosageValidation.error('Erro ao validar dosagem: $e');
    }
  }

  /// Limpa cache de validações
  void clearCache() {
    _validationCache.clear();
    _lastCacheUpdate = null;
    debugPrint('🗑️ DiagnosticoCompatibilityService: Cache limpo');
  }

  /// Obtém estatísticas do serviço
  CompatibilityServiceStats getStats() {
    return CompatibilityServiceStats(
      cacheSize: _validationCache.length,
      lastCacheUpdate: _lastCacheUpdate,
      isCacheValid: _isCacheValid,
      totalValidations: _validationCache.length,
    );
  }
}

class CompatibilityValidation {
  final CompatibilityResult result;
  final List<ValidationIssue> issues;
  final List<ValidationWarning> warnings;
  final List<String> recommendations;
  final List<DiagnosticoEntity> diagnosticos;
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

  factory CompatibilityValidation.success({
    required List<DiagnosticoEntity> diagnosticos,
    required List<String> recommendations,
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) {
    return CompatibilityValidation._(
      result: CompatibilityResult.success,
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

  factory CompatibilityValidation.warning({
    required List<ValidationIssue> issues,
    required List<ValidationWarning> warnings,
    required List<String> recommendations,
    required List<DiagnosticoEntity> diagnosticos,
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

  factory CompatibilityValidation.failed({
    required List<ValidationIssue> issues,
    required List<ValidationWarning> warnings,
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
    List<String> alternatives = const [],
  }) {
    return CompatibilityValidation._(
      result: CompatibilityResult.failed,
      issues: issues,
      warnings: warnings,
      recommendations: [],
      diagnosticos: [],
      alternatives: alternatives,
      idDefensivo: idDefensivo,
      idCultura: idCultura,
      idPraga: idPraga,
      timestamp: DateTime.now(),
    );
  }

  factory CompatibilityValidation.error({
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

  bool get isValid => result == CompatibilityResult.success || result == CompatibilityResult.warning;
  bool get hasIssues => issues.isNotEmpty || warnings.isNotEmpty;
  bool get hasAlternatives => alternatives.isNotEmpty;
}

enum CompatibilityResult { success, warning, failed, error }

class ValidationIssue {
  final String message;
  final IssueSeverity severity;

  const ValidationIssue(this.message, this.severity);

  factory ValidationIssue.error(String message) => 
      ValidationIssue(message, IssueSeverity.error);
  
  factory ValidationIssue.warning(String message) => 
      ValidationIssue(message, IssueSeverity.warning);
  
  factory ValidationIssue.info(String message) => 
      ValidationIssue(message, IssueSeverity.info);
}

enum IssueSeverity { error, warning, info }

class ValidationWarning {
  final String message;
  final WarningSevetiry severity;

  const ValidationWarning(this.message, {required this.severity});
}

enum WarningSevetiry { high, medium, low }

class EntityValidationResult {
  final List<ValidationIssue> issues;
  final bool hasBlockingIssues;

  const EntityValidationResult({
    required this.issues,
    required this.hasBlockingIssues,
  });
}

class DiagnosticosValidationResult {
  final List<ValidationIssue> issues;
  final List<ValidationWarning> warnings;
  final List<String> recommendations;

  const DiagnosticosValidationResult({
    required this.issues,
    required this.warnings,
    required this.recommendations,
  });
}

class RegistrationValidationResult {
  final List<ValidationIssue> issues;
  final List<ValidationWarning> warnings;

  const RegistrationValidationResult({
    required this.issues,
    required this.warnings,
  });
}

class DosageValidation {
  final DosageValidationResult result;
  final String message;

  const DosageValidation._(this.result, this.message);

  factory DosageValidation.success(String message) =>
      DosageValidation._(DosageValidationResult.valid, message);
  
  factory DosageValidation.warning(String message) =>
      DosageValidation._(DosageValidationResult.warning, message);
  
  factory DosageValidation.error(String message) =>
      DosageValidation._(DosageValidationResult.invalid, message);

  bool get isValid => result == DosageValidationResult.valid;
}

enum DosageValidationResult { valid, warning, invalid }

class CompatibilityServiceStats {
  final int cacheSize;
  final DateTime? lastCacheUpdate;
  final bool isCacheValid;
  final int totalValidations;

  const CompatibilityServiceStats({
    required this.cacheSize,
    required this.lastCacheUpdate,
    required this.isCacheValid,
    required this.totalValidations,
  });

  @override
  String toString() {
    return 'CompatibilityServiceStats{cache: $cacheSize, validations: $totalValidations, valid: $isCacheValid}';
  }
}