import 'package:dartz/dartz.dart';
import 'package:core/core.dart' hide Column;

import '../data/models/diagnostico_legacy.dart';
import '../data/models/diagnostico_with_warnings.dart';

/// Extension para enriquecer DiagnosticoHive com dados relacionados
///
/// DEPRECATED: This extension depends on Hive/BoxManager which has been removed.
/// TODO: Migrate to Drift-based queries or remove if no longer needed.
@Deprecated('Hive/BoxManager removed. Migrate to Drift queries.')
extension DiagnosticoEnrichmentExtension on DiagnosticoHive {
  /// Enriquece o diagnóstico com dados relacionados completos
  ///
  /// DEPRECATED: Depends on BoxManager which was removed.
  @Deprecated('Hive/BoxManager removed. Migrate to Drift queries.')
  Future<Either<Failure, DiagnosticoWithWarnings>> enrichWithRelatedData(
    IHiveManager hiveManager,
  ) async {
    return Left(
      CacheFailure('Extension deprecated: Hive/BoxManager removed. Use Drift queries instead.'),
    );
  }

  /// Enriquece apenas com defensivo
  /// DEPRECATED: Depends on BoxManager which was removed.
  @Deprecated('Hive/BoxManager removed. Migrate to Drift queries.')
  Future<Either<Failure, DiagnosticoWithWarnings>> enrichWithDefensivo(
    IHiveManager hiveManager,
  ) async {
    return Left(
      CacheFailure('Extension deprecated: Hive/BoxManager removed. Use Drift queries instead.'),
    );
  }

  /// Enriquece apenas com praga
  /// DEPRECATED: Depends on BoxManager which was removed.
  @Deprecated('Hive/BoxManager removed. Migrate to Drift queries.')
  Future<Either<Failure, DiagnosticoWithWarnings>> enrichWithPraga(
    IHiveManager hiveManager,
  ) async {
    return Left(
      CacheFailure('Extension deprecated: Hive/BoxManager removed. Use Drift queries instead.'),
    );
  }

  /// Enriquece apenas com cultura
  /// DEPRECATED: Depends on BoxManager which was removed.
  @Deprecated('Hive/BoxManager removed. Migrate to Drift queries.')
  Future<Either<Failure, DiagnosticoWithWarnings>> enrichWithCultura(
    IHiveManager hiveManager,
  ) async {
    return Left(
      CacheFailure('Extension deprecated: Hive/BoxManager removed. Use Drift queries instead.'),
    );
  }
}

/// Extension para enriquecer lista de diagnósticos
/// DEPRECATED: Depends on Hive/BoxManager which was removed.
@Deprecated('Hive/BoxManager removed. Migrate to Drift queries.')
extension DiagnosticoListEnrichmentExtension on List<DiagnosticoHive> {
  /// Enriquece uma lista completa de diagnósticos com dados relacionados
  /// DEPRECATED: Depends on BoxManager which was removed.
  @Deprecated('Hive/BoxManager removed. Migrate to Drift queries.')
  Future<Either<Failure, List<DiagnosticoWithWarnings>>>
      enrichAllWithRelatedData(
    IHiveManager hiveManager,
  ) async {
    return Left(
      CacheFailure('Extension deprecated: Hive/BoxManager removed. Use Drift queries instead.'),
    );
  }
}
