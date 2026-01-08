
import 'package:drift/drift.dart';

import '../../../../database/receituagro_database.dart';
import '../../domain/entities/diagnostico_entity.dart';

class DiagnosticoMapper {
  const DiagnosticoMapper._();

  /// Converts Drift Diagnostico to DiagnosticoEntity
  /// New schema: uses idReg as PK, string FKs (fkIdDefensivo, fkIdCultura, fkIdPraga)
  static DiagnosticoEntity fromDrift(Diagnostico drift) {
    return DiagnosticoEntity(
      id: drift.idReg,
      idDefensivo: drift.fkIdDefensivo,
      idCultura: drift.fkIdCultura,
      idPraga: drift.fkIdPraga,
      nomeDefensivo: '', // Resolved via extension
      nomeCultura: '', // Resolved via extension
      nomePraga: '', // Resolved via extension
      dosagem: DosagemEntity(
        dosagemMinima: double.tryParse(drift.dsMin ?? '0'),
        dosagemMaxima: double.tryParse(drift.dsMax) ?? 0.0,
        unidadeMedida: drift.um,
      ),
      aplicacao: AplicacaoEntity(
        terrestre: drift.minAplicacaoT != null
            ? AplicacaoTerrestrefEntity(
                volumeMinimo: double.tryParse(drift.minAplicacaoT!),
                volumeMaximo: double.tryParse(drift.maxAplicacaoT ?? '0'),
                unidadeMedida: drift.umT,
              )
            : null,
        aerea: drift.minAplicacaoA != null
            ? AplicacaoAereaEntity(
                volumeMinimo: double.tryParse(drift.minAplicacaoA!),
                volumeMaximo: double.tryParse(drift.maxAplicacaoA ?? '0'),
                unidadeMedida: drift.umA,
              )
            : null,
        intervaloReaplicacao: drift.intervalo,
        intervaloReaplicacao2: drift.intervalo2,
        epocaAplicacao: drift.epocaAplicacao,
      ),
      createdAt: null, // Static data - no audit fields
      updatedAt: null, // Static data - no audit fields
    );
  }

  // DiagnosticoData removed - use Diagnostico (static table) directly

  static List<DiagnosticoEntity> fromDriftList(List<Diagnostico> dataList) {
    return dataList.map(fromDrift).toList();
  }

  /// Converts DiagnosticoEntity to Drift Diagnostico (static data)
  /// New schema: uses string FKs (fkIdDefensivo, fkIdCultura, fkIdPraga)
  static DiagnosticosCompanion toDrift(DiagnosticoEntity entity) {
    return DiagnosticosCompanion(
      idReg: Value(entity.id),
      fkIdDefensivo: Value(entity.idDefensivo),
      fkIdCultura: Value(entity.idCultura),
      fkIdPraga: Value(entity.idPraga),
      dsMin: Value(entity.dosagem.dosagemMinima?.toString()),
      dsMax: Value(entity.dosagem.dosagemMaxima.toString()),
      um: Value(entity.dosagem.unidadeMedida),
      minAplicacaoT: Value(entity.aplicacao.terrestre?.volumeMinimo?.toString()),
      maxAplicacaoT: Value(entity.aplicacao.terrestre?.volumeMaximo?.toString()),
      umT: Value(entity.aplicacao.terrestre?.unidadeMedida),
      minAplicacaoA: Value(entity.aplicacao.aerea?.volumeMinimo?.toString()),
      maxAplicacaoA: Value(entity.aplicacao.aerea?.volumeMaximo?.toString()),
      umA: Value(entity.aplicacao.aerea?.unidadeMedida),
      intervalo: Value(entity.aplicacao.intervaloReaplicacao),
      intervalo2: Value(entity.aplicacao.intervaloReaplicacao2),
      epocaAplicacao: Value(entity.aplicacao.epocaAplicacao),
    );
  }

  static DiagnosticosStats statsFromDriftStats(dynamic driftStats) {
    return const DiagnosticosStats(
      total: 0,
      completos: 0,
      parciais: 0,
      incompletos: 0,
      porDefensivo: <String, int>{},
      porCultura: <String, int>{},
      porPraga: <String, int>{},
      topDiagnosticos: [],
    );
  }
}
