import 'package:flutter/material.dart';

import '../comentarios/comentarios_page.dart';
import '../defensivos/home_defensivos_page.dart';
import '../favoritos/favoritos_page.dart';
import '../pragas/presentation/pages/home_pragas_page.dart';
import '../settings/settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;

  const MainNavigationPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentBottomNavIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Constrói BottomNavigationBar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentBottomNavIndex,
      onTap: _onBottomNavTap,
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

  void _onBottomNavTap(int index) {
    if (_currentBottomNavIndex == index) return; // Evita rebuilds desnecessários
    
    setState(() {
      _currentBottomNavIndex = index;
    });
    if (index == 2) { // Index 2 é a página de favoritos
      FavoritosPage.reloadIfActive();
    }
  }

  Widget _buildCurrentPage() {
    switch (_currentBottomNavIndex) {
      case 0:
        return const HomeDefensivosPage();
      case 1:
        return const HomePragasPage();
      case 2:
        return const FavoritosPage();
      case 3:
        return const ComentariosPage();
      case 4:
        return const SettingsPage();
      default:
        return const HomeDefensivosPage();
    }
  }

}
