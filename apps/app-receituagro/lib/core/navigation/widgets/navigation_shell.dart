import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/route_settings_extension.dart';
import '../providers/navigation_state_provider.dart';

/// Shell que envolve o MaterialApp e provê BottomNavigationBar persistente
class NavigationShell extends ConsumerWidget {
  final Widget? child;

  const NavigationShell({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);

    // Se não deve mostrar bottom nav, retorna apenas o child sem Scaffold extra
    // Isso evita Scaffolds aninhados em páginas de detalhe
    if (!navigationState.showBottomNav) {
      return child ?? const SizedBox.shrink();
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context, ref, navigationState),
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
      currentIndex: state.selectedTabIndex,
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

    // Atualiza estado do provider
    ref.read(navigationStateProvider.notifier).selectTab(index);

    // Navega para página principal correspondente
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
  final void Function(bool) onVisibilityChanged;

  BottomNavVisibilityObserver({required this.onVisibilityChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateVisibility(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateVisibility(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _updateVisibility(newRoute);
    }
  }

  void _updateVisibility(Route<dynamic> route) {
    final settings = route.settings;
    onVisibilityChanged(settings.showBottomNav);
  }
}
