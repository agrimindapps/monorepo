/// DEPRECATED: Este arquivo foi substituído por AdaptiveMainNavigation
/// A navegação agora é gerenciada por StatefulShellRoute e AdaptiveMainNavigation
/// que suporta layouts adaptativos (mobile/tablet/desktop).
///
/// Para uso futuro, consulte:
/// - lib/shared/widgets/adaptive_main_navigation.dart
/// - lib/core/router/app_router.dart (StatefulShellRoute)
library;

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bottom_navigation.g.dart';

/// Enum para as tabs da navegação principal
/// DEPRECATED: Mantido apenas para compatibilidade temporária
@Deprecated('Use AdaptiveMainNavigation em vez disso')
enum MainTab { home, animals, calculators, reminders, settings }

/// Provider para gerenciar o estado da tab atual
/// DEPRECATED: O estado de navegação agora é gerenciado pelo StatefulNavigationShell
@Deprecated('O estado de navegação é gerenciado pelo GoRouter StatefulShellRoute')
@riverpod
class CurrentTab extends _$CurrentTab {
  @override
  MainTab build() => MainTab.home;

  void set(MainTab tab) => state = tab;
}

/// Widget de navegação inferior principal do app
/// Usa o NavigationBar do Material 3 para consistência visual
/// DEPRECATED: Substituído por AdaptiveMainNavigation
@Deprecated('Use AdaptiveMainNavigation que suporta layouts adaptativos')
class MainBottomNavigation extends ConsumerStatefulWidget {
  final Widget child;

  const MainBottomNavigation({super.key, required this.child});

  @override
  ConsumerState<MainBottomNavigation> createState() =>
      _MainBottomNavigationState();
}

class _MainBottomNavigationState extends ConsumerState<MainBottomNavigation> {
  int _getCurrentIndex(BuildContext context) {
    try {
      final location = GoRouterState.of(context).uri.path;

      if (location == '/') return 0;
      if (location.startsWith('/animals')) return 1;
      if (location.startsWith('/calculators')) return 2;
      if (location.startsWith('/reminders')) return 3;
      if (location.startsWith('/settings') ||
          location.startsWith('/profile') ||
          location.startsWith('/expenses') ||
          location.startsWith('/subscription') ||
          location.startsWith('/notifications-settings')) {
        return 4;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  void _onTabTapped(int index) {
    if (!mounted) return;

    try {
      final tab = MainTab.values[index];
      ref.read(currentTabProvider.notifier).set(tab);

      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/animals');
          break;
        case 2:
          context.go('/calculators');
          break;
        case 3:
          context.go('/reminders');
          break;
        case 4:
          context.go('/settings');
          break;
      }
    } catch (e) {
      debugPrint('Erro na navegação: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child),
        NavigationBar(
          selectedIndex: _getCurrentIndex(context),
          onDestinationSelected: _onTabTapped,
          height: 65,
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.timeline),
              icon: Icon(Icons.timeline_outlined),
              label: 'Timeline',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.pets),
              icon: Icon(Icons.pets_outlined),
              label: 'Pets',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.assignment),
              icon: Icon(Icons.assignment_outlined),
              label: 'Atividades',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.build),
              icon: Icon(Icons.build_outlined),
              label: 'Ferramentas',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings_outlined),
              label: 'Config',
            ),
          ],
        ),
      ],
    );
  }
}

/// Shell customizado para navegação com bottom bar
/// DEPRECATED: Substituído por AdaptiveMainNavigation gerenciado pelo GoRouter
@Deprecated('Use StatefulShellRoute com AdaptiveMainNavigation no app_router.dart')
class BottomNavShell extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;

  const BottomNavShell({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideBottomNavPages = ['/login', '/onboarding', '/splash'];

    final shouldShowBottomNav = !hideBottomNavPages.any(
      (page) => state.uri.toString().startsWith(page),
    );

    if (!shouldShowBottomNav) {
      return child;
    }

    return MainBottomNavigation(child: child);
  }
}

/// Badge para notificações na navegação
class NavigationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const NavigationBadge({super.key, required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
