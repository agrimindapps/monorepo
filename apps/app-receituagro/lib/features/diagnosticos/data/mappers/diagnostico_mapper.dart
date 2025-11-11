import '../../../../core/data/models/diagnostico_legacy.dart';
import '../../../../database/repositories/diagnostico_repository.dart';
import '../../domain/entities/diagnostico_entity.dart';

class DiagnosticoMapper {
  const DiagnosticoMapper._();

  static DiagnosticoEntity fromHive(DiagnosticoHive hive) {
    return DiagnosticoEntity(
      id: hive.objectId,
      idDefensivo: hive.fkIdDefensivo,
      idCultura: hive.fkIdCultura,
      idPraga: hive.fkIdPraga,
      nomeDefensivo: hive.nomeDefensivo,
      nomeCultura: hive.nomeCultura,
      nomePraga: hive.nomePraga,
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
      createdAt: DateTime.fromMillisecondsSinceEpoch(hive.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(hive.updatedAt),
    );
  }

  static DiagnosticoEntity fromDrift(DiagnosticoData data) {
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
    return dataList.map(fromDrift).toList();
  }

  static DiagnosticoHive toHive(DiagnosticoEntity entity) {
    return DiagnosticoHive(
      objectId: entity.id,
      createdAt:
          entity.createdAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      updatedAt:
          entity.updatedAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      idReg: entity.id,
      fkIdDefensivo: entity.idDefensivo,
      nomeDefensivo: entity.nomeDefensivo,
      fkIdCultura: entity.idCultura,
      nomeCultura: entity.nomeCultura,
      fkIdPraga: entity.idPraga,
      nomePraga: entity.nomePraga,
      dsMin: entity.dosagem.dosagemMinima?.toString(),
      dsMax: entity.dosagem.dosagemMaxima.toString(),
      um: entity.dosagem.unidadeMedida,
      minAplicacaoT: entity.aplicacao.terrestre?.volumeMinimo?.toString(),
      maxAplicacaoT: entity.aplicacao.terrestre?.volumeMaximo?.toString(),
      umT: entity.aplicacao.terrestre?.unidadeMedida,
      minAplicacaoA: entity.aplicacao.aerea?.volumeMinimo?.toString(),
      maxAplicacaoA: entity.aplicacao.aerea?.volumeMaximo?.toString(),
      umA: entity.aplicacao.aerea?.unidadeMedida,
      intervalo: entity.aplicacao.intervaloReaplicacao,
      intervalo2: entity.aplicacao.intervaloReaplicacao2,
      epocaAplicacao: entity.aplicacao.epocaAplicacao,
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
