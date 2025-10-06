import '../../../../core/data/models/cultura_hive.dart';
import '../../data/cultura_model.dart';
import '../../domain/entities/cultura_entity.dart';

/// Mapper para conversão entre CulturaModel/CulturaHive e CulturaEntity
/// Segue padrão Clean Architecture - isolamento entre camadas
class CulturaMapper {
  /// Converte Model para Entity
  static CulturaEntity toEntity(CulturaModel model) {
    return CulturaEntity(
      id: model.idReg,
      nome: model.cultura,
      grupo: model.grupo,
      isActive: true, // Assumindo que culturas carregadas estão ativas
    );
  }

  /// Converte CulturaHive para Entity
  static CulturaEntity fromHiveToEntity(CulturaHive hive) {
    return CulturaEntity(
      id: hive.idReg,
      nome: hive.cultura,
      grupo: null, // CulturaHive não tem grupo, definir como null
      isActive: true, // Assumindo que culturas carregadas estão ativas
    );
  }

  /// Converte Entity para Model
  static CulturaModel toModel(CulturaEntity entity) {
    return CulturaModel(
      idReg: entity.id,
      cultura: entity.nome,
      grupo: entity.grupo ?? 'Sem grupo definido',
    );
  }

  /// Converte lista de Models para Entities
  static List<CulturaEntity> toEntityList(List<CulturaModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Converte lista de CulturaHive para Entities
  static List<CulturaEntity> fromHiveToEntityList(List<CulturaHive> hives) {
    return hives.map((hive) => fromHiveToEntity(hive)).toList();
  }

  /// Converte lista de Entities para Models
  static List<CulturaModel> toModelList(List<CulturaEntity> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
