import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../data/models/cultura_hive.dart';
import '../data/models/diagnostico_hive.dart';
import '../data/models/diagnostico_with_warnings.dart';
import '../data/models/fitossanitario_hive.dart';
import '../data/models/pragas_hive.dart';
import '../utils/hive_box_manager.dart';

/// Extension para enriquecer DiagnosticoHive com dados relacionados
///
/// Fornece métodos para carregar dados de defensivos, pragas e culturas
/// de forma segura, retornando DiagnosticoWithWarnings com avisos caso
/// referências não sejam encontradas.
extension DiagnosticoEnrichmentExtension on DiagnosticoHive {
  /// Enriquece o diagnóstico com dados relacionados completos
  ///
  /// Busca defensivo, praga e cultura nas respectivas boxes.
  /// Se alguma referência não for encontrada, adiciona warning na lista.
  ///
  /// [hiveManager] - Instância do HiveManager para acesso às boxes
  ///
  /// Retorna `Result<DiagnosticoWithWarnings>` com dados enriquecidos ou erro
  Future<Result<DiagnosticoWithWarnings>> enrichWithRelatedData(
    IHiveManager hiveManager,
  ) async {
    try {
      // Usa HiveBoxManager para abrir múltiplas boxes de forma segura
      final result =
          await HiveBoxManager.withMultipleBoxes<DiagnosticoWithWarnings>(
        hiveManager: hiveManager,
        boxNames: [
          'receituagro_defensivos',
          'receituagro_pragas',
          'receituagro_culturas',
        ],
        operation: (boxes) async {
          final defensivoBox = boxes['receituagro_defensivos']!;
          final pragasBox = boxes['receituagro_pragas']!;
          final culturasBox = boxes['receituagro_culturas']!;

          final warnings = <String>[];

          // Busca defensivo
          FitossanitarioHive? defensivo;
          if (fkIdDefensivo.isNotEmpty) {
            defensivo = _findInBox<FitossanitarioHive>(
              defensivoBox,
              fkIdDefensivo,
              (item) => item.idReg,
            );

            if (defensivo == null) {
              warnings.add('Defensivo não encontrado (ID: $fkIdDefensivo)');
              developer.log(
                'Missing defensivo: $fkIdDefensivo for diagnostico: $idReg',
                name: 'DiagnosticoEnrichment.enrichWithRelatedData',
                level: 800, // Warning
              );
            }
          }

          // Busca praga
          PragasHive? praga;
          if (fkIdPraga.isNotEmpty) {
            praga = _findInBox<PragasHive>(
              pragasBox,
              fkIdPraga,
              (item) => item.idReg,
            );

            if (praga == null) {
              warnings.add('Praga não encontrada (ID: $fkIdPraga)');
              developer.log(
                'Missing praga: $fkIdPraga for diagnostico: $idReg',
                name: 'DiagnosticoEnrichment.enrichWithRelatedData',
                level: 800,
              );
            }
          }

          // Busca cultura
          CulturaHive? cultura;
          if (fkIdCultura.isNotEmpty) {
            cultura = _findInBox<CulturaHive>(
              culturasBox,
              fkIdCultura,
              (item) => item.idReg,
            );

            if (cultura == null) {
              warnings.add('Cultura não encontrada (ID: $fkIdCultura)');
              developer.log(
                'Missing cultura: $fkIdCultura for diagnostico: $idReg',
                name: 'DiagnosticoEnrichment.enrichWithRelatedData',
                level: 800,
              );
            }
          }

          return DiagnosticoWithWarnings(
            data: this,
            defensivo: defensivo,
            praga: praga,
            cultura: cultura,
            warnings: warnings,
          );
        },
      );

      return result;
    } catch (e, stackTrace) {
      developer.log(
        'Error enriching diagnostico: $e',
        name: 'DiagnosticoEnrichment.enrichWithRelatedData',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );

      return Result.error(
        AppErrorFactory.fromException(e, stackTrace),
      );
    }
  }

  /// Enriquece apenas com defensivo
  ///
  /// Método otimizado para carregar apenas dados do defensivo
  Future<Result<DiagnosticoWithWarnings>> enrichWithDefensivo(
    IHiveManager hiveManager,
  ) async {
    try {
      final result =
          await HiveBoxManager.readBox<FitossanitarioHive, DiagnosticoWithWarnings>(
        hiveManager: hiveManager,
        boxName: 'receituagro_defensivos',
        operation: (box) async {
          final warnings = <String>[];
          FitossanitarioHive? defensivo;

          if (fkIdDefensivo.isNotEmpty) {
            defensivo = _findInBox<FitossanitarioHive>(
              box,
              fkIdDefensivo,
              (item) => item.idReg,
            );

            if (defensivo == null) {
              warnings.add('Defensivo não encontrado (ID: $fkIdDefensivo)');
            }
          }

          return DiagnosticoWithWarnings(
            data: this,
            defensivo: defensivo,
            warnings: warnings,
          );
        },
      );

      return result;
    } catch (e, stackTrace) {
      return Result.error(
        AppErrorFactory.fromException(e, stackTrace),
      );
    }
  }

  /// Enriquece apenas com praga
  Future<Result<DiagnosticoWithWarnings>> enrichWithPraga(
    IHiveManager hiveManager,
  ) async {
    try {
      final result =
          await HiveBoxManager.readBox<PragasHive, DiagnosticoWithWarnings>(
        hiveManager: hiveManager,
        boxName: 'receituagro_pragas',
        operation: (box) async {
          final warnings = <String>[];
          PragasHive? praga;

          if (fkIdPraga.isNotEmpty) {
            praga = _findInBox<PragasHive>(
              box,
              fkIdPraga,
              (item) => item.idReg,
            );

            if (praga == null) {
              warnings.add('Praga não encontrada (ID: $fkIdPraga)');
            }
          }

          return DiagnosticoWithWarnings(
            data: this,
            praga: praga,
            warnings: warnings,
          );
        },
      );

      return result;
    } catch (e, stackTrace) {
      return Result.error(
        AppErrorFactory.fromException(e, stackTrace),
      );
    }
  }

