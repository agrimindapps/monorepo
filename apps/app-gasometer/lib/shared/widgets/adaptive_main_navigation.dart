/// Adaptive main navigation component
/// Provides different navigation layouts based on screen size:
/// - Mobile: Bottom navigation bar
/// - Tablet: Navigation rail
/// - Desktop: Collapsible sidebar
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/responsive_constants.dart';
import '../../core/widgets/responsive_content_area.dart';
import 'responsive_sidebar.dart';

/// Main adaptive navigation shell that changes layout based on screen size
class AdaptiveMainNavigation extends StatefulWidget {
  
  const AdaptiveMainNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

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
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              const Color(0xFF1C1C1E), // Dark surface color
                              const Color(0xFF0F0F0F), // Darker shade
                            ]
                          : [
                              const Color(0xFFF0F2F5), // Light gray (Plantis style)
                              const Color(0xFFE8ECEF), // Slightly darker gray
                            ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: ResponsiveContentArea(
                    child: widget.navigationShell,
                  ),
                );
              },
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
            selectedIndex: _getNavigationIndex(widget.navigationShell.currentIndex),
            onDestinationSelected: _onNavigationSelected,
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Theme.of(context).colorScheme.surface, // Theme-aware surface
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
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              const Color(0xFF1C1C1E), // Dark surface color
                              const Color(0xFF0F0F0F), // Darker shade
                            ]
                          : [
                              const Color(0xFFF0F2F5), // Light gray (Plantis style)
                              const Color(0xFFE8ECEF), // Slightly darker gray
                            ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: ResponsiveContentArea(child: widget.navigationShell),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// Mobile layout with bottom navigation
  Widget _buildMobileBottomNavLayout() {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getNavigationIndex(widget.navigationShell.currentIndex),
        onDestinationSelected: _onNavigationSelected,
        destinations: _getNavigationDestinations(),
      ),
    );
  }
  
  /// Handle navigation selection
  void _onNavigationSelected(int index) {
    // Mapeia índice da navegação para índice do branch correto
    final branchIndex = _getBranchIndex(index);

    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

  /// Mapeia índice da navegação para índice do branch do router
  int _getBranchIndex(int navigationIndex) {
    if (ResponsiveLayout.isMobile(context)) {
      // Mobile: Timeline(0), Vehicles(1), Add(2-interceptado), Tools(3), Settings(4)
      // Branches: Timeline(0), Vehicles(1), Add(2), Tools(3), Settings(4), Fuel(5), Maintenance(6), Expenses(7), Odometer(8)
      switch (navigationIndex) {
        case 0: return 0; // Timeline
        case 1: return 1; // Vehicles
        case 2: return 2; // Add (não deve chegar aqui, interceptado antes)
        case 3: return 3; // Tools
        case 4: return 4; // Settings
        default: return 0;
      }
    } else {
      // Desktop/Tablet: usa o índice direto do navigation rail
      // Rail: Timeline(0), Tools(1), Vehicles(2), Fuel(3), Maintenance(4), Expenses(5), Odometer(6), Settings(7)
      // Branches: Timeline(0), Vehicles(1), Add(2), Tools(3), Settings(4), Fuel(5), Maintenance(6), Expenses(7), Odometer(8)
      switch (navigationIndex) {
        case 0: return 0; // Timeline
        case 1: return 3; // Tools
        case 2: return 1; // Vehicles
        case 3: return 5; // Fuel
        case 4: return 6; // Maintenance
        case 5: return 7; // Expenses
        case 6: return 8; // Odometer
        case 7: return 4; // Settings
        default: return 0;
      }
    }
  }

  /// Mapeia índice do branch para índice da navegação (inverso)
  int _getNavigationIndex(int branchIndex) {
    if (ResponsiveLayout.isMobile(context)) {
      // Branches → Mobile Navigation
      switch (branchIndex) {
        case 0: return 0; // Timeline
        case 1: return 1; // Vehicles
        case 3: return 3; // Tools
        case 4: return 4; // Settings
        // Branches que não estão na bottom nav retornam 0 (Timeline)
        case 2: return 2; // Add
        case 5: return 0; // Fuel → Timeline
        case 6: return 0; // Maintenance → Timeline
        case 7: return 0; // Expenses → Timeline
        case 8: return 0; // Odometer → Timeline
        default: return 0;
      }
    } else {
      // Branches → Desktop/Tablet Rail
      switch (branchIndex) {
        case 0: return 0; // Timeline
        case 3: return 1; // Tools
        case 1: return 2; // Vehicles
        case 5: return 3; // Fuel
        case 6: return 4; // Maintenance
        case 7: return 5; // Expenses
        case 8: return 6; // Odometer
        case 4: return 7; // Settings
        case 2: return 0; // Add → Timeline (não deve acontecer)
        default: return 0;
      }
    }
  }

  /// Get navigation destinations for rail layout
  List<NavigationRailDestination> _getNavigationRailDestinations() {
    return const [
      NavigationRailDestination(
        icon: Icon(Icons.timeline_outlined),
        selectedIcon: Icon(Icons.timeline),
        label: Text('Timeline'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.build_outlined),
        selectedIcon: Icon(Icons.build),
        label: Text('Ferramentas'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.directions_car_outlined),
        selectedIcon: Icon(Icons.directions_car),
        label: Text('Veículos'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.local_gas_station_outlined),
        selectedIcon: Icon(Icons.local_gas_station),
        label: Text('Abastecimento'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.build_outlined),
        selectedIcon: Icon(Icons.build),
        label: Text('Manutenção'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.attach_money_outlined),
        selectedIcon: Icon(Icons.attach_money),
        label: Text('Despesa'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.speed_outlined),
        selectedIcon: Icon(Icons.speed),
        label: Text('Odômetro'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text('Configurações'),
      ),
    ];
  }
  
  /// Get navigation destinations for NavigationBar (Mobile)
  List<NavigationDestination> _getNavigationDestinations() {
    return const [
      NavigationDestination(
        icon: Icon(Icons.timeline_outlined),
        selectedIcon: Icon(Icons.timeline),
        label: 'Timeline',
      ),
      NavigationDestination(
        icon: Icon(Icons.directions_car_outlined),
        selectedIcon: Icon(Icons.directions_car),
        label: 'Veículos',
      ),
      NavigationDestination(
        icon: Icon(Icons.grid_view_outlined),
        selectedIcon: Icon(Icons.grid_view),
        label: 'Atividades',
      ),
      NavigationDestination(
        icon: Icon(Icons.build_outlined),
        selectedIcon: Icon(Icons.build),
        label: 'Ferramentas',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Configurações',
      ),
    ];
  }
}

/// Responsive floating action button that adapts to layout
class AdaptiveFloatingActionButton extends StatelessWidget {
  
  const AdaptiveFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
  });
  final VoidCallback onPressed;
  final Widget child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
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
      case '/timeline':
        return 'Timeline';
      case '/vehicles':
        return 'Veículos';
      case '/fuel':
        return 'Abastecimento';
      case '/maintenance':
        return 'Manutenção';
      case '/expenses':
        return 'Despesa';
      case '/odometer':
        return 'Odômetro';
      case '/tools':
        return 'Ferramentas';
      case '/reports':
        return 'Estatísticas';
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
      case '/timeline':
        return selected ? Icons.timeline : Icons.timeline_outlined;
      case '/vehicles':
        return selected ? Icons.directions_car : Icons.directions_car_outlined;
      case '/fuel':
        return selected ? Icons.local_gas_station : Icons.local_gas_station_outlined;
      case '/maintenance':
        return selected ? Icons.build : Icons.build_outlined;
      case '/expenses':
        return selected ? Icons.attach_money : Icons.attach_money_outlined;
      case '/odometer':
        return selected ? Icons.speed : Icons.speed_outlined;
      case '/tools':
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
