import '../../../../core/data/models/diagnostico_hive.dart';
import '../../domain/entities/diagnostico_entity.dart';

class DiagnosticoMapper {
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

  static DiagnosticoHive toHive(DiagnosticoEntity entity) {
    return DiagnosticoHive(
      objectId: entity.id,
      createdAt: entity.createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: entity.updatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
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
