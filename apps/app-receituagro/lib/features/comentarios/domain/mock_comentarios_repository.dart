import 'package:flutter/foundation.dart';
import '../data/comentario_model.dart';
import 'comentarios_service.dart';

class MockComentariosRepository implements IComentariosRepository {
  final List<ComentarioModel> _comentarios = [];
  bool _isInitialized = false;

  void _initializeMockData() {
    if (_isInitialized) return;
    _isInitialized = true;

    _comentarios.addAll([
      ComentarioModel(
        id: '1',
        idReg: 'REG_001',
        titulo: '',
        conteudo: 'Este é um comentário de exemplo sobre defensivos. Muito útil para anotações.',
        ferramenta: 'Defensivos',
        pkIdentificador: 'DEF001',
        status: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ComentarioModel(
        id: '2',
        idReg: 'REG_002',
        titulo: '',
        conteudo: 'Comentário sobre pragas da soja. Identificação visual foi fundamental.',
        ferramenta: 'Pragas',
        pkIdentificador: 'PRAGA001',
        status: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ComentarioModel(
        id: '3',
        idReg: 'REG_003',
        titulo: '',
        conteudo: 'Anotação geral sobre o aplicativo. Interface muito intuitiva!',
        ferramenta: 'Comentário direto',
        pkIdentificador: '',
        status: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  @override
  Future<List<ComentarioModel>> getAllComentarios() async {
    _initializeMockData();
    await Future<void>.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return List.from(_comentarios.where((c) => c.status));
  }

  @override
  Future<void> addComentario(ComentarioModel comentario) async {
    await Future<void>.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    _comentarios.add(comentario);
    debugPrint('Mock: Added comentario ${comentario.id}');
  }

  @override
  Future<void> updateComentario(ComentarioModel comentario) async {
    await Future<void>.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    final index = _comentarios.indexWhere((c) => c.id == comentario.id);
    if (index != -1) {
      _comentarios[index] = comentario;
      debugPrint('Mock: Updated comentario ${comentario.id}');
    }
  }

  @override
  Future<void> deleteComentario(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    final index = _comentarios.indexWhere((c) => c.id == id);
    if (index != -1) {
      _comentarios[index] = _comentarios[index].copyWith(status: false);
      debugPrint('Mock: Deleted comentario $id');
    }
  }
}
