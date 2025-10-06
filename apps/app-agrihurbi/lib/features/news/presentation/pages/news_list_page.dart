import 'package:app_agrihurbi/features/news/domain/entities/commodity_price_entity.dart';
import 'package:app_agrihurbi/features/news/domain/entities/news_article_entity.dart';
import 'package:app_agrihurbi/features/news/presentation/providers/news_provider.dart';
import 'package:app_agrihurbi/features/news/presentation/widgets/commodity_prices_widget.dart';
import 'package:app_agrihurbi/features/news/presentation/widgets/news_article_card.dart';
import 'package:app_agrihurbi/features/news/presentation/widgets/news_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// News List Page
///
/// Main page for displaying agriculture news with RSS feeds,
/// commodity prices, and filtering capabilities
class NewsListPage extends ConsumerStatefulWidget {
  const NewsListPage({super.key});

  @override
  ConsumerState<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends ConsumerState<NewsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newsProviderProvider).initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNewsTab(),
                _buildPremiumTab(),
                _buildCommoditiesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildRefreshFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Notícias Agropecuárias'),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh_rss',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Atualizar RSS'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'manage_feeds',
              child: Row(
                children: [
                  Icon(Icons.rss_feed),
                  SizedBox(width: 8),
                  Text('Gerenciar Feeds'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'favorites',
              child: Row(
                children: [
                  Icon(Icons.favorite),
                  SizedBox(width: 8),
                  Text('Favoritos'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.article),
            text: 'Notícias',
          ),
          Tab(
            icon: Icon(Icons.star),
            text: 'Premium',
          ),
          Tab(
            icon: Icon(Icons.trending_up),
            text: 'Commodities',
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    final provider = ref.watch(newsProviderProvider);

    return Builder(
      builder: (context) {
        if (provider.isLoadingNews && provider.articles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.hasError && provider.articles.isEmpty) {
          return _buildErrorWidget(provider.errorMessage!);
        }

        if (provider.articles.isEmpty) {
          return _buildEmptyWidget();
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadNews(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.articles.length + (provider.isLoadingNews ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.articles.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final article = provider.articles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NewsArticleCard(
                  article: article,
                  onTap: () => _navigateToArticle(article),
                  onFavorite: () => _toggleFavorite(article.id),
                  onShare: () => _shareArticle(article),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPremiumTab() {
    final provider = ref.watch(newsProviderProvider);

    return Builder(
      builder: (context) {
        if (provider.isLoadingPremium && provider.premiumArticles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.premiumArticles.isEmpty) {
          return _buildPremiumEmptyWidget();
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadPremiumNews(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.premiumArticles.length,
            itemBuilder: (context, index) {
              final article = provider.premiumArticles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NewsArticleCard(
                  article: article,
                  onTap: () => _navigateToArticle(article),
                  onFavorite: () => _toggleFavorite(article.id),
                  onShare: () => _shareArticle(article),
                  isPremium: true,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCommoditiesTab() {
    final provider = ref.watch(newsProviderProvider);

    return Builder(
      builder: (context) {
        return RefreshIndicator(
          onRefresh: () => provider.loadCommodityPrices(refresh: true),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.marketSummary != null)
                  _buildMarketSummaryCard(provider.marketSummary!),
                const SizedBox(height: 16),
                Text(
                  'Preços das Commodities',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                CommodityPricesWidget(
                  prices: provider.commodityPrices,
                  isLoading: provider.isLoadingCommodities,
                  onRefresh: () => provider.loadCommodityPrices(refresh: true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketSummaryCard(MarketSummaryEntity summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo do Mercado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              summary.marketName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Índice: ${summary.marketIndex.toStringAsFixed(2)}'),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: summary.marketIndexChange >= 0 ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${summary.marketIndexChange >= 0 ? '+' : ''}${summary.marketIndexChange.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Atualizado em: ${_formatDateTime(summary.lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar notícias',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(newsProviderProvider).loadNews(refresh: true);
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma notícia encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Verifique sua conexão com a internet e tente novamente.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(newsProviderProvider).refreshRSSFeeds();
            },
            child: const Text('Atualizar Feeds'),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Conteúdo Premium',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Assine o plano premium para acessar conteúdo exclusivo.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/subscription');
            },
            child: const Text('Ver Planos'),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshFAB() {
    final provider = ref.watch(newsProviderProvider);

    return FloatingActionButton(
      onPressed: provider.isRefreshing ? null : () {
        provider.refreshRSSFeeds();
      },
      child: provider.isRefreshing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.refresh),
    );
  }

  void _showSearchDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pesquisar Notícias'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Digite sua pesquisa...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (query) {
            Navigator.pop(context);
            if (query.isNotEmpty) {
              ref.read(newsProviderProvider).searchNews(query: query);
              Navigator.pushNamed(context, '/news/search', arguments: query);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final query = _searchController.text.trim();
              if (query.isNotEmpty) {
                ref.read(newsProviderProvider).searchNews(query: query);
                Navigator.pushNamed(context, '/news/search', arguments: query);
              }
            },
            child: const Text('Pesquisar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: NewsFilterWidget(
          currentFilter: ref.read(newsProviderProvider).currentFilter,
          onApply: (filter) {
            ref.read(newsProviderProvider).applyFilter(filter);
            Navigator.pop(context);
          },
          onClear: () {
            ref.read(newsProviderProvider).clearFilter();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    final provider = ref.read(newsProviderProvider);

    switch (action) {
      case 'refresh_rss':
        provider.refreshRSSFeeds();
        break;
      case 'manage_feeds':
        Navigator.pushNamed(context, '/news/feeds');
        break;
      case 'favorites':
        Navigator.pushNamed(context, '/news/favorites');
        break;
    }
  }

  void _navigateToArticle(NewsArticleEntity article) {
    Navigator.pushNamed(
      context,
      '/news/article',
      arguments: article,
    );
  }

  Future<void> _toggleFavorite(String articleId) async {
    final provider = ref.read(newsProviderProvider);
    final isFavorite = await provider.isArticleFavorite(articleId);

    if (isFavorite) {
      await provider.removeFromFavorites(articleId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removido dos favoritos')),
        );
      }
    } else {
      await provider.addToFavorites(articleId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicionado aos favoritos')),
        );
      }
    }
  }

  void _shareArticle(NewsArticleEntity article) {
    print('Sharing article: ${article.title}');
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}