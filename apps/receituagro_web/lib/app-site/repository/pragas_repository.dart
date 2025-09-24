import 'package:supabase_flutter/supabase_flutter.dart';
import '../classes/pragas_class.dart';
import '../adapters/praga_adapter.dart';

/// Repository for Pragas data with Core entity integration
class PragasRepository {
  final _client = Supabase.instance.client;

  // === LEGACY METHODS (Backward Compatibility) ===

  Future<List<Pragas>> getAllPragas() async {
    try {
      final response = await _client.from('pragas').select();

      return (response as List<dynamic>)
          .map((json) => Pragas.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar pragas: $e');
    }
  }

  Future<void> createPraga(Pragas praga) async {
    try {
      await _client.from('pragas').insert(praga.toJson());
    } catch (e) {
      throw Exception('Erro ao criar praga: $e');
    }
  }

  Future<void> updatePraga(String objectId, Pragas praga) async {
    try {
      await _client
          .from('pragas')
          .update(praga.toJson())
          .eq('objectId', objectId);
    } catch (e) {
      throw Exception('Erro ao atualizar praga: $e');
    }
  }

  Future<void> deletePraga(String objectId) async {
    try {
      await _client.from('pragas').delete().eq('objectId', objectId);
    } catch (e) {
      throw Exception('Erro ao deletar praga: $e');
    }
  }

  // === CORE ENTITY METHODS (New SOLID Approach) ===

  /// Fetches all pragas as Core entities
  Future<List<PragaEntity>> getAllEntities() async {
    try {
      final supabaseModels = await getAllPragas();
      return PragaAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao buscar pragas (entities): $e');
    }
  }

  /// Fetches praga by ID as Core entity
  Future<PragaEntity?> getEntityById(String objectId) async {
    try {
      final response = await _client
          .from('pragas')
          .select()
          .eq('objectId', objectId)
          .limit(1);

      if (response.isEmpty) return null;

      final supabaseModel = Pragas.fromJson(response.first);
      return PragaAdapter.toEntity(supabaseModel);
    } catch (e) {
      throw Exception('Erro ao buscar praga por ID (entity): $e');
    }
  }

  /// Searches pragas by name as Core entities
  Future<List<PragaEntity>> searchEntitiesByName(String query) async {
    try {
      final response = await _client
          .from('pragas')
          .select()
          .or('nomeComum.ilike.%$query%,nomeCientifico.ilike.%$query%');

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Pragas.fromJson(json))
          .toList();

      return PragaAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao pesquisar pragas (entities): $e');
    }
  }

  /// Creates a new praga from Core entity
  Future<void> createEntity(PragaEntity entity) async {
    try {
      final supabaseModel = PragaAdapter.fromEntity(entity);
      await createPraga(supabaseModel);
    } catch (e) {
      throw Exception('Erro ao criar praga (entity): $e');
    }
  }

  /// Updates praga from Core entity
  Future<void> updateEntity(PragaEntity entity) async {
    try {
      final supabaseModel = PragaAdapter.fromEntity(entity);
      await updatePraga(entity.id, supabaseModel);
    } catch (e) {
      throw Exception('Erro ao atualizar praga (entity): $e');
    }
  }

  /// Fetches pragas by type pattern as Core entities
  Future<List<PragaEntity>> getEntitiesByType(String tipoPraga) async {
    try {
      final response = await _client
          .from('pragas')
          .select()
          .ilike('tipoPraga', '%$tipoPraga%');

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Pragas.fromJson(json))
          .toList();

      return PragaAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao buscar pragas por tipo (entities): $e');
    }
  }

  /// Fetches active pragas as Core entities
  Future<List<PragaEntity>> getActiveEntities() async {
    try {
      final response = await _client
          .from('pragas')
          .select()
          .eq('Status', 1);

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Pragas.fromJson(json))
          .toList();

      return PragaAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao buscar pragas ativas (entities): $e');
    }
  }

}
