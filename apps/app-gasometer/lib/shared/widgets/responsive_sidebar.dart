/// Modern minimalist sidebar navigation component inspired by Alphabank design
/// Provides clean, hierarchical navigation with proper spacing and typography
/// Features: Section grouping, minimalist design, enhanced readability
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/responsive_constants.dart';
import '../../core/theme/design_tokens.dart';
import '../../features/auth/presentation/notifiers/auth_notifier.dart';

/// Main responsive sidebar widget with collapse/expand functionality
class ResponsiveSidebar extends ConsumerWidget {
  
  const ResponsiveSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });
  final bool isCollapsed;
  final VoidCallback onToggle;

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
            color: Theme.of(context).colorScheme.surface, // Fundo branco para contraste
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
                _SidebarFooter(isCollapsed: isCollapsed, ref: ref),
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
  
  const _SidebarNavigationItems({required this.isCollapsed});
  final bool isCollapsed;

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
  
  const _SidebarNavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.isCollapsed,
  });
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;
  final bool isActive;
  final bool isCollapsed;

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

/// User and settings section grouped together
class _SidebarFooter extends StatelessWidget {

  const _SidebarFooter({required this.isCollapsed, required this.ref});
  final bool isCollapsed;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    
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
          // Settings section
          _SidebarNavigationItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Configurações',
            route: '/settings',
            isActive: currentLocation.startsWith('/settings'),
            isCollapsed: isCollapsed,
          ),
          
          const SizedBox(height: 12),
          
          // User section
          Row(
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
        ],
      ),
    );
  }
  
  void _showUserMenu(BuildContext context) {
    final authState = ref.read(authProvider);
    final isAnonymous = authState.isAnonymous;

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(0, 0, 0, 80),
      items: [
        PopupMenuItem<void>(
          child: const ListTile(
            leading: Icon(Icons.person_outlined),
            title: Text('Perfil'),
            dense: true,
          ),
          onTap: () {
            // Handle profile navigation
          },
        ),
        // Only show logout for non-anonymous users
        if (!isAnonymous)
          PopupMenuItem<void>(
            child: const ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sair'),
              dense: true,
            ),
            onTap: () {
              _handleLogout(context);
            },
          ),
      ],
    );
  }

  /// Handle logout with enhanced dialog
  Future<void> _handleLogout(BuildContext context) async {
    final authNotifier = ref.read(authProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildEnhancedLogoutDialog(context),
    );

    if (confirmed == true && context.mounted) {
      await authNotifier.logoutWithLoadingDialog(context);
      final authState = ref.read(authProvider);
      if (context.mounted && authState.errorMessage != null) {
        _showSnackBar(context, authState.errorMessage!);
      } else if (context.mounted) {
        _showSnackBar(context, 'Logout realizado com sucesso');
      }
    }
  }

  /// Builds an enhanced logout dialog with detailed information
  Widget _buildEnhancedLogoutDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout,
              size: 32,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Sair da Conta',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Detailed explanation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusSm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ao sair da sua conta:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildLogoutInfoItem(
                  context,
                  icon: Icons.delete_sweep,
                  text: 'Todos os dados serão removidos deste dispositivo',
                ),
                const SizedBox(height: 8),
                
                _buildLogoutInfoItem(
                  context,
                  icon: Icons.link_off,
                  text: 'O dispositivo será desconectado da sua conta',
                ),
                const SizedBox(height: 8),
                
                _buildLogoutInfoItem(
                  context,
                  icon: Icons.login,
                  text: 'Você pode fazer login novamente a qualquer momento',
                  isPositive: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Sair'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds individual info items for the logout dialog
  Widget _buildLogoutInfoItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    bool isPositive = false,
  }) {
    final color = isPositive 
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
        
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

