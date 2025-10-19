import 'package:hive/hive.dart';

import '../hive_models/comentarios_models.dart';

class ComentariosRepository {
  final String _boxName = 'comentariosBox';
  final int maxComentarios = 10;

  Future<Box<Comentarios>> _openBox() async {
    return await Hive.openBox<Comentarios>(_boxName);
  }

  Future<void> addComentario(Comentarios comentario) async {
    final box = await _openBox();
    await box.put(comentario.id, comentario);
  }

  Future<List<Comentarios>> getAllComentarios() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<Comentarios?> getComentarioById(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  Future<List<Comentarios>> getComentariosByFerramenta(
      String ferramenta) async {
    final box = await _openBox();
    return box.values.where((c) => c.ferramenta.contains(ferramenta)).toList();
  }

  Future<void> updateComentario(Comentarios comentario) async {
    final box = await _openBox();
    await box.put(comentario.id, comentario);
  }

  Future<void> deleteComentario(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> deleteAllComentarios() async {
    final box = await _openBox();
    await box.clear();
  }

  Future<void> closeBox() async {
    final box = await _openBox();
    await box.close();
  }
}
