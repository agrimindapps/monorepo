
import '../../database/repositories/culturas_repository.dart';

import '../utils/diagnostico_logger.dart';

/// EXEMPLO DE USO:
///
/// ```dart
/// // Injeção de dependências (GetIt)
/// final validator = DataIntegrityValidator(
///   diagnosticoRepo: getIt<DiagnosticoRepository>(),
///   defensivoRepo: getIt<FitossanitariosRepository>(),
///   pragaRepo: getIt<PragasRepository>(),
///   culturaRepo: getIt<CulturasRepository>(),
/// );
///
/// // Validação completa
/// final report = await validator.validateAll();
///
/// // Verificação rápida de problemas críticos
/// if (await validator.hasCriticalIssues()) {
///   // Problemas críticos detectados - log automático será feito
/// }
///
/// // Logging automático
/// await validator.logIntegrityReport();
/// ```

/// Relatório de integridade referencial dos dados Hive
class IntegrityReport {
  final int totalDiagnosticos;
  final List<IntegrityIssue> issues;
  final DateTime timestamp;

  const IntegrityReport({
    required this.totalDiagnosticos,
    required this.issues,
    required this.timestamp,
  });

  bool get hasIssues => issues.isNotEmpty;

  int get criticalIssues =>
      issues.where((i) => i.severity == IntegritySeverity.critical).length;
  int get warningIssues =>
      issues.where((i) => i.severity == IntegritySeverity.warning).length;
  int get infoIssues =>
      issues.where((i) => i.severity == IntegritySeverity.info).length;

  @override
  String toString() {
    return 'IntegrityReport(total: $totalDiagnosticos, issues: ${issues.length}, critical: $criticalIssues, warnings: $warningIssues, info: $infoIssues)';
  }
}

/// Problema de integridade identificado
class IntegrityIssue {
  final String entity;
  final String id;
  final String field;
  final String value;
  final IntegritySeverity severity;
  final String description;

  const IntegrityIssue({
    required this.entity,
    required this.id,
    required this.field,
    required this.value,
    required this.severity,
    required this.description,
  });

  factory IntegrityIssue.brokenForeignKey(
    String entity,
    String id,
    String field,
    String value,
  ) {
    return IntegrityIssue(
      entity: entity,
      id: id,
      field: field,
      value: value,
      severity: IntegritySeverity.critical,
      description:
          'Foreign key $field references non-existent $field record: $value',
    );
  }

  factory IntegrityIssue.missingRequiredField(
    String entity,
    String id,
    String field,
  ) {
    return IntegrityIssue(
      entity: entity,
      id: id,
      field: field,
      value: '',
      severity: IntegritySeverity.warning,
      description: 'Required field $field is missing or empty',
    );
  }

  @override
  String toString() {
    return '[$severity] $entity($id): $description';
  }
}

/// Severidade do problema de integridade
enum IntegritySeverity {
  critical, // Dados inválidos, pode causar crashes
  warning, // Dados suspeitos, pode causar comportamentos inesperados
  info, // Dados incompletos, mas funcionais
}

/// Serviço para validar integridade referencial dos dados Hive
class DataIntegrityValidator {
  final DiagnosticoRepository _diagnosticoRepo;
  final FitossanitariosRepository _defensivoRepo;
  final PragasRepository _pragaRepo;
  final CulturasRepository _culturaRepo;

  DataIntegrityValidator({
    required DiagnosticoRepository diagnosticoRepo,
    required FitossanitariosRepository defensivoRepo,
    required PragasRepository pragaRepo,
    required CulturasRepository culturaRepo,
  }) : _diagnosticoRepo = diagnosticoRepo,
       _defensivoRepo = defensivoRepo,
       _pragaRepo = pragaRepo,
       _culturaRepo = culturaRepo;

  /// Executa validação completa de integridade referencial
  Future<IntegrityReport> validateAll() async {
    final issues = <IntegrityIssue>[];
    final startTime = DateTime.now();

    // Validar diagnósticos
    final diagnosticosResult = await _diagnosticoRepo.getAll();
    if (diagnosticosResult.isSuccess) {
      final diagnosticos = diagnosticosResult.data!;
      issues.addAll(await _validateDiagnosticos(diagnosticos));
    }

    final report = IntegrityReport(
      totalDiagnosticos: diagnosticosResult.isSuccess
          ? diagnosticosResult.data!.length
          : 0,
      issues: issues,
      timestamp: startTime,
    );

    return report;
  }

