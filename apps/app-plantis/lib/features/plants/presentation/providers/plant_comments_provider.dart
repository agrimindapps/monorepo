import 'package:core/core.dart' hide Column;

import '../../../../core/data/models/comentario_model.dart';
import '../../domain/repositories/plant_comments_repository.dart';

part 'plant_comments_provider.g.dart';

/// Plant Comments State model for Riverpod
class PlantCommentsState {
  final List<ComentarioModel> comments;
  final bool isLoading;
  final String? error;
  final String? currentPlantId;

  const PlantCommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
    this.currentPlantId,
  });
  bool get hasComments => comments.isNotEmpty;
  int get commentsCount => comments.length;
  bool get hasError => error != null;

  /// Check if comments are loaded for current plant
  bool isLoadedForPlant(String plantId) {
    return currentPlantId == plantId && !isLoading;
  }

  /// Get comment by ID
  ComentarioModel? getCommentById(String commentId) {
    try {
      return comments.firstWhere((comment) => comment.id == commentId);
    } catch (e) {
      return null;
    }
  }

  PlantCommentsState copyWith({
    List<ComentarioModel>? comments,
    bool? isLoading,
    String? error,
    String? currentPlantId,
    bool clearError = false,
    bool clearComments = false,
  }) {
    return PlantCommentsState(
      comments: clearComments ? [] : (comments ?? this.comments),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentPlantId: currentPlantId ?? this.currentPlantId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantCommentsState &&
          runtimeType == other.runtimeType &&
          comments == other.comments &&
          isLoading == other.isLoading &&
          error == other.error &&
          currentPlantId == other.currentPlantId;

  @override
  int get hashCode =>
      comments.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      currentPlantId.hashCode;
}

/// Plant Comments Notifier using Riverpod code generation
@riverpod
class PlantCommentsNotifier extends _$PlantCommentsNotifier {
  late final PlantCommentsRepository _repository;

  @override
  Future<PlantCommentsState> build() async {
    _repository = ref.read(plantCommentsRepositoryProvider);
    return const PlantCommentsState();
  }

  /// Load comments for a specific plant
  Future<void> loadComments(String plantId) async {
    final currentState = state.valueOrNull ?? const PlantCommentsState();
    if (currentState.currentPlantId == plantId &&
        currentState.comments.isNotEmpty) {
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, currentPlantId: plantId),
    );

    final result = await _repository.getCommentsForPlant(plantId);

    result.fold(
      (failure) {
        state = AsyncValue.data(
          const PlantCommentsState().copyWith(
            error: failure.message,
            isLoading: false,
            currentPlantId: plantId,
          ),
        );
      },
      (comments) {
        state = AsyncValue.data(
          PlantCommentsState(
            comments: comments,
            isLoading: false,
            currentPlantId: plantId,
          ),
        );
      },
    );
  }

  /// Add a new comment
  Future<bool> addComment(String plantId, String content) async {
    if (content.trim().isEmpty) {
      final currentState = state.valueOrNull ?? const PlantCommentsState();
      state = AsyncValue.data(
        currentState.copyWith(error: 'Comentário não pode estar vazio'),
      );
      return false;
    }

    final currentState = state.valueOrNull ?? const PlantCommentsState();
    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final result = await _repository.addComment(plantId, content.trim());

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const PlantCommentsState();
        state = AsyncValue.data(
          newState.copyWith(error: failure.message, isLoading: false),
        );
        return false;
      },
      (comment) {
        final newState = state.valueOrNull ?? const PlantCommentsState();
        final updatedComments = [comment, ...newState.comments];
        state = AsyncValue.data(
          newState.copyWith(
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
      final currentState = state.valueOrNull ?? const PlantCommentsState();
      state = AsyncValue.data(
        currentState.copyWith(error: 'Comentário não pode estar vazio'),
      );
      return false;
    }

    final currentState = state.valueOrNull ?? const PlantCommentsState();
    final commentIndex =
        currentState.comments.indexWhere((c) => c.id == commentId);

    if (commentIndex == -1) {
      state = AsyncValue.data(
        currentState.copyWith(error: 'Comentário não encontrado'),
      );
      return false;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final originalComment = currentState.comments[commentIndex];
    final updatedComment = originalComment.copyWith(
      conteudo: newContent.trim(),
    );

    final result = await _repository.updateComment(updatedComment);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const PlantCommentsState();
        state = AsyncValue.data(
          newState.copyWith(error: failure.message, isLoading: false),
        );
        return false;
      },
      (comment) {
        final newState = state.valueOrNull ?? const PlantCommentsState();
        final updatedComments =
            List<ComentarioModel>.from(newState.comments);
        updatedComments[commentIndex] = comment;

        state = AsyncValue.data(
          newState.copyWith(
            comments: updatedComments,
            isLoading: false,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> deleteComment(String commentId) async {
    final currentState = state.valueOrNull ?? const PlantCommentsState();
    final commentIndex =
        currentState.comments.indexWhere((c) => c.id == commentId);

    if (commentIndex == -1) {
      state = AsyncValue.data(
        currentState.copyWith(error: 'Comentário não encontrado'),
      );
      return false;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final result = await _repository.deleteComment(commentId);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const PlantCommentsState();
        state = AsyncValue.data(
          newState.copyWith(error: failure.message, isLoading: false),
        );
        return false;
      },
      (_) {
        final newState = state.valueOrNull ?? const PlantCommentsState();
        final updatedComments =
            newState.comments.where((c) => c.id != commentId).toList();

        state = AsyncValue.data(
          newState.copyWith(
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
    state = const AsyncValue.data(PlantCommentsState());
  }

  /// Clear error message
  void clearError() {
    final currentState = state.valueOrNull ?? const PlantCommentsState();
    if (currentState.hasError) {
      state = AsyncValue.data(currentState.copyWith(clearError: true));
    }
  }
}

@riverpod
PlantCommentsRepository plantCommentsRepository(
  PlantCommentsRepositoryRef ref,
) {
  return GetIt.instance<PlantCommentsRepository>();
}

@riverpod
List<ComentarioModel> plantComments(PlantCommentsRef ref) {
  final commentsState = ref.watch(plantCommentsNotifierProvider);
  return commentsState.when(
    data: (state) => state.comments,
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
bool plantCommentsIsLoading(PlantCommentsIsLoadingRef ref) {
  final commentsState = ref.watch(plantCommentsNotifierProvider);
  return commentsState.when(
    data: (state) => state.isLoading,
    loading: () => true,
    error: (_, __) => false,
  );
}

@riverpod
String? plantCommentsError(PlantCommentsErrorRef ref) {
  final commentsState = ref.watch(plantCommentsNotifierProvider);
  return commentsState.when(
    data: (state) => state.error,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
}
