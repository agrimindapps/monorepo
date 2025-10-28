import '../classes/diagnostico_class.dart';
class DiagnosticoEntity {
  final String id;
  final String titulo;
  final String cultura;
  final bool isAprovado;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const DiagnosticoEntity({
    required this.id,
    required this.titulo,
    required this.cultura,
    required this.isAprovado,
    this.createdAt,
    this.updatedAt,
  });
}

/// Adapter class to convert between Supabase Diagnostico and Core DiagnosticoEntity
class DiagnosticoAdapter {
  /// Converts Supabase Diagnostico to Core DiagnosticoEntity
  /// Simplified implementation for demonstration purposes
  static DiagnosticoEntity toEntity(Diagnostico model) {
    return DiagnosticoEntity(
      id: model.objectId.isNotEmpty ? model.objectId : DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _gerarTituloDiagnostico(model),
      cultura: model.nomeCultura ?? model.fkIdCultura,
      isAprovado: model.status,
      createdAt: model.createdAt > 0 
          ? DateTime.fromMillisecondsSinceEpoch(model.createdAt) 
          : DateTime.now(),
      updatedAt: model.updatedAt > 0 
          ? DateTime.fromMillisecondsSinceEpoch(model.updatedAt) 
          : DateTime.now(),
    );
  }

  /// Converts Core DiagnosticoEntity back to Supabase Diagnostico
  /// Simplified implementation for demonstration purposes
  static Diagnostico fromEntity(DiagnosticoEntity entity) {
    return Diagnostico(
      objectId: entity.id,
      createdAt: entity.createdAt?.millisecondsSinceEpoch ?? 0,
      updatedAt: entity.updatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      status: entity.isAprovado,
      idReg: entity.id,
      fkIdDefensivo: '',
      nomeDefensivo: 'Defensivo Padrão',
      fkIdCultura: entity.cultura,
      nomeCultura: entity.cultura,
      fkIdPraga: '',
      nomePraga: 'Praga Padrão',
      dsMax: '1.0',
      um: 'L/ha',
      epocaAplicacao: 'Conforme recomendação técnica',
    );
  }

  /// Converts list of Supabase models to Core entities
  static List<DiagnosticoEntity> toEntityList(List<Diagnostico> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Converts list of Core entities to Supabase models
  static List<Diagnostico> fromEntityList(List<DiagnosticoEntity> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }

  /// Generates diagnosis title from model
  static String _gerarTituloDiagnostico(Diagnostico model) {
    final praga = model.nomePraga ?? 'Problema';
    final cultura = model.nomeCultura ?? 'cultura';
    
    return 'Controle de $praga em $cultura';
  }
}
