/// Adaptive main navigation component
/// Provides different navigation layouts based on screen size:
/// - Mobile: Bottom navigation bar
/// - Tablet: Navigation rail
/// - Desktop: Collapsible sidebar
library adaptive_main_navigation;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/responsive_constants.dart';
import '../../core/presentation/widgets/responsive_content_area.dart';
import 'responsive_sidebar.dart';

/// Main adaptive navigation shell that changes layout based on screen size
class AdaptiveMainNavigation extends StatefulWidget {
  final Widget child;
  
  const AdaptiveMainNavigation({super.key, required this.child});

  @override
  State<AdaptiveMainNavigation> createState() => _AdaptiveMainNavigationState();
}

class _AdaptiveMainNavigationState extends State<AdaptiveMainNavigation> {
  bool _sidebarCollapsed = false;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final navigationType = ResponsiveLayout.getNavigationType(constraints.maxWidth);
        
        switch (navigationType) {
          case NavigationType.sidebar:
            return _buildDesktopSidebarLayout();
          case NavigationType.rail:
            return _buildTabletRailLayout();
          case NavigationType.bottom:
            return _buildMobileBottomNavLayout();
        }
      },
    );
  }
  
  /// Desktop layout with collapsible sidebar
  Widget _buildDesktopSidebarLayout() {
    return Scaffold(
      body: Row(
        children: [
          ResponsiveSidebar(
            isCollapsed: _sidebarCollapsed,
            onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
          ),
          Expanded(
            child: ResponsiveContentArea(
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Tablet layout with navigation rail
  Widget _buildTabletRailLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _getCurrentNavigationIndex(context),
            onDestinationSelected: _onNavigationSelected,
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Theme.of(context).colorScheme.surface,
            indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            unselectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            destinations: _getNavigationRailDestinations(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: ResponsiveContentArea(child: widget.child),
          ),
        ],
      ),
    );
  }
  
  /// Mobile layout with bottom navigation
  Widget _buildMobileBottomNavLayout() {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentNavigationIndex(context),
        onTap: _onNavigationSelected,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: _getBottomNavigationItems(),
      ),
    );
  }
  
  /// Get current navigation index based on route
  int _getCurrentNavigationIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    if (location == '/' || location.startsWith('/vehicle')) return 0;
    if (location.startsWith('/odometer')) return 1;
    if (location.startsWith('/fuel')) return 2;
    if (location.startsWith('/expenses')) return 3;
    if (location.startsWith('/maintenance')) return 4;
    if (location.startsWith('/reports')) return 5;
    if (location.startsWith('/settings')) return 6;
    
    return 0; // Default to vehicles
  }
  
  /// Handle navigation selection
  void _onNavigationSelected(int index) {
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
        context.go('/expenses');
        break;
      case 4:
        context.go('/maintenance');
        break;
      case 5:
        context.go('/reports');
        break;
      case 6:
        context.go('/settings');
        break;
    }
  }
  
  /// Get navigation destinations for rail layout
  List<NavigationRailDestination> _getNavigationRailDestinations() {
    return const [
      NavigationRailDestination(
        icon: Icon(Icons.directions_car_outlined),
        selectedIcon: Icon(Icons.directions_car),
        label: Text('Veículos'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.speed_outlined),
        selectedIcon: Icon(Icons.speed),
        label: Text('Odômetro'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.local_gas_station_outlined),
        selectedIcon: Icon(Icons.local_gas_station),
        label: Text('Combustível'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.attach_money_outlined),
        selectedIcon: Icon(Icons.attach_money),
        label: Text('Despesas'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.build_outlined),
        selectedIcon: Icon(Icons.build),
        label: Text('Manutenção'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart),
        label: Text('Relatórios'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text('Configurações'),
      ),
    ];
  }
  
  /// Get navigation items for bottom navigation
  List<BottomNavigationBarItem> _getBottomNavigationItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.directions_car_outlined),
        activeIcon: Icon(Icons.directions_car),
        label: 'Veículos',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.speed_outlined),
        activeIcon: Icon(Icons.speed),
        label: 'Odômetro',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.local_gas_station_outlined),
        activeIcon: Icon(Icons.local_gas_station),
        label: 'Combustível',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.attach_money_outlined),
        activeIcon: Icon(Icons.attach_money),
        label: 'Despesas',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.build_outlined),
        activeIcon: Icon(Icons.build),
        label: 'Manutenção',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart_outlined),
        activeIcon: Icon(Icons.bar_chart),
        label: 'Relatórios',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: 'Configurações',
      ),
    ];
  }
}

/// Responsive floating action button that adapts to layout
class AdaptiveFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String? tooltip;
  
  const AdaptiveFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    // Hide FAB on desktop/tablet when sidebar/rail is present
    if (!ResponsiveLayout.isMobile(context)) {
      return const SizedBox.shrink();
    }
    
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: child,
    );
  }
}

/// Navigation utility functions
class NavigationUtils {
  /// Get navigation label by route
  static String getLabelByRoute(String route) {
    switch (route) {
      case '/':
        return 'Veículos';
      case '/odometer':
        return 'Odômetro';
      case '/fuel':
        return 'Combustível';
      case '/expenses':
        return 'Despesas';
      case '/maintenance':
        return 'Manutenção';
      case '/reports':
        return 'Relatórios';
      case '/settings':
        return 'Configurações';
      default:
        return 'Página';
    }
  }
  
  /// Get navigation icon by route
  static IconData getIconByRoute(String route, {bool selected = false}) {
    switch (route) {
      case '/':
        return selected ? Icons.directions_car : Icons.directions_car_outlined;
      case '/odometer':
        return selected ? Icons.speed : Icons.speed_outlined;
      case '/fuel':
        return selected ? Icons.local_gas_station : Icons.local_gas_station_outlined;
      case '/expenses':
        return selected ? Icons.attach_money : Icons.attach_money_outlined;
      case '/maintenance':
        return selected ? Icons.build : Icons.build_outlined;
      case '/reports':
        return selected ? Icons.bar_chart : Icons.bar_chart_outlined;
      case '/settings':
        return selected ? Icons.settings : Icons.settings_outlined;
      default:
        return selected ? Icons.pageview : Icons.pageview_outlined;
    }
  }
}