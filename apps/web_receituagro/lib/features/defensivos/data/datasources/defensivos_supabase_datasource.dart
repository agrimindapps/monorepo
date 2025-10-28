import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/defensivo_model.dart';
import 'defensivos_remote_datasource.dart';

/// Supabase implementation of defensivos remote data source
@LazySingleton(as: DefensivosRemoteDataSource)
class DefensivosSupabaseDataSource implements DefensivosRemoteDataSource {
  final SupabaseClient client;

  const DefensivosSupabaseDataSource(this.client);

  @override
  Future<List<DefensivoModel>> getAllDefensivos() async {
    try {
      // Fetch from vw_fitossanitarios view
      final response = await client.from('vw_fitossanitarios').select();

      // Extract produtos array from each row
      List<DefensivoModel> allDefensivos = [];
      for (var row in response) {
        if (row['produtos'] != null) {
          final produtos = row['produtos'] as List;
          for (var produto in produtos) {
            allDefensivos.add(
              DefensivoModel.fromJson(produto as Map<String, dynamic>),
            );
          }
        }
      }

      return allDefensivos;
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar defensivos: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar defensivos: $e');
    }
  }

  @override
  Future<DefensivoModel> getDefensivoById(String id) async {
    try {
      final response = await client
          .from('vw_diagnosticos')
          .select()
          .eq('fkiddefensivo', id)
          .limit(1)
          .single();

      return DefensivoModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Defensivo não encontrado');
      }
      throw Exception('Erro ao buscar defensivo: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar defensivo: $e');
    }
  }

  @override
  Future<List<DefensivoModel>> searchDefensivos(String query) async {
    try {
      // For now, get all and let the use case filter
      // In production, you might want to implement server-side search
      return getAllDefensivos();
    } catch (e) {
      throw Exception('Erro ao pesquisar defensivos: $e');
    }
  }

  @override
  Future<DefensivoModel> createDefensivo(DefensivoModel defensivo) async {
    try {
      final response = await client
          .from('defensivos')
          .insert(defensivo.toJson())
          .select()
          .single();

      return DefensivoModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao criar defensivo: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao criar defensivo: $e');
    }
  }

  @override
  Future<DefensivoModel> updateDefensivo(DefensivoModel defensivo) async {
    try {
      final response = await client
          .from('defensivos')
          .update(defensivo.toJson())
          .eq('id', defensivo.id)
          .select()
          .single();

      return DefensivoModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Defensivo não encontrado');
      }
      throw Exception('Erro ao atualizar defensivo: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao atualizar defensivo: $e');
    }
  }

  @override
  Future<void> deleteDefensivo(String id) async {
    try {
      await client.from('defensivos').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar defensivo: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao deletar defensivo: $e');
    }
  }
}
