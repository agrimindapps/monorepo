import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/debounced_search_manager.dart';
import '../../../../core/utils/performance_benchmark.dart';
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
class CalculatorsSearchPage extends ConsumerStatefulWidget {
  const CalculatorsSearchPage({super.key});

  @override
  ConsumerState<CalculatorsSearchPage> createState() =>
      _CalculatorsSearchPageState();
}

class _CalculatorsSearchPageState extends ConsumerState<CalculatorsSearchPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late final _debouncedSearchManager = DebouncedSearchManager();

  CalculatorCategory? _selectedCategory;
  CalculatorComplexity? _selectedComplexity;
  search_service.CalculatorSortOrder _sortOrder =
      search_service.CalculatorSortOrder.nameAsc;
  List<String> _selectedTags = [];
  bool _showOnlyFavorites = false;

  List<CalculatorEntity> _searchResults = [];
  List<String> _availableTags = [];
  bool _isSearching = false;
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
      final provider = ref.read(calculatorProvider);
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
      body: Builder(
        builder: (context) {
          ref.watch(calculatorProvider); // Watch for reactivity
          return Column(
            children: [
              CalculatorSearchBarWidget(
                controller: _searchController,
                onChanged: (_) => _debouncedSearchManager.searchWithDebounce(
                  _searchController.text,
                  _performOptimizedSearch,
                ),
                isLoading: _isSearching,
              ),
              CalculatorSearchFiltersWidget(
                selectedCategory: _selectedCategory,
                selectedComplexity: _selectedComplexity,
                selectedTags: _selectedTags,
                sortOrder: _sortOrder,
                showOnlyFavorites: _showOnlyFavorites,
                availableTags: _availableTags,
                onCategoryChanged: (CalculatorCategory? category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  _updateSearchResults();
                },
                onComplexityChanged: (CalculatorComplexity? complexity) {
                  setState(() {
                    _selectedComplexity = complexity;
                  });
                  _updateSearchResults();
                },
                onTagsChanged: (List<String> tags) {
                  setState(() {
                    _selectedTags = tags;
                  });
                  _updateSearchResults();
                },
                onSortOrderChanged: (search_service.CalculatorSortOrder order) {
                  setState(() {
                    _sortOrder = order;
                  });
                  _updateSearchResults();
                },
                onFavoritesFilterChanged: (bool showFavorites) {
                  setState(() {
                    _showOnlyFavorites = showFavorites;
                  });
                  _updateSearchResults();
                },
                onClearFilters: _clearAllFilters,
                onApplyFilters: _updateSearchResults,
              ),
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

  /// Nova implementação otimizada com single-pass algorithm
  void _performOptimizedSearch(String query) async {
    if (!mounted) return; // ✅ Safety check at start

    setState(() {
      _isSearching = true;
      _searchCallCount++;
    });

    await PerformanceBenchmark.measureAsync('search_otimizada', () async {
      final provider = ref.read(calculatorProvider);
      List<String> favoriteIds = [];
      if (_showOnlyFavorites) {
        final favoritesService = CalculatorFavoritesService(
          await SharedPreferences.getInstance(),
        );
        favoriteIds = await favoritesService.getFavoriteIds();
      }

      if (!mounted) return <CalculatorEntity>[];
      final criteria = search_service.SearchCriteria(
        query: query.trim().isEmpty ? null : query.trim(),
        category: _selectedCategory,
        complexity: _selectedComplexity,
        tags: _selectedTags,
        sortOrder: _sortOrder,
        favoriteIds: favoriteIds,
        showOnlyFavorites: _showOnlyFavorites,
      );
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
    });
  }

  void _updateSearchResults() {
    _performOptimizedSearch(_searchController.text);
  }

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
}
