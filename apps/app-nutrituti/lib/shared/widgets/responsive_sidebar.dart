/// Modern minimalist sidebar navigation component for NutriTuti
/// Provides clean, hierarchical navigation with proper spacing and typography
/// Features: Section grouping, minimalist design, enhanced readability
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../core/constants/responsive_constants.dart';

/// Navigation item data model
class NavigationItemData {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String routeName;

  const NavigationItemData({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.routeName,
  });
}

/// Main responsive sidebar widget with collapse/expand functionality
class ResponsiveSidebar extends ConsumerWidget {
  const ResponsiveSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    required this.selectedRoute,
    required this.onNavigate,
    required this.onExit,
  });

  final bool isCollapsed;
  final VoidCallback onToggle;
  final String selectedRoute;
  final Function(String routeName) onNavigate;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      width: isCollapsed
          ? ResponsiveBreakpoints.collapsedSidebarWidth
          : ResponsiveBreakpoints.sidebarWidth,
      child: Material(
        elevation: 0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color:
                    Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
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
                  selectedRoute: selectedRoute,
                  onNavigate: onNavigate,
                ),
              ),
              if (isCollapsed)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    onPressed: onToggle,
                    icon: Icon(
                      Icons.menu,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      size: 20,
                    ),
                    tooltip: 'Expandir menu',
                  ),
                )
              else
                _SidebarFooter(
                  isCollapsed: isCollapsed,
                  onExit: onExit,
                  selectedRoute: selectedRoute,
                  onNavigate: onNavigate,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal sidebar header following Alphabank design pattern
class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.isCollapsed,
    required this.onToggle,
  });

  final bool isCollapsed;
  final VoidCallback onToggle;

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
          Container(
            width: isCollapsed ? 32 : 40,
            height: isCollapsed ? 32 : 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400,
                  Colors.teal.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.health_and_safety,
              color: Colors.white,
              size: isCollapsed ? 16 : 20,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'NutriTuti',
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
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
              tooltip: 'Contrair sidebar',
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}

/// Navigation section with clean hierarchy
class _SidebarNavigationItems extends StatelessWidget {
  const _SidebarNavigationItems({
    required this.isCollapsed,
    required this.selectedRoute,
    required this.onNavigate,
  });

  final bool isCollapsed;
  final String selectedRoute;
  final Function(String routeName) onNavigate;

  static const List<NavigationItemData> _mainItems = [
    NavigationItemData(
      icon: FontAwesome.glass_water_solid,
      label: 'Água',
      routeName: '/beber_agua',
    ),
    NavigationItemData(
      icon: FontAwesome.calculator_solid,
      label: 'Cálculos',
      routeName: '/calculos',
    ),
    NavigationItemData(
      icon: FontAwesome.dumbbell_solid,
      label: 'Exercícios',
      routeName: '/exercicios',
    ),
    NavigationItemData(
      icon: FontAwesome.spa_solid,
      label: 'Meditação',
      routeName: '/meditacao',
    ),
    NavigationItemData(
      icon: FontAwesome.weight_scale_solid,
      label: 'Peso',
      routeName: '/peso',
    ),
    NavigationItemData(
      icon: FontAwesome.utensils_solid,
      label: 'Pratos',
      routeName: '/pratos',
    ),
    NavigationItemData(
      icon: FontAwesome.bowl_food_solid,
      label: 'Receitas',
      routeName: '/receitas',
    ),
    NavigationItemData(
      icon: FontAwesome.apple_whole_solid,
      label: 'Alimentos',
      routeName: '/alimentos',
    ),
    NavigationItemData(
      icon: FontAwesome.headphones_simple_solid,
      label: 'ASMR',
      routeName: '/asmr',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : 16,
        vertical: 8,
      ),
      children: [
        if (!isCollapsed) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16, top: 8),
            child: Text(
              'Ferramentas',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ],
        ..._mainItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _SidebarNavigationItem(
              icon: item.icon,
              activeIcon: item.activeIcon,
              label: item.label,
              route: item.routeName,
              isActive: selectedRoute == item.routeName,
              isCollapsed: isCollapsed,
              onTap: () => onNavigate(item.routeName),
            ),
          ),
        ),
      ],
    );
  }
}

/// Clean navigation item following minimalist design
class _SidebarNavigationItem extends StatefulWidget {
  const _SidebarNavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

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
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 12 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : _isHovered
                      ? Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.02)
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
                            ? Theme.of(context).colorScheme.primary
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
                        ? Theme.of(context).colorScheme.primary
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
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(
                                      alpha: _isHovered ? 0.87 : 0.7,
                                    ),
                            fontWeight: widget.isActive
                                ? FontWeight.w500
                                : FontWeight.w400,
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

/// Action item for sidebar (logout, etc)
class _SidebarActionItem extends StatefulWidget {
  const _SidebarActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isCollapsed,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isCollapsed;
  final bool isDestructive;

  @override
  State<_SidebarActionItem> createState() => _SidebarActionItemState();
}

class _SidebarActionItemState extends State<_SidebarActionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final itemColor = widget.isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 12 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _isHovered
                  ? itemColor.withValues(alpha: 0.08)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (widget.isCollapsed)
                  Expanded(
                    child: Center(
                      child: Icon(
                        widget.icon,
                        size: 20,
                        color: itemColor.withValues(
                          alpha: _isHovered ? 1 : 0.6,
                        ),
                      ),
                    ),
                  )
                else ...[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: itemColor.withValues(
                      alpha: _isHovered ? 1 : 0.6,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: itemColor.withValues(
                              alpha: _isHovered ? 1 : 0.7,
                            ),
                            fontWeight: FontWeight.w400,
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

/// User and settings section grouped together
class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({
    required this.isCollapsed,
    required this.onExit,
    required this.selectedRoute,
    required this.onNavigate,
  });

  final bool isCollapsed;
  final VoidCallback onExit;
  final String selectedRoute;
  final Function(String routeName) onNavigate;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SidebarNavigationItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Configurações',
            route: '/config',
            isActive: selectedRoute == '/config',
            isCollapsed: isCollapsed,
            onTap: () => onNavigate('/config'),
          ),
          const SizedBox(height: 12),
          _SidebarActionItem(
            icon: Icons.exit_to_app,
            label: 'Sair do Módulo',
            isCollapsed: isCollapsed,
            isDestructive: true,
            onTap: onExit,
          ),
        ],
      ),
    );
  }
}
