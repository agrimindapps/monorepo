// Adapter to bridge Supabase Fitossanitario model with Core FitossanitarioEntity
// Note: Currently using minimal core integration due to missing enum definitions
// This demonstrates the adapter pattern for future full implementation
import '../classes/fitossanitario_class.dart';

// Temporary stub types until core package is fully implemented
class FitossanitarioEntity {
  final String id;
  final String nome;
  final String nomeTecnico;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const FitossanitarioEntity({
    required this.id,
    required this.nome, 
    required this.nomeTecnico,
    this.createdAt,
    this.updatedAt,
  });
}

/// Adapter class to convert between Supabase Fitossanitario and Core FitossanitarioEntity
class FitossanitarioAdapter {
  /// Converts Supabase Fitossanitario to Core FitossanitarioEntity  
  /// Simplified implementation for demonstration purposes
  static FitossanitarioEntity toEntity(Fitossanitario model) {
    return FitossanitarioEntity(
      id: model.objectId.isNotEmpty ? model.objectId : DateTime.now().millisecondsSinceEpoch.toString(),
      nome: model.nomeComum.isNotEmpty ? model.nomeComum : 'Produto Sem Nome',
      nomeTecnico: model.nomeTecnico.isNotEmpty ? model.nomeTecnico : model.nomeComum,
      createdAt: model.createdAt > 0 
          ? DateTime.fromMillisecondsSinceEpoch(model.createdAt) 
          : DateTime.now(),
      updatedAt: model.updatedAt > 0 
          ? DateTime.fromMillisecondsSinceEpoch(model.updatedAt) 
          : DateTime.now(),
    );
  }

  /// Converts Core FitossanitarioEntity back to Supabase Fitossanitario
  /// Simplified implementation for demonstration purposes  
  static Fitossanitario fromEntity(FitossanitarioEntity entity) {
    return Fitossanitario(
      objectId: entity.id,
      createdAt: entity.createdAt?.millisecondsSinceEpoch ?? 0,
      updatedAt: entity.updatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      idReg: entity.id,
      status: 1, // Default active
      nomeComum: entity.nome,
      nomeTecnico: entity.nomeTecnico,
      classeAgronomica: 'Classificação Padrão',
      fabricante: 'Fabricante Padrão',
      comercializado: 1,
      formulacao: 'Formulação Padrão',
      modoAcao: 'Modo de Ação Padrão',
      mapa: '',
      ingredienteAtivo: 'Ingrediente Padrão',
      quantProduto: '0%',
      elegivel: true,
    );
  }

  /// Converts list of Supabase models to Core entities
  static List<FitossanitarioEntity> toEntityList(List<Fitossanitario> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Converts list of Core entities to Supabase models
  static List<Fitossanitario> fromEntityList(List<FitossanitarioEntity> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }
}