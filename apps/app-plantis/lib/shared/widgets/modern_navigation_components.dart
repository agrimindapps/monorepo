import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../../core/theme/plantis_colors.dart';

/// Modern Navigation List Component
class ModernNavigationList extends StatelessWidget {
  final int currentIndex;
  final bool isExpanded;
  final Animation<double> expandAnimation;
  final Function(int) onDestinationSelected;

  const ModernNavigationList({
    super.key,
    required this.currentIndex,
    required this.isExpanded,
    required this.expandAnimation,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = _getNavigationItems();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Navigation Section
          if (isExpanded || expandAnimation.value > 0.5) ...[
            AnimatedBuilder(
              animation: expandAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: expandAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      'PRINCIPAIS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
          ],
          
          // Main Navigation Items
          Expanded(
            child: ListView.builder(
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final item = destinations[index];
                final isSelected = currentIndex == index;

                return ModernNavigationTile(
                  icon: item.icon,
                  selectedIcon: item.selectedIcon,
                  label: item.label,
                  description: item.description,
                  badge: item.badge,
                  isNew: item.isNew,
                  isSelected: isSelected,
                  isExpanded: isExpanded,
                  expandAnimation: expandAnimation,
                  onTap: () => onDestinationSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<NavigationItemData> _getNavigationItems() {
    return [
      const NavigationItemData(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: 'Visão Geral',
        description: 'Dashboard principal',
      ),
      const NavigationItemData(
        icon: Icons.checklist_rtl_outlined,
        selectedIcon: Icons.checklist_rtl_rounded,
        label: 'Tarefas',
        description: 'Cuidados pendentes',
        badge: 3,
      ),
      const NavigationItemData(
        icon: Icons.local_florist_outlined,
        selectedIcon: Icons.local_florist_rounded,
        label: 'Plantas',
        description: 'Gerenciar plantas',
      ),
      const NavigationItemData(
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded,
        label: 'Jardim',
        description: 'Visualizar jardim',
        isNew: true,
      ),
      const NavigationItemData(
        icon: Icons.smart_button_outlined,
        selectedIcon: Icons.smart_button_rounded,
        label: 'Automações',
        description: 'Irrigação e lembretes',
        isNew: true,
      ),
      const NavigationItemData(
        icon: Icons.workspace_premium_outlined,
        selectedIcon: Icons.workspace_premium_rounded,
        label: 'Premium',
        description: 'Recursos avançados',
      ),
      const NavigationItemData(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        label: 'Configurações',
        description: 'Ajustes do app',
      ),
    ];
  }
}

/// Navigation Item Data Model
class NavigationItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String description;
  final int? badge;
  final bool isNew;

  const NavigationItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.description,
    this.badge,
    this.isNew = false,
  });
}

/// Modern Navigation Tile Component
class ModernNavigationTile extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String description;
  final int? badge;
  final bool isNew;
  final bool isSelected;
  final bool isExpanded;
  final Animation<double> expandAnimation;
  final VoidCallback onTap;

  const ModernNavigationTile({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.isExpanded,
    required this.expandAnimation,
    required this.onTap,
    this.badge,
    this.isNew = false,
  });

  @override
  State<ModernNavigationTile> createState() => _ModernNavigationTileState();
}

class _ModernNavigationTileState extends State<ModernNavigationTile>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _tapController.reverse();
  }

  void _handleTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _tapAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _tapAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: MouseRegion(
              onEnter: (_) {
                setState(() => _isHovered = true);
                _hoverController.forward();
              },
              onExit: (_) {
                setState(() => _isHovered = false);
                _hoverController.reverse();
              },
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? PlantisColors.primary.withValues(alpha: 0.1)
                        : _isHovered
                            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: widget.isSelected
                        ? Border.all(
                            color: PlantisColors.primary.withValues(alpha: 0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Main Icon
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.isSelected
                                    ? PlantisColors.primary
                                    : _isHovered
                                        ? PlantisColors.primary.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  widget.isSelected ? widget.selectedIcon : widget.icon,
                                  key: ValueKey(widget.isSelected),
                                  color: widget.isSelected
                                      ? Colors.white
                                      : _isHovered
                                          ? PlantisColors.primary
                                          : colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                            ),
                            
                            // Badge
                            if (widget.badge != null && widget.badge! > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PlantisColors.flower,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: PlantisColors.flower.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    widget.badge.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            
                            // New Indicator
                            if (widget.isNew)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: PlantisColors.success,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: PlantisColors.success.withValues(alpha: 0.4),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Label and Description
                      AnimatedBuilder(
                        animation: widget.expandAnimation,
                        builder: (context, child) {
                          if (widget.expandAnimation.value < 0.1) {
                            return const SizedBox.shrink();
                          }
                          
                          return Expanded(
                            child: Opacity(
                              opacity: widget.expandAnimation.value,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4, right: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.label,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: widget.isSelected
                                            ? colorScheme.onSurface
                                            : colorScheme.onSurface.withValues(alpha: 0.9),
                                        fontWeight: widget.isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      widget.description,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: widget.isSelected
                                            ? PlantisColors.primary
                                            : colorScheme.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Selection Indicator
                      if (widget.isSelected)
                        Container(
                          width: 3,
                          height: 24,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: PlantisColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
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

/// Modern Sidebar Footer Component
class ModernSidebarFooter extends StatelessWidget {
  final bool isExpanded;
  final Animation<double> expandAnimation;

  const ModernSidebarFooter({
    super.key,
    required this.isExpanded,
    required this.expandAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: expandAnimation,
      builder: (context, child) {
        if (expandAnimation.value < 0.5) return const SizedBox.shrink();
        
        return Opacity(
          opacity: expandAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [PlantisColors.primary, PlantisColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PlantisColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Jardineiro',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'v1.0.0 • Inside Garden',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Settings Button
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      context.go('/settings');
                    },
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(32, 32),
                    ),
                    tooltip: 'Mais opções',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}