// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

class ComentariosViewModel extends GetxController {
  Timer? _debounceTimer;

  final TextEditingController searchController = TextEditingController();

  // Estados de UI
  final RxBool _isSearching = false.obs;
  final RxString _searchText = ''.obs;
  final RxMap<String, bool> _editingStates = <String, bool>{}.obs;
  final RxMap<String, String> _editingContents = <String, String>{}.obs;
  final RxBool _isCreatingNew = false.obs;
  final RxString _newCommentContent = ''.obs;

  // Callback para quando a busca é executada
  void Function(String)? onSearchPerformed;

  // Getters
  bool get isSearching => _isSearching.value;
  String get searchText => _searchText.value;
  bool get isCreatingNew => _isCreatingNew.value;
  String get newCommentContent => _newCommentContent.value;

  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      final text = searchController.text;
      _searchText.value = text;
      _isSearching.value = text.isNotEmpty;

      // Implementa debounce de 300ms
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        onSearchPerformed?.call(text);
      });
    });
  }

  // Gerenciamento de estado de edição
  void startEditing(String comentarioId, String initialContent) {
    _editingStates[comentarioId] = true;
    _editingContents[comentarioId] = initialContent;
  }

  void stopEditing(String comentarioId) {
    _editingStates.remove(comentarioId);
    _editingContents.remove(comentarioId);
  }

  void updateEditingContent(String comentarioId, String content) {
    _editingContents[comentarioId] = content;
  }

  bool isEditing(String comentarioId) {
    return _editingStates[comentarioId] ?? false;
  }

  String getEditingContent(String comentarioId) {
    return _editingContents[comentarioId] ?? '';
  }

  void cancelEditing(String comentarioId, String originalContent) {
    _editingContents[comentarioId] = originalContent;
    stopEditing(comentarioId);
  }

  // Gerenciamento de novo comentário
  void startCreatingNew() {
    _isCreatingNew.value = true;
    _newCommentContent.value = '';
  }

  void stopCreatingNew() {
    _isCreatingNew.value = false;
    _newCommentContent.value = '';
  }

  void updateNewCommentContent(String content) {
    _newCommentContent.value = content;
  }

  // Validações de UI
  bool isValidCommentContent(String content) {
    final trimmed = content.trim();
    return trimmed.length >= 5 && trimmed.length <= 300;
  }

  // Limpeza de busca
  void clearSearch() {
    searchController.clear();
    _searchText.value = '';
    _isSearching.value = false;
    onSearchPerformed?.call('');
  }
}
