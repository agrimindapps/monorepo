import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';
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
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedFontSize: 12,
      unselectedFontSize: 0, // 0 para ocultar completamente
      iconSize: 24,
      selectedIconTheme: const IconThemeData(size: 26),
      items: const [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(AppIcons.defensivos),
          ),
          activeIcon: Icon(AppIcons.defensivos),
          label: 'Defensivos',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(AppIcons.pragas),
          ),
          activeIcon: Icon(AppIcons.pragas),
          label: 'Pragas',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(AppIcons.favoritos),
          ),
          activeIcon: Icon(AppIcons.favoritosFill),
          label: 'Favoritos',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(AppIcons.comentarios),
          ),
          activeIcon: Icon(AppIcons.comentariosFill),
          label: 'Comentários',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(AppIcons.configuracoes),
          ),
          activeIcon: Icon(AppIcons.configuracoesFill),
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
