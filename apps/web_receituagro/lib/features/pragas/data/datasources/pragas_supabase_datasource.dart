import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/praga_model.dart';

/// Remote data source interface for pragas
abstract class PragasRemoteDataSource {
  Future<List<PragaModel>> getAllPragas();
  Future<PragaModel> getPragaById(String id);
  Future<List<PragaModel>> searchPragas(String query);
  Future<PragaModel> createPraga(PragaModel praga);
  Future<PragaModel> updatePraga(PragaModel praga);
  Future<void> deletePraga(String id);
}

/// Supabase implementation of pragas remote data source
class PragasSupabaseDataSource implements PragasRemoteDataSource {
  final SupabaseClient client;
  static const String _tableName = 'pragas';

  PragasSupabaseDataSource(this.client);

  @override
  Future<List<PragaModel>> getAllPragas() async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .order('nome_comum', ascending: true);

      return (response as List)
          .map((json) => PragaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar pragas: $e');
    }
  }

  @override
  Future<PragaModel> getPragaById(String id) async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return PragaModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao buscar praga: $e');
    }
  }

  @override
  Future<List<PragaModel>> searchPragas(String query) async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .or('nome_comum.ilike.%$query%,nome_cientifico.ilike.%$query%,nomes_secundarios.ilike.%$query%,ordem.ilike.%$query%')
          .order('nome_comum', ascending: true);

      return (response as List)
          .map((json) => PragaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar pragas: $e');
    }
  }

  @override
  Future<PragaModel> createPraga(PragaModel praga) async {
    try {
      final data = praga.toJson();
      data.remove('id');
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return PragaModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao criar praga: $e');
    }
  }

  @override
  Future<PragaModel> updatePraga(PragaModel praga) async {
    try {
      final data = praga.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(_tableName)
          .update(data)
          .eq('id', praga.id)
          .select()
          .single();

      return PragaModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao atualizar praga: $e');
    }
  }

  @override
  Future<void> deletePraga(String id) async {
    try {
      await client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar praga: $e');
    }
  }
}
