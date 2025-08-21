import 'package:flutter/foundation.dart';
import '../../domain/entities/plant.dart';
import '../../domain/repositories/plants_repository.dart';
import '../../../../core/error/error_adapter.dart';

class PlantsListProvider extends ChangeNotifier with ErrorHandlingMixin {
  final PlantsRepository _plantsRepository;

  PlantsListProvider({required PlantsRepository plantsRepository})
    : _plantsRepository = plantsRepository;

  List<Plant> _plants = [];
  List<Plant> _filteredPlants = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<Plant> get plants =>
      _filteredPlants.isEmpty && _searchQuery.isEmpty
          ? _plants
          : _filteredPlants;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get hasPlants => _plants.isNotEmpty;
  bool get isEmpty => _plants.isEmpty && !_isLoading;
  int get plantsCount => _plants.length;

  // Error handling - agora vem do mixin
  String? get errorMessage => lastError?.message;

  // Main methods
  Future<void> loadPlants() async {
    _setLoading(true);

    final plants = await handleEitherOperation(
      () => _plantsRepository.getPlants(),
    );

    if (plants != null) {
      _plants = plants;
      _applySearch(); // Reapply current search if any
    }

    _setLoading(false);
  }

  Future<void> addPlant(Plant plant) async {
    final addedPlant = await handleEitherOperation(
      () => _plantsRepository.addPlant(plant),
    );

    if (addedPlant != null) {
      _plants.add(addedPlant);
      _applySearch(); // Reapply search to include new plant if it matches
    }
  }

  Future<void> updatePlant(Plant plant) async {
    final updatedPlant = await handleEitherOperation(
      () => _plantsRepository.updatePlant(plant),
    );

    if (updatedPlant != null) {
      final index = _plants.indexWhere((p) => p.id == updatedPlant.id);
      if (index != -1) {
        _plants[index] = updatedPlant;
        _applySearch(); // Reapply search after update
      }
    }
  }

  Future<void> deletePlant(String id) async {
    await handleEitherOperation(
      () => _plantsRepository.deletePlant(id),
    );

    // Se chegou até aqui, a operação foi bem-sucedida
    _plants.removeWhere((plant) => plant.id == id);
    _filteredPlants.removeWhere((plant) => plant.id == id);
    notifyListeners();
  }

  // Search functionality
  void searchPlants(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applySearch();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredPlants.clear();
    notifyListeners();
  }

  Future<void> performRemoteSearch(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _setLoading(true);

    final searchResults = await handleEitherOperation(
      () => _plantsRepository.searchPlants(query),
    );

    if (searchResults != null) {
      _searchQuery = query.trim().toLowerCase();
      _filteredPlants = searchResults;
    }

    _setLoading(false);
  }

  // Filter methods
  List<Plant> getPlantsBySpace(String spaceId) {
    final plantsToFilter =
        _filteredPlants.isEmpty && _searchQuery.isEmpty
            ? _plants
            : _filteredPlants;
    return plantsToFilter.where((plant) => plant.spaceId == spaceId).toList();
  }

  List<Plant> getPlantsWithImages() {
    final plantsToFilter =
        _filteredPlants.isEmpty && _searchQuery.isEmpty
            ? _plants
            : _filteredPlants;
    return plantsToFilter.where((plant) => plant.hasImage).toList();
  }

  List<Plant> getRecentPlants({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final plantsToFilter =
        _filteredPlants.isEmpty && _searchQuery.isEmpty
            ? _plants
            : _filteredPlants;
    return plantsToFilter
        .where((plant) => plant.createdAt?.isAfter(cutoffDate) ?? false)
        .toList();
  }

  // Utility methods
  Plant? getPlantById(String id) {
    try {
      return _plants.firstWhere((plant) => plant.id == id);
    } catch (e) {
      return null;
    }
  }

  void refresh() {
    loadPlants();
  }

  // Private methods
  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredPlants.clear();
    } else {
      _filteredPlants =
          _plants.where((plant) {
            final name = plant.name.toLowerCase();
            final species = plant.species?.toLowerCase() ?? '';
            final notes = plant.notes?.toLowerCase() ?? '';

            return name.contains(_searchQuery) ||
                species.contains(_searchQuery) ||
                notes.contains(_searchQuery);
          }).toList();
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
