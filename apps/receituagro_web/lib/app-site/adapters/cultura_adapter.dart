// Adapter to bridge Supabase Cultura model with Core CulturaEntity
// Note: Currently using minimal core integration for demonstration purposes
import '../classes/cultura_class.dart';

// Temporary stub types until core package is fully implemented
class CulturaEntity {
  final String id;
  final String nomeComum;
  final bool isAtiva;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const CulturaEntity({
    required this.id,
    required this.nomeComum,
    required this.isAtiva,
    this.createdAt,
    this.updatedAt,
  });
}

/// Adapter class to convert between Supabase Cultura and Core CulturaEntity
class CulturaAdapter {
  /// Converts Supabase Cultura to Core CulturaEntity
  /// Simplified implementation for demonstration purposes
  static CulturaEntity toEntity(Cultura model) {
    return CulturaEntity(
      id: model.objectId.isNotEmpty ? model.objectId : DateTime.now().millisecondsSinceEpoch.toString(),
      nomeComum: model.cultura.isNotEmpty ? model.cultura : 'Cultura Não Identificada',
      isAtiva: model.status == 1,
      createdAt: model.createdAt > 0 
          ? DateTime.fromMillisecondsSinceEpoch(model.createdAt) 
          : DateTime.now(),
      updatedAt: model.updatedAt > 0 
          ? DateTime.fromMillisecondsSinceEpoch(model.updatedAt) 
          : DateTime.now(),
    );
  }

  /// Converts Core CulturaEntity back to Supabase Cultura
  /// Simplified implementation for demonstration purposes
  static Cultura fromEntity(CulturaEntity entity) {
    return Cultura(
      objectId: entity.id,
      createdAt: entity.createdAt?.millisecondsSinceEpoch ?? 0,
      updatedAt: entity.updatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      idReg: entity.id,
      status: entity.isAtiva ? 1 : 0,
      cultura: entity.nomeComum,
    );
  }

  /// Converts list of Supabase models to Core entities
  static List<CulturaEntity> toEntityList(List<Cultura> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Converts list of Core entities to Supabase models
  static List<Cultura> fromEntityList(List<CulturaEntity> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }
}