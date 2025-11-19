import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart' as di;
import 'domain/navigation_constants.dart';
import 'domain/navigation_item_builder.dart';
import 'domain/navigation_page_service.dart';

/// Main navigation page com BottomNavigationBar
///
/// **REFACTORED (SOLID):**
/// - Usa NavigationPageService para gerenciar páginas (elimina switch case)
/// - Usa NavigationItemBuilder para criar items (elimina duplicação)
/// - Usa NavigationConstants para índices (elimina magic numbers)
class MainNavigationPage extends StatefulWidget {
  final int initialIndex;

  const MainNavigationPage({
    super.key,
    this.initialIndex = NavigationConstants.indexDefensivos,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late final NavigationPageService _pageService;
  int _currentBottomNavIndex = NavigationConstants.indexDefensivos;

  @override
  void initState() {
    super.initState();
    _pageService = di.sl<NavigationPageService>();
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
      // REFACTORED: Usa NavigationItemBuilder (elimina 50+ linhas de código)
      items: NavigationItemBuilder.buildItems(),
    );
  }

  void _onBottomNavTap(int index) {
    if (_currentBottomNavIndex == index) {
      return; // Evita rebuilds desnecessários
    }

    setState(() {
      _currentBottomNavIndex = index;
    });

    // REFACTORED: Usa NavigationPageService (elimina magic number)
    _pageService.onNavigateToIndex(index);
  }

  Widget _buildCurrentPage() {
    // REFACTORED: Usa NavigationPageService (elimina switch case - OCP violation)
    return _pageService.getPageByIndex(_currentBottomNavIndex);
  }
}
