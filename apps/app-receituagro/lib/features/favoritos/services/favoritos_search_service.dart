import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/favoritos_design_tokens.dart';
import 'favoritos_data_service.dart';

class FavoritosSearchService extends ChangeNotifier {
  final FavoritosDataService _dataService;
  
  Timer? _searchDebounceTimer;
  
  final _searchControllers = <TextEditingController>[];
  
  FavoritosSearchService({required FavoritosDataService dataService})
      : _dataService = dataService {
    _searchControllers.addAll([
      TextEditingController(), // Defensivos
      TextEditingController(), // Pragas  
      TextEditingController(), // Diagnósticos
    ]);
  }

  TextEditingController getControllerForTab(int tabIndex) {
    if (tabIndex >= 0 && tabIndex < _searchControllers.length) {
      return _searchControllers[tabIndex];
    }
    return _searchControllers[0];
  }

  String getSearchTextForTab(int tabIndex) {
    return getControllerForTab(tabIndex).text;
  }

  void onSearchChanged(int tabIndex, String searchText) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(
      const Duration(milliseconds: 300),
      () => filterItems(tabIndex, searchText),
    );
  }

  void filterItems(int tabIndex, String searchText) {
    switch (tabIndex) {
      case 0:
        _dataService.updateDefensivosFilter(searchText);
        break;
      case 1:
        _dataService.updatePragasFilter(searchText);
        break;
      case 2:
        _dataService.updateDiagnosticosFilter(searchText);
        break;
    }
  }

  void clearSearch(int tabIndex) {
    getControllerForTab(tabIndex).clear();
    filterItems(tabIndex, '');
  }

  void clearAllSearches() {
    for (int i = 0; i < _searchControllers.length; i++) {
      clearSearch(i);
    }
  }

  bool hasActiveSearch(int tabIndex) {
    return getSearchTextForTab(tabIndex).isNotEmpty;
  }

  String getHintForTab(int tabIndex) {
    return FavoritosDesignTokens.getSearchHint(tabIndex);
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    for (final controller in _searchControllers) {
      try {
        controller.dispose();
      } catch (e) {
        debugPrint('Error disposing search controller: $e');
      }
    }
    super.dispose();
  }
}