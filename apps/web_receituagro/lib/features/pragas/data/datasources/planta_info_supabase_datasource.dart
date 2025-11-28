import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/planta_info_model.dart';

/// Remote data source interface for planta info
abstract class PlantaInfoRemoteDataSource {
  Future<PlantaInfoModel?> getPlantaInfoByPragaId(String pragaId);
  Future<PlantaInfoModel> getPlantaInfoById(String id);
  Future<PlantaInfoModel> createPlantaInfo(PlantaInfoModel info);
  Future<PlantaInfoModel> updatePlantaInfo(PlantaInfoModel info);
  Future<void> deletePlantaInfo(String id);
  Future<void> deletePlantaInfoByPragaId(String pragaId);
}

/// Supabase implementation of planta info remote data source
class PlantaInfoSupabaseDataSource implements PlantaInfoRemoteDataSource {
  final SupabaseClient client;
  static const String _tableName = 'plantas_info';

  const PlantaInfoSupabaseDataSource(this.client);

  @override
  Future<PlantaInfoModel?> getPlantaInfoByPragaId(String pragaId) async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('praga_id', pragaId)
          .maybeSingle();

      if (response == null) return null;

      return PlantaInfoModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar informações da planta: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar informações: $e');
    }
  }

  @override
  Future<PlantaInfoModel> getPlantaInfoById(String id) async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return PlantaInfoModel.fromJson(response);
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
  Future<PlantaInfoModel> createPlantaInfo(PlantaInfoModel info) async {
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

      return PlantaInfoModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao criar informações: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao criar informações: $e');
    }
  }

  @override
  Future<PlantaInfoModel> updatePlantaInfo(PlantaInfoModel info) async {
    try {
      final data = info.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(_tableName)
          .update(data)
          .eq('id', info.id)
          .select()
          .single();

      return PlantaInfoModel.fromJson(response);
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
  Future<void> deletePlantaInfo(String id) async {
    try {
      await client.from(_tableName).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar informações: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao deletar informações: $e');
    }
  }

  @override
  Future<void> deletePlantaInfoByPragaId(String pragaId) async {
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
