import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/fitossanitario_model.dart';

abstract class FitossanitariosRemoteDataSource {
  Future<List<FitossanitarioModel>> getFitossanitarios();
  Future<FitossanitarioModel> getFitossanitarioById(String id);
}

class FitossanitariosRemoteDataSourceImpl
    implements FitossanitariosRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const FitossanitariosRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<FitossanitarioModel>> getFitossanitarios() async {
    try {
      final response = await _supabaseClient.from('fitossanitarios').select();

      return (response as List)
          .map((e) => FitossanitarioModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<FitossanitarioModel> getFitossanitarioById(String id) async {
    try {
      final response = await _supabaseClient
          .from('fitossanitarios')
          .select()
          .eq('id', id)
          .single();

      return FitossanitarioModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
