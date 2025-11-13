import 'package:injectable/injectable.dart';

import '../comentario_model.dart';

/// Local datasource for comentarios using in-memory storage
/// Simplified version without Hive persistence (session only)
abstract class ComentariosLocalDatasource {
  Future<List<ComentarioModel>> getComentarios();
  Future<ComentarioModel?> getComentarioById(String id);
  Future<void> addComentario(ComentarioModel comentario);
  Future<void> updateComentario(ComentarioModel comentario);
  Future<void> deleteComentario(String id);
  Future<List<ComentarioModel>> getComentariosByContext(String pkIdentificador);
  Future<List<ComentarioModel>> getComentariosByTool(String ferramenta);
  Future<List<ComentarioModel>> searchComentarios(String query);
  Future<void> clearCache();
}

@LazySingleton(as: ComentariosLocalDatasource)
class ComentariosLocalDatasourceImpl implements ComentariosLocalDatasource {
  // In-memory storage (session only)
  final Map<String, ComentarioModel> _storage = {};
  
  ComentariosLocalDatasourceImpl();

  @override
  Future<List<ComentarioModel>> getComentarios() async {
    return _storage.values.where((c) => c.status).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<ComentarioModel?> getComentarioById(String id) async {
    return _storage[id];
  }

  @override
  Future<void> addComentario(ComentarioModel comentario) async {
    _storage[comentario.id] = comentario;
  }

  @override
  Future<void> updateComentario(ComentarioModel comentario) async {
    _storage[comentario.id] = comentario;
  }

  @override
  Future<void> deleteComentario(String id) async {
    _storage.remove(id);
  }

  @override
  Future<List<ComentarioModel>> getComentariosByContext(
    String pkIdentificador,
  ) async {
    return _storage.values
        .where((c) => c.status && c.pkIdentificador == pkIdentificador)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<ComentarioModel>> getComentariosByTool(String ferramenta) async {
    return _storage.values
        .where((c) => c.status && c.ferramenta == ferramenta)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<ComentarioModel>> searchComentarios(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _storage.values
        .where((c) =>
            c.status &&
            (c.comentario.toLowerCase().contains(lowercaseQuery) ||
                (c.publicName?.toLowerCase().contains(lowercaseQuery) ?? false)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> clearCache() async {
    _storage.clear();
  }
}
