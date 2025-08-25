import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/comentarios_design_tokens.dart';
import '../models/comentario_edit_state.dart';
import '../models/comentario_model.dart';
import '../models/comentarios_state.dart';
import '../services/comentarios_service.dart';

class ComentariosController extends ChangeNotifier {
  final ComentariosService _service;
  final TextEditingController searchController = TextEditingController();
  
  Timer? _debounceTimer;
  bool _isDisposed = false;
  
  ComentariosState _state = const ComentariosState();
  ComentariosState get state => _state;

  String? pkIdentificador;
  String? ferramenta;

  ComentariosController({required ComentariosService service}) : _service = service {
    _initializeController();
  }

  void _initializeController() {
    searchController.addListener(_onSearchChanged);
    loadComentarios();
  }

  void _updateState(ComentariosState newState) {
    if (_isDisposed) return;
    _state = newState;
    notifyListeners();
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

  Future<void> loadComentarios() async {
    if (_isDisposed) return;

    _updateState(_state.copyWith(isLoading: true, error: null));

    try {
      final comentarios = await _service.getAllComentarios(
        pkIdentificador: pkIdentificador,
      );

      final maxComentarios = _service.getMaxComentarios();
      final quantComentarios = comentarios.length;

      final comentariosFiltrados = _service.filterComentarios(
        comentarios,
        _state.searchText,
        pkIdentificador: pkIdentificador,
        ferramenta: ferramenta,
      );


      _updateState(_state.copyWith(
        comentarios: comentarios,
        comentariosFiltrados: comentariosFiltrados,
        quantComentarios: quantComentarios,
        maxComentarios: maxComentarios,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      if (!_isDisposed) {
        _updateState(_state.copyWith(
          isLoading: false,
          error: 'Erro ao carregar comentários: $e',
        ));
      }
    }
  }

  void _onSearchChanged() {
    if (_isDisposed) return;

    final searchText = searchController.text;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(ComentariosDesignTokens.debounceDelay, () {
      if (_isDisposed) return;

      final filteredComentarios = _service.filterComentarios(
        _state.comentarios,
        searchText,
        pkIdentificador: pkIdentificador,
        ferramenta: ferramenta,
      );

      _updateState(_state.copyWith(
        searchText: searchText,
        comentariosFiltrados: filteredComentarios,
      ));
    });
  }

  void clearSearch() {
    searchController.clear();
  }

  Future<void> addComentario(String conteudo) async {
    if (_isDisposed) return;

    if (!_service.isValidContent(conteudo)) {
      _showErrorMessage(_service.getValidationErrorMessage());
      return;
    }

    if (!_service.canAddComentario(_state.quantComentarios)) {
      // This should be handled by UI state, but as fallback
      _showErrorMessage('Limite de comentários atingido');
      return;
    }

    final comentario = ComentarioModel(
      id: _service.generateId(),
      idReg: _service.generateIdReg(),
      titulo: '',
      conteudo: conteudo,
      ferramenta: ferramenta ?? 'Comentário direto',
      pkIdentificador: pkIdentificador ?? '',
      status: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _service.addComentario(comentario);
      await loadComentarios();
      _showSuccessMessage(ComentariosDesignTokens.commentSavedMessage);
    } catch (e) {
      _showErrorMessage('${ComentariosDesignTokens.saveErrorMessage}: $e');
    }
  }

  void startEditingComentario(ComentarioModel comentario) {
    if (_isDisposed) return;

    final newEditStates = Map<String, ComentarioEditState>.from(_state.editStates);
    newEditStates[comentario.id] = ComentarioEditState(
      comentarioId: comentario.id,
      isEditing: true,
      currentContent: comentario.conteudo,
    );

    _updateState(_state.copyWith(editStates: newEditStates));
  }

  void stopEditingComentario(String comentarioId) {
    if (_isDisposed) return;

    final newEditStates = Map<String, ComentarioEditState>.from(_state.editStates);
    newEditStates.remove(comentarioId);

    _updateState(_state.copyWith(editStates: newEditStates));
  }

  void updateEditingContent(String comentarioId, String content) {
    if (_isDisposed) return;

    final currentEditState = _state.editStates[comentarioId];
    if (currentEditState == null || !currentEditState.isEditing) return;

    final newEditStates = Map<String, ComentarioEditState>.from(_state.editStates);
    newEditStates[comentarioId] = currentEditState.copyWith(currentContent: content);

    _updateState(_state.copyWith(editStates: newEditStates));
  }

  Future<void> updateComentario(ComentarioModel comentario, String newContent) async {
    if (_isDisposed) return;

    if (!_service.isValidContent(newContent)) {
      _showErrorMessage(_service.getValidationErrorMessage());
      return;
    }

    // Set saving state
    final newEditStates = Map<String, ComentarioEditState>.from(_state.editStates);
    final currentEditState = newEditStates[comentario.id];
    if (currentEditState != null) {
      newEditStates[comentario.id] = currentEditState.copyWith(isSaving: true);
      _updateState(_state.copyWith(editStates: newEditStates));
    }

    try {
      final updatedComentario = comentario.copyWith(
        conteudo: newContent,
        updatedAt: DateTime.now(),
      );

      await _service.updateComentario(updatedComentario);
      await loadComentarios();
      stopEditingComentario(comentario.id);
      _showSuccessMessage(ComentariosDesignTokens.commentUpdatedMessage);
    } catch (e) {
      // Remove saving state on error
      final errorEditStates = Map<String, ComentarioEditState>.from(_state.editStates);
      final errorEditState = errorEditStates[comentario.id];
      if (errorEditState != null) {
        errorEditStates[comentario.id] = errorEditState.copyWith(isSaving: false);
        _updateState(_state.copyWith(editStates: errorEditStates));
      }
      _showErrorMessage('${ComentariosDesignTokens.updateErrorMessage}: $e');
    }
  }

  Future<void> deleteComentario(ComentarioModel comentario) async {
    if (_isDisposed) return;

    try {
      await _service.deleteComentario(comentario.id);
      await loadComentarios();
      _showSuccessMessage(ComentariosDesignTokens.commentDeletedMessage);
    } catch (e) {
      _showErrorMessage('${ComentariosDesignTokens.deleteErrorMessage}: $e');
    }
  }

  void _showErrorMessage(String message) {
    // This would typically show a snackbar, but since we're using Provider
    // the view layer should handle this
    debugPrint('Error: $message');
  }

  void _showSuccessMessage(String message) {
    // This would typically show a snackbar, but since we're using Provider
    // the view layer should handle this
    debugPrint('Success: $message');
  }

  String getHeaderSubtitle() {
    if (_state.isLoading) {
      return ComentariosDesignTokens.loadingMessage;
    }

    final total = _state.comentarios.length;
    if (total > 0) {
      return '$total comentários';
    }

    return 'Suas anotações pessoais';
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }
}