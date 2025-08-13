// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'favoritos_data_service.dart';

/// Service responsible for search and filtering logic
/// Follows Single Responsibility Principle by handling only search operations
class FavoritosSearchService extends GetxController {
  // =========================================================================
  // Constants
  // =========================================================================
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);

  // =========================================================================
  // Dependencies
  // =========================================================================
  late final FavoritosDataService _dataService;

  // =========================================================================
  // Controllers and State
  // =========================================================================
  late final List<TextEditingController> searchControllers;
  final List<VoidCallback> _searchListeners = [];

  // Debounce functionality
  Timer? _searchDebounceTimer;
  final Map<int, bool> _isSearching = {};

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
    _initSearchControllers();
  }

  @override
  void onClose() {
    _cleanupSearchResources();
    super.onClose();
  }

  // =========================================================================
  // Initialization
  // =========================================================================
  
  void _initDependencies() {
    try {
      _dataService = Get.find<FavoritosDataService>();
    } catch (e) {
      // Service initialization error - continue with defaults
    }
  }

  void _initSearchControllers() {
    try {
      searchControllers = List.generate(3, (_) => TextEditingController());
      _addSearchListeners();
    } catch (e) {
      // Service initialization error - continue with defaults
    }
  }

  void _addSearchListeners() {
    try {
      // Clear any existing listeners first
      _searchListeners.clear();
      
      // Create and store listener functions for safe removal later
      _searchListeners.addAll([
        () => filtrarDefensivos(searchControllers[0].text),
        () => filtrarPragas(searchControllers[1].text),
        () => filtrarDiagnosticos(searchControllers[2].text),
      ]);

      // Add listeners to controllers
      for (int i = 0; i < searchControllers.length && i < _searchListeners.length; i++) {
        searchControllers[i].addListener(_searchListeners[i]);
      }
      
    } catch (e) {
      // Service initialization error - continue with defaults
    }
  }

  // =========================================================================
  // Cleanup Methods
  // =========================================================================

  void _cleanupSearchResources() {
    try {
      // Cleanup timer first
      _cleanupTimer();
      
      // Remove listeners safely
      for (int i = 0; i < searchControllers.length && i < _searchListeners.length; i++) {
        try {
          final controller = searchControllers[i];
          final listener = _searchListeners[i];
          
          // Remove listener safely
          controller.removeListener(listener);
        } catch (e) {
          // Error removing listener - continue cleanup
        }
      }
      
      // Dispose controllers
      for (int i = 0; i < searchControllers.length; i++) {
        try {
          final controller = searchControllers[i];
          controller.dispose();
        } catch (e) {
          // Error disposing controller - continue cleanup
        }
      }
      
      // Clear the listeners list
      _searchListeners.clear();
      debugPrint('✅ FavoritosSearchService: Recursos de busca limpos');
      
    } catch (e) {
      // Error during cleanup - continue
    }
  }

  void _cleanupTimer() {
    try {
      if (_searchDebounceTimer != null) {
        if (_searchDebounceTimer!.isActive) {
          _searchDebounceTimer!.cancel();
        }
        _searchDebounceTimer = null;
      }
    } catch (e) {
      // Error cleaning up timer - continue
    }
  }

  // =========================================================================
  // Generic Filter System - Eliminates code duplication
  // =========================================================================
  
  /// Generic filter method that eliminates duplication
  void _applyFilter(String query, String filterType, void Function(String) updateFunction) {
    try {
      updateFunction(query);
      debugPrint('🔍 FavoritosSearchService: $filterType filtrados com: "$query"');
    } catch (e) {
      // Error applying filter - continue with current state
    }
  }

  // =========================================================================
  // Public Filter Methods - Now use generic implementation
  // =========================================================================
  
  void filtrarDefensivos(String query) => _applyFilter(
    query, 
    'Defensivos', 
    _dataService.updateDefensivosFilter
  );

  void filtrarPragas(String query) => _applyFilter(
    query,
    'Pragas', 
    _dataService.updatePragasFilter
  );

  void filtrarDiagnosticos(String query) => _applyFilter(
    query,
    'Diagnósticos', 
    _dataService.updateDiagnosticosFilter
  );

  /// Enhanced filter dispatcher using lookup table instead of switch
  void filterItems(int tabIndex, String query) {
    // Filter function lookup table - eliminates switch statement duplication
    final filterFunctions = <int, void Function(String)>{
      0: filtrarDefensivos,
      1: filtrarPragas,
      2: filtrarDiagnosticos,
    };

    final filterFunction = filterFunctions[tabIndex];
    if (filterFunction != null) {
      filterFunction(query);
    } else {
      debugPrint('⚠️ FavoritosSearchService: Índice de aba inválido: $tabIndex');
    }
  }

  // =========================================================================
  // Debounced Search Methods
  // =========================================================================
  
  void onSearchChanged(int tabIndex) {
    try {
      _cancelCurrentSearchTimer();

      final searchText = searchControllers[tabIndex].text;
      debugPrint('🔍 FavoritosSearchService: Texto de busca mudou para aba $tabIndex: "$searchText"');

      // Update searching state immediately
      _isSearching[tabIndex] = searchText.isNotEmpty;
      update();

      // Start new debounce timer
      _searchDebounceTimer = Timer(searchDebounceDelay, () {
        debugPrint('🔍 FavoritosSearchService: Executando busca após debounce para aba $tabIndex: "$searchText"');
        _performSearch(tabIndex, searchText);
      });
    } catch (e) {
      _isSearching[tabIndex] = false;
      update();
    }
  }

  void _cancelCurrentSearchTimer() {
    try {
      if (_searchDebounceTimer != null) {
        if (_searchDebounceTimer!.isActive) {
          _searchDebounceTimer!.cancel();
        }
        _searchDebounceTimer = null;
      }
    } catch (e) {
      // Service initialization error - continue with defaults
    }
  }

  void _performSearch(int tabIndex, String searchText) {
    try {
      filterItems(tabIndex, searchText);
      // Manter _isSearching = true se ainda há texto de busca
      _isSearching[tabIndex] = searchText.isNotEmpty;
      update();
      debugPrint('✅ FavoritosSearchService: Busca executada para aba $tabIndex');
    } catch (e) {
      _isSearching[tabIndex] = searchText.isNotEmpty;
      update();
    }
  }

  void clearSearch(int tabIndex) {
    try {
      _cancelCurrentSearchTimer();
      searchControllers[tabIndex].clear();
      _isSearching[tabIndex] = false;
      filterItems(tabIndex, '');
      update();
      debugPrint('✅ FavoritosSearchService: Busca limpa para aba $tabIndex');
    } catch (e) {
      // Service initialization error - continue with defaults
    }
  }

  // =========================================================================
  // Public State Methods
  // =========================================================================
  
  bool isSearchingForTab(int tabIndex) {
    return _isSearching[tabIndex] ?? false;
  }

  String getSearchTextForTab(int tabIndex) {
    if (tabIndex >= 0 && tabIndex < searchControllers.length) {
      return searchControllers[tabIndex].text;
    }
    return '';
  }

  void setSearchTextForTab(int tabIndex, String text) {
    if (tabIndex >= 0 && tabIndex < searchControllers.length) {
      searchControllers[tabIndex].text = text;
    }
  }
}
