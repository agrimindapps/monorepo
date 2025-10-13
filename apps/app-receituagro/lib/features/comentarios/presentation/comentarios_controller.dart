import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/comentarios_design_tokens.dart';
import '../data/comentario_edit_state.dart';
import '../data/comentario_model.dart';
import '../data/comentarios_state.dart';
import '../domain/comentarios_service.dart';

part 'comentarios_controller.g.dart';

/// Comentarios Notifier - UI State Management with Riverpod
@riverpod
class ComentariosNotifier extends _$ComentariosNotifier {
  Timer? _debounceTimer;
  String? _pkIdentificador;
  String? _ferramenta;

  @override
  ComentariosState build() {
    // Auto-load on first access
    Future.microtask(() => _loadComentarios());

    // Cleanup on dispose
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    return const ComentariosState();
  }

  /// Set filters and reload if changed
  void setFilters({String? pkIdentificador, String? ferramenta}) {
    final needsReload = _pkIdentificador != pkIdentificador || _ferramenta != ferramenta;

    _pkIdentificador = pkIdentificador;
    _ferramenta = ferramenta;

    if (needsReload) {
      _loadComentarios();
    }
  }

  /// Load comentarios from service
  Future<void> _loadComentarios() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(comentariosServiceProvider);
      final comentarios = await service.getAllComentarios(
        pkIdentificador: _pkIdentificador,
      );

      final maxComentarios = service.getMaxComentarios();
      final quantComentarios = comentarios.length;

      final comentariosFiltrados = service.filterComentarios(
        comentarios,
        state.searchText,
        pkIdentificador: _pkIdentificador,
        ferramenta: _ferramenta,
      );

      state = state.copyWith(
        comentarios: comentarios,
        comentariosFiltrados: comentariosFiltrados,
        quantComentarios: quantComentarios,
        maxComentarios: maxComentarios,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar comentários: $e',
      );
    }
  }

  /// Public method to reload comentarios
  Future<void> loadComentarios() async {
    await _loadComentarios();
  }

  /// Handle search text changes with debounce
  void onSearchChanged(String searchText) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(ComentariosDesignTokens.debounceDelay, () {
      final service = ref.read(comentariosServiceProvider);
      final filteredComentarios = service.filterComentarios(
        state.comentarios,
        searchText,
        pkIdentificador: _pkIdentificador,
        ferramenta: _ferramenta,
      );

      state = state.copyWith(
        searchText: searchText,
        comentariosFiltrados: filteredComentarios,
      );
    });
  }

  /// Clear search
  void clearSearch() {
    onSearchChanged('');
  }

  /// Add new comentario
  Future<void> addComentario(String conteudo) async {
    final service = ref.read(comentariosServiceProvider);

    if (!service.isValidContent(conteudo)) {
      _showErrorMessage(service.getValidationErrorMessage());
      return;
    }

    if (!service.canAddComentario(state.quantComentarios)) {
      _showErrorMessage('Limite de comentários atingido');
      return;
    }

    final comentario = ComentarioModel(
      id: service.generateId(),
      idReg: service.generateIdReg(),
      titulo: '',
      conteudo: conteudo,
      ferramenta: _ferramenta ?? 'Comentário direto',
      pkIdentificador: _pkIdentificador ?? '',
      status: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await service.addComentario(comentario);
      await _loadComentarios();
      _showSuccessMessage(ComentariosDesignTokens.commentSavedMessage);
    } catch (e) {
      _showErrorMessage('${ComentariosDesignTokens.saveErrorMessage}: $e');
    }
  }

  /// Start editing a comentario
  void startEditingComentario(ComentarioModel comentario) {
    final newEditStates = Map<String, ComentarioEditState>.from(state.editStates);
    newEditStates[comentario.id] = ComentarioEditState(
      comentarioId: comentario.id,
      isEditing: true,
      currentContent: comentario.conteudo,
    );

    state = state.copyWith(editStates: newEditStates);
  }

  /// Stop editing a comentario
  void stopEditingComentario(String comentarioId) {
    final newEditStates = Map<String, ComentarioEditState>.from(state.editStates);
    newEditStates.remove(comentarioId);

    state = state.copyWith(editStates: newEditStates);
  }

  /// Update editing content
  void updateEditingContent(String comentarioId, String content) {
    final currentEditState = state.editStates[comentarioId];
    if (currentEditState == null || !currentEditState.isEditing) return;

    final newEditStates = Map<String, ComentarioEditState>.from(state.editStates);
    newEditStates[comentarioId] = currentEditState.copyWith(currentContent: content);

    state = state.copyWith(editStates: newEditStates);
  }

  /// Update comentario
  Future<void> updateComentario(ComentarioModel comentario, String newContent) async {
    final service = ref.read(comentariosServiceProvider);

    if (!service.isValidContent(newContent)) {
      _showErrorMessage(service.getValidationErrorMessage());
      return;
    }

    // Set saving state
    final newEditStates = Map<String, ComentarioEditState>.from(state.editStates);
    final currentEditState = newEditStates[comentario.id];
    if (currentEditState != null) {
      newEditStates[comentario.id] = currentEditState.copyWith(isSaving: true);
      state = state.copyWith(editStates: newEditStates);
    }

    try {
      final updatedComentario = comentario.copyWith(
        conteudo: newContent,
        updatedAt: DateTime.now(),
      );

      await service.updateComentario(updatedComentario);
      await _loadComentarios();
      stopEditingComentario(comentario.id);
      _showSuccessMessage(ComentariosDesignTokens.commentUpdatedMessage);
    } catch (e) {
      // Clear saving state on error
      final errorEditStates = Map<String, ComentarioEditState>.from(state.editStates);
      final errorEditState = errorEditStates[comentario.id];
      if (errorEditState != null) {
        errorEditStates[comentario.id] = errorEditState.copyWith(isSaving: false);
        state = state.copyWith(editStates: errorEditStates);
      }
      _showErrorMessage('${ComentariosDesignTokens.updateErrorMessage}: $e');
    }
  }

  /// Delete comentario
  Future<void> deleteComentario(ComentarioModel comentario) async {
    try {
      final service = ref.read(comentariosServiceProvider);
      await service.deleteComentario(comentario.id);
      await _loadComentarios();
      _showSuccessMessage(ComentariosDesignTokens.commentDeletedMessage);
    } catch (e) {
      _showErrorMessage('${ComentariosDesignTokens.deleteErrorMessage}: $e');
    }
  }

  /// Get header subtitle
  String getHeaderSubtitle() {
    if (state.isLoading) {
      return ComentariosDesignTokens.loadingMessage;
    }

    final total = state.comentarios.length;
    if (total > 0) {
      return '$total comentários';
    }

    return 'Suas anotações pessoais';
  }

  void _showErrorMessage(String message) {
    debugPrint('Error: $message');
    // TODO: Show snackbar or dialog if context available
  }

  void _showSuccessMessage(String message) {
    debugPrint('Success: $message');
    // TODO: Show snackbar if context available
  }
}

/// Derived provider for header subtitle
@riverpod
String comentariosHeaderSubtitle(ComentariosHeaderSubtitleRef ref) {
  final state = ref.watch(comentariosNotifierProvider);

  if (state.isLoading) {
    return ComentariosDesignTokens.loadingMessage;
  }

  final total = state.comentarios.length;
  if (total > 0) {
    return '$total comentários';
  }

  return 'Suas anotações pessoais';
}
