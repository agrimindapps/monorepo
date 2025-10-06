import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
class CalculatorsListPage extends ConsumerStatefulWidget {
  final String? category;

  const CalculatorsListPage({super.key, this.category});

  @override
  ConsumerState<CalculatorsListPage> createState() =>
      _CalculatorsListPageState();
}

class _CalculatorsListPageState extends ConsumerState<CalculatorsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // ✅ Safety check
      final provider = ref.read(calculatorProvider.notifier);
      provider.refreshAllData();
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
    final provider = ref.watch(calculatorProvider);
    final providerNotifier = ref.read(calculatorProvider.notifier);
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
            onPressed: () => providerNotifier.refreshAllData(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(provider, providerNotifier),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllCalculatorsTab(provider, providerNotifier),
                _buildFavoritesTab(provider, providerNotifier),
                _buildHistoryTab(provider, providerNotifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(
    CalculatorProvider provider,
    CalculatorProvider providerNotifier,
  ) {
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
            onChanged: providerNotifier.updateSearchQuery,
            hintText: 'Buscar calculadoras...',
          ),
          const SizedBox(height: 12),
          CalculatorCategoryFilter(
            selectedCategory: provider.selectedCategory,
            onCategoryChanged: providerNotifier.updateCategoryFilter,
            onClearFilters: providerNotifier.clearFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildAllCalculatorsTab(
    CalculatorProvider provider,
    CalculatorProvider providerNotifier,
  ) {
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
          providerNotifier.clearError();
          providerNotifier.loadCalculators();
        },
      );
    }

    final calculators = provider.filteredCalculators;

    if (calculators.isEmpty) {
      final hasFilters =
          provider.searchQuery.isNotEmpty || provider.selectedCategory != null;
      return CalculatorEmptyStateWidget(
        type:
            hasFilters
                ? CalculatorEmptyStateType.noSearchResults
                : CalculatorEmptyStateType.noCalculators,
        onAction:
            hasFilters
                ? () {
                  _searchController.clear();
                  providerNotifier.clearFilters();
                }
                : null,
      );
    }

    return CalculatorListWidget(
      calculators: calculators,
      scrollController: _scrollController,
      showCategory: provider.selectedCategory == null,
      onRefresh: providerNotifier.loadCalculators,
    );
  }

  Widget _buildFavoritesTab(
    CalculatorProvider provider,
    CalculatorProvider providerNotifier,
  ) {
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
      onRefresh: providerNotifier.refreshAllData,
    );
  }

  Widget _buildHistoryTab(
    CalculatorProvider provider,
    CalculatorProvider providerNotifier,
  ) {
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
      onReapply:
          (CalculationHistory historyItem) =>
              _navigateToCalculatorWithHistory(historyItem, providerNotifier),
      onDelete:
          (CalculationHistory historyItem) =>
              providerNotifier.removeFromHistory(historyItem.id),
    );
  }

  void _navigateToCalculatorWithHistory(
    CalculationHistory historyItem,
    CalculatorProvider providerNotifier,
  ) {
    providerNotifier.applyHistoryResult(historyItem);
    CalculatorUIService.navigateToCalculatorWithHistory(context, historyItem);
  }

  String _getPageTitle() {
    return CalculatorUIService.getPageTitle(widget.category);
  }

  CalculatorCategory? _mapStringToCategory(String categoryString) {
    return CalculatorUIService.mapStringToCategory(categoryString);
  }
}
