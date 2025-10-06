import '../classes/pragas_class.dart';
class PragaEntity {
  final String id;
  final String nomeComum;
  final String nomeCientifico;
  final bool isAtiva;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const PragaEntity({
    required this.id,
    required this.nomeComum,
    required this.nomeCientifico,
    required this.isAtiva,
    this.createdAt,
    this.updatedAt,
  });
}

/// Adapter class to convert between Supabase Pragas and Core PragaEntity
class PragaAdapter {
  /// Converts Supabase Pragas to Core PragaEntity
  /// Simplified implementation for demonstration purposes
  static PragaEntity toEntity(Pragas model) {
    return PragaEntity(
      id: model.objectId.isNotEmpty ? model.objectId : DateTime.now().millisecondsSinceEpoch.toString(),
      nomeComum: model.nomeComum.isNotEmpty ? model.nomeComum : 'Praga Não Identificada',
      nomeCientifico: model.nomeCientifico.isNotEmpty 
          ? model.nomeCientifico 
          : '${model.genero ?? 'Genus'} ${model.especie ?? 'species'}',
      isAtiva: model.status == 1,
      createdAt: model.createdAt > 0 
          ? DateTime.fromMillisecondsSinceEpoch(model.createdAt) 
          : DateTime.now(),
      updatedAt: model.updatedAt > 0 
          ? DateTime.fromMillisecondsSinceEpoch(model.updatedAt) 
          : DateTime.now(),
    );
  }

  /// Converts Core PragaEntity back to Supabase Pragas
  /// Simplified implementation for demonstration purposes
  static Pragas fromEntity(PragaEntity entity) {
    final nomeParts = entity.nomeCientifico.split(' ');
    final genero = nomeParts.isNotEmpty ? nomeParts[0] : '';
    final especie = nomeParts.length > 1 ? nomeParts[1] : '';

    return Pragas(
      objectId: entity.id,
      createdAt: entity.createdAt?.millisecondsSinceEpoch ?? 0,
      updatedAt: entity.updatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      idReg: entity.id,
      status: entity.isAtiva ? 1 : 0,
      nomeComum: entity.nomeComum,
      nomeCientifico: entity.nomeCientifico,
      familia: 'Família Padrão',
      ordem: 'Ordem Padrão',
      genero: genero,
      especie: especie,
      tipoPraga: 'Tipo Padrão',
    );
  }

  /// Converts list of Supabase models to Core entities
  static List<PragaEntity> toEntityList(List<Pragas> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Converts list of Core entities to Supabase models
  static List<Pragas> fromEntityList(List<PragaEntity> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }
}
