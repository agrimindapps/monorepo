import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import 'favoritos_di.dart';
import 'presentation/providers/favoritos_provider_simplified.dart';
import 'presentation/widgets/favoritos_tabs_widget.dart';

/// Favoritos Page - Implementação consolidada sem wrapper desnecessário
/// 
/// REFATORAÇÃO APLICADA:
/// ✅ Eliminado wrapper desnecessário (double rendering)
/// ✅ Consolidação direta da lógica principal
/// ✅ Mantido método estático reloadIfActive()
/// ✅ Template consolidado aplicado
/// ✅ Provider pattern para state management
/// ✅ Tab system optimization
/// 
/// FUNCIONALIDADES PRESERVADAS:
/// - Sistema de abas (Defensivos, Pragas, Diagnósticos)  
/// - Add/remove favoritos functionality
/// - Premium restrictions para diagnósticos
/// - Navigation para detalhes
/// - Loading/error/empty states
/// - Pull-to-refresh
/// - App lifecycle management
/// - Static method reloadIfActive()
class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  static _FavoritosPageState? _currentState;

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();

  /// Método estático para recarregar a página quando estiver ativa
  static void reloadIfActive() {
    _currentState?._reloadFavoritos();
  }
}

class _FavoritosPageState extends State<FavoritosPage> 
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  late TabController _tabController;
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    FavoritosPage._currentState = this;
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
    if (FavoritosPage._currentState == this) {
      FavoritosPage._currentState = null;
    }
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