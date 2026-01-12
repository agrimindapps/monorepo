import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/user_preferences_providers.dart';
import '../../domain/entities/game_entity.dart';

/// Modern game card with gradient and visual effects
class GameCard extends ConsumerStatefulWidget {
  final GameEntity game;
  final bool isCompact;

  const GameCard({super.key, required this.game, this.isCompact = false});

  @override
  ConsumerState<GameCard> createState() => _GameCardState();
}

class _GameCardState extends ConsumerState<GameCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go(game.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          transformAlignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: game.primaryColor.withValues(
                    alpha: _isHovered ? 0.5 : 0.3,
                  ),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Background gradient or Image
                  if (game.assetPath != null)
                    Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(game.assetPath!, fit: BoxFit.cover),
                        // Dark overlay for readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    // Background gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [game.primaryColor, game.secondaryColor],
                        ),
                      ),
                    ),
                    // Pattern overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PatternPainter(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ],

                  // Content
                  Padding(
                    padding: EdgeInsets.all(widget.isCompact ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges row
                        Row(
                          children: [
                            if (game.isNew)
                              const _Badge(text: 'NOVO', color: Colors.green),
                            if (game.playerCount > 1) ...[
                              if (game.isNew) const SizedBox(width: 6),
                              _Badge(
                                icon: Icons.people,
                                text: '${game.playerCount}',
                                color: Colors.blue,
                              ),
                            ],
                            const Spacer(),
                            // Favorite button
                            _FavoriteButton(
                              gameId: game.id,
                              isCompact: widget.isCompact,
                            ),
                            const SizedBox(width: 6),
                            // Category emoji
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                game.category.emoji,
                                style: TextStyle(
                                  fontSize: widget.isCompact ? 14 : 18,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Icon
                        if (game.assetPath == null)
                          Center(
                            child: Hero(
                              tag: 'game_icon_${game.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      widget.isCompact ? 16 : 24,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      game.icon,
                                      size: widget.isCompact ? 40 : 56,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const Spacer(),

                        // Title and description
                        Text(
                          game.name,
                          style: TextStyle(
                            fontSize: widget.isCompact ? 14 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!widget.isCompact) ...[
                          const SizedBox(height: 4),
                          Text(
                            game.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Hover glow effect
                  if (_isHovered)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;

  const _Badge({required this.text, this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 20.0;
    for (var i = 0.0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Favorite button widget
class _FavoriteButton extends ConsumerWidget {
  final String gameId;
  final bool isCompact;

  const _FavoriteButton({
    required this.gameId,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteGamesAsync = ref.watch(favoriteGamesProvider);
    final isFavorite = favoriteGamesAsync.value?.contains(gameId) ?? false;

    return GestureDetector(
      onTap: () {
        ref.read(favoriteGamesProvider.notifier).toggle(gameId);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isFavorite
                  ? Colors.pink.withValues(alpha: 0.3)
                  : Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: isCompact ? 14 : 16,
              color: isFavorite ? Colors.pink : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
