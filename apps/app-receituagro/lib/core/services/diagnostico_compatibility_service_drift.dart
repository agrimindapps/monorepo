import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../features/diagnosticos/domain/entities/diagnostico_entity.dart';
import '../../features/diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../../database/receituagro_database.dart';
import '../../database/tables/receituagro_tables.dart';
import '../di/injection_container.dart';

/// Serviço avançado para validação de compatibilidade entre entidades (versão Drift)
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
class DiagnosticoCompatibilityServiceDrift {
  static DiagnosticoCompatibilityServiceDrift? _instance;
  static DiagnosticoCompatibilityServiceDrift get instance =>
      _instance ??= DiagnosticoCompatibilityServiceDrift._internal();

  DiagnosticoCompatibilityServiceDrift._internal();
  late final IDiagnosticosRepository _diagnosticosRepository =
      sl<IDiagnosticosRepository>();
  late final ReceituagroDatabase _db = sl<ReceituagroDatabase>();
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
      idDefensivo,
      idCultura,
      idPraga,
    );
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
    final diagnosticosResult = await _diagnosticosRepository
        .queryByTriplaCombinacao(
          idDefensivo: idDefensivo,
          idCultura: idCultura,
          idPraga: idPraga,
        );

    List<DiagnosticoEntity> diagnosticos = [];
    diagnosticosResult.fold(
      (failure) => issues.add(
        ValidationIssue.error(
          'Erro ao buscar diagnósticos: ${failure.toString()}',
        ),
      ),
      (data) => diagnosticos = data,
    );
    if (diagnosticos.isEmpty) {
      issues.add(
        ValidationIssue.warning(
          'Nenhum diagnóstico encontrado para esta combinação',
        ),
      );
      if (includeAlternatives) {
        final alternatives = await _findAlternatives(idCultura, idPraga);
        recommendations.addAll(alternatives);
      }
    } else {
      final diagValidation = await _validateDiagnosticos(
        diagnosticos,
        checkDosage,
        checkRegistration,
      );
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
    final hasWarnings =
        issues.any((i) => i.severity == IssueSeverity.warning) ||
        warnings.isNotEmpty;

    if (hasErrors) {
      return CompatibilityValidation.failed(
        issues: issues,
        warnings: warnings,
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
        alternatives: includeAlternatives
            ? await _findAlternatives(idCultura, idPraga)
            : [],
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
    String idDefensivo,
    String idCultura,
    String idPraga,
  ) async {
    final issues = <ValidationIssue>[];

    // Buscar defensivo diretamente no Drift
    final defensivo =
        await (_db.select(_db.fitossanitarios)
              ..where((Fitossanitarios f) => f.idDefensivo.equals(idDefensivo)))
            .getSingleOrNull();

    if (defensivo == null) {
      issues.add(
        ValidationIssue.error('Defensivo com ID $idDefensivo não encontrado'),
      );
    } else if (!defensivo.status) {
      issues.add(
        ValidationIssue.warning(
          'Defensivo ${defensivo.nomeComum} está inativo',
        ),
      );
    }

    // Buscar cultura diretamente no Drift
    final cultura = await (_db.select(
      _db.culturas,
    )..where((Culturas c) => c.idCultura.equals(idCultura))).getSingleOrNull();

    if (cultura == null) {
      issues.add(
        ValidationIssue.error('Cultura com ID $idCultura não encontrada'),
      );
    }

    // Buscar praga diretamente no Drift
    final praga = await (_db.select(
      _db.pragas,
    )..where((Pragas p) => p.idPraga.equals(idPraga))).getSingleOrNull();

    if (praga == null) {
      issues.add(ValidationIssue.error('Praga com ID $idPraga não encontrada'));
    }

    return EntityValidationResult(
      issues: issues,
      hasBlockingIssues: issues.any((i) => i.severity == IssueSeverity.error),
    );
  }

  /// Valida diagnósticos encontrados
  Future<DiagnosticosValidationResult> _validateDiagnosticos(
    List<DiagnosticoEntity> diagnosticos,
    bool checkDosage,
    bool checkRegistration,
  ) async {
    final issues = <ValidationIssue>[];
    final warnings = <ValidationWarning>[];
    final recommendations = <String>[];

    for (final diag in diagnosticos) {
      if (checkDosage && !diag.dosagem.isValid) {
        warnings.add(
          ValidationWarning(
            'Diagnóstico ${diag.id} tem dosagem inválida',
            severity: WarningSevetiry.medium,
          ),
        );
      }
      if (checkRegistration && diag.completude.index < 3) {
        warnings.add(
          ValidationWarning(
            'Diagnóstico ${diag.id} tem completude baixa',
            severity: WarningSevetiry.low,
          ),
        );
      }
    }

    if (diagnosticos.length > 1) {
      final dosages = diagnosticos
          .where((d) => d.dosagem.isValid)
          .map((d) => d.dosagem.dosageAverage)
          .toList();

      if (dosages.length > 1) {
        final variance = _calculateVariance(dosages);
        if (variance > 50) {
          warnings.add(
            ValidationWarning(
              'Grande variação nas dosagens recomendadas (${variance.toStringAsFixed(1)}%)',
              severity: WarningSevetiry.high,
            ),
          );
          recommendations.add('Consulte especialista para dosagem específica');
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
  Future<RegistrationValidationResult> _validateRegistration(
    String idDefensivo,
  ) async {
    final issues = <ValidationIssue>[];
    final warnings = <ValidationWarning>[];

    // Buscar defensivo diretamente no Drift
    final defensivo =
        await (_db.select(_db.fitossanitarios)
              ..where((Fitossanitarios f) => f.idDefensivo.equals(idDefensivo)))
            .getSingleOrNull();

    if (defensivo != null) {
      if (defensivo.comercializado != 1) {
        issues.add(
          ValidationIssue.warning(
            'Defensivo ${defensivo.nomeComum} não está sendo comercializado',
          ),
        );
      }
      if (!defensivo.elegivel) {
        warnings.add(
          ValidationWarning(
            'Defensivo ${defensivo.nomeComum} pode ter restrições de uso',
            severity: WarningSevetiry.medium,
          ),
        );
      }
      if (defensivo.classeAgronomica?.isEmpty != false) {
        warnings.add(
          ValidationWarning(
            'Classe agronômica não especificada para ${defensivo.nomeComum}',
            severity: WarningSevetiry.low,
          ),
        );
      }
    }

    return RegistrationValidationResult(issues: issues, warnings: warnings);
  }

  /// Busca alternativas para combinação não encontrada
  Future<List<String>> _findAlternatives(
    String idCultura,
    String idPraga,
  ) async {
    final alternatives = <String>[];

    try {
      final diagnosticosResult = await _diagnosticosRepository
          .queryByTriplaCombinacao(idCultura: idCultura, idPraga: idPraga);

      diagnosticosResult.fold(
        (Failure failure) =>
            debugPrint('Erro ao buscar alternativas: $failure'),
        (List<DiagnosticoEntity> diagnosticos) {
          final sorted = diagnosticos
            ..sort(
              (DiagnosticoEntity a, DiagnosticoEntity b) =>
                  b.completude.index.compareTo(a.completude.index),
            );

          final limited = sorted.take(5).toList();

          for (final diag in limited) {
            if (diag.nomeDefensivo?.isNotEmpty == true) {
              alternatives.add(
                'Considere usar ${diag.nomeDefensivo} com dosagem ${diag.dosagem.displayDosagem}',
              );
            }
          }
        },
      );

      if (alternatives.isEmpty) {
        alternatives.add(
          'Consulte um engenheiro agrônomo para recomendações específicas',
        );
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
    final variance =
        values.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
        values.length;

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
      final diagnosticosResult = await _diagnosticosRepository
          .queryByTriplaCombinacao(
            idDefensivo: idDefensivo,
            idCultura: idCultura,
            idPraga: idPraga,
          );

      return diagnosticosResult.fold(
        (failure) =>
            DosageValidation.error('Erro ao validar dosagem: $failure'),
        (diagnosticos) {
          if (diagnosticos.isEmpty) {
            return DosageValidation.warning(
              'Nenhuma referência de dosagem encontrada',
            );
          }

          final validDosages = diagnosticos
              .where((d) => d.dosagem.isValid && d.dosagem.unidade == unit)
              .toList();

          if (validDosages.isEmpty) {
            return DosageValidation.warning(
              'Nenhuma dosagem válida encontrada para a unidade $unit',
            );
          }
          final dosages = validDosages
              .map((d) => d.dosagem.dosageAverage)
              .toList();
          final minRecommended = dosages.reduce((a, b) => a < b ? a : b);
          final maxRecommended = dosages.reduce((a, b) => a > b ? a : b);

          if (proposedDosage < minRecommended) {
            return DosageValidation.warning(
              'Dosagem proposta ($proposedDosage $unit) está abaixo do recomendado '
              '(${minRecommended.toStringAsFixed(2)} - ${maxRecommended.toStringAsFixed(2)} $unit)',
            );
          } else if (proposedDosage > maxRecommended) {
            return DosageValidation.warning(
              'Dosagem proposta ($proposedDosage $unit) está acima do recomendado '
              '(${minRecommended.toStringAsFixed(2)} - ${maxRecommended.toStringAsFixed(2)} $unit)',
            );
          } else {
            return DosageValidation.success(
              'Dosagem está dentro da faixa recomendada '
              '(${minRecommended.toStringAsFixed(2)} - ${maxRecommended.toStringAsFixed(2)} $unit)',
            );
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
    debugPrint('🗑️ DiagnosticoCompatibilityServiceDrift: Cache limpo');
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

  bool get isValid =>
      result == CompatibilityResult.success ||
      result == CompatibilityResult.warning;
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
