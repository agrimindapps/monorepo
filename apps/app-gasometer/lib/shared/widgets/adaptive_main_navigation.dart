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
import 'add_options_bottom_sheet.dart';
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
            selectedIndex: widget.navigationShell.currentIndex,
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
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onNavigationSelected,
        destinations: _getNavigationDestinations(),
      ),
    );
  }
  
  /// Handle navigation selection
  void _onNavigationSelected(int index) {
    // Index 2 is the "Add" button - show bottom sheet instead of navigating
    if (index == 2) {
      _showAddOptionsBottomSheet();
      return;
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  /// Show bottom sheet with add options
  void _showAddOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddOptionsBottomSheet(),
    );
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
        icon: Icon(Icons.directions_car_outlined),
        selectedIcon: Icon(Icons.directions_car),
        label: Text('Veículos'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.add_circle_outline),
        selectedIcon: Icon(Icons.add_circle),
        label: Text('Adicionar'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.build_outlined),
        selectedIcon: Icon(Icons.build),
        label: Text('Ferramentas'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text('Configurações'),
      ),
    ];
  }
  
  /// Get navigation destinations for NavigationBar
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
        icon: Icon(Icons.add_circle_outline),
        selectedIcon: Icon(Icons.add_circle),
        label: 'Adicionar',
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
      case '/add':
        return 'Adicionar';
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
      case '/add':
        return selected ? Icons.add_circle : Icons.add_circle_outline;
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
