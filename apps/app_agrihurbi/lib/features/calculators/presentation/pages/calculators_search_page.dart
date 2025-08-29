import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/debounced_search_manager.dart';
import '../../../../core/utils/performance_benchmark.dart';
import '../../../../core/widgets/design_system_components.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/services/calculator_favorites_service.dart';
import '../../domain/services/calculator_search_service.dart' as search_service;
import '../../domain/services/calculator_ui_service.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calculator_search_bar_widget.dart';
import '../widgets/calculator_search_filters_widget.dart';
import '../widgets/calculator_search_results_widget.dart';

/// Página de busca avançada de calculadoras
/// 
/// Implementa busca por texto, filtros avançados e sugestões
class CalculatorsSearchPage extends StatefulWidget {
  const CalculatorsSearchPage({super.key});

  @override
  State<CalculatorsSearchPage> createState() => _CalculatorsSearchPageState();
}

class _CalculatorsSearchPageState extends State<CalculatorsSearchPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late final _debouncedSearchManager = DebouncedSearchManager();
  
  CalculatorCategory? _selectedCategory;
  CalculatorComplexity? _selectedComplexity;
  search_service.CalculatorSortOrder _sortOrder = search_service.CalculatorSortOrder.nameAsc;
  List<String> _selectedTags = [];
  bool _showOnlyFavorites = false;
  
  List<CalculatorEntity> _searchResults = [];
  List<String> _availableTags = [];
  bool _isSearching = false;
  
  // Performance benchmarking
  int _searchCallCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debouncedSearchManager.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // ✅ Safety check
      final provider = Provider.of<CalculatorProvider>(context, listen: false);
      _updateSearchResults();
      _extractAvailableTags(provider.calculators);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Calculadoras'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAllFilters,
            tooltip: 'Limpar filtros',
          ),
        ],
      ),
      body: Consumer<CalculatorProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Barra de busca
              CalculatorSearchBarWidget(
                controller: _searchController,
                onChanged: (_) => _debouncedSearchManager.searchWithDebounce(
                  _searchController.text,
                  _performOptimizedSearch,
                ),
                isLoading: _isSearching,
              ),
              
              // Filtros avançados
              CalculatorSearchFiltersWidget(
                selectedCategory: _selectedCategory,
                selectedComplexity: _selectedComplexity,
                selectedTags: _selectedTags,
                sortOrder: _sortOrder,
                showOnlyFavorites: _showOnlyFavorites,
                availableTags: _availableTags,
                onCategoryChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  _updateSearchResults();
                },
                onComplexityChanged: (complexity) {
                  setState(() {
                    _selectedComplexity = complexity;
                  });
                  _updateSearchResults();
                },
                onTagsChanged: (tags) {
                  setState(() {
                    _selectedTags = tags;
                  });
                  _updateSearchResults();
                },
                onSortOrderChanged: (order) {
                  setState(() {
                    _sortOrder = order;
                  });
                  _updateSearchResults();
                },
                onFavoritesFilterChanged: (showFavorites) {
                  setState(() {
                    _showOnlyFavorites = showFavorites;
                  });
                  _updateSearchResults();
                },
                onClearFilters: _clearAllFilters,
                onApplyFilters: _updateSearchResults,
              ),
              
              // Resultados da busca
              Expanded(
                child: CalculatorSearchResultsWidget(
                  searchResults: _searchResults,
                  isSearching: _isSearching,
                  showCategory: _selectedCategory == null,
                  scrollController: _scrollController,
                  onClearFilters: _clearAllFilters,
                  searchCallCount: _searchCallCount,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Método removido - funcionalidade movida para CalculatorSearchBarWidget

  // Método removido - funcionalidade movida para CalculatorSearchFiltersWidget

  // Método removido - funcionalidade movida para CalculatorSearchFiltersWidget

  // Método removido - funcionalidade movida para CalculatorSearchFiltersWidget

  // Método removido - funcionalidade movida para CalculatorSearchFiltersWidget

  // Método removido - funcionalidade movida para CalculatorSearchFiltersWidget

  // Método removido - funcionalidade movida para CalculatorSearchFiltersWidget

  // Método removido - funcionalidade movida para CalculatorSearchResultsWidget

  /// Nova implementação otimizada com single-pass algorithm
  void _performOptimizedSearch(String query) async {
    if (!mounted) return; // ✅ Safety check at start
    
    setState(() {
      _isSearching = true;
      _searchCallCount++;
    });

    await PerformanceBenchmark.measureAsync(
      'search_otimizada',
      () async {
        final provider = Provider.of<CalculatorProvider>(context, listen: false);
        
        // Obter IDs dos favoritos para o filtro
        List<String> favoriteIds = [];
        if (_showOnlyFavorites) {
          final favoritesService = CalculatorFavoritesService(
            await SharedPreferences.getInstance(),
          );
          favoriteIds = await favoritesService.getFavoriteIds();
        }

        if (!mounted) return <CalculatorEntity>[];

        // Criar critérios de busca unificados
        final criteria = search_service.SearchCriteria(
          query: query.trim().isEmpty ? null : query.trim(),
          category: _selectedCategory,
          complexity: _selectedComplexity,
          tags: _selectedTags,
          sortOrder: _sortOrder,
          favoriteIds: favoriteIds,
          showOnlyFavorites: _showOnlyFavorites,
        );

        // Executar busca otimizada em single-pass
        final results = search_service.CalculatorSearchService.optimizedSearch(
          provider.calculators,
          criteria,
        );

        if (!mounted) return results;
        
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });

        return results;
      },
    );
  }
  
  /// Método legacy mantido para compatibilidade
  void _updateSearchResults() {
    _performOptimizedSearch(_searchController.text);
  }
  
  // Método removido - funcionalidade movida para CalculatorSearchResultsWidget

  void _extractAvailableTags(List<CalculatorEntity> calculators) {
    setState(() {
      _availableTags = CalculatorUIService.extractAvailableTags(calculators);
    });
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedComplexity = null;
      _selectedTags.clear();
      _sortOrder = search_service.CalculatorSortOrder.nameAsc;
      _showOnlyFavorites = false;
    });
    _updateSearchResults();
  }

  // Método removido - funcionalidade movida para widgets

  // Método removido - funcionalidade movida para CalculatorSearchFiltersWidget

  // Método removido - funcionalidade movida para CalculatorSearchFiltersWidget

}