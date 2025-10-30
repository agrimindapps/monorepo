// fitossanitario_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../classes/fitossanitario_class.dart';

class FitossanitarioRepository {
  final SupabaseClient _client;

  FitossanitarioRepository(this._client);

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
}
