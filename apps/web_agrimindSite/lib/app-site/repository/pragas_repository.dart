import 'package:supabase_flutter/supabase_flutter.dart';
import '../classes/pragas_class.dart';

class PragasRepository {
  final _client = Supabase.instance.client;

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
}
