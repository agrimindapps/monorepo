import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/plants/domain/entities/space.dart';
import '../../features/plants/domain/usecases/spaces_usecases.dart';

/// Immutable state for Spaces feature
@immutable
class SpacesState {
  final List<Space> allSpaces;
  final Space? selectedSpace;
  final String? error;

  const SpacesState({
    required this.allSpaces,
    this.selectedSpace,
    this.error,
  });

  factory SpacesState.initial() {
    return const SpacesState(allSpaces: []);
  }

  SpacesState copyWith({
    List<Space>? allSpaces,
    Space? selectedSpace,
    String? error,
    bool clearSelectedSpace = false,
    bool clearError = false,
  }) {
    return SpacesState(
      allSpaces: allSpaces ?? this.allSpaces,
      selectedSpace: clearSelectedSpace ? null : (selectedSpace ?? this.selectedSpace),
      error: clearError ? null : (error ?? this.error),
    );
  }
  int get spacesCount => allSpaces.length;

  bool get hasSpaces => allSpaces.isNotEmpty;
  Space? findSpaceByName(String name) {
    try {
      return allSpaces.firstWhere(
        (space) => space.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
  List<Space> getSpacesByLightCondition(String lightCondition) {
    return allSpaces
        .where((space) => space.lightCondition == lightCondition)
        .toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpacesState &&
        listEquals(other.allSpaces, allSpaces) &&
        other.selectedSpace == selectedSpace &&
        other.error == error;
  }

  @override
  int get hashCode =>
      Object.hash(allSpaces.length, selectedSpace, error);
}

/// Riverpod AsyncNotifier for Spaces management
class SpacesNotifier extends AsyncNotifier<SpacesState> {
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
    return _loadSpacesOperation();
  }

  /// Load all spaces from repository
  Future<void> loadSpaces() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadSpacesOperation());
  }

  Future<SpacesState> _loadSpacesOperation() async {
    final result = await _getSpacesUseCase.call(const NoParams());

    return result.fold(
      (failure) => throw _getErrorMessage(failure),
      (spaces) {
        final sortedSpaces = List<Space>.from(spaces);
        sortedSpaces.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

        final currentState = state.valueOrNull ?? SpacesState.initial();
        return currentState.copyWith(
          allSpaces: sortedSpaces,
          clearError: true,
        );
      },
    );
  }

  /// Get space by ID
  Future<Space?> getSpaceById(String id) async {
    final result = await _getSpaceByIdUseCase.call(id);

    return result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? SpacesState.initial();
        state = AsyncValue.data(
          currentState.copyWith(error: _getErrorMessage(failure)),
        );
        return null;
      },
      (space) {
        final currentState = state.valueOrNull ?? SpacesState.initial();
        state = AsyncValue.data(
          currentState.copyWith(
            selectedSpace: space,
            clearError: true,
          ),
        );
        return space;
      },
    );
  }

  /// Add new space
  Future<bool> addSpace(AddSpaceParams params) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _addSpaceUseCase.call(params);

      return result.fold(
        (failure) => throw _getErrorMessage(failure),
        (space) {
          final currentState = state.valueOrNull ?? SpacesState.initial();
          final updatedSpaces = [space, ...currentState.allSpaces];

          return currentState.copyWith(
            allSpaces: updatedSpaces,
            clearError: true,
          );
        },
      );
    });

    return !state.hasError;
  }

  /// Update existing space
  Future<bool> updateSpace(UpdateSpaceParams params) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _updateSpaceUseCase.call(params);

      return result.fold(
        (failure) => throw _getErrorMessage(failure),
        (updatedSpace) {
          final currentState = state.valueOrNull ?? SpacesState.initial();
          final updatedSpaces = currentState.allSpaces.map((space) {
            return space.id == updatedSpace.id ? updatedSpace : space;
          }).toList();
          final newSelectedSpace = currentState.selectedSpace?.id == updatedSpace.id
              ? updatedSpace
              : currentState.selectedSpace;

          return currentState.copyWith(
            allSpaces: updatedSpaces,
            selectedSpace: newSelectedSpace,
            clearError: true,
          );
        },
      );
    });

    return !state.hasError;
  }

  /// Delete space
  Future<bool> deleteSpace(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _deleteSpaceUseCase.call(id);

      return result.fold(
        (failure) => throw _getErrorMessage(failure),
        (_) {
          final currentState = state.valueOrNull ?? SpacesState.initial();
          final updatedSpaces = currentState.allSpaces
              .where((space) => space.id != id)
              .toList();
          final shouldClearSelected = currentState.selectedSpace?.id == id;

          return currentState.copyWith(
            allSpaces: updatedSpaces,
            clearSelectedSpace: shouldClearSelected,
            clearError: true,
          );
        },
      );
    });

    return !state.hasError;
  }

  /// Clear selected space
  void clearSelectedSpace() {
    final currentState = state.valueOrNull ?? SpacesState.initial();
    state = AsyncValue.data(currentState.copyWith(clearSelectedSpace: true));
  }

  /// Clear error state
  void clearError() {
    final currentState = state.valueOrNull ?? SpacesState.initial();
    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }

  /// Convert Failure to user-friendly error message
  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure:
        return failure.message;
      case CacheFailure:
        return failure.message;
      case NetworkFailure:
        return 'Sem conexão com a internet';
      case ServerFailure:
        if (failure.message.contains('não autenticado') ||
            failure.message.contains('unauthorized') ||
            failure.message.contains('Usuário não autenticado')) {
          return 'Erro de autenticação. Tente fazer login novamente.';
        }
        return failure.message;
      case NotFoundFailure:
        return failure.message;
      default:
        return 'Erro inesperado';
    }
  }
}
final spacesProvider = AsyncNotifierProvider<SpacesNotifier, SpacesState>(() {
  return SpacesNotifier();
});
final getSpacesUseCaseProvider = Provider<GetSpacesUseCase>((ref) {
  return GetIt.instance<GetSpacesUseCase>();
});

final getSpaceByIdUseCaseProvider = Provider<GetSpaceByIdUseCase>((ref) {
  return GetIt.instance<GetSpaceByIdUseCase>();
});

final addSpaceUseCaseProvider = Provider<AddSpaceUseCase>((ref) {
  return GetIt.instance<AddSpaceUseCase>();
});

final updateSpaceUseCaseProvider = Provider<UpdateSpaceUseCase>((ref) {
  return GetIt.instance<UpdateSpaceUseCase>();
});

final deleteSpaceUseCaseProvider = Provider<DeleteSpaceUseCase>((ref) {
  return GetIt.instance<DeleteSpaceUseCase>();
});
