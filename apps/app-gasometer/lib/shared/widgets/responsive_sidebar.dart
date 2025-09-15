/// Modern minimalist sidebar navigation component inspired by Alphabank design
/// Provides clean, hierarchical navigation with proper spacing and typography
/// Features: Section grouping, minimalist design, enhanced readability
library responsive_sidebar;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/responsive_constants.dart';
import '../../core/theme/gasometer_colors.dart';

/// Main responsive sidebar widget with collapse/expand functionality
class ResponsiveSidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  
  const ResponsiveSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      width: isCollapsed 
          ? ResponsiveBreakpoints.collapsedSidebarWidth
          : ResponsiveBreakpoints.sidebarWidth,
      child: Material(
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _SidebarHeader(
                isCollapsed: isCollapsed,
                onToggle: onToggle,
              ),
              Expanded(
                child: _SidebarNavigationItems(
                  isCollapsed: isCollapsed,
                ),
              ),
              if (isCollapsed)
                // Expand button when collapsed
                Container(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    onPressed: onToggle,
                    icon: Icon(
                      Icons.menu,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    tooltip: 'Expandir menu',
                  ),
                )
              else
                _SidebarFooter(isCollapsed: isCollapsed),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal sidebar header following Alphabank design pattern
class _SidebarHeader extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  
  const _SidebarHeader({
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCollapsed ? 72 : 88,
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 16 : 24,
        vertical: 16,
      ),
      child: Row(
        children: [
          // Clean, minimal logo
          Container(
            width: isCollapsed ? 32 : 40,
            height: isCollapsed ? 32 : 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_gas_station,
              color: Theme.of(context).colorScheme.surface,
              size: isCollapsed ? 16 : 20,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'GasOMeter',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            IconButton(
              onPressed: onToggle,
              icon: Icon(
                Icons.menu_open,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
              tooltip: 'Contrair sidebar',
            ),
          ] else
            // Expandir button when collapsed
            const Spacer(),
        ],
      ),
    );
  }
}

/// Navigation section with clean hierarchy following Alphabank pattern  
class _SidebarNavigationItems extends StatelessWidget {
  final bool isCollapsed;
  
  const _SidebarNavigationItems({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : 16, 
        vertical: 8,
      ),
      children: [
        // Navigation section header (like Alphabank)
        if (!isCollapsed) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16, top: 8),
            child: Text(
              'Navigation',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        
        // Settings section - moved to top priority
        _SidebarNavigationItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Configurações',
          route: '/settings',
          isActive: currentLocation.startsWith('/settings'),
          isCollapsed: isCollapsed,
        ),
        
        const SizedBox(height: 32),
        
        // Main navigation items
        _SidebarNavigationItem(
          icon: Icons.directions_car_outlined,
          activeIcon: Icons.directions_car,
          label: 'Veículos',
          route: '/',
          isActive: currentLocation == '/' || currentLocation.startsWith('/vehicle'),
          isCollapsed: isCollapsed,
        ),
        const SizedBox(height: 4),
        _SidebarNavigationItem(
          icon: Icons.speed_outlined,
          activeIcon: Icons.speed,
          label: 'Odômetro', 
          route: '/odometer',
          isActive: currentLocation.startsWith('/odometer'),
          isCollapsed: isCollapsed,
        ),
        const SizedBox(height: 4),
        _SidebarNavigationItem(
          icon: Icons.local_gas_station_outlined,
          activeIcon: Icons.local_gas_station,
          label: 'Combustível',
          route: '/fuel',
          isActive: currentLocation.startsWith('/fuel'),
          isCollapsed: isCollapsed,
        ),
        const SizedBox(height: 4),
        _SidebarNavigationItem(
          icon: Icons.build_outlined,
          activeIcon: Icons.build,
          label: 'Manutenção',
          route: '/maintenance',
          isActive: currentLocation.startsWith('/maintenance'),
          isCollapsed: isCollapsed,
        ),
        const SizedBox(height: 4),
        _SidebarNavigationItem(
          icon: Icons.attach_money_outlined,
          activeIcon: Icons.attach_money,
          label: 'Despesas',
          route: '/expenses',
          isActive: currentLocation.startsWith('/expenses'),
          isCollapsed: isCollapsed,
        ),
        const SizedBox(height: 4),
        _SidebarNavigationItem(
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart,
          label: 'Relatórios',
          route: '/reports',
          isActive: currentLocation.startsWith('/reports'),
          isCollapsed: isCollapsed,
        ),
      ],
    );
  }
}

/// Clean navigation item following Alphabank minimalist design
class _SidebarNavigationItem extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;
  final bool isActive;
  final bool isCollapsed;
  
  const _SidebarNavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.isCollapsed,
  });

  @override
  State<_SidebarNavigationItem> createState() => _SidebarNavigationItemState();
}

class _SidebarNavigationItemState extends State<_SidebarNavigationItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go(widget.route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 12 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04)
                  : _isHovered
                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02)
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (widget.isCollapsed)
                  Expanded(
                    child: Center(
                      child: Icon(
                        widget.isActive && widget.activeIcon != null 
                            ? widget.activeIcon! 
                            : widget.icon,
                        size: 20,
                        color: widget.isActive
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withValues(
                                alpha: _isHovered ? 0.87 : 0.6,
                              ),
                      ),
                    ),
                  )
                else ...[
                  Icon(
                    widget.isActive && widget.activeIcon != null 
                        ? widget.activeIcon! 
                        : widget.icon,
                    size: 20,
                    color: widget.isActive
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: _isHovered ? 0.87 : 0.6,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: widget.isActive
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withValues(
                                alpha: _isHovered ? 0.87 : 0.7,
                              ),
                        fontWeight: widget.isActive ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple footer with minimal user information
class _SidebarFooter extends StatelessWidget {
  final bool isCollapsed;
  
  const _SidebarFooter({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Usuário',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _showUserMenu(context),
              icon: Icon(
                Icons.more_horiz,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                size: 20,
              ),
              tooltip: 'Menu do usuário',
            ),
          ],
        ],
      ),
    );
  }
  
  void _showUserMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(0, 0, 0, 80),
      items: [
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Configurações'),
            dense: true,
          ),
          onTap: () => context.go('/settings'),
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sair'),
            dense: true,
          ),
          onTap: () {
            // Handle logout
          },
        ),
      ],
    );
  }
}

