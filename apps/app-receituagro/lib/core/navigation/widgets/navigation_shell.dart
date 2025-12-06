import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/route_settings_extension.dart';
import '../providers/navigation_state_provider.dart';

/// Shell que envolve páginas e provê BottomNavigationBar persistente
/// 
/// **REFACTORED**: Não adiciona Scaffold extra - apenas BottomNavigationBar
/// As páginas filhas já têm seu próprio Scaffold
class NavigationShell extends ConsumerStatefulWidget {
  final Widget? child;

  const NavigationShell({
    super.key,
    this.child,
  });

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  @override
  Widget build(BuildContext context) {
    final navigationState = ref.watch(navigationStateProvider);

    // Se não deve mostrar bottom nav, retorna apenas o child
    if (!navigationState.showBottomNav) {
      return widget.child ?? const SizedBox.shrink();
    }

    // Usa Column para adicionar BottomNav sem Scaffold extra
    // As páginas filhas já têm Scaffold com SafeArea
    return Column(
      children: [
        Expanded(child: widget.child ?? const SizedBox.shrink()),
        _buildBottomNavigationBar(context, ref, navigationState),
      ],
    );
  }

  /// Constrói BottomNavigationBar com 5 tabs principais
  Widget _buildBottomNavigationBar(
    BuildContext context,
    WidgetRef ref,
    NavigationStateData state,
  ) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: state.selectedTabIndex.clamp(0, 4),
      onTap: (index) => _onBottomNavTap(context, ref, index),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shield),
          activeIcon: Icon(Icons.shield, size: 28),
          label: 'Defensivos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bug_report),
          activeIcon: Icon(Icons.bug_report, size: 28),
          label: 'Pragas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite, size: 28),
          label: 'Favoritos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.comment_outlined),
          activeIcon: Icon(Icons.comment, size: 28),
          label: 'Comentários',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings, size: 28),
          label: 'Config',
        ),
      ],
    );
  }

  /// Handle de tap no BottomNavigationBar
  void _onBottomNavTap(BuildContext context, WidgetRef ref, int index) {
    final currentIndex = ref.read(navigationStateProvider).selectedTabIndex;

    // Evita navegação desnecessária
    if (currentIndex == index) return;

    // Atualiza estado e navega
    ref.read(navigationStateProvider.notifier).selectTab(index);
    _navigateToMainPage(context, index);
  }

  /// Navega para página principal baseado no índice
  void _navigateToMainPage(BuildContext context, int index) {
    final routes = [
      '/home-defensivos', // 0
      '/home-pragas', // 1
      '/favoritos', // 2
      '/comentarios', // 3
      '/settings', // 4
    ];

    if (index < 0 || index >= routes.length) return;

    final navigator = Navigator.of(context);

    // Usa pushNamedAndRemoveUntil para limpar stack e navegar
    navigator.pushNamedAndRemoveUntil(
      routes[index],
      (route) => false, // Remove todas as rotas
    );
  }
}

/// NavigatorObserver para sincronizar estado do BottomNav com rotas
class BottomNavVisibilityObserver extends NavigatorObserver {
  final void Function(bool visible, int? tabIndex) onStateChanged;

  BottomNavVisibilityObserver({required this.onStateChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateState(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateState(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _updateState(newRoute);
    }
  }

  void _updateState(Route<dynamic> route) {
    final settings = route.settings;
    onStateChanged(settings.showBottomNav, settings.tabIndex);
  }
}
