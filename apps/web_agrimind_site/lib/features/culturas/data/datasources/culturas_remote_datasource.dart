import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/cultura_model.dart';

/// Remote data source for culturas
///
/// Handles all remote operations related to culturas using Supabase
abstract class CulturasRemoteDataSource {
  /// Get all culturas from remote database
  Future<List<CulturaModel>> getCulturas();

  /// Get a single cultura by id from remote database
  Future<CulturaModel> getCulturaById(String id);
}

@LazySingleton(as: CulturasRemoteDataSource)
class CulturasRemoteDataSourceImpl implements CulturasRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const CulturasRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<CulturaModel>> getCulturas() async {
    try {
      final response = await _supabaseClient
          .from('culturas')
          .select()
          .order('nome', ascending: true);

      return (response as List)
          .map((e) => CulturaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar culturas: ${e.toString()}');
    }
  }

  @override
  Future<CulturaModel> getCulturaById(String id) async {
    try {
      final response = await _supabaseClient
          .from('culturas')
          .select()
          .eq('id', id)
          .single();

      return CulturaModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Cultura não encontrada com id: $id');
      }
      throw ServerException('Erro ao buscar cultura: ${e.message}');
    } catch (e) {
      throw ServerException('Erro ao buscar cultura: ${e.toString()}');
    }
  }
}
