import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/space.dart';
import '../../domain/usecases/spaces_usecases.dart';

class SpacesProvider extends ChangeNotifier {
  final GetSpacesUseCase _getSpacesUseCase;
  final GetSpaceByIdUseCase _getSpaceByIdUseCase;
  final AddSpaceUseCase _addSpaceUseCase;
  final UpdateSpaceUseCase _updateSpaceUseCase;
  final DeleteSpaceUseCase _deleteSpaceUseCase;

  SpacesProvider({
    required GetSpacesUseCase getSpacesUseCase,
    required GetSpaceByIdUseCase getSpaceByIdUseCase,
    required AddSpaceUseCase addSpaceUseCase,
    required UpdateSpaceUseCase updateSpaceUseCase,
    required DeleteSpaceUseCase deleteSpaceUseCase,
  }) : _getSpacesUseCase = getSpacesUseCase,
       _getSpaceByIdUseCase = getSpaceByIdUseCase,
       _addSpaceUseCase = addSpaceUseCase,
       _updateSpaceUseCase = updateSpaceUseCase,
       _deleteSpaceUseCase = deleteSpaceUseCase;

  List<Space> _spaces = [];
  List<Space> get spaces => _spaces;

  Space? _selectedSpace;
  Space? get selectedSpace => _selectedSpace;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Load all spaces
  Future<void> loadSpaces() async {
    _setLoading(true);
    _clearError();

    final result = await _getSpacesUseCase.call(const NoParams());

    result.fold((failure) => _setError(_getErrorMessage(failure)), (spaces) {
      _spaces = spaces;
      _spaces.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
    });

    _setLoading(false);
  }

  // Get space by ID
  Future<Space?> getSpaceById(String id) async {
    final result = await _getSpaceByIdUseCase.call(id);

    return result.fold(
      (failure) {
        _setError(_getErrorMessage(failure));
        return null;
      },
      (space) {
        _selectedSpace = space;
        notifyListeners();
        return space;
      },
    );
  }

  // Add new space
  Future<bool> addSpace(AddSpaceParams params) async {
    _setLoading(true);
    _clearError();

    final result = await _addSpaceUseCase.call(params);

    final success = result.fold(
      (failure) {
        _setError(_getErrorMessage(failure));
        return false;
      },
      (space) {
        _spaces.insert(0, space);
        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  // Update existing space
  Future<bool> updateSpace(UpdateSpaceParams params) async {
    _setLoading(true);
    _clearError();

    final result = await _updateSpaceUseCase.call(params);

    final success = result.fold(
      (failure) {
        _setError(_getErrorMessage(failure));
        return false;
      },
      (updatedSpace) {
        final index = _spaces.indexWhere((s) => s.id == updatedSpace.id);
        if (index != -1) {
          _spaces[index] = updatedSpace;
        }

        // Update selected space if it's the same
        if (_selectedSpace?.id == updatedSpace.id) {
          _selectedSpace = updatedSpace;
        }

        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  // Delete space
  Future<bool> deleteSpace(String id) async {
    _setLoading(true);
    _clearError();

    final result = await _deleteSpaceUseCase.call(id);

    final success = result.fold(
      (failure) {
        _setError(_getErrorMessage(failure));
        return false;
      },
      (_) {
        _spaces.removeWhere((space) => space.id == id);

        // Clear selected space if it was deleted
        if (_selectedSpace?.id == id) {
          _selectedSpace = null;
        }

        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  // Clear selected space
  void clearSelectedSpace() {
    _selectedSpace = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _clearError();
  }

  // Get spaces count
  int get spacesCount => _spaces.length;

  // Find space by name
  Space? findSpaceByName(String name) {
    try {
      return _spaces.firstWhere(
        (space) => space.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get spaces with specific light condition
  List<Space> getSpacesByLightCondition(String lightCondition) {
    return _spaces
        .where((space) => space.lightCondition == lightCondition)
        .toList();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure _:
        return failure.message;
      case CacheFailure _:
        return failure.message;
      case NetworkFailure _:
        return 'Sem conexão com a internet';
      case ServerFailure _:
        // Check if it's specifically an auth error
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
