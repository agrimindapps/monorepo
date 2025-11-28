import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/praga_info_model.dart';

/// Remote data source interface for praga info
abstract class PragaInfoRemoteDataSource {
  Future<PragaInfoModel?> getPragaInfoByPragaId(String pragaId);
  Future<PragaInfoModel> getPragaInfoById(String id);
  Future<PragaInfoModel> createPragaInfo(PragaInfoModel info);
  Future<PragaInfoModel> updatePragaInfo(PragaInfoModel info);
  Future<void> deletePragaInfo(String id);
  Future<void> deletePragaInfoByPragaId(String pragaId);
}

/// Supabase implementation of praga info remote data source
class PragaInfoSupabaseDataSource implements PragaInfoRemoteDataSource {
  final SupabaseClient client;
  static const String _tableName = 'pragas_info';

  const PragaInfoSupabaseDataSource(this.client);

  @override
  Future<PragaInfoModel?> getPragaInfoByPragaId(String pragaId) async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('praga_id', pragaId)
          .maybeSingle();

      if (response == null) return null;

      return PragaInfoModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar informações da praga: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar informações: $e');
    }
  }

  @override
  Future<PragaInfoModel> getPragaInfoById(String id) async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return PragaInfoModel.fromJson(response);
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
  Future<PragaInfoModel> createPragaInfo(PragaInfoModel info) async {
    try {
      final data = info.toJson();
      if (data['id'] == null || (data['id'] as String).isEmpty) {
        data.remove('id');
      }
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return PragaInfoModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao criar informações: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao criar informações: $e');
    }
  }

  @override
  Future<PragaInfoModel> updatePragaInfo(PragaInfoModel info) async {
    try {
      final data = info.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(_tableName)
          .update(data)
          .eq('id', info.id)
          .select()
          .single();

      return PragaInfoModel.fromJson(response);
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
  Future<void> deletePragaInfo(String id) async {
    try {
      await client.from(_tableName).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar informações: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao deletar informações: $e');
    }
  }

  @override
  Future<void> deletePragaInfoByPragaId(String pragaId) async {
    try {
      await client
          .from(_tableName)
          .delete()
          .eq('praga_id', pragaId);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar informações: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao deletar informações: $e');
    }
  }
}
