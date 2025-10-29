import '../../domain/entities/comentario_entity.dart';
import '../comentario_model.dart';

/// Service responsible for mapping between ComentarioModel and ComentarioEntity.
///
/// Follows the Mapper Pattern to keep the repository focused on data access
/// and separates the concern of data transformation from persistence logic.
///
/// This is part of the SOLID refactoring to improve SRP compliance.
abstract class IComentariosMapper {
  /// Convert ComentarioModel to ComentarioEntity
  ComentarioEntity modelToEntity(ComentarioModel model);

  /// Convert ComentarioEntity to ComentarioModel
  ComentarioModel entityToModel(ComentarioEntity entity);

  /// Convert multiple models to entities
  List<ComentarioEntity> modelsToEntities(List<ComentarioModel> models);

  /// Convert multiple entities to models
  List<ComentarioModel> entitiesToModels(List<ComentarioEntity> entities);
}

/// Default implementation of ComentariosMapper
class ComentariosMapper implements IComentariosMapper {
  @override
  ComentarioEntity modelToEntity(ComentarioModel model) {
    return ComentarioEntity(
      id: model.id,
      idReg: model.idReg,
      titulo: model.titulo,
      conteudo: model.conteudo,
      ferramenta: model.ferramenta,
      pkIdentificador: model.pkIdentificador,
      status: model.status,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  ComentarioModel entityToModel(ComentarioEntity entity) {
    return ComentarioModel(
      id: entity.id,
      idReg: entity.idReg,
      titulo: entity.titulo,
      conteudo: entity.conteudo,
      ferramenta: entity.ferramenta,
      pkIdentificador: entity.pkIdentificador,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  List<ComentarioEntity> modelsToEntities(List<ComentarioModel> models) {
    return models.map(modelToEntity).toList();
  }

  @override
  List<ComentarioModel> entitiesToModels(List<ComentarioEntity> entities) {
    return entities.map(entityToModel).toList();
  }
}
