import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cultura_model.dart';

/// Remote data source interface for culturas
abstract class CulturasRemoteDataSource {
  Future<List<CulturaModel>> getAllCulturas();
  Future<CulturaModel> getCulturaById(String id);
  Future<List<CulturaModel>> searchCulturas(String query);
  Future<CulturaModel> createCultura(CulturaModel cultura);
  Future<CulturaModel> updateCultura(CulturaModel cultura);
  Future<void> deleteCultura(String id);
}

/// Supabase implementation of culturas remote data source
@LazySingleton(as: CulturasRemoteDataSource)
class CulturasSupabaseDataSource implements CulturasRemoteDataSource {
  final SupabaseClient client;
  static const String _tableName = 'culturas';

  CulturasSupabaseDataSource(this.client);

  @override
  Future<List<CulturaModel>> getAllCulturas() async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .order('nome_comum', ascending: true);

      return (response as List)
          .map((json) => CulturaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar culturas: $e');
    }
  }

  @override
  Future<CulturaModel> getCulturaById(String id) async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return CulturaModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao buscar cultura: $e');
    }
  }

  @override
  Future<List<CulturaModel>> searchCulturas(String query) async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .or('nome_comum.ilike.%$query%,nome_cientifico.ilike.%$query%,familia.ilike.%$query%')
          .order('nome_comum', ascending: true);

      return (response as List)
          .map((json) => CulturaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar culturas: $e');
    }
  }

  @override
  Future<CulturaModel> createCultura(CulturaModel cultura) async {
    try {
      final data = cultura.toJson();
      data.remove('id'); // Let Supabase generate the ID
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return CulturaModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao criar cultura: $e');
    }
  }

  @override
  Future<CulturaModel> updateCultura(CulturaModel cultura) async {
    try {
      final data = cultura.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(_tableName)
          .update(data)
          .eq('id', cultura.id)
          .select()
          .single();

      return CulturaModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao atualizar cultura: $e');
    }
  }

  @override
  Future<void> deleteCultura(String id) async {
    try {
      await client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar cultura: $e');
    }
  }
}
