// Flutter imports:
import 'package:flutter/material.dart';

class BottomBarWidget extends StatefulWidget {
  final PageController controller;

  const BottomBarWidget({
    super.key,
    required this.controller,
  });

  @override
  State<BottomBarWidget> createState() => _BottomBarWidgetState();
}

class _BottomBarWidgetState extends State<BottomBarWidget> {
  int _selectedIndex = 0;
  bool _isNavigating = false;

  final List<({IconData icon, IconData activeIcon, String label})>
      _navigationItems = const [
    (
      icon: Icons.directions_car_outlined,
      activeIcon: Icons.directions_car,
      label: 'Veículos',
    ),
    (
      icon: Icons.speed_outlined,
      activeIcon: Icons.speed,
      label: 'Odômetro',
    ),
    (
      icon: Icons.local_gas_station_outlined,
      activeIcon: Icons.local_gas_station,
      label: 'Abastecimentos',
    ),
    (
      icon: Icons.query_stats_outlined,
      activeIcon: Icons.query_stats,
      label: 'Estatísticas',
    ),
    (
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Config.',
    ),
  ];

  void _onItemTapped(int index) {
    _isNavigating = true;
    debugPrint('BottomBarWidget._onItemTapped: $index');

    try {
      widget.controller.jumpToPage(index);
      if (mounted) {
        setState(() => _selectedIndex = index);
      }
    } catch (error) {
      debugPrint('Navigation error: $error');
    } finally {
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        // backgroundColor: Colors.white,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        selectedItemColor: Theme.of(context).primaryColor,
        // unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _navigationItems
            .map((item) => BottomNavigationBarItem(
                  tooltip: item.label,
                  icon: Icon(item.icon, size: 24),
                  activeIcon: Icon(item.activeIcon, size: 32),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}
