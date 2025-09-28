import 'package:flutter/foundation.dart';

import '../../../../core/data/models/comentario_model.dart';
import '../../domain/repositories/plant_comments_repository.dart';

/// Provider for managing plant comments state
class PlantCommentsProvider extends ChangeNotifier {
  final PlantCommentsRepository _repository;

  PlantCommentsProvider({required PlantCommentsRepository repository})
    : _repository = repository;

  List<ComentarioModel> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentPlantId;

  // Getters
  List<ComentarioModel> get comments => List.unmodifiable(_comments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasComments => _comments.isNotEmpty;
  int get commentsCount => _comments.length;

  /// Load comments for a specific plant
  Future<void> loadComments(String plantId) async {
    if (_currentPlantId == plantId && _comments.isNotEmpty) {
      // Comments already loaded for this plant
      return;
    }

    _setLoading(true);
    _currentPlantId = plantId;

    final result = await _repository.getCommentsForPlant(plantId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _comments = [];
      },
      (comments) {
        _errorMessage = null;
        _comments = comments;
      },
    );

    _setLoading(false);
  }

  /// Add a new comment
  Future<bool> addComment(String plantId, String content) async {
    if (content.trim().isEmpty) {
      _errorMessage = 'Comentário não pode estar vazio';
      notifyListeners();
      return false;
    }

    _setLoading(true);

    final result = await _repository.addComment(plantId, content.trim());

    final success = result.fold(
      (failure) {
        _errorMessage = failure.message;
        return false;
      },
      (comment) {
        _errorMessage = null;
        // Add to the beginning of the list (newest first)
        _comments.insert(0, comment);
        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Update an existing comment
  Future<bool> updateComment(String commentId, String newContent) async {
    if (newContent.trim().isEmpty) {
      _errorMessage = 'Comentário não pode estar vazio';
      notifyListeners();
      return false;
    }

    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) {
      _errorMessage = 'Comentário não encontrado';
      notifyListeners();
      return false;
    }

    _setLoading(true);

    final originalComment = _comments[commentIndex];
    final updatedComment = originalComment.copyWith(
      conteudo: newContent.trim(),
    );

    final result = await _repository.updateComment(updatedComment);

    final success = result.fold(
      (failure) {
        _errorMessage = failure.message;
        return false;
      },
      (comment) {
        _errorMessage = null;
        _comments[commentIndex] = comment;
        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) {
      _errorMessage = 'Comentário não encontrado';
      notifyListeners();
      return false;
    }

    _setLoading(true);

    final result = await _repository.deleteComment(commentId);

    final success = result.fold(
      (failure) {
        _errorMessage = failure.message;
        return false;
      },
      (_) {
        _errorMessage = null;
        _comments.removeAt(commentIndex);
        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Clear comments when navigating away
  void clearComments() {
    _comments.clear();
    _currentPlantId = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get comment by ID
  ComentarioModel? getCommentById(String commentId) {
    try {
      return _comments.firstWhere((comment) => comment.id == commentId);
    } catch (e) {
      return null;
    }
  }

  /// Check if comments are loaded for current plant
  bool isLoadedForPlant(String plantId) {
    return _currentPlantId == plantId && !_isLoading;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _comments.clear();
    super.dispose();
  }
}
