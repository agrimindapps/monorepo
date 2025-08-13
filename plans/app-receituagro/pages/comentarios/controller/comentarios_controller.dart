// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/models/database.dart';
import '../../../models/comentarios_models.dart';
import '../models/comentarios_state.dart';
import '../services/comentarios_service.dart';

class ComentariosController extends GetxController {
  final ComentariosService _service = Get.find<ComentariosService>();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isControllerDisposed = false;

  final Rx<ComentariosState> _state = const ComentariosState().obs;
  ComentariosState get state => _state.value;
  bool get isControllerDisposed => _isControllerDisposed;

  String? pkIdentificador;
  String? ferramenta;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() {
    _isControllerDisposed = false;
    searchController.addListener(_onSearchChanged);
    loadComentarios();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    if (!_isControllerDisposed) {
      searchController.dispose();
      _isControllerDisposed = true;
    }
    super.onClose();
  }

  void setFilters({String? pkIdentificador, String? ferramenta}) {
    final needsReload = this.pkIdentificador != pkIdentificador ||
        this.ferramenta != ferramenta;

    this.pkIdentificador = pkIdentificador;
    this.ferramenta = ferramenta;

    if (needsReload) {
      loadComentarios();
    }
  }

  void _onSearchChanged() {
    // Verifica se o controller ainda é válido
    if (_isControllerDisposed) {
      return;
    }

    final searchText = searchController.text;

    // Implementa debounce de 300ms
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final filteredComentarios = _service.filterComentarios(
        state.comentarios,
        searchText,
        pkIdentificador: pkIdentificador,
        ferramenta: ferramenta,
      );

      _state.value = state.copyWith(
        searchText: searchText,
        comentariosFiltrados: filteredComentarios,
      );
    });
  }

  Future<void> loadComentarios() async {
    _state.value = state.copyWith(isLoading: true, error: null);

    try {
      final comentarios =
          await _service.getAllComentarios(pkIdentificador: pkIdentificador);
      final maxComentarios = _service.getMaxComentarios();

      // Aplica todos os filtros em uma única iteração
      final comentariosFiltrados = _service.filterComentarios(
        comentarios,
        state.searchText,
        pkIdentificador: pkIdentificador,
        ferramenta: ferramenta,
      );

      // Conta apenas os comentários filtrados por contexto (não por busca)
      final contextFilteredCount = pkIdentificador != null && ferramenta != null
          ? comentarios
              .where((c) =>
                  c.pkIdentificador == pkIdentificador &&
                  c.ferramenta == ferramenta)
              .length
          : comentarios.length;

      _state.value = state.copyWith(
        isLoading: false,
        comentarios: comentarios,
        comentariosFiltrados: comentariosFiltrados,
        quantComentarios: contextFilteredCount,
        maxComentarios: maxComentarios,
      );
    } catch (e) {
      _state.value = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addComentario(String conteudo) async {
    if (conteudo.trim().length < 5) {
      Get.snackbar(
        'Erro',
        'O comentário deve ter pelo menos 5 caracteres',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!_service.canAddComentario(state.quantComentarios)) {
      _showLimitDialog();
      return;
    }

    final comentario = Comentarios(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: true,
      idReg: Database().generateIdReg(),
      titulo: '',
      conteudo: conteudo,
      ferramenta: ferramenta ?? 'Comentário direto',
      pkIdentificador: pkIdentificador ?? '',
    );

    try {
      await _service.addComentario(comentario);
      await loadComentarios();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar comentário: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateComentario(
      Comentarios comentario, String novoConteudo) async {
    if (novoConteudo.trim().length < 5) {
      Get.snackbar(
        'Erro',
        'O comentário deve ter pelo menos 5 caracteres',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final updatedComentario = Comentarios(
      id: comentario.id,
      createdAt: comentario.createdAt,
      updatedAt: DateTime.now(),
      status: comentario.status,
      idReg: comentario.idReg,
      titulo: comentario.titulo,
      conteudo: novoConteudo,
      ferramenta: comentario.ferramenta,
      pkIdentificador: comentario.pkIdentificador,
    );

    try {
      await _service.updateComentario(updatedComentario);
      await loadComentarios();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao atualizar comentário: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteComentario(String id) async {
    try {
      await _service.deleteComentario(id);
      await loadComentarios();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao excluir comentário: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool canAddComentario() {
    return _service.hasAdvancedFeatures() &&
        _service.canAddComentario(state.quantComentarios);
  }

  void showAdvancedFeaturesDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Recursos Avançados'),
        content: const Text(
            'Para aproveitar este recurso, pedimos apenas um momento do seu tempo para assistir a um breve anúncio. Saiba mais em opções.'),
        actions: [
          OutlinedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/config');
            },
            child: const Text('Conferir'),
          ),
        ],
      ),
    );
  }

  void _showLimitDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Recurso Premium'),
        content: Text(
            'Limite de ${state.maxComentarios} comentários atingido. Assine nossos planos para ter acesso ilimitado.'),
        actions: [
          OutlinedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/config');
            },
            child: const Text('Acessar'),
          ),
        ],
      ),
    );
  }

  // Métodos específicos para callbacks do ComentariosCard

  /// Callback para salvar novo comentário via card
  Future<void> onCardSave(String conteudo) async {
    await addComentario(conteudo);
  }

  /// Callback para editar comentário existente via card
  Future<void> onCardEdit(Comentarios comentario, String novoConteudo) async {
    await updateComentario(comentario, novoConteudo);
  }

  /// Callback para excluir comentário via card
  Future<void> onCardDelete(Comentarios comentario) async {
    await deleteComentario(comentario.id);
  }

  /// Callback para cancelar edição via card
  void onCardCancel() {
    // Implementar lógica específica se necessário
    // Por exemplo, limpar estados temporários
  }

  // Métodos para gerenciamento de estado de edição

  /// Inicia edição de um comentário específico
  void startEditingComentario(String comentarioId, String currentContent) {
    final newEditStates =
        Map<String, ComentarioEditState>.from(state.editStates);
    newEditStates[comentarioId] = ComentarioEditState(
      comentarioId: comentarioId,
      isEditing: true,
      currentContent: currentContent,
    );

    _state.value = state.copyWith(editStates: newEditStates);
  }

  /// Para edição de um comentário específico
  void stopEditingComentario(String comentarioId) {
    final newEditStates =
        Map<String, ComentarioEditState>.from(state.editStates);
    newEditStates[comentarioId] = newEditStates[comentarioId]?.copyWith(
          isEditing: false,
        ) ??
        ComentarioEditState(comentarioId: comentarioId, isEditing: false);

    _state.value = state.copyWith(editStates: newEditStates);
  }

  /// Atualiza o conteúdo sendo editado
  void updateEditingContent(String comentarioId, String content) {
    final newEditStates =
        Map<String, ComentarioEditState>.from(state.editStates);
    newEditStates[comentarioId] = newEditStates[comentarioId]?.copyWith(
          currentContent: content,
        ) ??
        ComentarioEditState(
            comentarioId: comentarioId, currentContent: content);

    _state.value = state.copyWith(editStates: newEditStates);
  }

  /// Marca um comentário como deletado
  void markComentarioAsDeleted(String comentarioId) {
    final newEditStates =
        Map<String, ComentarioEditState>.from(state.editStates);
    newEditStates[comentarioId] = newEditStates[comentarioId]?.copyWith(
          isDeleted: true,
        ) ??
        ComentarioEditState(comentarioId: comentarioId, isDeleted: true);

    _state.value = state.copyWith(editStates: newEditStates);
  }

  /// Cancela edição e restaura conteúdo original
  void cancelEditingComentario(String comentarioId, String originalContent) {
    final newEditStates =
        Map<String, ComentarioEditState>.from(state.editStates);
    newEditStates[comentarioId] = ComentarioEditState(
      comentarioId: comentarioId,
      isEditing: false,
      currentContent: originalContent,
    );

    _state.value = state.copyWith(editStates: newEditStates);
  }

  /// Limpa estado de edição de um comentário
  void clearEditState(String comentarioId) {
    final newEditStates =
        Map<String, ComentarioEditState>.from(state.editStates);
    newEditStates.remove(comentarioId);

    _state.value = state.copyWith(editStates: newEditStates);
  }

  /// Limpa todos os estados de edição
  void clearAllEditStates() {
    _state.value = state.copyWith(editStates: {});
  }

  // Métodos para criação de novo comentário

  /// Inicia criação de novo comentário
  void startCreatingNewComentario() {
    _state.value = state.copyWith(isCreatingNew: true, newCommentContent: '');
  }

  /// Para criação de novo comentário
  void stopCreatingNewComentario() {
    _state.value = state.copyWith(isCreatingNew: false, newCommentContent: '');
  }

  /// Atualiza conteúdo do novo comentário
  void updateNewCommentContent(String content) {
    _state.value = state.copyWith(newCommentContent: content);
  }
}
