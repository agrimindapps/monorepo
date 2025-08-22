import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/bovine_entity.dart';

/// Provider especializado para filtros de bovinos
/// 
/// Responsabilidade única: Gerenciar filtros e filtragem de bovinos
/// Seguindo Single Responsibility Principle
@singleton
class BovinesFilterProvider extends ChangeNotifier {
  
  // === STATE MANAGEMENT ===
  
  /// Filtros ativos
  String _searchQuery = '';
  String? _selectedBreed;
  String? _selectedOriginCountry;
  BovineAptitude? _selectedAptitude;
  BreedingSystem? _selectedBreedingSystem;
  bool _onlyActive = true;
  
  /// Cache de valores únicos para filtros
  Set<String> _availableBreeds = {};
  Set<String> _availableCountries = {};
  
  // === GETTERS ===
  
  String get searchQuery => _searchQuery;
  String? get selectedBreed => _selectedBreed;
  String? get selectedOriginCountry => _selectedOriginCountry;
  BovineAptitude? get selectedAptitude => _selectedAptitude;
  BreedingSystem? get selectedBreedingSystem => _selectedBreedingSystem;
  bool get onlyActive => _onlyActive;
  
  List<String> get availableBreeds => _availableBreeds.toList()..sort();
  List<String> get availableCountries => _availableCountries.toList()..sort();
  List<BovineAptitude> get availableAptitudes => BovineAptitude.values;
  List<BreedingSystem> get availableBreedingSystems => BreedingSystem.values;
  
  /// Verifica se algum filtro está ativo
  bool get hasActiveFilters => 
    _searchQuery.isNotEmpty ||
    _selectedBreed != null ||
    _selectedOriginCountry != null ||
    _selectedAptitude != null ||
    _selectedBreedingSystem != null ||
    !_onlyActive;
    
