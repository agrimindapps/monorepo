import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'controller/favoritos_controller.dart';
import 'widgets/favoritos_search_field_widget.dart';
import 'tabs/defensivos_tab.dart';
import 'tabs/pragas_tab.dart';
import 'tabs/diagnosticos_tab.dart';
import 'constants/favoritos_design_tokens.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> 
    with TickerProviderStateMixin, WidgetsBindingObserver, AutomaticKeepAliveClientMixin {

  late TabController _tabController;
  FavoritosController? _controller;
  bool _hasAddedListener = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_controller == null) {
      try {
        _controller = context.read<FavoritosController>();
        
        if (!_hasAddedListener) {
          _tabController.addListener(() {
            if (!_tabController.indexIsChanging && _controller != null) {
              _controller!.onTabChanged(_tabController.index);
            }
          });
          _hasAddedListener = true;
        }
      } catch (e) {
        debugPrint('Error getting FavoritosController: $e');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _controller != null) {
      _controller!.refreshFavorites();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Consumer<FavoritosController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return _buildLoadingState(theme);
            }

            if (controller.hasError) {
              return _buildErrorState(controller, isDark);
            }

            return Column(
              children: [
                _buildHeader(controller, isDark),
                _buildTabBar(controller, theme),
                _buildSearchField(controller),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      DefensivosTab(controller: controller),
                      PragasTab(controller: controller),
                      DiagnosticosTab(controller: controller),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(FavoritosController controller, bool isDark) {
    final data = controller.favoritosData;
    final totalCount = data.totalCount;
    
    return ModernHeaderWidget(
      title: 'Favoritos',
      subtitle: totalCount > 0 
        ? 'Você tem $totalCount itens salvos'
        : 'Nenhum item salvo ainda',
      leftIcon: Icons.favorite_outlined,
      showBackButton: false,
      showActions: false,
      isDark: isDark,
    );
  }

  Widget _buildTabBar(FavoritosController controller, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade100,
            Colors.green.shade200,
          ],
        ),
        borderRadius: BorderRadius.circular(FavoritosDesignTokens.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(FavoritosDesignTokens.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: theme.colorScheme.onSurface,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 12,
        ),
        tabs: [
          _buildTab(controller, 0),
          _buildTab(controller, 1),
          _buildTab(controller, 2),
        ],
      ),
    );
  }

  Widget _buildTab(FavoritosController controller, int index) {
    final icon = FavoritosDesignTokens.getIconForTab(index);
    final name = FavoritosDesignTokens.getTabName(index);
    final data = controller.favoritosData;
    
    int count;
    switch (index) {
      case 0:
        count = data.defensivos.length;
        break;
      case 1:
        count = data.pragas.length;
        break;
      case 2:
        count = data.diagnosticos.length;
        break;
      default:
        count = 0;
    }

    return Tab(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: FavoritosDesignTokens.getColorForTab(index),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(FavoritosController controller) {
    final tabIndex = controller.currentTabIndex;
    final searchController = controller.getSearchControllerForTab(tabIndex);
    final accentColor = FavoritosDesignTokens.getColorForTab(tabIndex);
    final viewMode = controller.currentViewMode;
    final hintText = controller.getSearchHintForTab(tabIndex);

    return FavoritosSearchFieldWidget(
      controller: searchController,
      hintText: hintText,
      accentColor: accentColor,
      selectedViewMode: viewMode,
      onChanged: (value) => controller.onSearchChanged(tabIndex, value),
      onClear: () => controller.clearSearch(tabIndex),
      onToggleViewMode: controller.toggleViewMode,
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Carregando favoritos...',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(FavoritosController controller, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(FavoritosDesignTokens.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 32,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.retryInitialization,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}