import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'add_options_bottom_sheet.dart';

/// Wrapper widget that adds bottom navigation to standalone pages
/// Used for pages like Fuel, Odometer, Expenses, Maintenance that are outside the main navigation shell
class PageWithBottomNav extends StatelessWidget {
  const PageWithBottomNav({
    super.key,
    required this.child,
    this.currentIndex = -1, // -1 means no tab is selected (standalone page)
    this.fabRoute, // Route to navigate when FAB is pressed (e.g., '/fuel/add')
    this.fabIcon = Icons.add,
    this.fabLabel,
  });

  final Widget child;
  final int currentIndex;
  final String? fabRoute;
  final IconData fabIcon;
  final String? fabLabel;

  @override
  Widget build(BuildContext context) {
    // Debug: verificar se FAB está sendo criado
    if (kDebugMode) {
      print('🔧 PageWithBottomNav: fabRoute=$fabRoute, fabIcon=$fabIcon, fabLabel=$fabLabel');
    }
    
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex >= 0 ? currentIndex : 2, // Default to "Add" tab
        onDestinationSelected: (index) => _onNavigationSelected(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Veículos',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Adicionar',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Ferramentas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
      floatingActionButton: fabRoute != null
          ? FloatingActionButton.extended(
              onPressed: () {
                if (kDebugMode) {
                  print('🚀 FAB pressed: navigating to $fabRoute');
                }
                context.push(fabRoute!);
              },
              icon: Icon(fabIcon),
              label: Text(fabLabel ?? 'Adicionar'),
            )
          : null,
    );
  }

  void _onNavigationSelected(BuildContext context, int index) {
    // Index 2 is the "Add" button - show bottom sheet instead of navigating
    if (index == 2) {
      _showAddOptionsBottomSheet(context);
      return;
    }

    // Navigate to corresponding route
    switch (index) {
      case 0:
        context.go('/timeline');
        break;
      case 1:
        context.go('/vehicles');
        break;
      case 3:
        context.go('/tools');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  void _showAddOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddOptionsBottomSheet(),
    );
  }
}
