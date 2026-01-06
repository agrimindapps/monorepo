import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme_providers.dart';

/// A responsive shell that adapts to screen size:
/// - Desktop/Tablet: Left Navigation Rail/Drawer
/// - Mobile: Bottom Navigation Bar
class ResponsiveShell extends ConsumerStatefulWidget {
  const ResponsiveShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends ConsumerState<ResponsiveShell> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(currentThemeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          // Mobile/Small Tablet: Bottom Navigation
          return Scaffold(
            body: widget.navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Início',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calculate_outlined),
                  selectedIcon: Icon(Icons.calculate),
                  label: 'Calculadoras',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Configurações',
                ),
              ],
            ),
          );
        } else {
          // Desktop/Large Tablet: Navigation Rail
          return Scaffold(
            body: Row(
              children: [
                _DesktopNavigationRail(
                  isExtended: constraints.maxWidth >= 1200,
                  currentIndex: widget.navigationShell.currentIndex,
                  onDestinationSelected: _onDestinationSelected,
                  isDark: isDark,
                  onToggleTheme: () {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: widget.navigationShell),
              ],
            ),
          );
        }
      },
    );
  }

  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

/// Desktop Navigation Rail with category filters
class _DesktopNavigationRail extends StatelessWidget {
  final bool isExtended;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isDark;
  final VoidCallback onToggleTheme;

  const _DesktopNavigationRail({
    required this.isExtended,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExtended ? 280 : 80,
      decoration: BoxDecoration(
        color: Theme.of(context).navigationRailTheme.backgroundColor,
      ),
      child: Column(
        children: [
          // Logo/Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Icon(
              Icons.calculate_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          // Main Navigation
          ...List.generate(3, (index) {
            final destinations = [
              (Icons.home_outlined, Icons.home, 'Início'),
              (Icons.calculate_outlined, Icons.calculate, 'Calculadoras'),
              (Icons.settings_outlined, Icons.settings, 'Configurações'),
            ];
            
            final (icon, selectedIcon, label) = destinations[index];
            final isSelected = currentIndex == index;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Material(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => onDestinationSelected(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? selectedIcon : icon,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        if (isExtended) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // Divider
          if (isExtended) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Divider(),
            ),
            
            // Categories Section (only when extended)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CATEGORIAS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            // Category Items
            const _CategoryItem(
              icon: Icons.apps,
              label: 'Todos',
              color: Colors.grey,
            ),
            const _CategoryItem(
              icon: Icons.favorite,
              label: 'Favoritos',
              color: Colors.red,
            ),
            const _CategoryItem(
              icon: Icons.history,
              label: 'Recentes',
              color: Colors.purple,
            ),
            const _CategoryItem(
              icon: Icons.account_balance_wallet,
              label: 'Financeiro',
              color: Colors.blue,
            ),
            const _CategoryItem(
              icon: Icons.construction,
              label: 'Construção',
              color: Colors.deepOrange,
            ),
          ],

          const Spacer(),

          // Theme Toggle
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: onToggleTheme,
              tooltip: isExtended
                  ? (isDark ? 'Modo Claro' : 'Modo Escuro')
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            // TODO: Implement category filter
            // This will require passing a callback or using a provider
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
