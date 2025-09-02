import '../../domain/entities/defensivo_entity.dart';
import '../../models/defensivo_model.dart';

/// Mapper para conversão entre DefensivoModel e DefensivoEntity
/// Segue padrão Clean Architecture - isolamento entre camadas
class DefensivoMapper {
  /// Converte Model para Entity
  static DefensivoEntity toEntity(DefensivoModel model) {
    return DefensivoEntity(
      id: model.idReg,
      nome: model.line1,
      ingredienteAtivo: model.line2,
      nomeComum: model.nomeComum,
      classeAgronomica: model.classeAgronomica,
      fabricante: model.fabricante,
      modoAcao: model.modoAcao,
      isActive: true,
      lastUpdated: DateTime.now(), // Pode ser melhorado com timestamp real
    );
  }

  /// Converte Entity para Model
  static DefensivoModel toModel(DefensivoEntity entity) {
    return DefensivoModel(
      idReg: entity.id,
      line1: entity.nome,
      line2: entity.ingredienteAtivo,
      nomeComum: entity.nomeComum,
      ingredienteAtivo: entity.ingredienteAtivo,
      classeAgronomica: entity.classeAgronomica,
      fabricante: entity.fabricante,
      modoAcao: entity.modoAcao,
    );
  }

  /// Converte lista de Models para Entities
  static List<DefensivoEntity> toEntityList(List<DefensivoModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Converte lista de Entities para Models
  static List<DefensivoModel> toModelList(List<DefensivoEntity> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}