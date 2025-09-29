import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/design_system_components.dart';
import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/services/calculator_ui_service.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calculator_category_filter.dart';
import '../widgets/calculator_empty_state_widget.dart';
import '../widgets/calculator_history_list_widget.dart';
import '../widgets/calculator_list_widget.dart';
import '../widgets/calculator_search_widget.dart';

/// Página de listagem de calculadoras
/// 
/// Implementa navegação por categorias, busca e favoritos
/// Segue o padrão Provider estabelecido na migração livestock
class CalculatorsListPage extends StatefulWidget {
  final String? category;
  
  const CalculatorsListPage({super.key, category});

  @override
  State<CalculatorsListPage> createState() => _CalculatorsListPageState();
}

class _CalculatorsListPageState extends State<CalculatorsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Carrega dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // ✅ Safety check
      final provider = Provider.of<CalculatorProvider>(context, listen: false);
      provider.refreshAllData();
      
      // Aplica filtro de categoria se especificado
      if (widget.category != null) {
        final category = _mapStringToCategory(widget.category!);
        if (category != null) {
          provider.updateCategoryFilter(category);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calculate), text: 'Todas'),
            Tab(icon: Icon(Icons.favorite), text: 'Favoritas'),
            Tab(icon: Icon(Icons.history), text: 'Histórico'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CalculatorProvider>().refreshAllData(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Consumer<CalculatorProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Barra de busca e filtros
              _buildSearchAndFilters(provider),
              
              // Conteúdo principal em abas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllCalculatorsTab(provider),
                    _buildFavoritesTab(provider),
                    _buildHistoryTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(CalculatorProvider provider) {
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
          CalculatorSearchWidget(
            controller: _searchController,
            onChanged: provider.updateSearchQuery,
            hintText: 'Buscar calculadoras...',
          ),
          const SizedBox(height: 12),
          CalculatorCategoryFilter(
            selectedCategory: provider.selectedCategory,
            onCategoryChanged: provider.updateCategoryFilter,
            onClearFilters: provider.clearFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildAllCalculatorsTab(CalculatorProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando calculadoras...'),
          ],
        ),
      );
    }

    if (provider.errorMessage != null) {
      return DSErrorState(
        message: provider.errorMessage!,
        onRetry: () {
          provider.clearError();
          provider.loadCalculators();
        },
      );
    }

    final calculators = provider.filteredCalculators;

    if (calculators.isEmpty) {
      final hasFilters = provider.searchQuery.isNotEmpty || provider.selectedCategory != null;
      return CalculatorEmptyStateWidget(
        type: hasFilters 
            ? CalculatorEmptyStateType.noSearchResults 
            : CalculatorEmptyStateType.noCalculators,
        onAction: hasFilters 
            ? () {
                _searchController.clear();
                provider.clearFilters();
              } 
            : null,
      );
    }

    return CalculatorListWidget(
      calculators: calculators,
      scrollController: _scrollController,
      showCategory: provider.selectedCategory == null,
      onRefresh: provider.loadCalculators,
    );
  }

  Widget _buildFavoritesTab(CalculatorProvider provider) {
    final favoriteCalculators = provider.favoriteCalculators;

    if (provider.isLoadingFavorites) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando favoritos...'),
          ],
        ),
      );
    }

    if (favoriteCalculators.isEmpty) {
      return const CalculatorEmptyStateWidget(
        type: CalculatorEmptyStateType.noFavorites,
      );
    }

    return CalculatorListWidget(
      calculators: favoriteCalculators,
      scrollController: _scrollController,
      showCategory: true,
      onRefresh: provider.refreshAllData,
    );
  }

  Widget _buildHistoryTab(CalculatorProvider provider) {
    final history = provider.calculationHistory;

    if (provider.isLoadingHistory) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando histórico...'),
          ],
        ),
      );
    }

    if (history.isEmpty) {
      return const CalculatorEmptyStateWidget(
        type: CalculatorEmptyStateType.noHistory,
      );
    }

    return CalculatorHistoryListWidget(
      history: history,
      scrollController: _scrollController,
      onReapply: (historyItem) => _navigateToCalculatorWithHistory(historyItem, provider),
      onDelete: (historyItem) => provider.removeFromHistory(historyItem.id),
    );
  }

  // Método removido - funcionalidade movida para CalculatorListWidget

  // Método removido - funcionalidade movida para CalculatorUIService

  void _navigateToCalculatorWithHistory(
    CalculationHistory historyItem,
    CalculatorProvider provider,
  ) {
    provider.applyHistoryResult(historyItem);
    CalculatorUIService.navigateToCalculatorWithHistory(context, historyItem);
  }

  // Método removido - funcionalidade movida para CalculatorHistoryListWidget

  // Método removido - funcionalidade movida para CalculatorHistoryListWidget

  // Método removido - funcionalidade movida para CalculatorUIService

  // Método removido - funcionalidade movida para CalculatorUIService

  String _getPageTitle() {
    return CalculatorUIService.getPageTitle(widget.category);
  }

  CalculatorCategory? _mapStringToCategory(String categoryString) {
    return CalculatorUIService.mapStringToCategory(categoryString);
  }
}