import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/plants/data/repositories/plant_comments_repository_impl.dart';
import '../../features/plants/domain/repositories/plant_comments_repository.dart';
import '../data/models/comentario_model.dart';
final plantCommentsRepositoryProvider = Provider<PlantCommentsRepository>((ref) {
  return PlantCommentsRepositoryImpl();
});
@immutable
class CommentsState {
  final List<ComentarioModel> comments;
  final bool isLoading;
  final String? errorMessage;
  final String? currentPlantId;

  const CommentsState({
    required this.comments,
    required this.isLoading,
    this.errorMessage,
    this.currentPlantId,
  });

  factory CommentsState.initial() {
    return const CommentsState(
      comments: [],
      isLoading: false,
      errorMessage: null,
      currentPlantId: null,
    );
  }

  bool get hasComments => comments.isNotEmpty;
  int get commentsCount => comments.length;

  CommentsState copyWith({
    List<ComentarioModel>? comments,
    bool? isLoading,
    String? errorMessage,
    String? currentPlantId,
    bool clearError = false,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPlantId: currentPlantId ?? this.currentPlantId,
    );
  }
}

/// Comments Notifier for managing plant comments
class CommentsNotifier extends AutoDisposeAsyncNotifier<CommentsState> {
  late final PlantCommentsRepository _repository;

  @override
  Future<CommentsState> build() async {
    _repository = ref.read(plantCommentsRepositoryProvider);
    return CommentsState.initial();
  }

  /// Load comments for a specific plant
  Future<void> loadComments(String plantId) async {
    final currentState = state.valueOrNull ?? CommentsState.initial();
    if (currentState.currentPlantId == plantId &&
        currentState.hasComments &&
        !currentState.isLoading) {
      return;
    }
    state = AsyncData(
      currentState.copyWith(
        isLoading: true,
        currentPlantId: plantId,
        clearError: true,
      ),
    );

    final result = await _repository.getCommentsForPlant(plantId);

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('❌ Error loading comments: ${failure.message}');
        }
        state = AsyncData(
          CommentsState(
            comments: const [],
            isLoading: false,
            errorMessage: failure.message,
            currentPlantId: plantId,
          ),
        );
      },
      (comments) {
        if (kDebugMode) {
          print('✅ Loaded ${comments.length} comments for plant $plantId');
        }
        state = AsyncData(
          CommentsState(
            comments: comments,
            isLoading: false,
            errorMessage: null,
            currentPlantId: plantId,
          ),
        );
      },
    );
  }

  /// Add a new comment
  Future<bool> addComment(String plantId, String content) async {
    if (content.trim().isEmpty) {
      state = AsyncData(
        (state.valueOrNull ?? CommentsState.initial()).copyWith(
          errorMessage: 'Comentário não pode estar vazio',
        ),
      );
      return false;
    }

    final currentState = state.valueOrNull ?? CommentsState.initial();
    state = AsyncData(currentState.copyWith(isLoading: true, clearError: true));

    final result = await _repository.addComment(plantId, content.trim());

    return result.fold(
      (failure) {
        if (kDebugMode) {
          print('❌ Error adding comment: ${failure.message}');
        }
        state = AsyncData(
          currentState.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
      (comment) {
        if (kDebugMode) {
          print('✅ Added comment: ${comment.id}');
        }
        final updatedComments = [comment, ...currentState.comments];
        state = AsyncData(
          currentState.copyWith(
            comments: updatedComments,
            isLoading: false,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Update an existing comment
  Future<bool> updateComment(String commentId, String newContent) async {
    if (newContent.trim().isEmpty) {
      state = AsyncData(
        (state.valueOrNull ?? CommentsState.initial()).copyWith(
          errorMessage: 'Comentário não pode estar vazio',
        ),
      );
      return false;
    }

    final currentState = state.valueOrNull ?? CommentsState.initial();

    final commentIndex =
        currentState.comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) {
      state = AsyncData(
        currentState.copyWith(errorMessage: 'Comentário não encontrado'),
      );
      return false;
    }

    state = AsyncData(currentState.copyWith(isLoading: true, clearError: true));

    final originalComment = currentState.comments[commentIndex];
    final updatedComment = originalComment.copyWith(
      conteudo: newContent.trim(),
    );

    final result = await _repository.updateComment(updatedComment);

    return result.fold(
      (failure) {
        if (kDebugMode) {
          print('❌ Error updating comment: ${failure.message}');
        }
        state = AsyncData(
          currentState.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
      (comment) {
        if (kDebugMode) {
          print('✅ Updated comment: ${comment.id}');
        }
        final updatedComments = List<ComentarioModel>.from(currentState.comments);
        updatedComments[commentIndex] = comment;
        state = AsyncData(
          currentState.copyWith(
            comments: updatedComments,
            isLoading: false,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    final currentState = state.valueOrNull ?? CommentsState.initial();

    final commentIndex =
        currentState.comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) {
      state = AsyncData(
        currentState.copyWith(errorMessage: 'Comentário não encontrado'),
      );
      return false;
    }

    state = AsyncData(currentState.copyWith(isLoading: true, clearError: true));

    final result = await _repository.deleteComment(commentId);

    return result.fold(
      (failure) {
        if (kDebugMode) {
          print('❌ Error deleting comment: ${failure.message}');
        }
        state = AsyncData(
          currentState.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
      (_) {
        if (kDebugMode) {
          print('✅ Deleted comment: $commentId');
        }
        final updatedComments = List<ComentarioModel>.from(currentState.comments)
          ..removeAt(commentIndex);
        state = AsyncData(
          currentState.copyWith(
            comments: updatedComments,
            isLoading: false,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Clear comments when navigating away
  void clearComments() {
    state = AsyncData(CommentsState.initial());
  }

  /// Clear error message
  void clearError() {
    final currentState = state.valueOrNull ?? CommentsState.initial();
    state = AsyncData(currentState.copyWith(clearError: true));
  }

  /// Get comment by ID
  ComentarioModel? getCommentById(String commentId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    try {
      return currentState.comments.firstWhere((comment) => comment.id == commentId);
    } catch (e) {
      return null;
    }
  }

  /// Check if comments are loaded for current plant
  bool isLoadedForPlant(String plantId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return false;
    return currentState.currentPlantId == plantId && !currentState.isLoading;
  }
}

/// Global provider for comments management
final commentsProvider =
    AutoDisposeAsyncNotifierProvider<CommentsNotifier, CommentsState>(
  CommentsNotifier.new,
);

/// Provider for comments for a specific plant (family modifier for better performance)
final plantCommentsProvider =
    Provider.autoDispose.family<AsyncValue<List<ComentarioModel>>, String>(
  (ref, plantId) {
    final commentsState = ref.watch(commentsProvider);

    return commentsState.when(
      data: (state) {
        if (state.currentPlantId != plantId && !state.isLoading) {
          Future.microtask(() {
            ref.read(commentsProvider.notifier).loadComments(plantId);
          });
          return const AsyncLoading();
        }
        if (state.currentPlantId == plantId) {
          if (state.errorMessage != null) {
            return AsyncError(
              Exception(state.errorMessage),
              StackTrace.current,
            );
          }
          return AsyncData(state.comments);
        }

        return const AsyncLoading();
      },
      loading: () => const AsyncLoading(),
      error: (error, stack) => AsyncError(error, stack),
    );
  },
);