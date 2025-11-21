import 'package:drift/drift.dart';

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

  /// Converte Drift Praga para Entity (updated for Drift migration)
  static PragaEntity fromDriftToEntity(Praga drift) {
    return PragaEntity(
      idReg: drift.idPraga,
      nomeComum: drift.nome,
      nomeCientifico: drift.nomeLatino ?? '',
      tipoPraga: drift.tipo ?? '',
      dominio: null,
      reino: null,
      familia: null,
      genero: null,
      especie: null,
    );
  }

  /// Converte Entity para Drift Praga (Companion for insertion)
  static PragasCompanion fromEntityToDrift(PragaEntity entity) {
    return PragasCompanion(
      idPraga: Value(entity.idReg),
      nome: Value(entity.nomeComum),
      nomeLatino: Value(entity.nomeCientifico),
      tipo: Value(entity.tipoPraga),
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

  /// Converte lista de Praga para Entities
  static List<PragaEntity> fromDriftToEntityList(List<Praga> drifts) {
    return drifts.map((drift) => fromDriftToEntity(drift)).toList();
  }

  /// Converte lista de Entities para Praga Companions
  static List<PragasCompanion> fromEntityToDriftList(List<PragaEntity> entities) {
    return entities.map((entity) => fromEntityToDrift(entity)).toList();
  }

  /// Converte Drift Praga para Entity (alias for consistency)
  static PragaEntity fromDriftToEntity(Praga drift) {
    return fromDriftToEntity(drift);
  }

  /// Converte lista de Drift Praga para Entities (alias for consistency)
  static List<PragaEntity> fromDriftToEntityList(List<Praga> drifts) {
    return fromDriftToEntityList(drifts);
  }
}
