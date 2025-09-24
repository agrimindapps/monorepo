import 'package:supabase_flutter/supabase_flutter.dart';
import '../classes/cultura_class.dart';
import '../adapters/cultura_adapter.dart';

/// Repository for Cultura data with Core entity integration
class CulturaRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // === LEGACY METHODS (Backward Compatibility) ===

  Future<List<Cultura>> getAllCulturas() async {
    try {
      final response = await _client.from('culturas').select();

      return (response as List).map((json) => Cultura.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar culturas: $e');
    }
  }

  Future<Cultura> createCultura(Cultura cultura) async {
    try {
      final response = await _client
          .from('culturas')
          .insert(cultura.toJson())
          .select()
          .single();

      return Cultura.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar cultura: $e');
    }
  }

  Future<void> updateCultura(String objectId, Cultura cultura) async {
    try {
      await _client
          .from('culturas')
          .update(cultura.toJson())
          .eq('objectId', objectId);
    } catch (e) {
      throw Exception('Erro ao atualizar cultura: $e');
    }
  }

  Future<void> deleteCultura(String objectId) async {
    try {
      await _client.from('culturas').delete().eq('objectId', objectId);
    } catch (e) {
      throw Exception('Erro ao deletar cultura: $e');
    }
  }

  // === CORE ENTITY METHODS (New SOLID Approach) ===

  /// Fetches all culturas as Core entities
  Future<List<CulturaEntity>> getAllEntities() async {
    try {
      final supabaseModels = await getAllCulturas();
      return CulturaAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao buscar culturas (entities): $e');
    }
  }

  /// Fetches cultura by ID as Core entity
  Future<CulturaEntity?> getEntityById(String objectId) async {
    try {
      final response = await _client
          .from('culturas')
          .select()
          .eq('objectId', objectId)
          .limit(1);

      if (response.isEmpty) return null;

      final supabaseModel = Cultura.fromJson(response.first);
      return CulturaAdapter.toEntity(supabaseModel);
    } catch (e) {
      throw Exception('Erro ao buscar cultura por ID (entity): $e');
    }
  }

  /// Searches culturas by name as Core entities
  Future<List<CulturaEntity>> searchEntitiesByName(String query) async {
    try {
      final response = await _client
          .from('culturas')
          .select()
          .ilike('cultura', '%$query%');

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Cultura.fromJson(json))
          .toList();

      return CulturaAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao pesquisar culturas (entities): $e');
    }
  }

  /// Creates a new cultura from Core entity
  Future<CulturaEntity> createEntity(CulturaEntity entity) async {
    try {
      final supabaseModel = CulturaAdapter.fromEntity(entity);
      final created = await createCultura(supabaseModel);
      return CulturaAdapter.toEntity(created);
    } catch (e) {
      throw Exception('Erro ao criar cultura (entity): $e');
    }
  }

  /// Updates cultura from Core entity
  Future<void> updateEntity(CulturaEntity entity) async {
    try {
      final supabaseModel = CulturaAdapter.fromEntity(entity);
      await updateCultura(entity.id, supabaseModel);
    } catch (e) {
      throw Exception('Erro ao atualizar cultura (entity): $e');
    }
  }

  /// Fetches culturas by name pattern as Core entities
  Future<List<CulturaEntity>> getEntitiesByPattern(String pattern) async {
    try {
      final allCulturas = await getAllEntities();
      
      // Filter by name pattern matching
      return allCulturas.where((cultura) => 
        cultura.nomeComum.toLowerCase().contains(pattern.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Erro ao buscar culturas por padrão (entities): $e');
    }
  }

  /// Fetches active culturas as Core entities
  Future<List<CulturaEntity>> getActiveEntities() async {
    try {
      final response = await _client
          .from('culturas')
          .select()
          .eq('Status', 1);

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Cultura.fromJson(json))
          .toList();

      return CulturaAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao buscar culturas ativas (entities): $e');
    }
  }

  /// Recommends similar cultures for rotation
  Future<List<CulturaEntity>> getRotationRecommendations(CulturaEntity currentCultura) async {
    try {
      final allCulturas = await getAllEntities();
      
      // Filter different cultures (simplified recommendation logic)
      final compatibleCultures = allCulturas.where((cultura) => 
        cultura.id != currentCultura.id
      ).toList();

      return compatibleCultures.take(10).toList(); // Return top 10
    } catch (e) {
      throw Exception('Erro ao buscar recomendações de rotação (entities): $e');
    }
  }
}
