import 'package:flutter/material.dart';
import 'main_navigation_page.dart';

/// Widget wrapper que adiciona BottomNavigationBar a páginas secundárias

class BottomNavWrapper extends StatelessWidget {
  final Widget child;
  final int? selectedIndex;

  const BottomNavWrapper({super.key, required this.child, this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex ?? 0,
        onTap: (index) {
          _navigateToMainPage(context, index);
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

  void _navigateToMainPage(BuildContext context, int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<Widget>(
        builder: (context) => MainNavigationPage(initialIndex: index),
      ),
      (route) => false,
    );
  }
}
