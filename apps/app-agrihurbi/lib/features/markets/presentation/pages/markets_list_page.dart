import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_filter_entity.dart';
import 'package:app_agrihurbi/features/markets/presentation/providers/market_provider.dart';
import 'package:app_agrihurbi/features/markets/presentation/widgets/market_card.dart';
import 'package:app_agrihurbi/features/markets/presentation/widgets/market_filter_sheet.dart';
import 'package:app_agrihurbi/features/markets/presentation/widgets/market_summary_card.dart';
import 'package:app_agrihurbi/features/markets/presentation/widgets/market_type_chips.dart';
import 'package:app_agrihurbi/features/markets/presentation/widgets/top_performers_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Markets List Page
/// 
/// Main page displaying agricultural markets with filtering,
/// search, and real-time price updates
class MarketsListPage extends StatefulWidget {
  const MarketsListPage({super.key});

  @override
  State<MarketsListPage> createState() => _MarketsListPageState();
}

class _MarketsListPageState extends State<MarketsListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize market data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketProvider>().initialize();
    });

    // Setup pagination on scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // TODO: Implement pagination
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercados Agrícolas'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textLightColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          Consumer<MarketProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: provider.isRefreshing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.textLightColor,
                          ),
                        ),
                      )
                    : const Icon(Icons.refresh),
                onPressed: provider.isRefreshing
                    ? null
                    : () => provider.refreshAll(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.textLightColor,
          labelColor: AppTheme.textLightColor,
          unselectedLabelColor: AppTheme.textLightColor.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Resumo', icon: Icon(Icons.dashboard)),
            Tab(text: 'Mercados', icon: Icon(Icons.trending_up)),
            Tab(text: 'Favoritos', icon: Icon(Icons.favorite)),
          ],
        ),
      ),
      body: Consumer<MarketProvider>(
        builder: (context, provider, _) {
          if (provider.hasError) {
            return _buildErrorState(provider.errorMessage!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(provider),
              _buildMarketsTab(provider),
              _buildFavoritesTab(provider),
            ],
          );
        },
      ),
    );
  }

  /// Build summary tab with market overview
  Widget _buildSummaryTab(MarketProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadMarketSummary(refresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market Summary Card
            if (provider.marketSummary != null)
              MarketSummaryCard(summary: provider.marketSummary!)
            else if (provider.isLoadingSummary)
              const _LoadingCard()
            else
              const _EmptyStateCard(
                message: 'Resumo do mercado indisponível',
                icon: Icons.info_outline,
              ),

            const SizedBox(height: 24),

            // Market Types
            Text(
              'Categorias de Mercado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            MarketTypeChips(
              onTypeSelected: (type) {
                _tabController.animateTo(1); // Switch to markets tab
                provider.filterByType(type);
              },
            ),

            const SizedBox(height: 24),

            // Top Performers Section
            TopPerformersSection(
              topGainers: provider.topGainers,
              topLosers: provider.topLosers,
              mostActive: provider.mostActive,
              onMarketTap: _onMarketTap,
            ),
          ],
        ),
      ),
    );
  }

  /// Build markets tab with full list
  Widget _buildMarketsTab(MarketProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadMarkets(refresh: true),
      child: Column(
        children: [
          // Active filters indicator
          if (provider.currentFilter.hasActiveFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              child: Wrap(
                spacing: 8,
                children: provider.currentFilter.activeFiltersDescription
                    .map((desc) => Chip(
                          label: Text(desc, style: const TextStyle(fontSize: 12)),
                          onDeleted: () => provider.clearFilter(),
                          deleteIcon: const Icon(Icons.close, size: 16),
                        ))
                    .toList(),
              ),
            ),

          // Markets list
          Expanded(
            child: provider.isLoadingMarkets && provider.markets.isEmpty
                ? const _LoadingList()
                : provider.markets.isEmpty
                    ? const _EmptyStateCard(
                        message: 'Nenhum mercado encontrado',
                        icon: Icons.search_off,
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.markets.length,
                        itemBuilder: (context, index) {
                          final market = provider.markets[index];
                          return MarketCard(
                            market: market,
                            onTap: () => _onMarketTap(market),
                            onFavoriteToggle: () => provider.toggleFavorite(market.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// Build favorites tab
  Widget _buildFavoritesTab(MarketProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadFavorites(),
      child: provider.isLoadingFavorites && provider.favoriteMarkets.isEmpty
          ? const _LoadingList()
          : provider.favoriteMarkets.isEmpty
              ? const _EmptyStateCard(
                  message: 'Nenhum mercado favoritado',
                  subtitle: 'Adicione mercados aos favoritos na aba Mercados',
                  icon: Icons.favorite_border,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.favoriteMarkets.length,
                  itemBuilder: (context, index) {
                    final market = provider.favoriteMarkets[index];
                    return MarketCard(
                      market: market,
                      onTap: () => _onMarketTap(market),
                      onFavoriteToggle: () => provider.toggleFavorite(market.id),
                      isFavorite: true,
                    );
                  },
                ),
    );
  }

  /// Handle market tap to navigate to detail
  void _onMarketTap(MarketEntity market) {
    context.push('/home/markets/detail/${market.id}');
  }

  /// Show search dialog
  void _showSearchDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Mercados'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Digite o nome ou símbolo do mercado',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: _performSearch,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _performSearch(_searchController.text);
              Navigator.pop(context);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  /// Perform search operation
  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      final provider = context.read<MarketProvider>();
      provider.searchMarkets(query: query.trim());
      
      // Switch to markets tab to show results
      _tabController.animateTo(1);
    }
  }

  /// Show filter bottom sheet
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MarketFilterSheet(
        currentFilter: context.read<MarketProvider>().currentFilter,
        onFilterApplied: (filter) {
          context.read<MarketProvider>().applyFilter(filter);
          _tabController.animateTo(1); // Switch to markets tab
        },
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<MarketProvider>().initialize(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading card widget
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Loading list widget
class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          leading: CircleAvatar(backgroundColor: AppTheme.borderColor),
          title: const _ShimmerContainer(width: 120, height: 16),
          subtitle: const _ShimmerContainer(width: 80, height: 12),
          trailing: const _ShimmerContainer(width: 60, height: 20),
        ),
      ),
    );
  }
}

/// Empty state card widget
class _EmptyStateCard extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;

  const _EmptyStateCard({
    required message,
    subtitle,
    required icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading container
class _ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerContainer({
    required width,
    required height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.borderColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}