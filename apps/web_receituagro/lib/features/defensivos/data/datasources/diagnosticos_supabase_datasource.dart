import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/diagnostico_model.dart';
import 'diagnosticos_remote_datasource.dart';

/// Supabase implementation of diagnosticos remote data source
@LazySingleton(as: DiagnosticosRemoteDataSource)
class DiagnosticosSupabaseDataSource implements DiagnosticosRemoteDataSource {
  final SupabaseClient client;

  const DiagnosticosSupabaseDataSource(this.client);

  @override
  Future<List<DiagnosticoModel>> getDiagnosticosByDefensivoId(
    String defensivoId,
  ) async {
    try {
      final response = await client
          .from('diagnosticos')
          .select()
          .eq('defensivo_id', defensivoId);

      return (response as List)
          .map((json) => DiagnosticoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar diagnósticos: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar diagnósticos: $e');
    }
  }

  @override
  Future<DiagnosticoModel> getDiagnosticoById(String id) async {
    try {
      final response = await client
          .from('diagnosticos')
          .select()
          .eq('id', id)
          .single();

      return DiagnosticoModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Diagnóstico não encontrado');
      }
      throw Exception('Erro ao buscar diagnóstico: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar diagnóstico: $e');
    }
  }

  @override
  Future<DiagnosticoModel> createDiagnostico(DiagnosticoModel diagnostico) async {
    try {
      final response = await client
          .from('diagnosticos')
          .insert(diagnostico.toJson())
          .select()
          .single();

      return DiagnosticoModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao criar diagnóstico: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao criar diagnóstico: $e');
    }
  }

  @override
  Future<DiagnosticoModel> updateDiagnostico(DiagnosticoModel diagnostico) async {
    try {
      final response = await client
          .from('diagnosticos')
          .update(diagnostico.toJson())
          .eq('id', diagnostico.id)
          .select()
          .single();

      return DiagnosticoModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Diagnóstico não encontrado');
      }
      throw Exception('Erro ao atualizar diagnóstico: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao atualizar diagnóstico: $e');
    }
  }

  @override
  Future<void> deleteDiagnostico(String id) async {
    try {
      await client.from('diagnosticos').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar diagnóstico: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao deletar diagnóstico: $e');
    }
  }

  @override
  Future<void> deleteDiagnosticosByDefensivoId(String defensivoId) async {
    try {
      await client
          .from('diagnosticos')
          .delete()
          .eq('defensivo_id', defensivoId);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar diagnósticos: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao deletar diagnósticos: $e');
    }
  }
}
