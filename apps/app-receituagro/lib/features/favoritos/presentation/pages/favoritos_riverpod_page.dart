import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/favorito_entity.dart';
import '../providers/favoritos_riverpod_provider.dart';
import '../widgets/favoritos_header_widget.dart';
import '../widgets/favoritos_premium_required_widget.dart';
import '../widgets/favoritos_tab_content_widget.dart';

/// Favoritos Page refatorada com Riverpod e Clean Architecture
/// 
/// Responsabilidades:
/// - Orchestração da UI principal
/// - Gerenciamento de tabs
/// - Inicialização automática
/// - Estados de lifecycle da app
class FavoritosRiverpodPage extends ConsumerStatefulWidget {
  const FavoritosRiverpodPage({super.key});

  static _FavoritosRiverpodPageState? _currentState;

  @override
  ConsumerState<FavoritosRiverpodPage> createState() => _FavoritosRiverpodPageState();

  /// Método estático para recarregar a página quando estiver ativa
  static void reloadIfActive() {
    _currentState?._reloadFavoritos();
  }
}

class _FavoritosRiverpodPageState extends ConsumerState<FavoritosRiverpodPage> 
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  late TabController _tabController;
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    FavoritosRiverpodPage._currentState = this;
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    
    // Inicialização será feita pelo Provider quando criado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeIfNeeded();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasInitialized) {
      _reloadFavoritos();
    }
  }

  @override
  void dispose() {
    if (FavoritosRiverpodPage._currentState == this) {
      FavoritosRiverpodPage._currentState = null;
    }
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  void _initializeIfNeeded() {
    if (!_hasInitialized) {
      _hasInitialized = true;
      ref.read(favoritosProvider.notifier).initialize();
    }
  }

  void _reloadFavoritos() {
    ref.read(favoritosProvider.notifier).loadAllFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin
    
    final favoritosState = ref.watch(favoritosProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header moderno
            FavoritosHeaderWidget(
              favoritosState: favoritosState,
              isDark: isDark,
            ),
            
            const SizedBox(height: 20),
            
            // Tabs
            _buildTabs(isDark),
            
            const SizedBox(height: 16),
            
            // Conteúdo das tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Defensivos
                  FavoritosTabContentWidget(
                    tipo: TipoFavorito.defensivo,
                    items: favoritosState.defensivos,
                    viewState: favoritosState.getViewStateForType(TipoFavorito.defensivo),
                    emptyMessage: favoritosState.getEmptyMessageForType(TipoFavorito.defensivo),
                    errorMessage: favoritosState.errorMessage,
                    isDark: isDark,
                    onRefresh: _reloadFavoritos,
                    onRemove: (item) => ref.read(favoritosProvider.notifier).removeFavorito(item),
                  ),
                  
                  // Tab Pragas
                  FavoritosTabContentWidget(
                    tipo: TipoFavorito.praga,
                    items: favoritosState.pragas,
                    viewState: favoritosState.getViewStateForType(TipoFavorito.praga),
                    emptyMessage: favoritosState.getEmptyMessageForType(TipoFavorito.praga),
                    errorMessage: favoritosState.errorMessage,
                    isDark: isDark,
                    onRefresh: _reloadFavoritos,
                    onRemove: (item) => ref.read(favoritosProvider.notifier).removeFavorito(item),
                  ),
                  
                  // Tab Diagnósticos (com verificação premium)
                  isPremium 
                      ? FavoritosTabContentWidget(
                          tipo: TipoFavorito.diagnostico,
                          items: favoritosState.diagnosticos,
                          viewState: favoritosState.getViewStateForType(TipoFavorito.diagnostico),
                          emptyMessage: favoritosState.getEmptyMessageForType(TipoFavorito.diagnostico),
                          errorMessage: favoritosState.errorMessage,
                          isDark: isDark,
                          onRefresh: _reloadFavoritos,
                          onRemove: (item) => ref.read(favoritosProvider.notifier).removeFavorito(item),
                        )
                      : const FavoritosPremiumRequiredWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói as tabs
  Widget _buildTabs(bool isDark) {
    final favoritosState = ref.watch(favoritosProvider);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: isDark ? Colors.white : Colors.black87,
        unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: isDark ? Colors.blue.shade600 : Colors.blue.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: _buildTabLabel(
              'Defensivos', 
              favoritosState.getCountForType(TipoFavorito.defensivo),
              isDark,
            ),
          ),
          Tab(
            child: _buildTabLabel(
              'Pragas', 
              favoritosState.getCountForType(TipoFavorito.praga),
              isDark,
            ),
          ),
          Tab(
            child: _buildTabLabel(
              'Diagnósticos', 
              favoritosState.getCountForType(TipoFavorito.diagnostico),
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o label da tab com contador
  Widget _buildTabLabel(String title, int count, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? Colors.orange.shade600 : Colors.orange.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}