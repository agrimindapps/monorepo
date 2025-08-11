import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    
    if (location.startsWith('/plants')) return 0;
    if (location.startsWith('/spaces')) return 1;
    if (location.startsWith('/tasks')) return 2;
    if (location.startsWith('/premium')) return 3;
    if (location.startsWith('/profile')) return 4;
    
    return 0;
  }

  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        context.go('/plants');
        break;
      case 1:
        context.go('/spaces');
        break;
      case 2:
        context.go('/tasks');
        break;
      case 3:
        context.go('/premium');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getCurrentIndex(context),
        onDestinationSelected: _onTabTapped,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: PlantisColors.primary.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.eco),
            icon: Icon(Icons.eco_outlined),
            label: 'Plantas',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Espaços',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.checklist),
            icon: Icon(Icons.checklist_outlined),
            label: 'Tarefas',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.star),
            icon: Icon(Icons.star_outline),
            label: 'Premium',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}