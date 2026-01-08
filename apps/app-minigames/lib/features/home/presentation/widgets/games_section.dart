import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../domain/entities/game_entity.dart';
import 'game_card.dart';

/// Section with title and responsive grid of games
class GamesSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<GameEntity> games;
  final VoidCallback? onSeeAll;
  final int crossAxisCount;
  final bool isCompact;

  const GamesSection({
    super.key,
    required this.title,
    this.icon,
    required this.games,
    this.onSeeAll,
    this.crossAxisCount = 4,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFFFD700),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onSeeAll != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onSeeAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VER MAIS',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Responsive Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            
            // Calculate column count based on width
            final columnCount = width < 600
                ? 2
                : width < 1000
                    ? 3
                    : width < 1400
                        ? 4
                        : crossAxisCount;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isCompact || width < 500 ? 1.0 : 0.85,
              ),
              itemCount: games.length,
              itemBuilder: (context, index) {
                return GameCard(
                  game: games[index],
                  isCompact: isCompact || width < 500,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
