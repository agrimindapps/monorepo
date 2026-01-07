import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/plants/domain/entities/space.dart';
import '../../features/plants/domain/usecases/spaces_usecases.dart';
import 'repository_providers.dart';

part 'spaces_providers.g.dart';

/// Immutable state for Spaces feature
@immutable
class SpacesState {
  final List<Space> allSpaces;
  final Space? selectedSpace;
  final String? error;

  const SpacesState({required this.allSpaces, this.selectedSpace, this.error});

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
      selectedSpace: clearSelectedSpace
          ? null
          : (selectedSpace ?? this.selectedSpace),
      error: clearError ? null : (error ?? this.error),
    );
  }

  int get spacesCount => allSpaces.length;

  /// Alias for backwards compatibility
  List<Space> get spaces => allSpaces;

  /// Always false since AsyncNotifier handles loading state
  bool get isLoading => false;

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
  int get hashCode => Object.hash(allSpaces.length, selectedSpace, error);
}

/// Riverpod AsyncNotifier for Spaces management
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

    ref.onDispose(() {
      if (kDebugMode) {
        debugPrint('🧹 SpacesNotifier disposed');
      }
    });

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
      (failure) => throw Exception(_getErrorMessage(failure)),
      (spaces) {
        final sortedSpaces = List<Space>.from(spaces);
        sortedSpaces.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

        final currentState = state.value ?? SpacesState.initial();
        return currentState.copyWith(allSpaces: sortedSpaces, clearError: true);
      },
    );
  }

  /// Get space by ID
  Future<Space?> getSpaceById(String id) async {
    final result = await _getSpaceByIdUseCase.call(id);

    return result.fold(
      (failure) {
        final currentState = state.value ?? SpacesState.initial();
        state = AsyncValue.data(
          currentState.copyWith(error: _getErrorMessage(failure)),
        );
        return null;
      },
      (space) {
        final currentState = state.value ?? SpacesState.initial();
        state = AsyncValue.data(
          currentState.copyWith(selectedSpace: space, clearError: true),
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
        (failure) => throw Exception(_getErrorMessage(failure)),
        (space) {
          final currentState = state.value ?? SpacesState.initial();
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
        (failure) => throw Exception(_getErrorMessage(failure)),
        (updatedSpace) {
          final currentState = state.value ?? SpacesState.initial();
          final updatedSpaces = currentState.allSpaces.map((space) {
            return space.id == updatedSpace.id ? updatedSpace : space;
          }).toList();
          final newSelectedSpace =
              currentState.selectedSpace?.id == updatedSpace.id
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
        (failure) => throw Exception(_getErrorMessage(failure)),
        (_) {
          final currentState = state.value ?? SpacesState.initial();
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
    final currentState = state.value ?? SpacesState.initial();
    state = AsyncValue.data(currentState.copyWith(clearSelectedSpace: true));
  }

  /// Clear error state
  void clearError() {
    final currentState = state.value ?? SpacesState.initial();
    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }

  /// Convert Failure to user-friendly error message
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
GetSpacesUseCase getSpacesUseCase(Ref ref) {
  return GetSpacesUseCase(ref.watch(spacesRepositoryProvider));
}

@riverpod
GetSpaceByIdUseCase getSpaceByIdUseCase(Ref ref) {
  return GetSpaceByIdUseCase(ref.watch(spacesRepositoryProvider));
}

@riverpod
AddSpaceUseCase addSpaceUseCase(Ref ref) {
  return AddSpaceUseCase(ref.watch(spacesRepositoryProvider));
}

@riverpod
UpdateSpaceUseCase updateSpaceUseCase(Ref ref) {
  return UpdateSpaceUseCase(ref.watch(spacesRepositoryProvider));
}

@riverpod
DeleteSpaceUseCase deleteSpaceUseCase(Ref ref) {
  return DeleteSpaceUseCase(ref.watch(spacesRepositoryProvider));
}

/// Alias for backwards compatibility with legacy code
/// Use spacesProvider instead in new code

// LEGACY ALIAS
// ignore: deprecated_member_use_from_same_package
const spacesNotifierProvider = spacesProvider;