  /// Conta quantos filtros estão ativos
  int get activeFiltersCount {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_selectedBreed != null) count++;
    if (_selectedOriginCountry != null) count++;
    if (_selectedAptitude != null) count++;
    if (_selectedBreedingSystem != null) count++;
    if (!_onlyActive) count++; // Mostrando inativos também
    return count;
  }

  // === FILTER OPERATIONS ===

  /// Atualiza cache de valores disponíveis com base na lista de bovinos
  void updateAvailableValues(List<BovineEntity> bovines) {
    _availableBreeds.clear();
    _availableCountries.clear();
    
    for (final bovine in bovines) {
      _availableBreeds.add(bovine.breed);
      _availableCountries.add(bovine.originCountry);
    }
    
    // Remove filtros que não existem mais
    if (_selectedBreed != null && !_availableBreeds.contains(_selectedBreed)) {
      _selectedBreed = null;
    }
    if (_selectedOriginCountry != null && !_availableCountries.contains(_selectedOriginCountry)) {
      _selectedOriginCountry = null;
    }
    
    notifyListeners();
  }

  /// Aplica todos os filtros a uma lista de bovinos
  List<BovineEntity> applyFilters(List<BovineEntity> bovines) {
    var filtered = List<BovineEntity>.from(bovines);

    // Filtrar por status ativo/inativo
    if (_onlyActive) {
      filtered = filtered.where((bovine) => bovine.isActive).toList();
    }

    // Filtrar por busca de texto
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((bovine) =>
        bovine.commonName.toLowerCase().contains(query) ||
        bovine.breed.toLowerCase().contains(query) ||
        bovine.registrationId.toLowerCase().contains(query)
      ).toList();
    }

    // Filtrar por raça
    if (_selectedBreed != null) {
      filtered = filtered.where((bovine) => 
        bovine.breed.toLowerCase().contains(_selectedBreed!.toLowerCase())
      ).toList();
    }

    // Filtrar por país de origem
    if (_selectedOriginCountry != null) {
      filtered = filtered.where((bovine) => 
        bovine.originCountry.toLowerCase().contains(_selectedOriginCountry!.toLowerCase())
      ).toList();
    }

    // Filtrar por aptidão
    if (_selectedAptitude != null) {
      filtered = filtered.where((bovine) => bovine.aptitude == _selectedAptitude).toList();
    }

    // Filtrar por sistema de criação
    if (_selectedBreedingSystem != null) {
      filtered = filtered.where((bovine) => bovine.breedingSystem == _selectedBreedingSystem).toList();
    }

    return filtered;
  }

  // === FILTER SETTERS ===

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    debugPrint('BovinesFilterProvider: Query de busca atualizada - "$query"');
  }

  /// Atualiza filtro de raça
  void updateBreedFilter(String? breed) {
    _selectedBreed = breed;
    notifyListeners();
    debugPrint('BovinesFilterProvider: Filtro de raça atualizado - ${breed ?? "nenhum"}');
  }

  /// Atualiza filtro de país de origem
  void updateOriginCountryFilter(String? country) {
    _selectedOriginCountry = country;
    notifyListeners();
    debugPrint('BovinesFilterProvider: Filtro de país atualizado - ${country ?? "nenhum"}');
  }

  /// Atualiza filtro de aptidão
  void updateAptitudeFilter(BovineAptitude? aptitude) {
    _selectedAptitude = aptitude;
    notifyListeners();
    debugPrint('BovinesFilterProvider: Filtro de aptidão atualizado - ${aptitude?.name ?? "nenhum"}');
  }

  /// Atualiza filtro de sistema de criação
  void updateBreedingSystemFilter(BreedingSystem? system) {
    _selectedBreedingSystem = system;
    notifyListeners();
    debugPrint('BovinesFilterProvider: Filtro de sistema atualizado - ${system?.name ?? "nenhum"}');
  }

  /// Atualiza filtro de status ativo
  void updateActiveFilter(bool onlyActive) {
    _onlyActive = onlyActive;
    notifyListeners();
    debugPrint('BovinesFilterProvider: Filtro de ativos atualizado - $onlyActive');
  }

  /// Limpa todos os filtros
  void clearAllFilters() {
    _searchQuery = '';
    _selectedBreed = null;
    _selectedOriginCountry = null;
    _selectedAptitude = null;
    _selectedBreedingSystem = null;
    _onlyActive = true;
    notifyListeners();
    debugPrint('BovinesFilterProvider: Todos os filtros limpos');
  }

  /// Limpa apenas filtros de texto
  void clearTextFilters() {
    _searchQuery = '';
    notifyListeners();
    debugPrint('BovinesFilterProvider: Filtros de texto limpos');
  }

  /// Limpa apenas filtros de seleção
  void clearSelectionFilters() {
    _selectedBreed = null;
    _selectedOriginCountry = null;
    _selectedAptitude = null;
    _selectedBreedingSystem = null;
    notifyListeners();
    debugPrint('BovinesFilterProvider: Filtros de seleção limpos');
  }

  /// Define múltiplos filtros de uma vez
  void setFilters({
    String? searchQuery,
    String? breed,
    String? originCountry,
    BovineAptitude? aptitude,
    BreedingSystem? breedingSystem,
    bool? onlyActive,
  }) {
    bool changed = false;
    
    if (searchQuery != null && searchQuery != _searchQuery) {
      _searchQuery = searchQuery;
      changed = true;
    }
    
    if (breed != _selectedBreed) {
      _selectedBreed = breed;
      changed = true;
    }
    
    if (originCountry != _selectedOriginCountry) {
      _selectedOriginCountry = originCountry;
      changed = true;
    }
    
    if (aptitude != _selectedAptitude) {
      _selectedAptitude = aptitude;
      changed = true;
    }
    
    if (breedingSystem != _selectedBreedingSystem) {
      _selectedBreedingSystem = breedingSystem;
      changed = true;
    }
    
    if (onlyActive != null && onlyActive != _onlyActive) {
      _onlyActive = onlyActive;
      changed = true;
    }
    
    if (changed) {
      notifyListeners();
      debugPrint('BovinesFilterProvider: Múltiplos filtros atualizados');
    }
  }

  /// Obtém estado atual dos filtros como Map
  Map<String, dynamic> getCurrentFilters() {
    return {
      'searchQuery': _searchQuery,
      'selectedBreed': _selectedBreed,
      'selectedOriginCountry': _selectedOriginCountry,
      'selectedAptitude': _selectedAptitude?.name,
      'selectedBreedingSystem': _selectedBreedingSystem?.name,
      'onlyActive': _onlyActive,
    };
  }

  /// Restaura filtros de um Map
  void restoreFilters(Map<String, dynamic> filters) {
    _searchQuery = filters['searchQuery'] ?? '';
    _selectedBreed = filters['selectedBreed'];
    _selectedOriginCountry = filters['selectedOriginCountry'];
    
    // Restaura enums por nome
    if (filters['selectedAptitude'] != null) {
      _selectedAptitude = BovineAptitude.values.firstWhere(
        (apt) => apt.name == filters['selectedAptitude'],
        orElse: () => BovineAptitude.values.first,
      );
    }
    
    if (filters['selectedBreedingSystem'] != null) {
      _selectedBreedingSystem = BreedingSystem.values.firstWhere(
        (system) => system.name == filters['selectedBreedingSystem'],
        orElse: () => BreedingSystem.values.first,
      );
    }
    
    _onlyActive = filters['onlyActive'] ?? true;
    notifyListeners();
    debugPrint('BovinesFilterProvider: Filtros restaurados');
  }

  @override
  void dispose() {
    debugPrint('BovinesFilterProvider: Disposed');
    super.dispose();
  }
}