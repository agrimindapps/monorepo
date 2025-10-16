import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/defensivo_info_model.dart';
import 'defensivos_info_remote_datasource.dart';

/// Supabase implementation of defensivos info remote data source
@LazySingleton(as: DefensivosInfoRemoteDataSource)
class DefensivosInfoSupabaseDataSource implements DefensivosInfoRemoteDataSource {
  final SupabaseClient client;

  const DefensivosInfoSupabaseDataSource(this.client);

  @override
  Future<DefensivoInfoModel?> getDefensivoInfoByDefensivoId(
    String defensivoId,
  ) async {
    try {
      final response = await client
          .from('defensivos_info')
          .select()
          .eq('defensivo_id', defensivoId)
          .maybeSingle();

      if (response == null) return null;

      return DefensivoInfoModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar informações complementares: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar informações: $e');
    }
  }

  @override
  Future<DefensivoInfoModel> getDefensivoInfoById(String id) async {
    try {
      final response = await client
          .from('defensivos_info')
          .select()
          .eq('id', id)
          .single();

      return DefensivoInfoModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Informação não encontrada');
      }
      throw Exception('Erro ao buscar informação: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar informação: $e');
    }
  }

  @override
  Future<DefensivoInfoModel> createDefensivoInfo(
    DefensivoInfoModel info,
  ) async {
    try {
      final response = await client
          .from('defensivos_info')
          .insert(info.toJson())
          .select()
          .single();

      return DefensivoInfoModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao criar informações: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao criar informações: $e');
    }
  }

  @override
  Future<DefensivoInfoModel> updateDefensivoInfo(
    DefensivoInfoModel info,
  ) async {
    try {
      final response = await client
          .from('defensivos_info')
          .update(info.toJson())
          .eq('id', info.id)
          .select()
          .single();

      return DefensivoInfoModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Informação não encontrada');
      }
      throw Exception('Erro ao atualizar informações: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao atualizar informações: $e');
    }
  }

  @override
  Future<void> deleteDefensivoInfo(String id) async {
    try {
      await client.from('defensivos_info').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar informações: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao deletar informações: $e');
    }
  }

  @override
  Future<void> deleteDefensivoInfoByDefensivoId(String defensivoId) async {
    try {
      await client
          .from('defensivos_info')
          .delete()
          .eq('defensivo_id', defensivoId);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar informações: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao deletar informações: $e');
    }
  }
}
