import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../data/models/cultura_hive.dart';
import '../data/models/diagnostico_hive.dart';
import '../data/models/fitossanitario_hive.dart';
import '../data/models/pragas_hive.dart';
import '../utils/hive_box_manager.dart';

/// Relatório de integridade referencial dos dados
///
/// Contém estatísticas e lista de problemas encontrados na validação
class IntegrityReport {
  /// Total de diagnósticos validados
  final int totalDiagnosticos;

  /// IDs de defensivos referenciados mas não encontrados
  final List<String> missingDefensivos;

  /// IDs de pragas referenciadas mas não encontradas
  final List<String> missingPragas;

  /// IDs de culturas referenciadas mas não encontradas
  final List<String> missingCulturas;

  /// Total de diagnósticos com problemas de integridade
  final int totalWithIssues;

  /// Indica se todos os dados estão íntegros (sem problemas)
  bool get isValid =>
      missingDefensivos.isEmpty &&
      missingPragas.isEmpty &&
      missingCulturas.isEmpty;

  /// Total de problemas encontrados
  int get totalIssues =>
      missingDefensivos.length + missingPragas.length + missingCulturas.length;

  const IntegrityReport({
    required this.totalDiagnosticos,
    required this.missingDefensivos,
    required this.missingPragas,
    required this.missingCulturas,
    required this.totalWithIssues,
  });

  /// Cria um relatório vazio (sem problemas)
  factory IntegrityReport.empty() {
    return const IntegrityReport(
      totalDiagnosticos: 0,
      missingDefensivos: [],
      missingPragas: [],
      missingCulturas: [],
      totalWithIssues: 0,
    );
  }

  /// Converte para Map para logging/debugging
  Map<String, dynamic> toMap() {
    return {
      'totalDiagnosticos': totalDiagnosticos,
      'totalWithIssues': totalWithIssues,
      'isValid': isValid,
      'totalIssues': totalIssues,
      'missingDefensivos': missingDefensivos.length,
      'missingPragas': missingPragas.length,
      'missingCulturas': missingCulturas.length,
      'missingDefensivosIds': missingDefensivos,
      'missingPragasIds': missingPragas,
      'missingCulturasIds': missingCulturas,
    };
  }

  @override
  String toString() {
    return 'IntegrityReport{total: $totalDiagnosticos, issues: $totalIssues, valid: $isValid}';
  }
}

/// Serviço de validação de integridade referencial dos dados
///
/// Valida se todas as foreign keys de diagnósticos apontam para
/// registros existentes nas tabelas relacionadas (defensivos, pragas, culturas)
/// Note: Not using @lazySingleton because IHiveManager isn't injectable-annotated
/// Must be registered manually in injection_container.dart
class DataIntegrityService {
  final IHiveManager _hiveManager;

  DataIntegrityService(this._hiveManager);

  // Nomes das boxes
  static const String _diagnosticoBoxName = 'receituagro_diagnosticos';
  static const String _defensivoBoxName = 'receituagro_defensivos';
  static const String _pragasBoxName = 'receituagro_pragas';
  static const String _culturasBoxName = 'receituagro_culturas';

  /// Valida a integridade referencial de todos os diagnósticos
  ///
  /// Verifica se cada diagnóstico possui referências válidas para:
  /// - Defensivo (fkIdDefensivo)
  /// - Praga (fkIdPraga)
  /// - Cultura (fkIdCultura)
  ///
  /// Retorna um [IntegrityReport] com estatísticas e lista de problemas
  Future<Either<Failure, IntegrityReport>> validateIntegrity() async {
    try {
      developer.log(
        'Starting data integrity validation',
        name: 'DataIntegrityService.validateIntegrity',
      );

      // Usa HiveBoxManager para abrir múltiplas boxes de forma segura
      final result = await HiveBoxManager.withMultipleBoxes<IntegrityReport>(
        hiveManager: _hiveManager,
        boxNames: [
          _diagnosticoBoxName,
          _defensivoBoxName,
          _pragasBoxName,
          _culturasBoxName,
        ],
        operation: (boxes) async {
          final diagnosticoBox = boxes[_diagnosticoBoxName]!;
          final defensivoBox = boxes[_defensivoBoxName]!;
          final pragasBox = boxes[_pragasBoxName]!;
          final culturasBox = boxes[_culturasBoxName]!;

          // Cria Sets de IDs existentes para busca rápida O(1)
          final existingDefensivos = _buildIdSet<FitossanitarioHive>(
            defensivoBox,
            (item) => item.idReg,
          );
          final existingPragas = _buildIdSet<PragasHive>(
            pragasBox,
            (item) => item.idReg,
          );
          final existingCulturas = _buildIdSet<CulturaHive>(
            culturasBox,
            (item) => item.idReg,
          );

          developer.log(
            'Loaded reference data: defensivos=${existingDefensivos.length}, '
            'pragas=${existingPragas.length}, culturas=${existingCulturas.length}',
            name: 'DataIntegrityService.validateIntegrity',
          );

          // Valida cada diagnóstico
          final missingDefensivos = <String>{};
          final missingPragas = <String>{};
          final missingCulturas = <String>{};
          final diagnosticosWithIssues = <String>{};

          for (final item in diagnosticoBox.values) {
            final diagnostico = item as DiagnosticoHive;
            bool hasIssues = false;

            // Valida FK de defensivo
            if (diagnostico.fkIdDefensivo.isNotEmpty &&
                !existingDefensivos.contains(diagnostico.fkIdDefensivo)) {
              missingDefensivos.add(diagnostico.fkIdDefensivo);
              hasIssues = true;
            }

            // Valida FK de praga
            if (diagnostico.fkIdPraga.isNotEmpty &&
                !existingPragas.contains(diagnostico.fkIdPraga)) {
              missingPragas.add(diagnostico.fkIdPraga);
              hasIssues = true;
            }

            // Valida FK de cultura
            if (diagnostico.fkIdCultura.isNotEmpty &&
                !existingCulturas.contains(diagnostico.fkIdCultura)) {
              missingCulturas.add(diagnostico.fkIdCultura);
              hasIssues = true;
            }

            if (hasIssues) {
              diagnosticosWithIssues.add(diagnostico.idReg);
            }
          }

          final report = IntegrityReport(
            totalDiagnosticos: diagnosticoBox.length,
            missingDefensivos: missingDefensivos.toList()..sort(),
            missingPragas: missingPragas.toList()..sort(),
            missingCulturas: missingCulturas.toList()..sort(),
            totalWithIssues: diagnosticosWithIssues.length,
          );

          developer.log(
            'Validation completed: ${report.toMap()}',
            name: 'DataIntegrityService.validateIntegrity',
            level: report.isValid ? 0 : 800, // Warning se houver problemas
          );

          return report;
        },
      );

      return result;
    } catch (e, stackTrace) {
      developer.log(
        'Error during integrity validation: $e',
        name: 'DataIntegrityService.validateIntegrity',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );

      return Left(UnexpectedFailure('Error during integrity validation: $e'));
    }
  }

