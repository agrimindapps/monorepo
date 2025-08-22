import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/calculator_entity.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/services/calculator_favorites_service.dart';
import '../providers/calculator_provider_simple.dart';
import '../widgets/calculator_card_widget.dart';

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
  
  CalculatorCategory? _selectedCategory;
  CalculatorComplexity? _selectedComplexity;
  CalculatorSortOrder _sortOrder = CalculatorSortOrder.nameAsc;
  List<String> _selectedTags = [];
  bool _showOnlyFavorites = false;
  
  List<CalculatorEntity> _searchResults = [];
  List<String> _availableTags = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CalculatorProvider>();
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
              _buildSearchBar(),
              
              // Filtros avançados
              _buildAdvancedFilters(),
              
              // Resultados da busca
              Expanded(
                child: _buildSearchResults(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Digite para buscar calculadoras...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _updateSearchResults();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
            onChanged: (_) => _updateSearchResults(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Busque por nome, descrição, categoria ou parâmetros',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return ExpansionTile(
      title: const Text('Filtros Avançados'),
      leading: const Icon(Icons.filter_list),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categoria
              _buildCategoryFilter(),
              const SizedBox(height: 16),
              
              // Complexidade
              _buildComplexityFilter(),
              const SizedBox(height: 16),
              
              // Tags
              _buildTagsFilter(),
              const SizedBox(height: 16),
              
              // Ordenação
              _buildSortOrderFilter(),
              const SizedBox(height: 16),
              
              // Favoritos
              _buildFavoritesFilter(),
              const SizedBox(height: 16),
              
              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text('Limpar Filtros'),
                  ),
                  ElevatedButton(
                    onPressed: _updateSearchResults,
                    child: const Text('Aplicar Filtros'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Todas'),
              selected: _selectedCategory == null,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? null : _selectedCategory;
                });
                _updateSearchResults();
              },
            ),
            ...CalculatorCategory.values.map((category) {
              return FilterChip(
                label: Text(category.displayName),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                  _updateSearchResults();
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildComplexityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complexidade',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Todas'),
              selected: _selectedComplexity == null,
              onSelected: (selected) {
                setState(() {
                  _selectedComplexity = selected ? null : _selectedComplexity;
                });
                _updateSearchResults();
              },
            ),
            ...CalculatorComplexity.values.map((complexity) {
              return FilterChip(
                label: Text(_getComplexityName(complexity)),
                selected: _selectedComplexity == complexity,
                onSelected: (selected) {
                  setState(() {
                    _selectedComplexity = selected ? complexity : null;
                  });
                  _updateSearchResults();
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (_availableTags.isEmpty)
          Text(
            'Nenhuma tag disponível',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              return FilterChip(
                label: Text(tag),
                selected: _selectedTags.contains(tag),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                  _updateSearchResults();
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSortOrderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenação',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<CalculatorSortOrder>(
          value: _sortOrder,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: CalculatorSortOrder.values.map((order) {
            return DropdownMenuItem(
              value: order,
              child: Text(_getSortOrderName(order)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _sortOrder = value;
              });
              _updateSearchResults();
            }
          },
        ),
      ],
    );
  }

  Widget _buildFavoritesFilter() {
    return Row(
      children: [
        Checkbox(
          value: _showOnlyFavorites,
          onChanged: (value) {
            setState(() {
              _showOnlyFavorites = value ?? false;
            });
            _updateSearchResults();
          },
        ),
        const SizedBox(width: 8),
        Text(
          'Mostrar apenas favoritas',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSearchResults(CalculatorProvider provider) {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando calculadoras...'),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma calculadora encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tente ajustar os termos de busca\nou os filtros selecionados',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearAllFilters,
              child: const Text('Limpar Filtros'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho dos resultados
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${_searchResults.length} ${_searchResults.length == 1 ? "calculadora encontrada" : "calculadoras encontradas"}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Lista de resultados
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final calculator = _searchResults[index];
              return CalculatorCardWidget(
                calculator: calculator,
                isFavorite: provider.isCalculatorFavorite(calculator.id),
                onTap: () => _navigateToCalculator(calculator.id),
                onFavoriteToggle: () => provider.toggleFavorite(calculator.id),
                showCategory: _selectedCategory == null,
              );
            },
          ),
        ),
      ],
    );
  }

  void _updateSearchResults() async {
    setState(() {
      _isSearching = true;
    });

    final provider = context.read<CalculatorProvider>();
    List<CalculatorEntity> results = List.from(provider.calculators);

    // Aplicar busca por texto
    if (_searchController.text.trim().isNotEmpty) {
      results = CalculatorSearchService.searchCalculators(
        results,
        _searchController.text,
      );
    }

    // Aplicar filtro de categoria
    results = CalculatorSearchService.filterByCategory(results, _selectedCategory);

    // Aplicar filtro de complexidade
    results = CalculatorSearchService.filterByComplexity(results, _selectedComplexity);

    // Aplicar filtro de tags
    results = CalculatorSearchService.filterByTags(results, _selectedTags);

    // Aplicar filtro de favoritos
    if (_showOnlyFavorites) {
      final favoritesService = CalculatorFavoritesService(
        await SharedPreferences.getInstance(),
      );
      results = await favoritesService.filterFavorites(results);
    }

    // Aplicar ordenação
    results = CalculatorSearchService.sortCalculators(results, _sortOrder);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _extractAvailableTags(List<CalculatorEntity> calculators) {
    final allTags = <String>{};
    for (final calculator in calculators) {
      allTags.addAll(calculator.tags);
    }
    
    setState(() {
      _availableTags = allTags.toList()..sort();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedComplexity = null;
      _selectedTags.clear();
      _sortOrder = CalculatorSortOrder.nameAsc;
      _showOnlyFavorites = false;
    });
    _updateSearchResults();
  }

  void _navigateToCalculator(String calculatorId) {
    context.push('/home/calculators/detail/$calculatorId');
  }

  String _getComplexityName(CalculatorComplexity complexity) {
    switch (complexity) {
      case CalculatorComplexity.simple:
        return 'Simples';
      case CalculatorComplexity.intermediate:
        return 'Intermediária';
      case CalculatorComplexity.advanced:
        return 'Avançada';
    }
  }

  String _getSortOrderName(CalculatorSortOrder order) {
    switch (order) {
      case CalculatorSortOrder.nameAsc:
        return 'Nome (A-Z)';
      case CalculatorSortOrder.nameDesc:
        return 'Nome (Z-A)';
      case CalculatorSortOrder.categoryAsc:
        return 'Categoria';
      case CalculatorSortOrder.complexityAsc:
        return 'Complexidade (Crescente)';
      case CalculatorSortOrder.complexityDesc:
        return 'Complexidade (Decrescente)';
    }
  }
}