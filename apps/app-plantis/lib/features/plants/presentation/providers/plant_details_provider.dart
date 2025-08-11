import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../../domain/entities/plant.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/delete_plant_usecase.dart';

class PlantDetailsProvider extends ChangeNotifier {
  final GetPlantByIdUseCase getPlantByIdUseCase;
  final DeletePlantUseCase deletePlantUseCase;

  PlantDetailsProvider({
    required this.getPlantByIdUseCase,
    required this.deletePlantUseCase,
  });

  Plant? _plant;
  bool _isLoading = false;
  String? _errorMessage;

  Plant? get plant => _plant;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> loadPlant(String plantId) async {
    if (_plant?.id == plantId && !hasError) return;

    _isLoading = true;
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

    _isLoading = false;
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

  @override
  void dispose() {
    super.dispose();
  }
}