import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import 'presentation/notifiers/favoritos_notifier.dart';
import 'presentation/widgets/favoritos_tabs_widget.dart';

/// Favoritos Page - Implementação com Riverpod
///
/// MIGRAÇÃO PARA RIVERPOD:
/// ✅ Migrado de Provider para Riverpod com code generation
/// ✅ ConsumerStatefulWidget para state management
/// ✅ Mantido método estático reloadIfActive()
/// ✅ Template consolidado aplicado
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
class FavoritosPage extends ConsumerStatefulWidget {
  const FavoritosPage({super.key});

  static _FavoritosPageState? _currentState;

  @override
  ConsumerState<FavoritosPage> createState() => _FavoritosPageState();

  /// Método estático para recarregar a página quando estiver ativa
  static void reloadIfActive() {
    _currentState?._reloadFavoritos();
  }
}

class _FavoritosPageState extends ConsumerState<FavoritosPage>
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
    ref.read(favoritosNotifierProvider.notifier).loadAllFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final state = ref.watch(favoritosNotifierProvider);

    // Inicialização lazy
    if (!_hasInitialized) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(favoritosNotifierProvider.notifier).initialize();
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: ResponsiveContentWrapper(
            child: Column(
              children: [
                _buildModernHeader(context, isDark, state),
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
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark, FavoritosState state) {
    return ModernHeaderWidget(
      title: 'Favoritos',
      subtitle: state.hasAnyFavoritos
          ? '${state.allFavoritos.length} itens salvos'
          : 'Seus itens salvos',
      leftIcon: Icons.favorite,
      showBackButton: false,
      showActions: false,
      isDark: isDark,
    );
  }
}