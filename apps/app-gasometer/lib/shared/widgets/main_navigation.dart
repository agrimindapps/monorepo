import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;
  
  const MainNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTap(context, index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Veículos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Odômetro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station),
            label: 'Combustível',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Manutenção',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    if (location == '/' || location.startsWith('/vehicle')) return 0;
    if (location.startsWith('/odometer')) return 1;
    if (location.startsWith('/fuel')) return 2;
    if (location.startsWith('/maintenance')) return 3;
    if (location.startsWith('/reports')) return 4;
    if (location.startsWith('/settings')) return 5;
    
    return 0; // Default to vehicles
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/odometer');
        break;
      case 2:
        context.go('/fuel');
        break;
      case 3:
        context.go('/maintenance');
        break;
      case 4:
        context.go('/reports');
        break;
      case 5:
        context.go('/settings');
        break;
    }
  }
}