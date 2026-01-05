/// Adaptive main navigation component for PetiVeti
/// Provides different navigation layouts based on screen size:
/// - Mobile: Bottom navigation bar (5 items)
/// - Tablet: Navigation rail (10 items)
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
                              const Color(0xFF1C1C1E),
                              const Color(0xFF0F0F0F),
                            ]
                          : [
                              const Color(0xFFF0F2F5),
                              const Color(0xFFE8ECEF),
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
        destinations: _getMobileNavigationDestinations(),
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
      // Mobile: 5 itens mapeados para branches específicos
      // Nav: Timeline(0), Animals(1), Lembretes(2), Tools(3), Settings(4)
      // Branches: Timeline(0), Animals(1), Appointments(2), Vaccines(3), Medications(4),
      //           Weight(5), Reminders(6), Tools(7), Expenses(8), Settings(9)
      const mobileMapping = {
        0: 0, // Timeline
        1: 1, // Animals
        2: 6, // Lembretes (substituiu Activities)
        3: 7, // Tools
        4: 9, // Settings
      };
      return mobileMapping[navigationIndex] ?? 0;
    } else {
      // Tablet/Desktop: 9 itens (removido Activities)
      // Nav: Timeline(0), Animals(1), Appointments(2), Vaccines(3), Medications(4),
      //      Weight(5), Tools(6), Expenses(7), Settings(8)
      // Branch mapping:
      const desktopMapping = {
        0: 0, // Timeline
        1: 1, // Animals
        2: 2, // Appointments
        3: 3, // Vaccines
        4: 4, // Medications
        5: 5, // Weight
        6: 7, // Tools (pula branch 6)
        7: 8, // Expenses
        8: 9, // Settings
      };
      return desktopMapping[navigationIndex] ?? 0;
    }
  }

  /// Mapeia índice do branch para índice da navegação (inverso)
  int _getNavigationIndex(int branchIndex) {
    if (ResponsiveLayout.isMobile(context)) {
      // Branches → Mobile Navigation (reverse mapping)
      const branchToMobile = {
        0: 0, // Timeline
        1: 1, // Animals
        6: 2, // Lembretes
        7: 3, // Tools
        9: 4, // Settings
        // Branches não em mobile → fallback para Timeline
        2: 0, // Appointments → Timeline
        3: 0, // Vaccines → Timeline
        4: 0, // Medications → Timeline
        5: 0, // Weight → Timeline
        8: 0, // Expenses → Timeline
      };
      return branchToMobile[branchIndex] ?? 0;
    } else {
      // Tablet/Desktop: reverse mapping (9 itens)
      const branchToDesktop = {
        0: 0, // Timeline
        1: 1, // Animals
        2: 2, // Appointments
        3: 3, // Vaccines
        4: 4, // Medications
        5: 5, // Weight
        6: 0, // Activities → Timeline (removido)
        7: 6, // Tools
        8: 7, // Expenses
        9: 8, // Settings
      };
      return branchToDesktop[branchIndex] ?? 0;
    }
  }

  /// Get navigation destinations for rail layout (tablet/desktop - 9 itens)
  List<NavigationRailDestination> _getNavigationRailDestinations() {
    return const [
      // Index 0 → Branch 0: Timeline
      NavigationRailDestination(
        icon: Icon(Icons.timeline_outlined),
        selectedIcon: Icon(Icons.timeline),
        label: Text('Timeline'),
      ),
      // Index 1 → Branch 1: Animals
      NavigationRailDestination(
        icon: Icon(Icons.pets_outlined),
        selectedIcon: Icon(Icons.pets),
        label: Text('Pets'),
      ),
      // Index 2 → Branch 2: Appointments
      NavigationRailDestination(
        icon: Icon(Icons.event_outlined),
        selectedIcon: Icon(Icons.event),
        label: Text('Consultas'),
      ),
      // Index 3 → Branch 3: Vaccines
      NavigationRailDestination(
        icon: Icon(Icons.medical_services_outlined),
        selectedIcon: Icon(Icons.medical_services),
        label: Text('Vacinas'),
      ),
      // Index 4 → Branch 4: Medications
      NavigationRailDestination(
        icon: Icon(Icons.medication_outlined),
        selectedIcon: Icon(Icons.medication),
        label: Text('Medicamentos'),
      ),
      // Index 5 → Branch 5: Weight
      NavigationRailDestination(
        icon: Icon(Icons.monitor_weight_outlined),
        selectedIcon: Icon(Icons.monitor_weight),
        label: Text('Peso'),
      ),
      // Index 6 → Branch 7: Tools
      NavigationRailDestination(
        icon: Icon(Icons.handyman_outlined),
        selectedIcon: Icon(Icons.handyman),
        label: Text('Ferramentas'),
      ),
      // Index 7 → Branch 8: Expenses
      NavigationRailDestination(
        icon: Icon(Icons.attach_money_outlined),
        selectedIcon: Icon(Icons.attach_money),
        label: Text('Despesas'),
      ),
      // Index 8 → Branch 9: Settings
      NavigationRailDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text('Config'),
      ),
    ];
  }

  /// Get navigation destinations for NavigationBar (Mobile - 5 itens)
  List<NavigationDestination> _getMobileNavigationDestinations() {
    return const [
      // Mobile 0 → Branch 0: Timeline
      NavigationDestination(
        icon: Icon(Icons.timeline_outlined),
        selectedIcon: Icon(Icons.timeline),
        label: 'Timeline',
      ),
      // Mobile 1 → Branch 1: Animals
      NavigationDestination(
        icon: Icon(Icons.pets_outlined),
        selectedIcon: Icon(Icons.pets),
        label: 'Pets',
      ),
      // Mobile 2 → Branch 6: Lembretes
      NavigationDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: 'Lembretes',
      ),
      // Mobile 3 → Branch 7: Tools
      NavigationDestination(
        icon: Icon(Icons.handyman_outlined),
        selectedIcon: Icon(Icons.handyman),
        label: 'Ferramentas',
      ),
      // Mobile 4 → Branch 9: Settings
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Config',
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

/// Navigation utility functions for PetiVeti
class NavigationUtils {
  /// Get navigation label by route
  static String getLabelByRoute(String route) {
    switch (route) {
      case '/':
        return 'Timeline';
      case '/activities':
        return 'Atividades';
      case '/animals':
        return 'Pets';
      case '/appointments':
        return 'Consultas';
      case '/vaccines':
        return 'Vacinas';
      case '/medications':
        return 'Medicamentos';
      case '/weight':
        return 'Peso';
      case '/reminders':
        return 'Lembretes';
      case '/tools':
        return 'Ferramentas';
      case '/calculators':
        return 'Cálculos';
      case '/expenses':
        return 'Despesas';
      case '/settings':
        return 'Configurações';
      case '/profile':
        return 'Perfil';
      case '/subscription':
        return 'Premium';
      default:
        return 'Página';
    }
  }

  /// Get navigation icon by route
  static IconData getIconByRoute(String route, {bool selected = false}) {
    switch (route) {
      case '/':
        return selected ? Icons.timeline : Icons.timeline_outlined;
      case '/activities':
        return selected ? Icons.dashboard : Icons.dashboard_outlined;
      case '/animals':
        return selected ? Icons.pets : Icons.pets_outlined;
      case '/appointments':
        return selected ? Icons.event : Icons.event_outlined;
      case '/vaccines':
        return selected ? Icons.medical_services : Icons.medical_services_outlined;
      case '/medications':
        return selected ? Icons.medication : Icons.medication_outlined;
      case '/weight':
        return selected ? Icons.monitor_weight : Icons.monitor_weight_outlined;
      case '/reminders':
        return selected ? Icons.notifications : Icons.notifications_outlined;
      case '/tools':
        return selected ? Icons.handyman : Icons.handyman_outlined;
      case '/calculators':
        return selected ? Icons.calculate : Icons.calculate_outlined;
      case '/expenses':
        return selected ? Icons.attach_money : Icons.attach_money_outlined;
      case '/settings':
        return selected ? Icons.settings : Icons.settings_outlined;
      case '/profile':
        return selected ? Icons.person : Icons.person_outlined;
      case '/subscription':
        return selected ? Icons.workspace_premium : Icons.workspace_premium_outlined;
      default:
        return selected ? Icons.pageview : Icons.pageview_outlined;
    }
  }
}
