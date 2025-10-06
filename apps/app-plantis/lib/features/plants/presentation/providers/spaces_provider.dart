import 'package:core/core.dart';

import '../../domain/entities/space.dart';
import '../../domain/usecases/spaces_usecases.dart';

part 'spaces_provider.g.dart';

/// Spaces State model for Riverpod
class SpacesState {
  final List<Space> spaces;
  final Space? selectedSpace;
  final bool isLoading;
  final String? error;

  const SpacesState({
    this.spaces = const [],
    this.selectedSpace,
    this.isLoading = false,
    this.error,
  });
  bool get isEmpty => spaces.isEmpty;
  bool get hasError => error != null;
  int get spacesCount => spaces.length;
  Space? findSpaceByName(String name) {
    try {
      return spaces.firstWhere(
        (space) => space.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
  List<Space> getSpacesByLightCondition(String lightCondition) {
    return spaces
        .where((space) => space.lightCondition == lightCondition)
        .toList();
  }

  SpacesState copyWith({
    List<Space>? spaces,
    Space? selectedSpace,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSelectedSpace = false,
  }) {
    return SpacesState(
      spaces: spaces ?? this.spaces,
      selectedSpace:
          clearSelectedSpace ? null : (selectedSpace ?? this.selectedSpace),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpacesState &&
          runtimeType == other.runtimeType &&
          spaces == other.spaces &&
          selectedSpace == other.selectedSpace &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode =>
      spaces.hashCode ^
      selectedSpace.hashCode ^
      isLoading.hashCode ^
      error.hashCode;
}

/// Spaces Notifier using Riverpod code generation
@riverpod
class SpacesNotifier extends _$SpacesNotifier {
  late final GetSpacesUseCase _getSpacesUseCase;
  late final GetSpaceByIdUseCase _getSpaceByIdUseCase;
  late final AddSpaceUseCase _addSpaceUseCase;
  late final UpdateSpaceUseCase _updateSpaceUseCase;
  late final DeleteSpaceUseCase _deleteSpaceUseCase;

  @override
  Future<SpacesState> build() async {
    _getSpacesUseCase = ref.read(getSpacesUseCaseProvider);
    _getSpaceByIdUseCase = ref.read(getSpaceByIdUseCaseProvider);
    _addSpaceUseCase = ref.read(addSpaceUseCaseProvider);
    _updateSpaceUseCase = ref.read(updateSpaceUseCaseProvider);
    _deleteSpaceUseCase = ref.read(deleteSpaceUseCaseProvider);
    final result = await _getSpacesUseCase.call(const NoParams());

    return result.fold(
      (failure) => SpacesState(error: _getErrorMessage(failure)),
      (spaces) {
        final sortedSpaces = List<Space>.from(spaces);
        sortedSpaces.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );
        return SpacesState(spaces: sortedSpaces);
      },
    );
  }

  /// Load all spaces
  Future<void> loadSpaces() async {
    state = AsyncValue.data(
      (state.valueOrNull ?? const SpacesState()).copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    final result = await _getSpacesUseCase.call(const NoParams());

    result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const SpacesState();
        state = AsyncValue.data(
          currentState.copyWith(
            error: _getErrorMessage(failure),
            isLoading: false,
          ),
        );
      },
      (spaces) {
        final sortedSpaces = List<Space>.from(spaces);
        sortedSpaces.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

        final currentState = state.valueOrNull ?? const SpacesState();
        state = AsyncValue.data(
          currentState.copyWith(
            spaces: sortedSpaces,
            isLoading: false,
            clearError: true,
          ),
        );
      },
    );
  }

  /// Get space by ID
  Future<Space?> getSpaceById(String id) async {
    final result = await _getSpaceByIdUseCase.call(id);

    return result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const SpacesState();
        state = AsyncValue.data(
          currentState.copyWith(error: _getErrorMessage(failure)),
        );
        return null;
      },
      (space) {
        final currentState = state.valueOrNull ?? const SpacesState();
        state = AsyncValue.data(
          currentState.copyWith(selectedSpace: space),
        );
        return space;
      },
    );
  }

  /// Add new space
  Future<bool> addSpace(AddSpaceParams params) async {
    final currentState = state.valueOrNull ?? const SpacesState();
    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final result = await _addSpaceUseCase.call(params);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const SpacesState();
        state = AsyncValue.data(
          newState.copyWith(
            error: _getErrorMessage(failure),
            isLoading: false,
          ),
        );
        return false;
      },
      (space) {
        final newState = state.valueOrNull ?? const SpacesState();
        final updatedSpaces = [space, ...newState.spaces];
        state = AsyncValue.data(
          newState.copyWith(
            spaces: updatedSpaces,
            isLoading: false,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Update existing space
  Future<bool> updateSpace(UpdateSpaceParams params) async {
    final currentState = state.valueOrNull ?? const SpacesState();
    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final result = await _updateSpaceUseCase.call(params);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const SpacesState();
        state = AsyncValue.data(
          newState.copyWith(
            error: _getErrorMessage(failure),
            isLoading: false,
          ),
        );
        return false;
      },
      (updatedSpace) {
        final newState = state.valueOrNull ?? const SpacesState();
        final updatedSpaces =
            newState.spaces.map((s) {
              return s.id == updatedSpace.id ? updatedSpace : s;
            }).toList();

        state = AsyncValue.data(
          newState.copyWith(
            spaces: updatedSpaces,
            selectedSpace:
                newState.selectedSpace?.id == updatedSpace.id
                    ? updatedSpace
                    : newState.selectedSpace,
            isLoading: false,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Delete space
  Future<bool> deleteSpace(String id) async {
    final currentState = state.valueOrNull ?? const SpacesState();
    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final result = await _deleteSpaceUseCase.call(id);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const SpacesState();
        state = AsyncValue.data(
          newState.copyWith(
            error: _getErrorMessage(failure),
            isLoading: false,
          ),
        );
        return false;
      },
      (_) {
        final newState = state.valueOrNull ?? const SpacesState();
        final updatedSpaces =
            newState.spaces.where((space) => space.id != id).toList();

        state = AsyncValue.data(
          newState.copyWith(
            spaces: updatedSpaces,
            clearSelectedSpace: newState.selectedSpace?.id == id,
            isLoading: false,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Clear selected space
  void clearSelectedSpace() {
    final currentState = state.valueOrNull ?? const SpacesState();
    if (currentState.selectedSpace != null) {
      state = AsyncValue.data(
        currentState.copyWith(clearSelectedSpace: true),
      );
    }
  }

  /// Clear error
  void clearError() {
    final currentState = state.valueOrNull ?? const SpacesState();
    if (currentState.hasError) {
      state = AsyncValue.data(currentState.copyWith(clearError: true));
    }
  }

  /// Error message helper
  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure _:
        return failure.message;
      case CacheFailure _:
        return failure.message;
      case NetworkFailure _:
        return 'Sem conexão com a internet';
      case ServerFailure _:
        if (failure.message.contains('não autenticado') ||
            failure.message.contains('unauthorized') ||
            failure.message.contains('Usuário não autenticado')) {
          return 'Erro de autenticação. Tente fazer login novamente.';
        }
        return failure.message;
      case NotFoundFailure _:
        return failure.message;
      default:
        return 'Erro inesperado';
    }
  }
}

@riverpod
GetSpacesUseCase getSpacesUseCase(GetSpacesUseCaseRef ref) {
  return GetIt.instance<GetSpacesUseCase>();
}

@riverpod
GetSpaceByIdUseCase getSpaceByIdUseCase(GetSpaceByIdUseCaseRef ref) {
  return GetIt.instance<GetSpaceByIdUseCase>();
}

@riverpod
AddSpaceUseCase addSpaceUseCase(AddSpaceUseCaseRef ref) {
  return GetIt.instance<AddSpaceUseCase>();
}

@riverpod
UpdateSpaceUseCase updateSpaceUseCase(UpdateSpaceUseCaseRef ref) {
  return GetIt.instance<UpdateSpaceUseCase>();
}

@riverpod
DeleteSpaceUseCase deleteSpaceUseCase(DeleteSpaceUseCaseRef ref) {
  return GetIt.instance<DeleteSpaceUseCase>();
}

@riverpod
List<Space> spaces(SpacesRef ref) {
  final spacesState = ref.watch(spacesNotifierProvider);
  return spacesState.when(
    data: (state) => state.spaces,
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
bool spacesIsLoading(SpacesIsLoadingRef ref) {
  final spacesState = ref.watch(spacesNotifierProvider);
  return spacesState.when(
    data: (state) => state.isLoading,
    loading: () => true,
    error: (_, __) => false,
  );
}

@riverpod
String? spacesError(SpacesErrorRef ref) {
  final spacesState = ref.watch(spacesNotifierProvider);
  return spacesState.when(
    data: (state) => state.error,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
}
