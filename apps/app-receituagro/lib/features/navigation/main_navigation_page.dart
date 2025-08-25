import 'package:flutter/material.dart';

import '../comentarios/comentarios_page.dart';
import '../defensivos/defensivos_page.dart';
import '../favoritos/favoritos_page.dart';
import '../pragas/pragas_page.dart';
import '../settings/settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DefensivosPage(),
    const PragasPage(),
    const FavoritosPage(),
    const ComentariosPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
      ),
    );
  }
}