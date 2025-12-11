import 'package:core/core.dart' hide Column;
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
              decoration: const BoxDecoration(color: Color(0xFFE8ECEF)),
              child: ClipRRect(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: child,
                ),
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
  bool _showExpandedContent =
      true; // Controla quando mostrar conteúdo expandido
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
    _widthAnimation = Tween<double>(begin: _expandedWidth, end: _expandedWidth)
        .animate(
          CurvedAnimation(
            parent: _widthAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // Listener para controlar quando mostrar conteúdo expandido
    _widthAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showExpandedContent = _isExpanded;
        });
      }
    });

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
    // Se está expandindo, mostra conteúdo expandido imediatamente
    // Se está colapsando, esconde conteúdo expandido imediatamente para evitar overflow
    if (!_isExpanded) {
      // Vai expandir - mostra conteúdo após animação terminar (via listener)
    } else {
      // Vai colapsar - esconde conteúdo imediatamente
      setState(() {
        _showExpandedContent = false;
      });
    }

    setState(() {
      _isExpanded = !_isExpanded;
    });

    _widthAnimation =
        Tween<double>(
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
              color: theme.brightness == Brightness.dark
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
                _SidebarHeader(isExpanded: _showExpandedContent),
                Expanded(
                  child: _NavigationList(isExpanded: _showExpandedContent),
                ),
                _SidebarFooter(
                  isExpanded: _showExpandedContent,
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
      padding: EdgeInsets.fromLTRB(
        isExpanded ? 20 : 18,
        24,
        isExpanded ? 16 : 18,
        24,
      ),
      child: isExpanded
          ? Row(
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
            )
          : Center(
              child: Container(
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
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 8),
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
                    isExpanded: isExpanded,
                  ),
                  _NavigationItem(
                    icon: Icons.eco_outlined,
                    label: 'Plantas',
                    route: '/plants',
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

/// Botão de Configurações como ícone
class _SettingsIconButton extends StatefulWidget {
  const _SettingsIconButton();

  @override
  State<_SettingsIconButton> createState() => _SettingsIconButtonState();
}

class _SettingsIconButtonState extends State<_SettingsIconButton> {
  bool _isHovered = false;

  bool get _isActive {
    final currentRoute = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    return currentRoute.startsWith('/settings');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _isActive;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.go('/settings');
        },
        child: Tooltip(
          message: 'Configurações',
          waitDuration: const Duration(milliseconds: 500),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive
                  ? PlantisColors.primary
                  : _isHovered
                  ? PlantisColors.primary.withValues(alpha: 0.2)
                  : PlantisColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive
                    ? PlantisColors.primary
                    : _isHovered
                    ? PlantisColors.primary.withValues(alpha: 0.5)
                    : PlantisColors.primary.withValues(alpha: 0.3),
                width: _isHovered || isActive ? 1.5 : 1,
              ),
              boxShadow: _isHovered || isActive
                  ? [
                      BoxShadow(
                        color: PlantisColors.primary.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isActive ? Icons.settings : Icons.settings_outlined,
              size: 18,
              color: isActive
                  ? Colors.white
                  : _isHovered
                  ? PlantisColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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
  final bool isExpanded;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
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
    final currentRoute = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    if (widget.route == '/') {
      return currentRoute == '/';
    }
    if (currentRoute == widget.route) {
      return true;
    }

    if (currentRoute.startsWith(widget.route)) {
      final nextChar = currentRoute.length > widget.route.length
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
              cursor: SystemMouseCursors.click,
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
                      horizontal: widget.isExpanded ? 16 : 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? PlantisColors.primary
                          : _isHovering
                          ? theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: PlantisColors.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: widget.isExpanded
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
          color: isActive ? Colors.white : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            widget.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (widget.badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.2)
                  : PlantisColors.primary,
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
            color: isActive ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (widget.badge != null)
          Positioned(
            top: -2,
            right: 8, // Ajustado para melhor alinhamento quando centralizado
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : PlantisColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 1.5,
                ),
              ),
              child: Text(
                widget.badge! > 99 ? '99+' : widget.badge.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isActive ? PlantisColors.primary : Colors.white,
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
class _SidebarFooter extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _SidebarFooter({required this.isExpanded, required this.onToggle});

  @override
  State<_SidebarFooter> createState() => _SidebarFooterState();
}

class _SidebarFooterState extends State<_SidebarFooter> {
  bool _isUserHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isExpanded ? 20 : 16,
          ),
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final authState = ref.watch(authProvider);

              // Get user data from auth state
              final displayName =
                  authState.whenData((auth) {
                    return DataSanitizationService.sanitizeDisplayName(
                      auth.currentUser,
                      auth.isAnonymous,
                    );
                  }).value ??
                  'Usuário Anônimo';

              final statusText =
                  authState.whenData((auth) {
                    return auth.isAnonymous ? 'Modo Offline' : 'Online';
                  }).value ??
                  'Carregando...';

              Widget footerContent;
              if (!widget.isExpanded) {
                footerContent = Tooltip(
                  message: displayName,
                  waitDuration: const Duration(milliseconds: 500),
                  child: Center(
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
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
                                  alpha: _isUserHovered ? 0.5 : 0.3,
                                ),
                                blurRadius: _isUserHovered ? 12 : 8,
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
                footerContent = AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _isUserHovered
                        ? theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
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
                              color: PlantisColors.primary.withValues(
                                alpha: _isUserHovered ? 0.5 : 0.3,
                              ),
                              blurRadius: _isUserHovered ? 12 : 8,
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
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_isUserHovered)
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                );
              }

              // Wrap with clickable interaction and hover
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _isUserHovered = true),
                onExit: (_) => setState(() => _isUserHovered = false),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: widget.isExpanded
              ? Row(
                  children: [
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
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _SettingsIconButton(),
                    const SizedBox(width: 8),
                    _ToggleButton(
                      isExpanded: widget.isExpanded,
                      onToggle: widget.onToggle,
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _SettingsIconButton(),
                    const SizedBox(height: 8),
                    _ToggleButton(
                      isExpanded: widget.isExpanded,
                      onToggle: widget.onToggle,
                    ),
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
            color: _isHovered
                ? PlantisColors.primary.withValues(alpha: 0.2)
                : PlantisColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? PlantisColors.primary.withValues(alpha: 0.5)
                  : PlantisColors.primary.withValues(alpha: 0.3),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: _isHovered
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
              color: _isHovered
                  ? PlantisColors.primary
                  : PlantisColors.primary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
