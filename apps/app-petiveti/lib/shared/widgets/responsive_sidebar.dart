/// Modern minimalist sidebar navigation component for PetiVeti
/// Provides clean, hierarchical navigation with proper spacing and typography
/// Features: Section grouping, minimalist design, enhanced readability
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/responsive_constants.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

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

/// Minimal sidebar header with PetiVeti branding
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
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.pets,
              color: Theme.of(context).colorScheme.onPrimary,
              size: isCollapsed ? 18 : 22,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'PetiVeti',
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
            const Spacer(),
        ],
      ),
    );
  }
}

/// Navigation section with clean hierarchy for PetiVeti features
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
        // Seção: Navegação Principal
        if (!isCollapsed) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16, top: 8),
            child: Text(
              'Navegação Principal',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ],
        _SidebarNavigationItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Início',
          route: '/',
          isActive: currentLocation == '/',
          isCollapsed: isCollapsed,
        ),
        const SizedBox(height: 4),
        _SidebarNavigationItem(
          icon: Icons.calculate_outlined,
          activeIcon: Icons.calculate,
          label: 'Cálculos',
          route: '/calculators',
          isActive: currentLocation.startsWith('/calculators'),
          isCollapsed: isCollapsed,
        ),

        // Seção: Gestão de Pets
        if (!isCollapsed) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16, top: 24),
            child: Text(
              'Gestão de Pets',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ],
        _SidebarNavigationItem(
          icon: Icons.pets_outlined,
          activeIcon: Icons.pets,
          label: 'Pets',
          route: '/animals',
          isActive: currentLocation.startsWith('/animals'),
          isCollapsed: isCollapsed,
        ),
        const SizedBox(height: 4),
        _SidebarNavigationItem(
          icon: Icons.event_outlined,
          activeIcon: Icons.event,
          label: 'Consultas',
          route: '/appointments',
          isActive: currentLocation.startsWith('/appointments'),
          isCollapsed: isCollapsed,
        ),
        const SizedBox(height: 4),
        _SidebarNavigationItem(
          icon: Icons.medical_services_outlined,
          activeIcon: Icons.medical_services,
          label: 'Vacinas',
          route: '/vaccines',
          isActive: currentLocation.startsWith('/vaccines'),
          isCollapsed: isCollapsed,
        ),
        const SizedBox(height: 4),
        _SidebarNavigationItem(
          icon: Icons.medication_outlined,
          activeIcon: Icons.medication,
          label: 'Medicamentos',
          route: '/medications',
          isActive: currentLocation.startsWith('/medications'),
          isCollapsed: isCollapsed,
        ),
        const SizedBox(height: 4),
        _SidebarNavigationItem(
          icon: Icons.monitor_weight_outlined,
          activeIcon: Icons.monitor_weight,
          label: 'Peso',
          route: '/weight',
          isActive: currentLocation.startsWith('/weight'),
          isCollapsed: isCollapsed,
        ),
        const SizedBox(height: 4),
        _SidebarNavigationItem(
          icon: Icons.notifications_outlined,
          activeIcon: Icons.notifications,
          label: 'Lembretes',
          route: '/reminders',
          isActive: currentLocation.startsWith('/reminders'),
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
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                  : _isHovered
                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04)
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
                                : Theme.of(context).colorScheme.onSurface.withValues(
                                      alpha: _isHovered ? 0.87 : 0.7,
                                    ),
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isCollapsed;

  @override
  State<_SidebarActionItem> createState() => _SidebarActionItemState();
}

class _SidebarActionItemState extends State<_SidebarActionItem> {
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
              color: _isHovered
                  ? Theme.of(context).colorScheme.error.withValues(alpha: 0.08)
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
                        color: Theme.of(context).colorScheme.error.withValues(
                              alpha: _isHovered ? 1 : 0.6,
                            ),
                      ),
                    ),
                  )
                else ...[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.error.withValues(
                          alpha: _isHovered ? 1 : 0.6,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error.withValues(
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

/// Footer with user settings and logout
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
          _SidebarNavigationItem(
            icon: Icons.person_outlined,
            activeIcon: Icons.person,
            label: 'Perfil',
            route: '/profile',
            isActive: currentLocation.startsWith('/profile') || currentLocation.startsWith('/account-profile'),
            isCollapsed: isCollapsed,
          ),
          const SizedBox(height: 12),
          _SidebarNavigationItem(
            icon: Icons.workspace_premium_outlined,
            activeIcon: Icons.workspace_premium,
            label: 'Premium',
            route: '/subscription',
            isActive: currentLocation.startsWith('/subscription'),
            isCollapsed: isCollapsed,
          ),
          const SizedBox(height: 12),
          _SidebarNavigationItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Configurações',
            route: '/settings',
            isActive: currentLocation.startsWith('/settings') || currentLocation.startsWith('/notifications-settings'),
            isCollapsed: isCollapsed,
          ),
          const SizedBox(height: 12),
          _SidebarActionItem(
            icon: Icons.logout,
            label: 'Sair',
            isCollapsed: isCollapsed,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Sair da Conta',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja sair da sua conta?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogoutInfoItem(
                    context,
                    icon: Icons.cleaning_services,
                    text: 'Seus dados locais serão removidos',
                  ),
                  const SizedBox(height: 8),
                  _buildLogoutInfoItem(
                    context,
                    icon: Icons.sync_disabled,
                    text: 'Sincronização será interrompida',
                  ),
                  const SizedBox(height: 8),
                  _buildLogoutInfoItem(
                    context,
                    icon: Icons.login,
                    text: 'Você poderá fazer login novamente',
                    isPositive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) async {
    try {
      await ref.read(authProvider.notifier).signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Logout realizado com sucesso'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

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
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
