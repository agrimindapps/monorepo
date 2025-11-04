import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/praga_model.dart';

abstract class PragasRemoteDataSource {
  Future<List<PragaModel>> getPragas();
  Future<PragaModel> getPragaById(String id);
}

class PragasRemoteDataSourceImpl implements PragasRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const PragasRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<PragaModel>> getPragas() async {
    try {
      final response = await _supabaseClient.from('pragas').select();

      return (response as List)
          .map((e) => PragaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PragaModel> getPragaById(String id) async {
    try {
      final response =
          await _supabaseClient.from('pragas').select().eq('id', id).single();

      return PragaModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
