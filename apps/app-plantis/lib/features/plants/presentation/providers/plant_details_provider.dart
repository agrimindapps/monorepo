import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/plant.dart';
import '../../domain/usecases/delete_plant_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';

class PlantDetailsProvider extends ChangeNotifier {
  final GetPlantByIdUseCase getPlantByIdUseCase;
  final DeletePlantUseCase deletePlantUseCase;
  final UpdatePlantUseCase updatePlantUseCase;

  PlantDetailsProvider({
    required this.getPlantByIdUseCase,
    required this.deletePlantUseCase,
    required this.updatePlantUseCase,
  });

  Plant? _plant;
  bool _isLoading = false;
  String? _errorMessage;

  Plant? get plant => _plant;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> loadPlant(String plantId) async {
    // If we already have this plant loaded, don't show loading
    if (_plant?.id == plantId && !hasError) return;

    // Only show loading if we don't have any plant data yet
    final shouldShowLoading = _plant?.id != plantId;

    if (shouldShowLoading) {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    final result = await getPlantByIdUseCase(plantId);

    result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
        _plant = null;
      },
      (plant) {
        _plant = plant;
        _errorMessage = null;
      },
    );

    if (shouldShowLoading) {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<bool> deletePlant() async {
    if (_plant == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await deletePlantUseCase(_plant!.id);

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
      },
      (_) {
        success = true;
      },
    );

    _isLoading = false;
    notifyListeners();

    return success;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears the loading state
  /// 
  /// This method ensures that any pending loading state is cleared,
  /// particularly useful when operations are cancelled or interrupted.
  void clearLoadingState() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> toggleFavorite(String plantId) async {
    if (_plant == null || _plant!.id != plantId) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedPlant = _plant!.copyWith(
        isFavorited: !_plant!.isFavorited,
      );

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

      final result = await updatePlantUseCase(params);

      result.fold(
        (failure) {
          _errorMessage = _getErrorMessage(failure);
        },
        (plant) {
          _plant = plant;
          _errorMessage = null;
        },
      );
    } catch (e) {
      _errorMessage = 'Erro inesperado ao alterar favorito: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
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