  /// Valida integridade de um diagnóstico específico
  ///
  /// Retorna lista de mensagens de erro (vazia se tudo OK)
  Future<Either<Failure, List<String>>> validateDiagnostico(
    DiagnosticoHive diagnostico,
  ) async {
    try {
      final result = await HiveBoxManager.withMultipleBoxes<List<String>>(
        hiveManager: _hiveManager,
        boxNames: [
          _defensivoBoxName,
          _pragasBoxName,
          _culturasBoxName,
        ],
        operation: (boxes) async {
          final defensivoBox = boxes[_defensivoBoxName]!;
          final pragasBox = boxes[_pragasBoxName]!;
          final culturasBox = boxes[_culturasBoxName]!;

          final errors = <String>[];

          // Valida defensivo
          if (diagnostico.fkIdDefensivo.isNotEmpty) {
            final exists = _containsId<FitossanitarioHive>(
              defensivoBox,
              diagnostico.fkIdDefensivo,
              (item) => item.idReg,
            );
            if (!exists) {
              errors.add(
                'Defensivo não encontrado (ID: ${diagnostico.fkIdDefensivo})',
              );
            }
          }

          // Valida praga
          if (diagnostico.fkIdPraga.isNotEmpty) {
            final exists = _containsId<PragasHive>(
              pragasBox,
              diagnostico.fkIdPraga,
              (item) => item.idReg,
            );
            if (!exists) {
              errors.add('Praga não encontrada (ID: ${diagnostico.fkIdPraga})');
            }
          }

          // Valida cultura
          if (diagnostico.fkIdCultura.isNotEmpty) {
            final exists = _containsId<CulturaHive>(
              culturasBox,
              diagnostico.fkIdCultura,
              (item) => item.idReg,
            );
            if (!exists) {
              errors.add(
                'Cultura não encontrada (ID: ${diagnostico.fkIdCultura})',
              );
            }
          }

          return errors;
        },
      );

      return result;
    } catch (e, stackTrace) {
      developer.log(
        'Error validating diagnostico: $e',
        name: 'DataIntegrityService.validateDiagnostico',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );

      return Left(UnexpectedFailure('Error validating diagnostico: $e'));
    }
  }

  /// Obtém estatísticas de integridade resumidas
  Future<Either<Failure, Map<String, dynamic>>> getIntegrityStatistics() async {
    final reportResult = await validateIntegrity();

    return reportResult.map((report) => {
          'isValid': report.isValid,
          'totalDiagnosticos': report.totalDiagnosticos,
          'totalWithIssues': report.totalWithIssues,
          'totalIssues': report.totalIssues,
          'integrityPercentage': report.totalDiagnosticos > 0
              ? ((report.totalDiagnosticos - report.totalWithIssues) /
                      report.totalDiagnosticos *
                      100)
                  .toStringAsFixed(2)
              : '100.00',
        });
  }

  // ========== Helper Methods ==========

  /// Cria um Set de IDs a partir de uma box para busca rápida
  Set<String> _buildIdSet<T>(
    Box<dynamic> box,
    String Function(T) idExtractor,
  ) {
    final Set<String> ids = {};

    for (final item in box.values) {
      if (item is T) {
        final id = idExtractor(item);
        if (id.isNotEmpty) {
          ids.add(id);
        }
      }
    }

    return ids;
  }

  /// Verifica se uma box contém um ID específico
  bool _containsId<T>(
    Box<dynamic> box,
    String id,
    String Function(T) idExtractor,
  ) {
    for (final item in box.values) {
      if (item is T) {
        if (idExtractor(item) == id) {
          return true;
        }
      }
    }
    return false;
  }
}