  /// Enriquece apenas com cultura
  Future<Result<DiagnosticoWithWarnings>> enrichWithCultura(
    IHiveManager hiveManager,
  ) async {
    try {
      final result =
          await HiveBoxManager.readBox<CulturaHive, DiagnosticoWithWarnings>(
        hiveManager: hiveManager,
        boxName: 'receituagro_culturas',
        operation: (box) async {
          final warnings = <String>[];
          CulturaHive? cultura;

          if (fkIdCultura.isNotEmpty) {
            cultura = _findInBox<CulturaHive>(
              box,
              fkIdCultura,
              (item) => item.idReg,
            );

            if (cultura == null) {
              warnings.add('Cultura não encontrada (ID: $fkIdCultura)');
            }
          }

          return DiagnosticoWithWarnings(
            data: this,
            cultura: cultura,
            warnings: warnings,
          );
        },
      );

      return result;
    } catch (e, stackTrace) {
      return Result.error(
        AppErrorFactory.fromException(e, stackTrace),
      );
    }
  }

  /// Helper para buscar item em uma box pelo ID
  T? _findInBox<T>(
    Box<dynamic> box,
    String id,
    String Function(T) idExtractor,
  ) {
    for (final item in box.values) {
      if (item is T) {
        if (idExtractor(item) == id) {
          return item;
        }
      }
    }
    return null;
  }
}

/// Extension para enriquecer listas de diagnósticos em lote
extension DiagnosticoListEnrichmentExtension on List<DiagnosticoHive> {
  /// Enriquece uma lista completa de diagnósticos com dados relacionados
  ///
  /// Otimizado para processar múltiplos diagnósticos de uma vez,
  /// abrindo as boxes uma única vez para todos os registros.
  ///
  /// Retorna `Result<List<DiagnosticoWithWarnings>>`
  Future<Result<List<DiagnosticoWithWarnings>>> enrichAllWithRelatedData(
    IHiveManager hiveManager,
  ) async {
    try {
      final result =
          await HiveBoxManager.withMultipleBoxes<List<DiagnosticoWithWarnings>>(
        hiveManager: hiveManager,
        boxNames: [
          'receituagro_defensivos',
          'receituagro_pragas',
          'receituagro_culturas',
        ],
        operation: (boxes) async {
          final defensivoBox = boxes['receituagro_defensivos']!;
          final pragasBox = boxes['receituagro_pragas']!;
          final culturasBox = boxes['receituagro_culturas']!;

          // Cria Maps para busca rápida O(1)
          final defensivosMap = _buildMap<FitossanitarioHive>(
            defensivoBox,
            (item) => item.idReg,
          );
          final pragasMap = _buildMap<PragasHive>(
            pragasBox,
            (item) => item.idReg,
          );
          final culturasMap = _buildMap<CulturaHive>(
            culturasBox,
            (item) => item.idReg,
          );

          // Enriquece cada diagnóstico
          final enrichedList = <DiagnosticoWithWarnings>[];

          for (final diagnostico in this) {
            final warnings = <String>[];

            // Busca defensivo
            final defensivo = defensivosMap[diagnostico.fkIdDefensivo];
            if (diagnostico.fkIdDefensivo.isNotEmpty && defensivo == null) {
              warnings.add(
                'Defensivo não encontrado (ID: ${diagnostico.fkIdDefensivo})',
              );
            }

            // Busca praga
            final praga = pragasMap[diagnostico.fkIdPraga];
            if (diagnostico.fkIdPraga.isNotEmpty && praga == null) {
              warnings.add(
                'Praga não encontrada (ID: ${diagnostico.fkIdPraga})',
              );
            }

            // Busca cultura
            final cultura = culturasMap[diagnostico.fkIdCultura];
            if (diagnostico.fkIdCultura.isNotEmpty && cultura == null) {
              warnings.add(
                'Cultura não encontrada (ID: ${diagnostico.fkIdCultura})',
              );
            }

            enrichedList.add(
              DiagnosticoWithWarnings(
                data: diagnostico,
                defensivo: defensivo,
                praga: praga,
                cultura: cultura,
                warnings: warnings,
              ),
            );
          }

          developer.log(
            'Enriched ${enrichedList.length} diagnosticos, '
            '${enrichedList.where((d) => d.hasWarnings).length} with warnings',
            name: 'DiagnosticoListEnrichment.enrichAllWithRelatedData',
          );

          return enrichedList;
        },
      );

      return result;
    } catch (e, stackTrace) {
      developer.log(
        'Error enriching diagnostico list: $e',
        name: 'DiagnosticoListEnrichment.enrichAllWithRelatedData',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );

      return Result.error(
        AppErrorFactory.fromException(e, stackTrace),
      );
    }
  }

  /// Helper para criar Map de busca rápida
  Map<String, T> _buildMap<T>(
    Box<dynamic> box,
    String Function(T) idExtractor,
  ) {
    final Map<String, T> map = {};

    for (final item in box.values) {
      if (item is T) {
        final id = idExtractor(item);
        if (id.isNotEmpty) {
          map[id] = item;
        }
      }
    }

    return map;
  }
}
