// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../models/comentarios_models.dart';

class ComentariosRepository {
  final String _boxName = 'comentariosBox';
  Box<Comentarios>? _box;

  Future<Box<Comentarios>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      try {
        // Verifica se a box já está aberta com tipo incorreto
        if (Hive.isBoxOpen(_boxName)) {
          final existingBox = Hive.box(_boxName);
          if (existingBox is! Box<Comentarios>) {
            await existingBox.close();
          }
        }
        
        _box = await Hive.openBox<Comentarios>(_boxName);
      } catch (e) {
        // Se houver erro de adapter/typeId, deleta o box e cria um novo
        try {
          if (Hive.isBoxOpen(_boxName)) {
            await Hive.box(_boxName).close();
          }
          await Hive.deleteBoxFromDisk(_boxName);
          _box = await Hive.openBox<Comentarios>(_boxName);
        } catch (deleteError) {
          // Em último caso, tenta abrir sem tipagem forte
          _box = await Hive.openBox<Comentarios>(_boxName);
        }
      }
    }
    return _box!;
  }

  Future<void> addComentario(Comentarios comentario) async {
    final box = await _getBox();
    await box.put(comentario.id, comentario);
  }

  Future<List<Comentarios>> getAllComentarios() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<Comentarios?> getComentarioById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  Future<List<Comentarios>> getComentariosByFerramenta(
      String ferramenta) async {
    final box = await _getBox();
    return box.values.where((c) => c.ferramenta.contains(ferramenta)).toList();
  }

  Future<void> updateComentario(Comentarios comentario) async {
    final box = await _getBox();
    await box.put(comentario.id, comentario);
  }

  Future<void> deleteComentario(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> deleteAllComentarios() async {
    final box = await _getBox();
    await box.clear();
  }

  Future<void> closeBox() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
  
  // Método para forçar fechamento e limpeza de cache
  Future<void> dispose() async {
    await closeBox();
  }
  
  // Método para verificar se o box está aberto
  bool get isBoxOpen => _box != null && _box!.isOpen;
  
  // Método para executar operações em lote de forma otimizada
  Future<void> performBatchOperations(List<Future<void> Function(Box<Comentarios>)> operations) async {
    final box = await _getBox();
    
    for (final operation in operations) {
      await operation(box);
    }
  }
}
