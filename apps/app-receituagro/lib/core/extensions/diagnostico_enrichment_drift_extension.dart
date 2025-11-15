import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:core/core.dart' hide Column;

import '../../database/receituagro_database.dart';
import '../data/models/diagnostico_with_warnings_drift.dart';
import '../utils/data_with_warnings.dart';

/// Extension para enriquecer Diagnostico (Drift) com dados relacionados
///
/// Fornece métodos para carregar dados de defensivos, pragas e culturas
/// de forma segura, retornando DiagnosticoWithWarnings com avisos caso
/// referências não sejam encontradas.
extension DiagnosticoEnrichmentDriftExtension on Diagnostico {
  /// Enriquece o diagnóstico com dados relacionados completos
  ///
  /// Busca defensivo, praga e cultura usando os repositórios Drift.
  /// Se alguma referência não for encontrada, adiciona warning na lista.
  ///
  /// Retorna `Either<Failure, DiagnosticoWithWarnings>` com dados enriquecidos ou erro
  Future<Either<Failure, DiagnosticoWithWarningsDrift>>
  enrichWithRelatedData() async {
    try {
      final warnings = <String>[];

      // Busca defensivo
      Fitossanitario? defensivo;
      if (defensivoId > 0) {
        // TODO: Implementar busca usando FitossanitariosRepository
        // defensivo = await fitossanitariosRepo.findById(defensivoId!);
        warnings.add(
          'Busca de defensivo ainda não implementada (ID: $defensivoId)',
        );
        developer.log(
          'Defensivo lookup not implemented for diagnostico: $id',
          name: 'DiagnosticoEnrichmentDrift.enrichWithRelatedData',
          level: 800, // Warning
        );
      }

      // Busca praga
      Praga? praga;
      if (pragaId > 0) {
        // TODO: Implementar busca usando PragasRepository
        // praga = await pragasRepo.findById(pragaId!);
        warnings.add('Busca de praga ainda não implementada (ID: $pragaId)');
        developer.log(
          'Praga lookup not implemented for diagnostico: $id',
          name: 'DiagnosticoEnrichmentDrift.enrichWithRelatedData',
          level: 800,
        );
      }

      // Busca cultura
      Cultura? cultura;
      if (culturaId > 0) {
        // TODO: Implementar busca usando CulturasRepository
        // cultura = await culturasRepo.findById(culturaId!);
        warnings.add(
          'Busca de cultura ainda não implementada (ID: $culturaId)',
        );
        developer.log(
          'Cultura lookup not implemented for diagnostico: $id',
          name: 'DiagnosticoEnrichmentDrift.enrichWithRelatedData',
          level: 800,
        );
      }

      // Cria o objeto enriquecido
      final enriched = DiagnosticoWithWarningsDrift(
        diagnostico: this,
        defensivo: defensivo,
        praga: praga,
        cultura: cultura,
        warnings: warnings,
      );

      return Right(enriched);
    } catch (e) {
      developer.log(
        'Error enriching diagnostico $id: $e',
        name: 'DiagnosticoEnrichmentDrift.enrichWithRelatedData',
        error: e,
        level: 1000, // Error
      );
      return Left(ServerFailure('Erro ao enriquecer diagnóstico: $e'));
    }
  }

  /// Enriquece apenas com defensivo
  Future<Either<Failure, DataWithWarnings<Fitossanitario?>>>
  enrichWithDefensivo() async {
    try {
      if (defensivoId <= 0) {
        return Right(DataWithWarnings(data: null));
      }

      // TODO: Implementar busca usando FitossanitariosRepository
      // final defensivo = await fitossanitariosRepo.findById(defensivoId!);
      final warnings = ['Busca de defensivo ainda não implementada'];

      return Right(
        DataWithWarnings(
          data: null, // defensivo
          warnings: warnings,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar defensivo: $e'));
    }
  }

  /// Enriquece apenas com praga
  Future<Either<Failure, DataWithWarnings<Praga?>>> enrichWithPraga() async {
    try {
      if (pragaId <= 0) {
        return Right(DataWithWarnings(data: null));
      }

      // TODO: Implementar busca usando PragasRepository
      // final praga = await pragasRepo.findById(pragaId!);
      final warnings = ['Busca de praga ainda não implementada'];

      return Right(
        DataWithWarnings(
          data: null, // praga
          warnings: warnings,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar praga: $e'));
    }
  }

  /// Enriquece apenas com cultura
  Future<Either<Failure, DataWithWarnings<Cultura?>>>
  enrichWithCultura() async {
    try {
      if (culturaId <= 0) {
        return Right(DataWithWarnings(data: null));
      }

      // TODO: Implementar busca usando CulturasRepository
      // final cultura = await culturasRepo.findById(culturaId!);
      final warnings = ['Busca de cultura ainda não implementada'];

      return Right(
        DataWithWarnings(
          data: null, // cultura
          warnings: warnings,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar cultura: $e'));
    }
  }
}
