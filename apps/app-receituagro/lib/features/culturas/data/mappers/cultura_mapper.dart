import '../../../../database/receituagro_database.dart';
import '../../data/cultura_model.dart';
import '../../domain/entities/cultura_entity.dart';

/// Mapper para conversão entre CulturaModel/Cultura e CulturaEntity
/// Segue padrão Clean Architecture - isolamento entre camadas
class CulturaMapper {
  /// Converte Model para Entity
  static CulturaEntity toEntity(CulturaModel model) {
    return CulturaEntity(
      id: model.id,
      nome: model.nome,
      grupo: model.grupo,
      descricao: model.descricao,
      isActive: model.isActive,
    );
  }

  /// Converte Drift Cultura para Entity (updated for Drift migration)
  static CulturaEntity fromDriftToEntity(Cultura drift) {
    return CulturaEntity(
      id: drift.idCultura,
      nome: drift.nome,
      grupo: null, // Drift Cultura doesn't have grupo field
      descricao: drift.descricao,
      isActive: true, // Assuming loaded cultures are active
    );
  }

  /// Converte Entity para Model
  static CulturaModel toModel(CulturaEntity entity) {
    return CulturaModel(
      id: entity.id,
      nome: entity.nome,
      grupo: entity.grupo,
      descricao: entity.descricao,
      isActive: entity.isActive,
    );
  }

  /// Converte lista de Models para Entities
  static List<CulturaEntity> toEntityList(List<CulturaModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Converte lista de Cultura para Entities
  static List<CulturaEntity> fromDriftToEntityList(List<Cultura> drifts) {
    return drifts.map((drift) => fromDriftToEntity(drift)).toList();
  }

  /// Converte Cultura Drift para Entity (alias for consistency)
  static CulturaEntity fromDriftToEntity(Cultura drift) {
    return fromDriftToEntity(drift);
  }

  /// Converte lista de Cultura Drift para Entities (alias for consistency)
  static List<CulturaEntity> fromDriftToEntityList(List<Cultura> drifts) {
    return fromDriftToEntityList(drifts);
  }

  /// Converte lista de Entities para Models
  static List<CulturaModel> toModelList(List<CulturaEntity> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
