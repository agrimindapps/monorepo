import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/fitossanitario_hive_extension.dart';
import '../../../../core/models/fitossanitario_hive.dart';
import '../../../../core/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../../../DetalheDefensivos/detalhe_defensivo_page.dart';
import '../../models/view_mode.dart';
import '../providers/lista_defensivos_provider.dart';
import '../widgets/defensivo_item_widget.dart';
import '../widgets/defensivo_search_field.dart';
import '../widgets/defensivos_empty_state_widget.dart';
import '../widgets/defensivos_loading_skeleton_widget.dart';

/// Clean Architecture implementation of Lista Defensivos Page
/// Follows SOLID principles:
/// - Dependency Inversion: Repository injected through provider
/// - Single Responsibility: UI only handles presentation concerns
/// - Performance optimized: Consolidated state updates in provider
class ListaDefensivosCleanPage extends StatefulWidget {
  final FitossanitarioHiveRepository? repository; // For testing

  const ListaDefensivosCleanPage({
    super.key,
    this.repository,
  });

  @override
  State<ListaDefensivosCleanPage> createState() => _ListaDefensivosCleanPageState();
}

class _ListaDefensivosCleanPageState extends State<ListaDefensivosCleanPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ListaDefensivosProvider _provider;

  @override
  void initState() {
    super.initState();
    
    // Initialize provider with dependency injection
    _provider = ListaDefensivosProvider(
      repository: widget.repository ?? sl<FitossanitarioHiveRepository>(),
    );
    
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _provider.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _provider.search(_searchController.text);
  }

  void _onScroll() {
    // Lazy loading: load more items when near the end
    if (_scrollController.hasClients) {
      final threshold = _scrollController.position.maxScrollExtent * 0.8;
      if (_scrollController.position.pixels >= threshold) {
        _provider.loadMoreItems();
      }
    }
  }

  void _onDefensivoTap(FitossanitarioHive defensivo) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetalheDefensivoPage(
          defensivoName: defensivo.displayName,
          fabricante: defensivo.displayFabricante,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<ListaDefensivosProvider>(
        builder: (context, provider, child) {
          return _buildPage(context, provider);
        },
      ),
    );
  }

  Widget _buildPage(BuildContext context, ListaDefensivosProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Column(
              children: [
                _buildModernHeader(context, provider, isDark),
                DefensivoSearchField(
                  controller: _searchController,
                  isDark: isDark,
                  isSearching: provider.isSearching,
                  selectedViewMode: provider.selectedViewMode,
                  onToggleViewMode: provider.toggleViewMode,
                  onClear: () {
                    _searchController.clear();
                    provider.clearSearch();
                  },
                  onSubmitted: () => provider.search(_searchController.text),
                ),
                Expanded(
                  child: _buildContent(provider, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ListaDefensivosProvider provider, bool isDark) {
    if (provider.isLoading) {
      return DefensivosLoadingSkeletonWidget(
        isDark: isDark,
        viewMode: provider.selectedViewMode,
      );
    } else if (provider.errorMessage != null) {
      return _buildErrorState(provider, isDark);
    } else if (!provider.hasFilteredData) {
      return DefensivosEmptyStateWidget(
        onClearFilters: () {
          _searchController.clear();
          provider.clearSearch();
        },
        customTitle: _searchController.text.isNotEmpty
            ? 'Nenhum defensivo encontrado'
            : 'Nenhum defensivo disponível',
        customMessage: _searchController.text.isNotEmpty
            ? 'Tente ajustar os termos da busca'
            : 'Verifique se os dados foram carregados',
      );
    } else {
      return _buildDefensivosList(provider, isDark);
    }
  }

  Widget _buildErrorState(ListaDefensivosProvider provider, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? Colors.red.shade400 : Colors.red.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar defensivos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.loadData();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefensivosList(ListaDefensivosProvider provider, bool isDark) {
    if (provider.selectedViewMode == ViewMode.grid) {
      return _buildGridView(provider, isDark);
    } else {
      return _buildListView(provider, isDark);
    }
  }

  Widget _buildGridView(ListaDefensivosProvider provider, bool isDark) {
    final crossAxisCount = MediaQuery.of(context).size.width > 800
        ? 4
        : MediaQuery.of(context).size.width > 600
            ? 3
            : 2;

    return Container(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: provider.displayedDefensivos.length,
        itemBuilder: (context, index) {
          final defensivo = provider.displayedDefensivos[index];
          return DefensivoItemWidget(
            defensivo: defensivo,
            isDark: isDark,
            onTap: () => _onDefensivoTap(defensivo),
            isGridView: true,
          );
        },
      ),
    );
  }

  Widget _buildListView(ListaDefensivosProvider provider, bool isDark) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      itemCount: provider.displayedDefensivos.length +
          (provider.isLoadingMore ? 2 : 1), // +1 for space, +1 for loading
      separatorBuilder: (context, index) => const SizedBox(height: 1),
      itemBuilder: (context, index) {
        // Loading indicator in the middle of list
        if (provider.isLoadingMore && index == provider.displayedDefensivos.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Last item: space for bottom navigation
        if (index == provider.displayedDefensivos.length + (provider.isLoadingMore ? 1 : 0)) {
          return const SizedBox(height: 80);
        }

        // Virtualized list items
        final defensivo = provider.displayedDefensivos[index];
        return DefensivoItemWidget(
          defensivo: defensivo,
          isDark: isDark,
          onTap: () => _onDefensivoTap(defensivo),
          isGridView: false,
        );
      },
    );
  }

  Widget _buildModernHeader(BuildContext context, ListaDefensivosProvider provider, bool isDark) {
    return ModernHeaderWidget(
      title: 'Defensivos',
      subtitle: provider.getHeaderSubtitle(),
      leftIcon: Icons.shield_outlined,
      showBackButton: true,
      showActions: true,
      isDark: isDark,
      rightIcon: provider.isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined,
      onRightIconPressed: provider.toggleSort,
      onBackPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}