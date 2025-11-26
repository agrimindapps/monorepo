import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/defensivo_model.dart';

/// Remote data source for defensivos
///
/// Handles all remote operations related to defensivos using Supabase
abstract class DefensivosRemoteDataSource {
  /// Get all defensivos from remote database
  Future<List<DefensivoModel>> getDefensivos();

  /// Get a single defensivo by id from remote database
  Future<DefensivoModel> getDefensivoById(String id);
}

class DefensivosRemoteDataSourceImpl implements DefensivosRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const DefensivosRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<DefensivoModel>> getDefensivos() async {
    try {
      final response = await _supabaseClient
          .from('defensivos')
          .select()
          .order('nome', ascending: true);

      return (response as List)
          .map((e) => DefensivoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar defensivos: ${e.toString()}');
    }
  }

  @override
  Future<DefensivoModel> getDefensivoById(String id) async {
    try {
      final response = await _supabaseClient
          .from('defensivos')
          .select()
          .eq('id', id)
          .single();

      return DefensivoModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Defensivo não encontrado com id: $id');
      }
      throw ServerException('Erro ao buscar defensivo: ${e.message}');
    } catch (e) {
      throw ServerException('Erro ao buscar defensivo: ${e.toString()}');
    }
  }
}
