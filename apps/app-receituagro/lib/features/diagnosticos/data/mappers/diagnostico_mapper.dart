
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
      idDefensivo: drift.defenisivoId.toString(),
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
      createdAt: drift.createdAt,
      updatedAt: drift.updatedAt ?? drift.createdAt,
    );
  }

  static DiagnosticoEntity fromDriftData(DiagnosticoData data) {
    return DiagnosticoEntity(
      id: data.firebaseId ?? data.id.toString(),
      idDefensivo: data.defenisivoId.toString(),
      idCultura: data.culturaId.toString(),
      idPraga: data.pragaId.toString(),
      nomeDefensivo: '', // Será resolvido por join/lookup
      nomeCultura: '', // Será resolvido por join/lookup
      nomePraga: '', // Será resolvido por join/lookup
      dosagem: DosagemEntity(
        dosagemMinima: double.tryParse(data.dsMin ?? '0'),
        dosagemMaxima: double.tryParse(data.dsMax) ?? 0.0,
        unidadeMedida: data.um,
      ),
      aplicacao: AplicacaoEntity(
        terrestre: data.minAplicacaoT != null
            ? AplicacaoTerrestrefEntity(
                volumeMinimo: double.tryParse(data.minAplicacaoT!),
                volumeMaximo: double.tryParse(data.maxAplicacaoT ?? '0'),
                unidadeMedida: data.umT,
              )
            : null,
        aerea: data.minAplicacaoA != null
            ? AplicacaoAereaEntity(
                volumeMinimo: double.tryParse(data.minAplicacaoA!),
                volumeMaximo: double.tryParse(data.maxAplicacaoA ?? '0'),
                unidadeMedida: data.umA,
              )
            : null,
        intervaloReaplicacao: data.intervalo,
        intervaloReaplicacao2: data.intervalo2,
        epocaAplicacao: data.epocaAplicacao,
      ),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt ?? data.createdAt,
    );
  }

  static List<DiagnosticoEntity> fromDriftList(List<DiagnosticoData> dataList) {
    return dataList.map(fromDriftData).toList();
  }

  /// Converts DiagnosticoEntity to Drift Diagnostico (for backward compatibility)
  /// Note: This method creates a DiagnosticosCompanion for insertion
  static DiagnosticosCompanion toDrift(DiagnosticoEntity entity) {
    return DiagnosticosCompanion(
      firebaseId: Value(entity.id),
      userId: const Value(''), // Needs to be set by caller
      moduleName: const Value('diagnosticos'),
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      updatedAt: Value(entity.updatedAt ?? DateTime.now()),
      isDirty: const Value(false),
      isDeleted: const Value(false),
      version: const Value(1),
      idReg: Value(entity.id),
      defenisivoId: Value(int.tryParse(entity.idDefensivo) ?? 0),
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
      idDefensivo: hive.defenisivoId.toString(),
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
      createdAt: hive.createdAt,
      updatedAt: hive.updatedAt ?? hive.createdAt,
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
