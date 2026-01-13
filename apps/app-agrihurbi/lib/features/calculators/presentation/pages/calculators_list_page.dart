import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/design_system_components.dart';
import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/services/calculator_ui_service.dart';
import '../providers/calculator_coordinator_provider.dart';
import '../providers/calculator_favorites_provider.dart';
import '../providers/calculator_history_provider.dart';
import '../providers/calculator_management_provider.dart';
import '../providers/calculator_search_provider.dart';
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
      final coordinator = ref.read(calculatorCoordinatorProvider.notifier);
      coordinator.initializeSystem();
      if (widget.category != null) {
        final category = _mapStringToCategory(widget.category!);
        if (category != null) {
          ref.read(calculatorSearchProvider.notifier).updateCategoryFilter(
            category,
          );
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
    final coordinator = ref.read(calculatorCoordinatorProvider.notifier);
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
            onPressed: () => coordinator.refreshAllData(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllCalculatorsTab(),
                _buildFavoritesTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final searchState = ref.watch(calculatorSearchProvider);
    final searchNotifier = ref.read(calculatorSearchProvider.notifier);
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
            onChanged: searchNotifier.updateSearchQuery,
            hintText: 'Buscar calculadoras...',
          ),
          const SizedBox(height: 12),
          CalculatorCategoryFilter(
            selectedCategory: searchState.selectedCategory,
            onCategoryChanged: searchNotifier.updateCategoryFilter,
            onClearFilters: searchNotifier.clearAllFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildAllCalculatorsTab() {
    final managementState = ref.watch(calculatorManagementProvider);
    final searchState = ref.watch(calculatorSearchProvider);
    final coordinator = ref.read(calculatorCoordinatorProvider.notifier);
    if (managementState.isLoading) {
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

    if (managementState.errorMessage != null) {
      return DSErrorState(
        message: managementState.errorMessage!,
        onRetry: () {
          ref.read(calculatorManagementProvider.notifier).clearError();
          ref.read(calculatorManagementProvider.notifier).loadCalculators();
        },
      );
    }

    final calculators = coordinator.filteredCalculators;

    if (calculators.isEmpty) {
      final hasFilters = searchState.searchQuery.isNotEmpty ||
          searchState.selectedCategory != null;
      return CalculatorEmptyStateWidget(
        type: hasFilters
            ? CalculatorEmptyStateType.noSearchResults
            : CalculatorEmptyStateType.noCalculators,
        onAction: hasFilters
            ? () {
                _searchController.clear();
                ref.read(calculatorSearchProvider.notifier).clearAllFilters();
              }
            : null,
      );
    }

    return CalculatorListWidget(
      calculators: calculators,
      scrollController: _scrollController,
      showCategory: searchState.selectedCategory == null,
      onRefresh: () =>
          ref.read(calculatorManagementProvider.notifier).loadCalculators(),
    );
  }

  Widget _buildFavoritesTab() {
    final favoritesState = ref.watch(calculatorFavoritesProvider);
    final coordinator = ref.read(calculatorCoordinatorProvider.notifier);
    final favoriteCalculators = coordinator.favoriteCalculators;

    if (favoritesState.isLoadingFavorites) {
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
      onRefresh: () => coordinator.refreshAllData(),
    );
  }

  Widget _buildHistoryTab() {
    final historyState = ref.watch(calculatorHistoryProvider);
    final history = historyState.calculationHistory;

    if (historyState.isLoadingHistory) {
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
      onReapply: (CalculationHistory historyItem) =>
          _navigateToCalculatorWithHistory(historyItem),
      onDelete: (CalculationHistory historyItem) => ref
          .read(calculatorHistoryProvider.notifier)
          .removeFromHistory(historyItem.id),
    );
  }

  void _navigateToCalculatorWithHistory(CalculationHistory historyItem) {
    ref
        .read(calculatorCoordinatorProvider.notifier)
        .applyHistoryResult(historyItem.id);
    CalculatorUIService.navigateToCalculatorWithHistory(context, historyItem);
  }

  String _getPageTitle() {
    return CalculatorUIService.getPageTitle(widget.category);
  }

  CalculatorCategory? _mapStringToCategory(String categoryString) {
    return CalculatorUIService.mapStringToCategory(categoryString);
  }
}
