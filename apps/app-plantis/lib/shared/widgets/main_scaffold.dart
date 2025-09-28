import 'package:core/core.dart';
import 'package:flutter/material.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _getCurrentIndex(BuildContext context) {
    try {
      final location = GoRouterState.of(context).uri.path;

      if (location.startsWith('/tasks')) return 0;
      if (location.startsWith('/plants')) return 1;
      if (location.startsWith('/settings')) return 2;

      return 0;
    } catch (e) {
      // GoRouterState não está disponível no contexto atual
      return 0;
    }
  }

  void _onTabTapped(int index) {
    // Verificar se o contexto tem acesso ao GoRouter antes de navegar
    if (!mounted) return;
    
    try {
      switch (index) {
        case 0:
          context.go('/tasks');
          break;
        case 1:
          context.go('/plants');
          break;
        case 2:
          context.go('/settings');
          break;
      }
    } catch (e) {
      // Se a navegação falhar, pode ser que o contexto não tenha acesso ao GoRouter
      debugPrint('Erro na navegação: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getCurrentIndex(context),
        onDestinationSelected: _onTabTapped,
        height: 60,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.checklist),
            icon: Icon(Icons.checklist_outlined),
            label: 'Tarefas',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.eco),
            icon: Icon(Icons.eco_outlined),
            label: 'Plantas',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Conta',
          ),
        ],
      ),
    );
  }
}
