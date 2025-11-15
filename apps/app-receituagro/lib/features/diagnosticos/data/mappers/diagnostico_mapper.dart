
import 'package:drift/drift.dart';

import '../../../../database/receituagro_database.dart';
import '../../../../database/repositories/diagnostico_repository.dart';
import '../../domain/entities/diagnostico_entity.dart';

class DiagnosticoMapper {
  const DiagnosticoMapper._();

  /// Converts Drift Diagnostico to DiagnosticoEntity
  /// Note: nomeDefensivo, nomeCultura, nomePraga should be resolved via extensions
  static DiagnosticoEntity fromDrift(Diagnostico drift) {
    return DiagnosticoEntity(
      id: drift.firebaseId ?? drift.id.toString(),
      idDefensivo: drift.defensivoId.toString(),
      idCultura: drift.culturaId.toString(),
      idPraga: drift.pragaId.toString(),
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
  /// Note: Diagnosticos is now a static/lookup table, not user data
  static DiagnosticosCompanion toDrift(DiagnosticoEntity entity) {
    return DiagnosticosCompanion(
      firebaseId: Value(entity.id),
      idReg: Value(entity.id),
      defensivoId: Value(int.tryParse(entity.idDefensivo) ?? 0),
      culturaId: Value(int.tryParse(entity.idCultura) ?? 0),
      pragaId: Value(int.tryParse(entity.idPraga) ?? 0),
      dsMin: Value(entity.dosagem.dosagemMinima?.toString()),
      dsMax: Value(entity.dosagem.dosagemMaxima.toString()),
      um: Value(entity.dosagem.unidadeMedida ?? ''),
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

  static DiagnosticoEntity fromHive(Diagnostico hive) {
    return DiagnosticoEntity(
      id: hive.firebaseId ?? hive.id.toString(),
      idDefensivo: hive.defensivoId.toString(),
      idCultura: hive.culturaId.toString(),
      idPraga: hive.pragaId.toString(),
      nomeDefensivo: '', // Resolved via extension
      nomeCultura: '', // Resolved via extension
      nomePraga: '', // Resolved via extension
      dosagem: DosagemEntity(
        dosagemMinima: double.tryParse(hive.dsMin ?? '0'),
        dosagemMaxima: double.tryParse(hive.dsMax) ?? 0.0,
        unidadeMedida: hive.um,
      ),
      aplicacao: AplicacaoEntity(
        terrestre: hive.minAplicacaoT != null
            ? AplicacaoTerrestrefEntity(
                volumeMinimo: double.tryParse(hive.minAplicacaoT!),
                volumeMaximo: double.tryParse(hive.maxAplicacaoT ?? '0'),
                unidadeMedida: hive.umT,
              )
            : null,
        aerea: hive.minAplicacaoA != null
            ? AplicacaoAereaEntity(
                volumeMinimo: double.tryParse(hive.minAplicacaoA!),
                volumeMaximo: double.tryParse(hive.maxAplicacaoA ?? '0'),
                unidadeMedida: hive.umA,
              )
            : null,
        intervaloReaplicacao: hive.intervalo,
        intervaloReaplicacao2: hive.intervalo2,
        epocaAplicacao: hive.epocaAplicacao,
      ),
      createdAt: null, // Static data doesn't have user timestamps
      updatedAt: null,
    );
  }

  static DiagnosticosStats statsFromHiveStats(dynamic hiveStats) {
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
