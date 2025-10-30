import 'package:flutter/material.dart';

import 'domain/navigation_constants.dart';
import 'domain/navigation_item_builder.dart';
import 'main_navigation_page.dart';

/// Widget wrapper que adiciona BottomNavigationBar a páginas secundárias
///
/// **REFACTORED (SOLID):**
/// - Usa NavigationItemBuilder para criar items (elimina duplicação)
/// - Usa NavigationConstants para índice padrão (elimina magic numbers)
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
        currentIndex: selectedIndex ?? NavigationConstants.indexDefensivos,
        onTap: (index) {
          _navigateToMainPage(context, index);
        },
        elevation: 8,
        // REFACTORED: Usa NavigationItemBuilder (elimina duplicação)
        items: NavigationItemBuilder.buildSimpleItems(),
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
