/// Responsive sidebar navigation component
/// Provides collapsible sidebar for desktop layouts with smooth animations
/// Integrates with app navigation and maintains current route state
library responsive_sidebar;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/responsive_constants.dart';

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
        elevation: 8,
        shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.1),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
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
              _SidebarFooter(isCollapsed: isCollapsed),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sidebar header with app logo and collapse toggle
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
      height: 80,
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 16 : 24,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_gas_station,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'GasOMeter',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Controle de Veículos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            onPressed: onToggle,
            icon: AnimatedRotation(
              turns: isCollapsed ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            tooltip: isCollapsed ? 'Expandir sidebar' : 'Contrair sidebar',
          ),
        ],
      ),
    );
  }
}

/// Navigation items list in sidebar
class _SidebarNavigationItems extends StatelessWidget {
  final bool isCollapsed;
  
  const _SidebarNavigationItems({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _SidebarNavigationItem(
          icon: Icons.directions_car,
          label: 'Veículos',
          route: '/',
          isActive: currentLocation == '/' || currentLocation.startsWith('/vehicle'),
          isCollapsed: isCollapsed,
        ),
        _SidebarNavigationItem(
          icon: Icons.speed,
          label: 'Odômetro', 
          route: '/odometer',
          isActive: currentLocation.startsWith('/odometer'),
          isCollapsed: isCollapsed,
        ),
        _SidebarNavigationItem(
          icon: Icons.local_gas_station,
          label: 'Combustível',
          route: '/fuel',
          isActive: currentLocation.startsWith('/fuel'),
          isCollapsed: isCollapsed,
        ),
        _SidebarNavigationItem(
          icon: Icons.build,
          label: 'Manutenção',
          route: '/maintenance',
          isActive: currentLocation.startsWith('/maintenance'),
          isCollapsed: isCollapsed,
        ),
        _SidebarNavigationItem(
          icon: Icons.bar_chart,
          label: 'Relatórios',
          route: '/reports',
          isActive: currentLocation.startsWith('/reports'),
          isCollapsed: isCollapsed,
        ),
        const _SidebarDivider(),
        _SidebarNavigationItem(
          icon: Icons.settings,
          label: 'Configurações',
          route: '/settings',
          isActive: currentLocation.startsWith('/settings'),
          isCollapsed: isCollapsed,
        ),
        _SidebarNavigationItem(
          icon: Icons.person,
          label: 'Perfil',
          route: '/profile',
          isActive: currentLocation.startsWith('/profile'),
          isCollapsed: isCollapsed,
        ),
      ],
    );
  }
}

/// Individual navigation item in sidebar
class _SidebarNavigationItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final bool isCollapsed;
  
  const _SidebarNavigationItem({
    required this.icon,
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 8 : 12,
        vertical: 2,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : _isHovered
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.isActive
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.go(widget.route),
              child: Container(
                height: 48,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isCollapsed ? 0 : 16,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: widget.isCollapsed ? double.infinity : 24,
                      child: Icon(
                        widget.icon,
                        size: 24,
                        color: widget.isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    if (!widget.isCollapsed) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: widget.isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Visual divider for sidebar sections
class _SidebarDivider extends StatelessWidget {
  const _SidebarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      height: 1,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      ),
    );
  }
}

/// Footer with user info and secondary actions
class _SidebarFooter extends StatelessWidget {
  final bool isCollapsed;
  
  const _SidebarFooter({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCollapsed ? 8 : 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: isCollapsed 
          ? IconButton(
              onPressed: () => _showUserMenu(context),
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    size: 22,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Usuário',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Conta ativa',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showUserMenu(context),
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  tooltip: 'Menu do usuário',
                ),
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
            leading: Icon(Icons.person),
            title: Text('Perfil'),
            dense: true,
          ),
          onTap: () => context.go('/profile'),
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