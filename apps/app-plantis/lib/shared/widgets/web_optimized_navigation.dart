import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'responsive_layout.dart';

/// Navigation otimizada para web com sidebar desktop + bottom nav mobile
class WebOptimizedNavigation extends StatelessWidget {
  final Widget child;
  
  const WebOptimizedNavigation({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mobile: _MobileNavigation(child: child),
      desktop: _DesktopNavigation(child: child),
    );
  }
}

/// Navegação mobile com bottom navigation bar
class _MobileNavigation extends StatefulWidget {
  final Widget child;

  const _MobileNavigation({required this.child});

  @override
  State<_MobileNavigation> createState() => _MobileNavigationState();
}

class _MobileNavigationState extends State<_MobileNavigation> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/tasks')) return 0;
    if (location.startsWith('/plants')) return 1;
    if (location.startsWith('/settings')) return 2;

    return 0;
  }

  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        context.go('/tasks');
        break;
      case 1:
        context.go('/plants');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getCurrentIndex(context),
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.checklist),
            icon: Icon(Icons.checklist_outlined),
            label: 'Tarefas',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.eco),
            icon: Icon(Icons.eco_outlined),
            label: 'Plantas',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Conta',
          ),
        ],
      ),
    );
  }
}

/// Navegação desktop com sidebar
class _DesktopNavigation extends StatefulWidget {
  final Widget child;

  const _DesktopNavigation({required this.child});

  @override
  State<_DesktopNavigation> createState() => _DesktopNavigationState();
}

class _DesktopNavigationState extends State<_DesktopNavigation> {
  bool _isExpanded = true;

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/tasks')) return 0;
    if (location.startsWith('/plants')) return 1;
    if (location.startsWith('/settings')) return 2;

    return 0;
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go('/tasks');
        break;
      case 1:
        context.go('/plants');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _getCurrentIndex(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          // Enhanced Sidebar with modern design
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isExpanded ? 280 : 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface,
                  colorScheme.surface.withOpacity(0.95),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Logo/Header with enhanced styling
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: _isExpanded 
                              ? MainAxisAlignment.start 
                              : MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.eco,
                                color: colorScheme.onPrimary,
                                size: 24,
                              ),
                            ),
                            if (_isExpanded) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Plantis',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Toggle button with modern styling
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => setState(() => _isExpanded = !_isExpanded),
                          icon: AnimatedRotation(
                            turns: _isExpanded ? 0 : 0.5,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          tooltip: _isExpanded ? 'Recolher menu' : 'Expandir menu',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Navigation Items
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final destinations = [
                              _NavigationItem(
                                icon: Icons.checklist_rtl_rounded,
                                selectedIcon: Icons.checklist_rtl,
                                label: 'Tarefas',
                                description: 'Gerenciar tarefas',
                              ),
                              _NavigationItem(
                                icon: Icons.local_florist_outlined,
                                selectedIcon: Icons.local_florist,
                                label: 'Plantas', 
                                description: 'Cuidar das plantas',
                              ),
                              _NavigationItem(
                                icon: Icons.account_circle_outlined,
                                selectedIcon: Icons.account_circle,
                                label: 'Conta',
                                description: 'Configurações',
                              ),
                            ];
                            
                            final item = destinations[index];
                            final isSelected = currentIndex == index;
                            
                            return _ModernNavigationTile(
                              icon: item.icon,
                              selectedIcon: item.selectedIcon,
                              label: item.label,
                              description: item.description,
                              isSelected: isSelected,
                              isExpanded: _isExpanded,
                              onTap: () => _onDestinationSelected(index),
                            );
                          },
                          childCount: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Footer Section
                if (_isExpanded)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: colorScheme.primary,
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: colorScheme.onPrimary,
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
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Versão 1.0.0',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Enhanced divider
          Container(
            width: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.outline.withOpacity(0.1),
                  colorScheme.outline.withOpacity(0.3),
                  colorScheme.outline.withOpacity(0.1),
                ],
              ),
            ),
          ),
          // Main content
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

// Data class para itens de navegação
class _NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String description;

  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.description,
  });
}

// Widget customizado para tiles de navegação moderna
class _ModernNavigationTile extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String description;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ModernNavigationTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_ModernNavigationTile> createState() => _ModernNavigationTileState();
}

class _ModernNavigationTileState extends State<_ModernNavigationTile>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: MouseRegion(
              onEnter: (_) {
                setState(() => _isHovered = true);
                _hoverController.forward();
              },
              onExit: (_) {
                setState(() => _isHovered = false);
                _hoverController.reverse();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? colorScheme.primaryContainer.withOpacity(0.8)
                      : _isHovered
                          ? colorScheme.surfaceVariant.withOpacity(0.6)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: widget.isSelected
                      ? Border.all(
                          color: colorScheme.primary.withOpacity(0.3),
                          width: 1.5,
                        )
                      : null,
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Icon with enhanced styling
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.isSelected
                                  ? colorScheme.primary
                                  : _isHovered
                                      ? colorScheme.primary.withOpacity(0.1)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                widget.isSelected ? widget.selectedIcon : widget.icon,
                                key: ValueKey(widget.isSelected),
                                color: widget.isSelected
                                    ? colorScheme.onPrimary
                                    : _isHovered
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                            ),
                          ),
                          if (widget.isExpanded) ...[
                            const SizedBox(width: 16),
                            // Label and description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.label,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: widget.isSelected
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurface,
                                      fontWeight: widget.isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: widget.isSelected
                                          ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Selection indicator
                            if (widget.isSelected)
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
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
          ),
        );
      },
    );
  }
}

/// Extension para facilitar migração do MainScaffold
extension WebOptimizedNavigationExtension on Widget {
  /// Aplica navegação otimizada para web
  Widget withWebOptimizedNavigation() {
    return WebOptimizedNavigation(child: this);
  }
}