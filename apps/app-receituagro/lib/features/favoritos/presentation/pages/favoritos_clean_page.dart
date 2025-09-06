import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/responsive_content_wrapper.dart';
import '../../favoritos_di.dart';
import '../providers/favoritos_provider_simplified.dart';
import '../widgets/favoritos_tabs_widget.dart';

/// Favoritos Clean Page - Implementação principal seguindo template consolidado
/// Resultado esperado: 90%+ redução de complexidade mantendo 100% funcionalidade
class FavoritosCleanPage extends StatefulWidget {
  const FavoritosCleanPage({super.key});

  @override
  State<FavoritosCleanPage> createState() => _FavoritosCleanPageState();
}

class _FavoritosCleanPageState extends State<FavoritosCleanPage> 
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  late TabController _tabController;
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  void _reloadFavoritos() {
    final provider = FavoritosDI.get<FavoritosProviderSimplified>();
    provider.loadAllFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final provider = FavoritosDI.get<FavoritosProviderSimplified>();
    
    // Inicialização lazy
    if (!_hasInitialized) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.initialize();
      });
    }
    
    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: ResponsiveContentWrapper(
              child: Column(
              children: [
                _buildModernHeader(context, isDark),
                const SizedBox(height: 8),
                Expanded(
                  child: FavoritosTabsWidget(
                    tabController: _tabController,
                    onReload: _reloadFavoritos,
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return Consumer<FavoritosProviderSimplified>(
      builder: (context, provider, child) {
        return ModernHeaderWidget(
          title: 'Favoritos',
          subtitle: provider.hasAnyFavoritos 
              ? '${provider.allFavoritos.length} itens salvos'
              : 'Seus itens salvos',
          leftIcon: Icons.favorite,
          showBackButton: false,
          showActions: false,
          isDark: isDark,
        );
      },
    );
  }
}