import '../../../../database/receituagro_database.dart';
import '../../data/defensivo_agrupado_item_model.dart';
import '../../data/defensivo_model.dart';
import '../../domain/entities/defensivo_entity.dart';

/// Mapper unificado para conversão entre diferentes models e DefensivoEntity
/// Segue padrão Clean Architecture - isolamento entre camadas
/// Consolida funcionalidades dos mappers antigos eliminando duplicação
class DefensivoMapper {
  const DefensivoMapper._();

  /// Converte DefensivoModel para Entity
  static DefensivoEntity toEntity(DefensivoModel model) {
    return DefensivoEntity(
      id: model.idReg,
      nome: model.line1,
      ingredienteAtivo: model.line2,
      nomeComum: model.nomeComum,
      classeAgronomica: model.classeAgronomica,
      fabricante: model.fabricante,
      modoAcao: model.modoAcao,
      line1: model.line1,
      line2: model.line2,
      isActive: true,
      lastUpdated: DateTime.now(),
    );
  }

  /// Converte DefensivoAgrupadoItemModel para Entity
  static DefensivoEntity fromAgrupadoToEntity(
    DefensivoAgrupadoItemModel model,
  ) {
    return DefensivoEntity(
      id: model.idReg,
      nome: model.line1,
      ingredienteAtivo: model.ingredienteAtivo ?? model.line2,
      nomeComum: model.line1,
      classeAgronomica: model.classeAgronomica,
      fabricante: model.fabricante,
      modoAcao: model.modoAcao,
      categoria: model.categoria,
      line1: model.line1,
      line2: model.line2,
      count: model.count,
      isActive: true,
      lastUpdated: DateTime.now(),
    );
  }

  /// Converte Entity para DefensivoModel
  static DefensivoModel toModel(DefensivoEntity entity) {
    return DefensivoModel(
      idReg: entity.id,
      line1: entity.line1 ?? entity.nome,
      line2: entity.line2 ?? entity.ingredienteAtivo,
      nomeComum: entity.nomeComum,
      ingredienteAtivo: entity.ingredienteAtivo,
      classeAgronomica: entity.classeAgronomica,
      fabricante: entity.fabricante,
      modoAcao: entity.modoAcao,
    );
  }

  /// Converte Entity para DefensivoAgrupadoItemModel
  static DefensivoAgrupadoItemModel toAgrupadoModel(DefensivoEntity entity) {
    return DefensivoAgrupadoItemModel(
      idReg: entity.id,
      line1: entity.line1 ?? entity.nome,
      line2: entity.line2 ?? entity.ingredienteAtivo,
      count: entity.count,
      ingredienteAtivo: entity.ingredienteAtivo,
      categoria: entity.categoria,
      fabricante: entity.fabricante,
      classeAgronomica: entity.classeAgronomica,
      modoAcao: entity.modoAcao,
    );
  }

  /// Converte lista de DefensivoModel para Entities
  static List<DefensivoEntity> toEntityList(List<DefensivoModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Converte lista de DefensivoAgrupadoItemModel para Entities
  static List<DefensivoEntity> fromAgrupadoToEntityList(
    List<DefensivoAgrupadoItemModel> models,
  ) {
    return models.map((model) => fromAgrupadoToEntity(model)).toList();
  }

  /// Converte lista de Entities para DefensivoModel
  static List<DefensivoModel> toModelList(List<DefensivoEntity> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }

  /// Converte lista de Entities para DefensivoAgrupadoItemModel
  static List<DefensivoAgrupadoItemModel> toAgrupadoModelList(
    List<DefensivoEntity> entities,
  ) {
    return entities.map((entity) => toAgrupadoModel(entity)).toList();
  }

  /// Converte Drift Fitossanitario para Entity (updated for Drift migration)
  static DefensivoEntity fromDriftToEntity(
    Fitossanitario drift, {
    String? modoAcao,
  }) {
    return DefensivoEntity(
      id: drift.idDefensivo,
      nome: drift.nome,
      ingredienteAtivo: drift.ingredienteAtivo ?? '',
      nomeComum: drift.nomeComum ?? drift.nome,
      classeAgronomica: drift.classeAgronomica,
      fabricante: drift.fabricante,
      modoAcao: modoAcao, // Use provided modoAcao
      isActive: drift.status,
      lastUpdated: DateTime.now(),
    );
  }

  /// Converte lista de Fitossanitario para Entities
  static List<DefensivoEntity> fromDriftToEntityList(
    List<Fitossanitario> drifts, {
    Map<int, String?>? infoMap,
  }) {
    return drifts.map((drift) {
      final modoAcao = infoMap?[drift.id];
      return fromDriftToEntity(drift, modoAcao: modoAcao);
    }).toList();
  }
}
