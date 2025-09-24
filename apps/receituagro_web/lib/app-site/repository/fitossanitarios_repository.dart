// fitossanitario_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../classes/fitossanitario_class.dart';
import '../adapters/fitossanitario_adapter.dart';

/// Repository for Fitossanitario data with Core entity integration
class FitossanitarioRepository {
  final SupabaseClient _client;

  FitossanitarioRepository(this._client);

  // === LEGACY METHODS (Backward Compatibility) ===

  Future<List<Fitossanitario>> fetchAll() async {
    try {
      final response = await _client.from('fitossanitarios').select();

      return (response as List<dynamic>)
          .map((json) => Fitossanitario.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar fitossanitários: $e');
    }
  }

  Future<void> add(Fitossanitario fitossanitario) async {
    try {
      await _client.from('fitossanitarios').insert(fitossanitario.toJson());
    } catch (e) {
      throw Exception('Erro ao adicionar fitossanitário: $e');
    }
  }

  Future<void> update(Fitossanitario fitossanitario) async {
    try {
      await _client
          .from('fitossanitarios')
          .update(fitossanitario.toJson())
          .eq('objectId', fitossanitario.objectId);
    } catch (e) {
      throw Exception('Erro ao atualizar fitossanitário: $e');
    }
  }

  Future<void> delete(String objectId) async {
    try {
      await _client.from('fitossanitarios').delete().eq('objectId', objectId);
    } catch (e) {
      throw Exception('Erro ao deletar fitossanitário: $e');
    }
  }

  // === CORE ENTITY METHODS (New SOLID Approach) ===

  /// Fetches all fitossanitarios as Core entities
  Future<List<FitossanitarioEntity>> fetchAllEntities() async {
    try {
      final supabaseModels = await fetchAll();
      return FitossanitarioAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao buscar fitossanitários (entities): $e');
    }
  }

  /// Fetches fitossanitario by ID as Core entity
  Future<FitossanitarioEntity?> fetchEntityById(String objectId) async {
    try {
      final response = await _client
          .from('fitossanitarios')
          .select()
          .eq('objectId', objectId)
          .limit(1);

      if (response.isEmpty) return null;

      final supabaseModel = Fitossanitario.fromJson(response.first);
      return FitossanitarioAdapter.toEntity(supabaseModel);
    } catch (e) {
      throw Exception('Erro ao buscar fitossanitário por ID (entity): $e');
    }
  }

  /// Searches fitossanitarios by name as Core entities
  Future<List<FitossanitarioEntity>> searchEntitiesByName(String query) async {
    try {
      final response = await _client
          .from('fitossanitarios')
          .select()
          .or('nomeComum.ilike.%$query%,nomeTecnico.ilike.%$query%');

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Fitossanitario.fromJson(json))
          .toList();

      return FitossanitarioAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao pesquisar fitossanitários (entities): $e');
    }
  }

  /// Adds a new fitossanitario from Core entity
  Future<void> addEntity(FitossanitarioEntity entity) async {
    try {
      final supabaseModel = FitossanitarioAdapter.fromEntity(entity);
      await add(supabaseModel);
    } catch (e) {
      throw Exception('Erro ao adicionar fitossanitário (entity): $e');
    }
  }

  /// Updates fitossanitario from Core entity
  Future<void> updateEntity(FitossanitarioEntity entity) async {
    try {
      final supabaseModel = FitossanitarioAdapter.fromEntity(entity);
      await update(supabaseModel);
    } catch (e) {
      throw Exception('Erro ao atualizar fitossanitário (entity): $e');
    }
  }

  /// Fetches fitossanitarios by fabricante as Core entities
  Future<List<FitossanitarioEntity>> fetchEntitiesByFabricante(String fabricante) async {
    try {
      final response = await _client
          .from('fitossanitarios')
          .select()
          .ilike('fabricante', '%$fabricante%');

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Fitossanitario.fromJson(json))
          .toList();

      return FitossanitarioAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao buscar fitossanitários por fabricante (entities): $e');
    }
  }

  /// Fetches active fitossanitarios as Core entities
  Future<List<FitossanitarioEntity>> fetchActiveEntities() async {
    try {
      final response = await _client
          .from('fitossanitarios')
          .select()
          .eq('comercializado', 1);

      final supabaseModels = (response as List<dynamic>)
          .map((json) => Fitossanitario.fromJson(json))
          .toList();

      return FitossanitarioAdapter.toEntityList(supabaseModels);
    } catch (e) {
      throw Exception('Erro ao buscar fitossanitários ativos (entities): $e');
    }
  }
}
