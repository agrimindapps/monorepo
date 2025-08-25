import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../../../DetalheDefensivos/detalhe_defensivo_page.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../models/view_mode.dart';
import '../../widgets/defensivo_search_field.dart';
import '../../widgets/defensivos_empty_state_widget.dart';
import '../../widgets/defensivos_loading_skeleton_widget.dart';
import '../providers/defensivos_provider.dart';

/// Nova versão da ListaDefensivosPage usando Clean Architecture
/// Remove business logic da UI e utiliza DefensivosProvider
class DefensivosCleanPage extends StatefulWidget {
  const DefensivosCleanPage({super.key});

  @override
  State<DefensivosCleanPage> createState() => _DefensivosCleanPageState();
}

class _DefensivosCleanPageState extends State<DefensivosCleanPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ViewMode _selectedViewMode = ViewMode.list;
  bool _isAscending = true;
  Timer? _debounceTimer;

  late DefensivosProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = sl<DefensivosProvider>();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    
    // Carrega dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _provider.initialize();
    await _provider.loadActiveDefensivos();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      _provider.loadActiveDefensivos();
      return;
    }

    // Busca por nome comum por padrão
    _provider.searchByNome(query.trim());
  }

  void _onScroll() {
    // TODO: Implementar paginação se necessário
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      // Carregar mais dados
    }
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      // A ordenação é feita no provider ou no repository
    });
  }

  void _changeViewMode(ViewMode mode) {
    setState(() {
      _selectedViewMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilters(),
            Expanded(
              child: Consumer<DefensivosProvider>(
                builder: (context, provider, child) {
                  return _buildContent(provider);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ModernHeaderWidget(
      title: 'Defensivos Agrícolas',
      subtitle: 'Encontre informações sobre defensivos',
      leftIcon: Icons.shield_outlined,
      isDark: isDark,
      showBackButton: true,
      onBackPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Consumer<DefensivosProvider>(
            builder: (context, provider, child) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              
              return DefensivoSearchField(
                controller: _searchController,
                isDark: isDark,
                isSearching: provider.isLoading,
                selectedViewMode: _selectedViewMode,
                onToggleViewMode: _changeViewMode,
                onClear: () {
                  _searchController.clear();
                  _provider.loadActiveDefensivos();
                },
                onSubmitted: () => _performSearch(_searchController.text),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Consumer<DefensivosProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            // Estatísticas
            if (provider.stats != null)
              Expanded(
                child: Text(
                  provider.searchSummary,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            
            const Spacer(),
            
            // Botões de ação
            IconButton(
              icon: Icon(_isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha),
              tooltip: _isAscending ? 'A-Z' : 'Z-A',
              onPressed: _toggleSortOrder,
            ),
            
            PopupMenuButton<ViewMode>(
              icon: const Icon(Icons.view_list),
              onSelected: _changeViewMode,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ViewMode.list,
                  child: Row(
                    children: [
                      Icon(Icons.view_list),
                      SizedBox(width: 8),
                      Text('Lista'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ViewMode.grid,
                  child: Row(
                    children: [
                      Icon(Icons.view_module),
                      SizedBox(width: 8),
                      Text('Grade'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(DefensivosProvider provider) {
    switch (provider.viewState) {
      case DefensivosViewState.loading:
        return DefensivosLoadingSkeletonWidget(
          isDark: Theme.of(context).brightness == Brightness.dark,
          viewMode: _selectedViewMode,
        );
        
      case DefensivosViewState.error:
        return _buildErrorState(provider);
        
      case DefensivosViewState.empty:
        return DefensivosEmptyStateWidget(
          isDark: Theme.of(context).brightness == Brightness.dark,
          isSearchResult: _searchController.text.isNotEmpty,
        );
        
      case DefensivosViewState.loaded:
        return _buildLoadedState(provider);
        
      case DefensivosViewState.initial:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildErrorState(DefensivosProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar defensivos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage ?? 'Erro desconhecido',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              provider.clearError();
              _loadInitialData();
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(DefensivosProvider provider) {
    final defensivos = provider.defensivos;
    
    if (_selectedViewMode == ViewMode.grid) {
      return _buildGridView(defensivos);
    } else {
      return _buildListView(defensivos);
    }
  }

  Widget _buildListView(List<DefensivoEntity> defensivos) {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: defensivos.length,
        itemBuilder: (context, index) {
          final defensivo = defensivos[index];
          return _buildDefensivoItem(defensivo, index);
        },
      ),
    );
  }

  Widget _buildGridView(List<DefensivoEntity> defensivos) {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
        ),
        itemCount: defensivos.length,
        itemBuilder: (context, index) {
          final defensivo = defensivos[index];
          return _buildDefensivoCard(defensivo, index);
        },
      ),
    );
  }

  Widget _buildDefensivoItem(DefensivoEntity defensivo, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 2,
        child: ListTile(
          title: Text(
            defensivo.nomeComum,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (defensivo.fabricante?.isNotEmpty == true)
                Text(
                  defensivo.fabricante!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (defensivo.classeAgronomica?.isNotEmpty == true)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    defensivo.classeAgronomica!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (defensivo.isActive)
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
              if (defensivo.isElegible)
                const Icon(Icons.star, color: Colors.amber, size: 16),
            ],
          ),
          onTap: () => _navigateToDetail(defensivo),
        ),
      ),
    );
  }

  Widget _buildDefensivoCard(DefensivoEntity defensivo, int index) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(defensivo),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                defensivo.nomeComum,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (defensivo.fabricante?.isNotEmpty == true)
                Text(
                  defensivo.fabricante!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              if (defensivo.classeAgronomica?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    defensivo.classeAgronomica!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  if (defensivo.isActive)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  if (defensivo.isElegible)
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return Consumer<DefensivosProvider>(
      builder: (context, provider, child) {
        if (!provider.hasData) return const SizedBox.shrink();
        
        return FloatingActionButton(
          onPressed: () => _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ),
          child: const Icon(Icons.keyboard_arrow_up),
        );
      },
    );
  }

  void _navigateToDetail(DefensivoEntity defensivo) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetalheDefensivoPage(
          defensivoName: defensivo.nomeComum,
          fabricante: defensivo.fabricante ?? '',
        ),
      ),
    );
  }

}