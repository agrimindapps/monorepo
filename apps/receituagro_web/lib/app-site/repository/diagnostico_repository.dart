import 'package:supabase_flutter/supabase_flutter.dart';
import '../classes/diagnostico_class.dart';
import '../adapters/diagnostico_adapter.dart';

/// Repository for Diagnostico data with Core entity integration
class DiagnosticoRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // === LEGACY METHODS (Backward Compatibility) ===

  Future<List<Diagnostico>> getAllDiagnosticos() async {
    try {
      final response = await _client.from('diagnosticos').select();

      return (response as List).map((json) => Diagnostico.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar diagnósticos: $e');
    }
  }

  Future<Diagnostico> createDiagnostico(Diagnostico diagnostico) async {
    try {
      final response = await _client
          .from('diagnosticos')
          .insert(diagnostico.toJson())
          .select()
          .single();

      return Diagnostico.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar diagnóstico: $e');
    }
  }

  Future<void> updateDiagnostico(String objectId, Diagnostico diagnostico) async {
    try {
      await _client
          .from('diagnosticos')
          .update(diagnostico.toJson())
          .eq('objectId', objectId);
    } catch (e) {
      throw Exception('Erro ao atualizar diagnóstico: $e');
    }
  }

  Future<void> deleteDiagnostico(String objectId) async {
    try {
      await _client.from('diagnosticos').delete().eq('objectId', objectId);
    } catch (e) {
      throw Exception('Erro ao deletar diagnóstico: $e');
    }
  }

  // === CORE ENTITY METHODS (New SOLID Approach) ===

  /// Fetches all diagnosticos as Core entities
  Future<List<DiagnosticoEntity>> getAllEntities() async {
    try {
      final supabaseModels = await getAllDiagnosticos();
      return DiagnosticoAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao buscar diagnósticos (entities): $e');
    }
  }

  /// Fetches diagnostico by ID as Core entity
  Future<DiagnosticoEntity?> getEntityById(String objectId) async {
    try {
      final response = await _client
          .from('diagnosticos')
          .select()
          .eq('objectId', objectId)
          .limit(1);

      if (response.isEmpty) return null;

      final supabaseModel = Diagnostico.fromJson(response.first);
      return DiagnosticoAdapter.toEntity(supabaseModel);
    } catch (e) {
      throw Exception('Erro ao buscar diagnóstico por ID (entity): $e');
    }
  }

  /// Searches diagnosticos by culture as Core entities
  Future<List<DiagnosticoEntity>> searchEntitiesByCulture(String cultura) async {
    try {
      final response = await _client
          .from('diagnosticos')
          .select()
          .ilike('nomeCultura', '%$cultura%');

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Diagnostico.fromJson(json))
          .toList();

      return DiagnosticoAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao pesquisar diagnósticos por cultura (entities): $e');
    }
  }

  /// Searches diagnosticos by pest as Core entities
  Future<List<DiagnosticoEntity>> searchEntitiesByPest(String praga) async {
    try {
      final response = await _client
          .from('diagnosticos')
          .select()
          .ilike('nomePraga', '%$praga%');

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Diagnostico.fromJson(json))
          .toList();

      return DiagnosticoAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao pesquisar diagnósticos por praga (entities): $e');
    }
  }

  /// Creates a new diagnostico from Core entity
  Future<DiagnosticoEntity> createEntity(DiagnosticoEntity entity) async {
    try {
      final supabaseModel = DiagnosticoAdapter.fromEntity(entity);
      final created = await createDiagnostico(supabaseModel);
      return DiagnosticoAdapter.toEntity(created);
    } catch (e) {
      throw Exception('Erro ao criar diagnóstico (entity): $e');
    }
  }

  /// Updates diagnostico from Core entity
  Future<void> updateEntity(DiagnosticoEntity entity) async {
    try {
      final supabaseModel = DiagnosticoAdapter.fromEntity(entity);
      await updateDiagnostico(entity.id, supabaseModel);
    } catch (e) {
      throw Exception('Erro ao atualizar diagnóstico (entity): $e');
    }
  }

  /// Fetches approved diagnosticos as Core entities  
  Future<List<DiagnosticoEntity>> getApprovedEntities() async {
    try {
      final allDiagnosticos = await getAllEntities();
      
      // Filter approved ones
      return allDiagnosticos.where((diagnostico) => diagnostico.isAprovado).toList();
    } catch (e) {
      throw Exception('Erro ao buscar diagnósticos aprovados (entities): $e');
    }
  }

  /// Fetches active diagnosticos as Core entities
  Future<List<DiagnosticoEntity>> getActiveEntities() async {
    try {
      final response = await _client
          .from('diagnosticos')
          .select()
          .eq('Status', true);

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Diagnostico.fromJson(json))
          .toList();

      return DiagnosticoAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao buscar diagnósticos ativos (entities): $e');
    }
  }

  /// Gets treatment recommendations for culture and pest
  Future<List<DiagnosticoEntity>> getRecommendations({
    required String cultura,
    required String praga,
  }) async {
    try {
      final response = await _client
          .from('diagnosticos')
          .select()
          .ilike('nomeCultura', '%$cultura%')
          .ilike('nomePraga', '%$praga%');

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Diagnostico.fromJson(json))
          .toList();

      final entities = DiagnosticoAdapter.toEntityList(supabaseModels);

      // Sort by title for consistent ordering
      entities.sort((a, b) => a.titulo.compareTo(b.titulo));

      return entities.take(10).toList(); // Return top 10 recommendations
    } catch (e) {
      throw Exception('Erro ao buscar recomendações (entities): $e');
    }
  }

  /// Gets comprehensive diagnosis details in simple format
  Future<Map<String, dynamic>> getDiagnosisDetails(String diagnosticoId) async {
    try {
      final entity = await getEntityById(diagnosticoId);
      if (entity == null) {
        throw Exception('Diagnóstico não encontrado');
      }

      return {
        'diagnostico': entity,
        'titulo': entity.titulo,
        'cultura': entity.cultura,
        'aprovado': entity.isAprovado,
        'criadoEm': entity.createdAt,
        'atualizadoEm': entity.updatedAt,
      };
    } catch (e) {
      throw Exception('Erro ao buscar detalhes do diagnóstico: $e');
    }
  }
}
