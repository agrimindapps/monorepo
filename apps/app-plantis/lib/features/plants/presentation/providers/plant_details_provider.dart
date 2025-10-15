import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/plant.dart';
import '../../domain/usecases/delete_plant_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';

part 'plant_details_provider.freezed.dart';
part 'plant_details_provider.g.dart';

/// State for Plant Details
@freezed
class PlantDetailsState with _$PlantDetailsState {
  const factory PlantDetailsState({
    Plant? plant,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _PlantDetailsState;

  const PlantDetailsState._();

  bool get hasError => errorMessage != null;
}

/// Provider for managing individual plant details
@riverpod
class PlantDetailsNotifier extends _$PlantDetailsNotifier {
  GetPlantByIdUseCase get _getPlantByIdUseCase =>
      ref.read(getPlantByIdUseCaseProvider);
  DeletePlantUseCase get _deletePlantUseCase =>
      ref.read(deletePlantUseCaseProvider);
  UpdatePlantUseCase get _updatePlantUseCase =>
      ref.read(updatePlantUseCaseProvider);

  @override
  PlantDetailsState build() {
    ref.onDispose(() {
      // Cleanup resources if needed
    });

    return const PlantDetailsState();
  }

  Future<void> loadPlant(String plantId) async {
    await _loadPlant(plantId, forceReload: false);
  }

  /// Force reload the plant data, bypassing cache
  Future<void> reloadPlant(String plantId) async {
    await _loadPlant(plantId, forceReload: true);
  }

  Future<void> _loadPlant(String plantId, {required bool forceReload}) async {
    if (!forceReload &&
        state.plant?.id == plantId &&
        !state.hasError) {
      return;
    }

    final shouldShowLoading = state.plant?.id != plantId || forceReload;

    if (shouldShowLoading) {
      state = state.copyWith(isLoading: true);
    }
    state = state.copyWith(errorMessage: null);

    try {
      final result = await _getPlantByIdUseCase(plantId);

      result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: _getErrorMessage(failure),
            plant: null,
            isLoading: false,
          );
        },
        (plant) {
          state = state.copyWith(
            plant: plant,
            errorMessage: null,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        plant: null,
        isLoading: false,
      );
    }
  }

  Future<bool> deletePlant() async {
    if (state.plant == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _deletePlantUseCase(state.plant!.id);

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: _getErrorMessage(failure),
          isLoading: false,
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
    state = state.copyWith(errorMessage: null);
  }

  /// Clears the loading state
  ///
  /// This method ensures that any pending loading state is cleared,
  /// particularly useful when operations are cancelled or interrupted.
  void clearLoadingState() {
    state = state.copyWith(isLoading: false, errorMessage: null);
  }

  Future<void> toggleFavorite(String plantId) async {
    if (state.plant == null || state.plant!.id != plantId) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

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
            errorMessage: _getErrorMessage(failure),
            isLoading: false,
          );
        },
        (plant) {
          state = state.copyWith(
            plant: plant,
            errorMessage: null,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado ao alterar favorito: $e',
        isLoading: false,
      );
    }
  }

  Future<void> refresh(String plantId) async {
    await loadPlant(plantId);
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NotFoundFailure):
        return 'Planta não encontrada';
      case const (NetworkFailure):
        return 'Sem conexão com a internet';
      case const (ServerFailure):
        return 'Erro no servidor. Tente novamente.';
      case const (CacheFailure):
        return 'Erro local. Verifique o armazenamento.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}

// Dependency providers using GetIt
@riverpod
GetPlantByIdUseCase getPlantByIdUseCase(GetPlantByIdUseCaseRef ref) {
  return GetIt.instance<GetPlantByIdUseCase>();
}

@riverpod
DeletePlantUseCase deletePlantUseCase(DeletePlantUseCaseRef ref) {
  return GetIt.instance<DeletePlantUseCase>();
}

@riverpod
UpdatePlantUseCase updatePlantUseCase(UpdatePlantUseCaseRef ref) {
  return GetIt.instance<UpdatePlantUseCase>();
}

/// Alias for backwards compatibility with existing code
/// Use plantDetailsNotifierProvider instead in new code
final plantDetailsProviderProvider = plantDetailsNotifierProvider;

/// Compatibility wrapper class for PlantDetailsController
/// This class wraps the Riverpod notifier to provide a compatible interface
/// with the old Provider-based PlantDetailsController
class PlantDetailsProvider {
  final PlantDetailsNotifier _notifier;
  final PlantDetailsState _state;

  PlantDetailsProvider(this._notifier, this._state);

  Plant? get plant => _state.plant;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  bool get hasError => _state.hasError;

  Future<void> loadPlant(String plantId) => _notifier.loadPlant(plantId);
  Future<void> reloadPlant(String plantId) => _notifier.reloadPlant(plantId);
  Future<bool> deletePlant() => _notifier.deletePlant();
  void clearError() => _notifier.clearError();
}
