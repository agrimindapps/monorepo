import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Enum para as tabs da navegação principal
enum MainTab {
  home,
  animals,
  calculators,
  reminders,
  profile,
}

/// Provider para gerenciar o estado da tab atual
final currentTabProvider = StateProvider<MainTab>((ref) => MainTab.home);

/// Widget de navegação inferior principal do app
class MainBottomNavigation extends ConsumerWidget {
  final Widget child;
  final String currentLocation;

  const MainBottomNavigation({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        child, // This will be the individual page with its own Scaffold
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: MainTab.values.map((tab) {
                    final isSelected = _isTabSelected(tab, currentLocation);
                    
                    return Expanded(
                      child: _NavBarItem(
                        tab: tab,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(currentTabProvider.notifier).state = tab;
                          _navigateToTab(context, tab);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isTabSelected(MainTab tab, String location) {
    switch (tab) {
      case MainTab.home:
        return location == '/';
      case MainTab.animals:
        return location.startsWith('/animals');
      case MainTab.calculators:
        return location.startsWith('/calculators');
      case MainTab.reminders:
        return location.startsWith('/reminders');
      case MainTab.profile:
        return location.startsWith('/profile') || 
               location.startsWith('/expenses') ||
               location.startsWith('/subscription');
    }
  }

  void _navigateToTab(BuildContext context, MainTab tab) {
    switch (tab) {
      case MainTab.home:
        context.go('/');
        break;
      case MainTab.animals:
        context.go('/animals');
        break;
      case MainTab.calculators:
        context.go('/calculators');
        break;
      case MainTab.reminders:
        context.go('/reminders');
        break;
      case MainTab.profile:
        context.go('/profile');
        break;
    }
  }
}

/// Item individual da barra de navegação
class _NavBarItem extends StatelessWidget {
  final MainTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final tabInfo = _getTabInfo(tab);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                (isSelected ? tabInfo['selectedIcon'] : tabInfo['icon']) as IconData? ?? Icons.home,
                color: isSelected 
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.labelSmall!.copyWith(
                color: isSelected 
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 10,
              ),
              child: Text(tabInfo['label'] as String? ?? ''),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getTabInfo(MainTab tab) {
    switch (tab) {
      case MainTab.home:
        return {
          'label': 'Início',
          'icon': Icons.home_outlined,
          'selectedIcon': Icons.home,
        };
      case MainTab.animals:
        return {
          'label': 'Pets',
          'icon': Icons.pets_outlined,
          'selectedIcon': Icons.pets,
        };
      case MainTab.calculators:
        return {
          'label': 'Cálculos',
          'icon': Icons.calculate_outlined,
          'selectedIcon': Icons.calculate,
        };
      case MainTab.reminders:
        return {
          'label': 'Lembretes',
          'icon': Icons.notifications_outlined,
          'selectedIcon': Icons.notifications,
        };
      case MainTab.profile:
        return {
          'label': 'Perfil',
          'icon': Icons.person_outline,
          'selectedIcon': Icons.person,
        };
    }
  }
}

/// Shell customizado para navegação com bottom bar
class BottomNavShell extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;

  const BottomNavShell({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Páginas que não devem mostrar o bottom navigation
    final hideBottomNavPages = [
      '/login',
      '/onboarding',
      '/splash',
    ];

    final shouldShowBottomNav = !hideBottomNavPages.any(
      (page) => state.uri.toString().startsWith(page),
    );

    if (!shouldShowBottomNav) {
      return child;
    }

    return MainBottomNavigation(
      currentLocation: state.uri.toString(),
      child: child,
    );
  }
}

/// Badge para notificações na navegação
class NavigationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const NavigationBadge({
    super.key,
    required this.count,
    required this.child,
  });

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
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
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