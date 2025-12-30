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
      // Nav: Home(0), Animals(1), Calculators(2), Reminders(3), Settings(4)
      // Branches: Home(0), Animals(1), Appointments(2), Vaccines(3), Medications(4),
      //           Weight(5), Reminders(6), Calculators(7), Expenses(8), Settings(9)
      const mobileMapping = {
        0: 0, // Home
        1: 1, // Animals
        2: 7, // Calculators
        3: 6, // Reminders
        4: 9, // Settings
      };
      return mobileMapping[navigationIndex] ?? 0;
    } else {
      // Tablet/Desktop: mapeamento direto (10 itens = 10 branches)
      return navigationIndex;
    }
  }

  /// Mapeia índice do branch para índice da navegação (inverso)
  int _getNavigationIndex(int branchIndex) {
    if (ResponsiveLayout.isMobile(context)) {
      // Branches → Mobile Navigation (reverse mapping)
      const branchToMobile = {
        0: 0, // Home
        1: 1, // Animals
        7: 2, // Calculators
        6: 3, // Reminders
        9: 4, // Settings
        // Branches não em mobile → fallback para Home
        2: 0, // Appointments → Home
        3: 0, // Vaccines → Home
        4: 0, // Medications → Home
        5: 0, // Weight → Home
        8: 0, // Expenses → Home
      };
      return branchToMobile[branchIndex] ?? 0;
    } else {
      // Tablet/Desktop: mapeamento direto
      return branchIndex;
    }
  }

  /// Get navigation destinations for rail layout (tablet/desktop)
  List<NavigationRailDestination> _getNavigationRailDestinations() {
    return const [
      // Branch 0: Home
      NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Início'),
      ),
      // Branch 1: Animals
      NavigationRailDestination(
        icon: Icon(Icons.pets_outlined),
        selectedIcon: Icon(Icons.pets),
        label: Text('Pets'),
      ),
      // Branch 2: Appointments
      NavigationRailDestination(
        icon: Icon(Icons.event_outlined),
        selectedIcon: Icon(Icons.event),
        label: Text('Consultas'),
      ),
      // Branch 3: Vaccines
      NavigationRailDestination(
        icon: Icon(Icons.medical_services_outlined),
        selectedIcon: Icon(Icons.medical_services),
        label: Text('Vacinas'),
      ),
      // Branch 4: Medications
      NavigationRailDestination(
        icon: Icon(Icons.medication_outlined),
        selectedIcon: Icon(Icons.medication),
        label: Text('Medicamentos'),
      ),
      // Branch 5: Weight
      NavigationRailDestination(
        icon: Icon(Icons.monitor_weight_outlined),
        selectedIcon: Icon(Icons.monitor_weight),
        label: Text('Peso'),
      ),
      // Branch 6: Reminders
      NavigationRailDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: Text('Lembretes'),
      ),
      // Branch 7: Calculators
      NavigationRailDestination(
        icon: Icon(Icons.calculate_outlined),
        selectedIcon: Icon(Icons.calculate),
        label: Text('Cálculos'),
      ),
      // Branch 8: Expenses
      NavigationRailDestination(
        icon: Icon(Icons.attach_money_outlined),
        selectedIcon: Icon(Icons.attach_money),
        label: Text('Despesas'),
      ),
      // Branch 9: Settings
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
      // Mobile 0 → Branch 0: Home
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Início',
      ),
      // Mobile 1 → Branch 1: Animals
      NavigationDestination(
        icon: Icon(Icons.pets_outlined),
        selectedIcon: Icon(Icons.pets),
        label: 'Pets',
      ),
      // Mobile 2 → Branch 7: Calculators
      NavigationDestination(
        icon: Icon(Icons.calculate_outlined),
        selectedIcon: Icon(Icons.calculate),
        label: 'Cálculos',
      ),
      // Mobile 3 → Branch 6: Reminders
      NavigationDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: 'Lembretes',
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
        return 'Início';
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
        return selected ? Icons.home : Icons.home_outlined;
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
