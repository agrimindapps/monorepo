import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/game_category.dart';
import '../providers/home_providers.dart';

/// Sidebar with game categories and filters
class HomeSidebar extends ConsumerWidget {
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const HomeSidebar({
    super.key,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoryCounts = ref.watch(categoryCountsProvider);
    final newGamesCount = ref.watch(newGamesProvider).length;
    final multiplayerCount = ref.watch(multiplayerGamesProvider).length;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: isCollapsed ? 70 : 240,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.85),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
          // Header with logo
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.games,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Text(
                    'MiniGames',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Quick filters
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SectionHeader(
                  title: 'Filtros Rápidos',
                  isCollapsed: isCollapsed,
                ),
                _SidebarItem(
                  icon: Icons.star,
                  label: 'Novos jogos',
                  count: newGamesCount,
                  color: Colors.amber,
                  isSelected: false,
                  isCollapsed: isCollapsed,
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: Icons.people,
                  label: 'Multijogador',
                  count: multiplayerCount,
                  color: Colors.blue,
                  isSelected: false,
                  isCollapsed: isCollapsed,
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: Icons.shuffle,
                  label: 'Aleatório',
                  color: Colors.purple,
                  isSelected: false,
                  isCollapsed: isCollapsed,
                  onTap: () {},
                ),

                const SizedBox(height: 16),
                _SectionHeader(
                  title: 'Categorias',
                  isCollapsed: isCollapsed,
                ),

                // Categories
                ...GameCategory.values.map((category) {
                  return _SidebarItem(
                    icon: _getCategoryIcon(category),
                    label: category.displayName,
                    count: categoryCounts[category] ?? 0,
                    emoji: category.emoji,
                    isSelected: selectedCategory == category,
                    isCollapsed: isCollapsed,
                    onTap: () {
                      ref
                          .read(selectedCategoryProvider.notifier)
                          .select(category);
                    },
                  );
                }),
              ],
            ),
          ),

            // Collapse button
            if (onToggleCollapse != null)
              InkWell(
                onTap: onToggleCollapse,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    isCollapsed
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                    color: Colors.white54,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
  }

  IconData _getCategoryIcon(GameCategory category) {
    switch (category) {
      case GameCategory.all:
        return Icons.apps;
      case GameCategory.puzzle:
        return Icons.extension;
      case GameCategory.strategy:
        return Icons.psychology;
      case GameCategory.arcade:
        return Icons.sports_esports;
      case GameCategory.word:
        return Icons.text_fields;
      case GameCategory.quiz:
        return Icons.quiz;
      case GameCategory.classic:
        return Icons.star;
      case GameCategory.casual:
        return Icons.emoji_emotions;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isCollapsed;

  const _SectionHeader({
    required this.title,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      return const SizedBox(height: 8);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int? count;
  final String? emoji;
  final Color? color;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.count,
    this.emoji,
    this.color,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 12 : 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: widget.isSelected
                ? Border.all(
                    color: widget.color ?? const Color(0xFFFFD700),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Icon or emoji
              if (widget.emoji != null && !widget.isCollapsed)
                Text(
                  widget.emoji!,
                  style: const TextStyle(fontSize: 18),
                )
              else
                Icon(
                  widget.icon,
                  color: widget.color ?? Colors.white70,
                  size: 20,
                ),

              if (!widget.isCollapsed) ...[
                const SizedBox(width: 12),

                // Label
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight:
                          widget.isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),

                // Count badge
                if (widget.count != null && widget.count! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.color?.withValues(alpha: 0.2) ??
                          Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.count}',
                      style: TextStyle(
                        color: widget.color ?? Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
