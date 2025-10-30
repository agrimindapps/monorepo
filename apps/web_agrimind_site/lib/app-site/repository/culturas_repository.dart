import 'package:supabase_flutter/supabase_flutter.dart';
import '../classes/cultura_class.dart';

class CulturaRepository {
  final SupabaseClient _client = Supabase.instance.client;

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
}
