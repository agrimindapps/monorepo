import 'package:core/core.dart' hide getIt;
import 'package:flutter/foundation.dart';

import '../../domain/entities/plant.dart';
import '../../domain/usecases/delete_plant_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';

part 'plant_details_notifier.g.dart';

/// State for plant details
class PlantDetailsState {
  final Plant? plant;
  final bool isLoading;
  final String? errorMessage;

  const PlantDetailsState({
    this.plant,
    this.isLoading = false,
    this.errorMessage,
  });

  PlantDetailsState copyWith({
    Plant? plant,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearPlant = false,
  }) {
    return PlantDetailsState(
      plant: clearPlant ? null : (plant ?? this.plant),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get hasError => errorMessage != null;
}

/// Notifier for plant details management
@riverpod
class PlantDetailsNotifier extends _$PlantDetailsNotifier {
  late final GetPlantByIdUseCase _getPlantByIdUseCase;
  late final DeletePlantUseCase _deletePlantUseCase;
  late final UpdatePlantUseCase _updatePlantUseCase;

  @override
  PlantDetailsState build() {
    _getPlantByIdUseCase = ref.read(getPlantByIdUseCaseProvider);
    _deletePlantUseCase = ref.read(deletePlantUseCaseProvider);
    _updatePlantUseCase = ref.read(updatePlantUseCaseProvider);

    return const PlantDetailsState();
  }

  Future<void> loadPlant(String plantId) async {
    await _loadPlant(plantId, forceReload: false);
  }

  /// Force reload the plant data, bypassing cache
  Future<void> reloadPlant(String plantId) async {
    if (kDebugMode) {
      print(
        '🔄 PlantDetailsNotifier.reloadPlant() - Forçando reload para plantId: $plantId',
      );
    }
    await _loadPlant(plantId, forceReload: true);
  }

  Future<void> _loadPlant(String plantId, {required bool forceReload}) async {
    // If we already have this plant loaded and not forcing reload, don't show loading
    if (!forceReload && state.plant?.id == plantId && !state.hasError) return;

    // Only show loading if we don't have any plant data yet or forcing reload
    final shouldShowLoading = state.plant?.id != plantId || forceReload;

    if (shouldShowLoading) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    final result = await _getPlantByIdUseCase(plantId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
          clearPlant: true,
        );
      },
      (plant) {
        state = state.copyWith(
          plant: plant,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  Future<bool> deletePlant() async {
    if (state.plant == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _deletePlantUseCase(state.plant!.id);

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        );
      },
      (_) {
        success = true;
        state = state.copyWith(isLoading: false);
      },
    );

    return success;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clears the loading state
  ///
  /// This method ensures that any pending loading state is cleared,
  /// particularly useful when operations are cancelled or interrupted.
  void clearLoadingState() {
    state = state.copyWith(isLoading: false, clearError: true);
  }

  Future<void> toggleFavorite(String plantId) async {
    if (state.plant == null || state.plant!.id != plantId) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedPlant =
          state.plant!.copyWith(isFavorited: !state.plant!.isFavorited);

      final params = UpdatePlantParams(
        id: plantId,
        name: updatedPlant.name,
        species: updatedPlant.species,
        spaceId: updatedPlant.spaceId,
        imageBase64: updatedPlant.imageBase64,
        imageUrls: updatedPlant.imageUrls,
        plantingDate: updatedPlant.plantingDate,
        notes: updatedPlant.notes,
        config: updatedPlant.config,
        isFavorited: updatedPlant.isFavorited,
      );

      final result = await _updatePlantUseCase(params);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
        (plant) {
          state = state.copyWith(
            plant: plant,
            isLoading: false,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado ao alterar favorito: $e',
      );
    }
  }

  Future<void> refresh(String plantId) async {
    await loadPlant(plantId);
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NotFoundFailure:
        return 'Planta não encontrada';
      case NetworkFailure:
        return 'Sem conexão com a internet';
      case ServerFailure:
        return 'Erro no servidor. Tente novamente.';
      case CacheFailure:
        return 'Erro local. Verifique o armazenamento.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}

// Dependency providers
@riverpod
GetPlantByIdUseCase getPlantByIdUseCase(Ref ref) {
  return GetIt.instance<GetPlantByIdUseCase>();
}

@riverpod
DeletePlantUseCase deletePlantUseCase(Ref ref) {
  return GetIt.instance<DeletePlantUseCase>();
}

@riverpod
UpdatePlantUseCase updatePlantUseCase(Ref ref) {
  return GetIt.instance<UpdatePlantUseCase>();
}
