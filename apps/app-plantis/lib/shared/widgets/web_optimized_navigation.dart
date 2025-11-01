import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/providers/auth_providers.dart';
import '../../core/services/data_sanitization_service.dart';
import '../../core/theme/plantis_colors.dart';
import 'main_scaffold.dart';

/// Shell layout web otimizado com sidebar moderna para desktop
/// Mantém navegação mobile atual para telas < 1200px
class WebOptimizedNavigationShell extends StatelessWidget {
  final Widget child;

  const WebOptimizedNavigationShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldShowSidebar = constraints.maxWidth >= 1200;

        if (shouldShowSidebar) {
          return _DesktopLayout(child: child);
        } else {
          return MainScaffold(child: child);
        }
      },
    );
  }
}

/// Layout desktop com sidebar fixa
class _DesktopLayout extends StatelessWidget {
  final Widget child;

  const _DesktopLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlantisColors.getPageBackgroundColor(context),
      body: Row(
        children: [
          const ModernSidebar(),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: PlantisColors.getPageBackgroundColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sidebar moderna para desktop
class ModernSidebar extends StatefulWidget {
  const ModernSidebar({super.key});

  @override
  State<ModernSidebar> createState() => _ModernSidebarState();
}

class _ModernSidebarState extends State<ModernSidebar>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _widthAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _widthAnimation;

  bool _isExpanded = true;
  static const double _expandedWidth = 280.0;
  static const double _collapsedWidth = 80.0;

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _widthAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(
      begin: _expandedWidth,
      end: _expandedWidth,
    ).animate(
      CurvedAnimation(
        parent: _widthAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimationController.forward();
    _widthAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _widthAnimationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    _widthAnimation = Tween<double>(
      begin: _isExpanded ? _collapsedWidth : _expandedWidth,
      end: _isExpanded ? _expandedWidth : _collapsedWidth,
    ).animate(
      CurvedAnimation(
        parent: _widthAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _widthAnimationController.reset();
    _widthAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _widthAnimation,
        builder: (context, child) {
          return Container(
            width: _widthAnimation.value,
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.dark
                      ? Colors.grey.shade900.withValues(alpha: 0.95)
                      : Colors.grey.shade50,
              border: Border(
                right: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _SidebarHeader(isExpanded: _isExpanded),
                Expanded(child: _NavigationList(isExpanded: _isExpanded)),
                _BottomNavigationSection(isExpanded: _isExpanded),
                _SidebarFooter(
                  isExpanded: _isExpanded,
                  onToggle: _toggleSidebar,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Header da sidebar com branding e toggle
class _SidebarHeader extends StatelessWidget {
  final bool isExpanded;

  const _SidebarHeader({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 24),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [PlantisColors.primary, PlantisColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: PlantisColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 22),
          ),

          if (isExpanded) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inside Garden',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'Cuidado de Plantas',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Lista de navegação principal
class _NavigationList extends StatelessWidget {
  final bool isExpanded;

  const _NavigationList({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Text(
                'PRINCIPAIS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              const pendingTasksCount = 0;

              return Column(
                children: [
                  _NavigationItem(
                    icon: Icons.check_circle_outline,
                    label: 'Tarefas',
                    route: '/tasks',
                    badge: pendingTasksCount > 0 ? pendingTasksCount : null,
                    shortcut: '1',
                    isExpanded: isExpanded,
                  ),
                  _NavigationItem(
                    icon: Icons.eco_outlined,
                    label: 'Plantas',
                    route: '/plants',
                    shortcut: '2',
                    isExpanded: isExpanded,
                  ),
                  _NavigationItem(
                    icon: Icons.person_outline,
                    label: 'Perfil',
                    route: '/account-profile',
                    shortcut: '3',
                    isExpanded: isExpanded,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Seção de navegação bottom (Configurações)
class _BottomNavigationSection extends StatelessWidget {
  final bool isExpanded;

  const _BottomNavigationSection({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _NavigationItem(
            icon: Icons.settings_outlined,
            label: 'Configurações',
            route: '/settings',
            shortcut: '4',
            isExpanded: isExpanded,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Item individual de navegação
class _NavigationItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final int? badge;
  final String? shortcut;
  final bool isExpanded;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
    this.shortcut,
    required this.isExpanded,
  });

  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool get _isActive {
    final currentRoute =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    if (widget.route == '/') {
      return currentRoute == '/';
    }
    if (currentRoute == widget.route) {
      return true;
    }

    if (currentRoute.startsWith(widget.route)) {
      final nextChar =
          currentRoute.length > widget.route.length
              ? currentRoute[widget.route.length]
              : '';
      return nextChar == '/' || nextChar == '?' || nextChar == '#';
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _isActive;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              child: GestureDetector(
                onTapDown: (_) {
                  _scaleController.forward();
                },
                onTapUp: (_) {
                  _scaleController.reverse();
                },
                onTapCancel: () {
                  _scaleController.reverse();
                },
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go(widget.route);
                },
                child: Tooltip(
                  message: widget.isExpanded ? '' : widget.label,
                  waitDuration: const Duration(milliseconds: 500),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          widget.isExpanded
                              ? 16
                              : 0, // Sem padding horizontal quando colapsado
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isActive
                              ? PlantisColors.primary.withValues(alpha: 0.1)
                              : _isHovering
                              ? theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          isActive
                              ? Border.all(
                                color: PlantisColors.primary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              )
                              : null,
                    ),
                    child:
                        widget.isExpanded
                            ? _buildExpandedContent(theme, isActive)
                            : _buildCollapsedContent(theme, isActive),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Conteúdo quando sidebar está expandida
  Widget _buildExpandedContent(ThemeData theme, bool isActive) {
    return Row(
      children: [
        Icon(
          widget.icon,
          size: 20,
          color:
              isActive
                  ? PlantisColors.primary
                  : theme.colorScheme.onSurfaceVariant,
        ),

        const SizedBox(width: 16),
        Expanded(
          child: Text(
            widget.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color:
                  isActive
                      ? PlantisColors.primary
                      : theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (widget.badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PlantisColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.badge.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
        if (widget.shortcut != null && _isHovering) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.dividerColor, width: 0.5),
            ),
            child: Text(
              widget.shortcut!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Conteúdo quando sidebar está colapsada
  Widget _buildCollapsedContent(ThemeData theme, bool isActive) {
    return Stack(
      children: [
        Center(
          child: Icon(
            widget.icon,
            size: 22,
            color:
                isActive
                    ? PlantisColors.primary
                    : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (widget.badge != null)
          Positioned(
            top: -2,
            right: 8, // Ajustado para melhor alinhamento quando centralizado
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: PlantisColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 1.5,
                ),
              ),
              child: Text(
                widget.badge! > 99 ? '99+' : widget.badge.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Footer da sidebar com informações do usuário
class _SidebarFooter extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _SidebarFooter({required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isExpanded ? 20 : 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final authState = ref.watch(authProvider);

              // Get user data from auth state
              final displayName = authState.whenData((auth) {
                return DataSanitizationService.sanitizeDisplayName(
                  auth.currentUser,
                  auth.isAnonymous,
                );
              }).value ?? 'Usuário Anônimo';

              final statusText = authState.whenData((auth) {
                return auth.isAnonymous ? 'Modo Offline' : 'Online';
              }).value ?? 'Carregando...';

              Widget footerContent;
              if (!isExpanded) {
                footerContent = Tooltip(
                  message: displayName,
                  waitDuration: const Duration(milliseconds: 500),
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                PlantisColors.primary,
                                PlantisColors.primaryLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: PlantisColors.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                footerContent = Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            PlantisColors.primary,
                            PlantisColors.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: PlantisColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            statusText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                );
              }

              // Wrap with clickable interaction
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Future.microtask(() {
                      if (context.mounted) {
                        context.go('/account-profile');
                      }
                    });
                  },
                  child: footerContent,
                ),
              );
            },
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (isExpanded) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inside Garden',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'v1.0.0',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              _ToggleButton(isExpanded: isExpanded, onToggle: onToggle),
            ],
          ),
        ),
      ],
    );
  }
}

/// Botão de toggle com estados hover mais visíveis
class _ToggleButton extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ToggleButton({required this.isExpanded, required this.onToggle});

  @override
  State<_ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<_ToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? PlantisColors.primary.withValues(alpha: 0.2)
                    : PlantisColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  _isHovered
                      ? PlantisColors.primary.withValues(alpha: 0.5)
                      : PlantisColors.primary.withValues(alpha: 0.3),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow:
                _isHovered
                    ? [
                      BoxShadow(
                        color: PlantisColors.primary.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: AnimatedRotation(
            turns: widget.isExpanded ? 0.0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.chevron_left,
              size: 18,
              color:
                  _isHovered
                      ? PlantisColors.primary
                      : PlantisColors.primary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