  /// Valida integridade dos diagnósticos
  Future<List<IntegrityIssue>> _validateDiagnosticos(
    List<Diagnostico> diagnosticos,
  ) async {
    final issues = <IntegrityIssue>[];

    for (final diag in diagnosticos) {
      // Validar FK do defensivo
      if (diag.fkIdDefensivo.isEmpty) {
        issues.add(
          IntegrityIssue.missingRequiredField(
            'diagnostico',
            diag.idReg,
            'fkIdDefensivo',
          ),
        );
      } else {
        final defensivoExists =
            await _defensivoRepo.getById(diag.fkIdDefensivo) != null;
        if (!defensivoExists) {
          issues.add(
            IntegrityIssue.brokenForeignKey(
              'diagnostico',
              diag.idReg,
              'defensivo',
              diag.fkIdDefensivo,
            ),
          );
        }
      }

      // Validar FK da praga
      if (diag.fkIdPraga.isEmpty) {
        issues.add(
          IntegrityIssue.missingRequiredField(
            'diagnostico',
            diag.idReg,
            'fkIdPraga',
          ),
        );
      } else {
        final pragaExists = await _pragaRepo.getById(diag.fkIdPraga) != null;
        if (!pragaExists) {
          issues.add(
            IntegrityIssue.brokenForeignKey(
              'diagnostico',
              diag.idReg,
              'praga',
              diag.fkIdPraga,
            ),
          );
        }
      }

      // Validar FK da cultura
      if (diag.fkIdCultura.isEmpty) {
        issues.add(
          IntegrityIssue.missingRequiredField(
            'diagnostico',
            diag.idReg,
            'fkIdCultura',
          ),
        );
      } else {
        final idCulturaInt = int.tryParse(diag.fkIdCultura);
        if (idCulturaInt != null) {
          final culturaExists =
              await _culturaRepo.findById(idCulturaInt) != null;
          if (!culturaExists) {
            issues.add(
              IntegrityIssue.brokenForeignKey(
                'diagnostico',
                diag.idReg,
                'cultura',
                diag.fkIdCultura,
              ),
            );
          }
        }
      }

      // Validar campos obrigatórios
      if (diag.dsMax.isEmpty) {
        issues.add(
          IntegrityIssue.missingRequiredField(
            'diagnostico',
            diag.idReg,
            'dsMax',
          ),
        );
      }

      if (diag.um.isEmpty) {
        issues.add(
          IntegrityIssue.missingRequiredField('diagnostico', diag.idReg, 'um'),
        );
      }
    }

    return issues;
  }

  /// Valida apenas um diagnóstico específico
  Future<List<IntegrityIssue>> validateDiagnostico(String diagnosticoId) async {
    final result = await _diagnosticoRepo.getByIdOrObjectId(diagnosticoId);
    if (result == null) {
      return [
        IntegrityIssue(
          entity: 'diagnostico',
          id: diagnosticoId,
          field: 'id',
          value: diagnosticoId,
          severity: IntegritySeverity.critical,
          description: 'Diagnóstico não encontrado',
        ),
      ];
    }

    return _validateDiagnosticos([result]);
  }

  /// Gera relatório de integridade em formato legível
  String generateReport(IntegrityReport report) {
    final buffer = StringBuffer();

    buffer.writeln('=== RELATÓRIO DE INTEGRIDADE REFERENCIAL ===');
    buffer.writeln('Data: ${report.timestamp}');
    buffer.writeln('Total de diagnósticos: ${report.totalDiagnosticos}');
    buffer.writeln('Total de problemas: ${report.issues.length}');
    buffer.writeln('Críticos: ${report.criticalIssues}');
    buffer.writeln('Avisos: ${report.warningIssues}');
    buffer.writeln('Informações: ${report.infoIssues}');
    buffer.writeln('');

    if (report.issues.isEmpty) {
      buffer.writeln('✅ Nenhum problema de integridade encontrado.');
    } else {
      buffer.writeln('🚨 PROBLEMAS IDENTIFICADOS:');
      buffer.writeln('');

      for (final issue in report.issues) {
        final icon = switch (issue.severity) {
          IntegritySeverity.critical => '🔴',
          IntegritySeverity.warning => '🟡',
          IntegritySeverity.info => 'ℹ️',
        };
        buffer.writeln('$icon ${issue.toString()}');
      }
    }

    return buffer.toString();
  }

  Future<bool> hasCriticalIssues() async {
    final report = await validateAll();
    return report.criticalIssues > 0;
  }

  /// Método de conveniência para logging de relatório
  Future<void> logIntegrityReport() async {
    final report = await validateAll();
    final reportText = generateReport(report);

    // Log estruturado
    if (report.hasIssues) {
      DiagnosticoLogger.critical('INTEGRITY ISSUES DETECTED: $reportText');
    } else {
      DiagnosticoLogger.info('Data integrity check passed');
    }
  }
}
