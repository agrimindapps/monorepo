import 'package:flutter/material.dart';

/// Configuração de paginação
class PaginationConfig {
  final int pageSize;
  final int initialPageSize;
  final bool enableInfiniteScroll;
  final double scrollThreshold; // % de scroll para carregar próxima página

  const PaginationConfig({
    this.pageSize = 20,
    this.initialPageSize = 20,
    this.enableInfiniteScroll = true,
    this.scrollThreshold = 0.8, // 80%
  });
}

/// Widget genérico para listas paginadas com lazy loading
class PaginatedListView<T> extends StatefulWidget {
  /// Função que carrega uma página de dados
  final Future<List<T>> Function(int page, int pageSize) loadPage;
  
  /// Widget builder para cada item
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  
  /// Widget builder para separadores
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  
  /// Widget exibido quando não há dados
  final Widget? emptyWidget;
  
  /// Widget exibido durante carregamento
  final Widget? loadingWidget;
  
  /// Widget exibido em caso de erro
  final Widget Function(String error, VoidCallback retry)? errorBuilder;
  
  /// Configurações de paginação
  final PaginationConfig config;
  
  /// Chave única para cache
  final String? cacheKey;
  
  /// Se deve usar virtualização (recomendado para listas grandes)
  final bool enableVirtualization;
  
  /// Controller de scroll customizado
  final ScrollController? scrollController;
  
  /// Physics de scroll
  final ScrollPhysics? physics;
  
  /// Padding da lista
  final EdgeInsetsGeometry? padding;

  const PaginatedListView({
    super.key,
    required this.loadPage,
    required this.itemBuilder,
    this.separatorBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.errorBuilder,
    this.config = const PaginationConfig(),
    this.cacheKey,
    this.enableVirtualization = true,
    this.scrollController,
    this.physics,
    this.padding,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late ScrollController _scrollController;
  
  List<T> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMoreData = true;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.config.enableInfiniteScroll || !_hasMoreData || _isLoadingMore) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent * widget.config.scrollThreshold;
    
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _items.clear();
      _currentPage = 0;
      _hasMoreData = true;
    });

    await _loadPage(0, widget.config.initialPageSize);
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _loadPage(_currentPage + 1, widget.config.pageSize);

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _loadPage(int page, int pageSize) async {
    try {
      final newItems = await widget.loadPage(page, pageSize);
      
      if (mounted) {
        setState(() {
          if (page == 0) {
            _items = newItems;
          } else {
            _items.addAll(newItems);
          }
          
          _currentPage = page;
          _hasMoreData = newItems.length >= pageSize;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }

  void retry() {
    if (_error != null) {
      refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Erro
    if (_error != null && _items.isEmpty) {
      return widget.errorBuilder?.call(_error!, retry) ?? 
             _buildDefaultErrorWidget(_error!, retry);
    }

    // Loading inicial
    if (_isLoading && _items.isEmpty) {
      return widget.loadingWidget ?? 
             const Center(child: CircularProgressIndicator());
    }

    // Lista vazia
    if (_items.isEmpty && !_isLoading) {
      return widget.emptyWidget ?? 
             const Center(child: Text('Nenhum item encontrado'));
    }

    // Lista com dados
    return RefreshIndicator(
      onRefresh: refresh,
      child: widget.enableVirtualization 
          ? _buildVirtualizedList() 
          : _buildRegularList(),
    );
  }

  Widget _buildVirtualizedList() {
    final itemCount = _items.length + (_hasMoreData && !_isLoadingMore ? 1 : 0);
    
    if (widget.separatorBuilder != null) {
      return ListView.separated(
        controller: _scrollController,
        physics: widget.physics,
        padding: widget.padding,
        itemCount: itemCount,
        separatorBuilder: (context, index) {
          if (index >= _items.length) return const SizedBox.shrink();
          return widget.separatorBuilder!(context, index);
        },
        itemBuilder: _buildListItem,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: widget.physics,
      padding: widget.padding,
      itemCount: itemCount,
      itemBuilder: _buildListItem,
    );
  }

  Widget _buildRegularList() {
    final itemCount = _items.length;
    final children = <Widget>[];
    
    for (int i = 0; i < itemCount; i++) {
      children.add(widget.itemBuilder(context, _items[i], i));
      
      if (widget.separatorBuilder != null && i < itemCount - 1) {
        children.add(widget.separatorBuilder!(context, i));
      }
    }
    
    if (_isLoadingMore) {
      children.add(_buildLoadMoreIndicator());
    }

    return SingleChildScrollView(
      controller: _scrollController,
      physics: widget.physics,
      padding: widget.padding,
      child: Column(children: children),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    // Loading more indicator
    if (index >= _items.length) {
      return _buildLoadMoreIndicator();
    }

    return widget.itemBuilder(context, _items[index], index);
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: _isLoadingMore 
          ? const CircularProgressIndicator()
          : _error != null 
              ? _buildRetryButton()
              : const SizedBox.shrink(),
    );
  }

  Widget _buildRetryButton() {
    return TextButton.icon(
      onPressed: retry,
      icon: const Icon(Icons.refresh),
      label: const Text('Tentar novamente'),
    );
  }

  Widget _buildDefaultErrorWidget(String error, VoidCallback retry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              'Erro ao carregar dados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mixin para providers que suportam paginação
mixin PaginatedProvider<T> on ChangeNotifier {
  static const int defaultPageSize = 20;
  
  List<T> _allItems = [];
  final Map<int, List<T>> _pageCache = {};
  bool _hasMoreData = true;
  
  List<T> get allItems => _allItems;
  bool get hasMoreData => _hasMoreData;
  
  /// Carrega uma página específica
  Future<List<T>> loadPage(int page, int pageSize) async {
    // Verificar cache primeiro
    if (_pageCache.containsKey(page)) {
      return _pageCache[page]!;
    }
    
    // Carregar dados da fonte
    final items = await fetchPage(page, pageSize);
    
    // Cachear a página
    _pageCache[page] = items;
    
    // Atualizar lista completa se necessário
    if (page == 0) {
      _allItems = List<T>.from(items);
    } else {
      _allItems.addAll(items);
    }
    
    // Verificar se há mais dados
    _hasMoreData = items.length >= pageSize;
    
    notifyListeners();
    return items;
  }
  
  /// Implementar este método na classe concreta
  Future<List<T>> fetchPage(int page, int pageSize);
  
  /// Limpa o cache de páginas
  void clearPageCache() {
    _pageCache.clear();
    _allItems.clear();
    _hasMoreData = true;
  }
  
  /// Invalida uma página específica do cache
  void invalidatePage(int page) {
    _pageCache.remove(page);
  }
  
  /// Obtém estatísticas do cache
  Map<String, int> getCacheStats() {
    return {
      'cachedPages': _pageCache.length,
      'totalItems': _allItems.length,
    };
  }
}