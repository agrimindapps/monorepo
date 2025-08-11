import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../../domain/entities/space.dart';
import '../../domain/usecases/get_spaces_usecase.dart';
import '../../domain/usecases/add_space_usecase.dart';
import '../../domain/usecases/update_space_usecase.dart';
import '../../domain/usecases/delete_space_usecase.dart';

class SpacesProvider extends ChangeNotifier {
  final GetSpacesUseCase getSpacesUseCase;
  final SearchSpacesUseCase searchSpacesUseCase;
  final AddSpaceUseCase addSpaceUseCase;
  final UpdateSpaceUseCase updateSpaceUseCase;
  final DeleteSpaceUseCase deleteSpaceUseCase;

  SpacesProvider({
    required this.getSpacesUseCase,
    required this.searchSpacesUseCase,
    required this.addSpaceUseCase,
    required this.updateSpaceUseCase,
    required this.deleteSpaceUseCase,
  });

  // State
  List<Space> _spaces = [];
  List<Space> _filteredSpaces = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchQuery = '';
  ViewMode _viewMode = ViewMode.grid;
  SortOption _sortOption = SortOption.name;

  // Getters
  List<Space> get spaces => _filteredSpaces.isEmpty ? _spaces : _filteredSpaces;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasSpaces => spaces.isNotEmpty;
  String get searchQuery => _searchQuery;
  ViewMode get viewMode => _viewMode;
  SortOption get sortOption => _sortOption;

  int get spacesCount => _spaces.length;

  // Load spaces
  Future<void> loadSpaces() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getSpacesUseCase(NoParams());
    
    result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (spaces) {
        _spaces = spaces;
        _applySorting();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  // Search spaces
  Future<void> searchSpaces(String query) async {
    _searchQuery = query;
    
    if (query.trim().isEmpty) {
      _filteredSpaces = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    final result = await searchSpacesUseCase(query);
    
    result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
        _isSearching = false;
        notifyListeners();
      },
      (spaces) {
        _filteredSpaces = spaces;
        _applySorting();
        _isSearching = false;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  // Add space
  Future<bool> addSpace({
    required String name,
    String? description,
    String? imageBase64,
    required SpaceType type,
    SpaceConfig? config,
  }) async {
    final params = AddSpaceParams(
      name: name,
      description: description,
      imageBase64: imageBase64,
      type: type,
      config: config,
    );

    final result = await addSpaceUseCase(params);
    
    return result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
        notifyListeners();
        return false;
      },
      (space) {
        _spaces.add(space);
        _applySorting();
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  // Update space
  Future<bool> updateSpace({
    required String id,
    required String name,
    String? description,
    String? imageBase64,
    required SpaceType type,
    SpaceConfig? config,
  }) async {
    final params = UpdateSpaceParams(
      id: id,
      name: name,
      description: description,
      imageBase64: imageBase64,
      type: type,
      config: config,
    );

    final result = await updateSpaceUseCase(params);
    
    return result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
        notifyListeners();
        return false;
      },
      (updatedSpace) {
        final index = _spaces.indexWhere((s) => s.id == id);
        if (index != -1) {
          _spaces[index] = updatedSpace;
          _applySorting();
        }
        
        // Also update filtered spaces if searching
        if (_filteredSpaces.isNotEmpty) {
          final filteredIndex = _filteredSpaces.indexWhere((s) => s.id == id);
          if (filteredIndex != -1) {
            _filteredSpaces[filteredIndex] = updatedSpace;
          }
        }
        
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  // Delete space
  Future<bool> deleteSpace(String id) async {
    final result = await deleteSpaceUseCase(id);
    
    return result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
        notifyListeners();
        return false;
      },
      (_) {
        _spaces.removeWhere((s) => s.id == id);
        _filteredSpaces.removeWhere((s) => s.id == id);
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  // Get space by id
  Space? getSpaceById(String id) {
    try {
      return _spaces.firstWhere((space) => space.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredSpaces = [];
    _isSearching = false;
    notifyListeners();
  }

  // Change view mode
  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  // Change sort option
  void setSortOption(SortOption option) {
    _sortOption = option;
    _applySorting();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh
  Future<void> refresh() async {
    await loadSpaces();
  }

  // Apply sorting
  void _applySorting() {
    switch (_sortOption) {
      case SortOption.name:
        _spaces.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _filteredSpaces.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.type:
        _spaces.sort((a, b) => a.type.displayName.compareTo(b.type.displayName));
        _filteredSpaces.sort((a, b) => a.type.displayName.compareTo(b.type.displayName));
        break;
      case SortOption.dateCreated:
        _spaces.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _filteredSpaces.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.dateUpdated:
        _spaces.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        _filteredSpaces.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure:
        return failure.message;
      case NotFoundFailure:
        return 'Espaço não encontrado';
      case NetworkFailure:
        return 'Sem conexão com a internet';
      case ServerFailure:
        return 'Erro no servidor. Tente novamente.';
      case CacheFailure:
        return 'Erro local. Verifique o armazenamento.';
      case AuthFailure:
        return 'Erro de autenticação. Faça login novamente.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}

enum ViewMode { grid, list }

enum SortOption { name, type, dateCreated, dateUpdated }