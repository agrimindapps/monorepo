import '../../../../core/data/models/pragas_legacy.dart';
import '../../../../database/receituagro_database.dart';
import '../../data/praga_model.dart';
import '../../domain/entities/praga_entity.dart';

/// Mapper unificado para conversão entre diferentes models e PragaEntity
/// Segue padrão Clean Architecture - isolamento entre camadas
/// Consolida funcionalidades eliminando duplicação
class PragaMapper {
  const PragaMapper._();

  /// Converte PragaModel para Entity
  static PragaEntity toEntity(PragaModel model) {
    return PragaEntity(
      idReg: model.idReg,
      nomeComum: model.nomeComum,
      nomeCientifico: model.nomeCientifico ?? '',
      tipoPraga: model.tipoPraga,
    );
  }

  /// Converte Entity para PragaModel
  static PragaModel toModel(PragaEntity entity) {
    return PragaModel(
      idReg: entity.idReg,
      nomeComum: entity.nomeComum,
      nomeCientifico: entity.nomeCientifico,
      tipoPraga: entity.tipoPraga,
    );
  }

  /// Converte PragasHive para Entity
  static PragaEntity fromHiveToEntity(PragasHive hive) {
    return PragaEntity(
      idReg: hive.idReg,
      nomeComum: hive.nomeComum,
      nomeCientifico: hive.nomeCientifico,
      tipoPraga: hive.tipoPraga,
      dominio: hive.dominio,
      reino: hive.reino,
      familia: hive.familia,
      genero: hive.genero,
      especie: hive.especie,
    );
  }

  /// Converte Entity para PragasHive
  static PragasHive fromEntityToHive(PragaEntity entity) {
    return PragasHive(
      objectId: entity.idReg,
      createdAt: 0,
      updatedAt: 0,
      idReg: entity.idReg,
      nomeComum: entity.nomeComum,
      nomeCientifico: entity.nomeCientifico,
      tipoPraga: entity.tipoPraga,
      dominio: entity.dominio,
      reino: entity.reino,
      familia: entity.familia,
      genero: entity.genero,
      especie: entity.especie,
    );
  }

  /// Converte lista de PragaModel para Entities
  static List<PragaEntity> toEntityList(List<PragaModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Converte lista de Entities para PragaModel
  static List<PragaModel> toModelList(List<PragaEntity> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }

  /// Converte lista de PragasHive para Entities
  static List<PragaEntity> fromHiveToEntityList(List<PragasHive> hives) {
    return hives.map((hive) => fromHiveToEntity(hive)).toList();
  }

  /// Converte lista de Entities para PragasHive
  static List<PragasHive> fromEntityToHiveList(List<PragaEntity> entities) {
    return entities.map((entity) => fromEntityToHive(entity)).toList();
  }

  /// Converte Drift Praga para Entity
  static PragaEntity fromDriftToEntity(Praga drift) {
    return PragaEntity(
      idReg: drift.idPraga,
      nomeComum: drift.nome,
      nomeCientifico: drift.nomeLatino ?? '',
      tipoPraga: drift.tipo ?? '',
    );
  }

  /// Converte lista de Drift Praga para Entities
  static List<PragaEntity> fromDriftToEntityList(List<Praga> drifts) {
    return drifts.map((drift) => fromDriftToEntity(drift)).toList();
  }
}
