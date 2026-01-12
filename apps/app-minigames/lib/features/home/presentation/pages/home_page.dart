import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_shell.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/enums/game_category.dart';
import '../providers/home_providers.dart';
import '../widgets/game_card_featured.dart';
import '../widgets/games_section.dart';
import '../widgets/home_search_bar.dart';

/// HomePage - Modern game portal design
/// Displays games in a portal-style layout with sidebar and sections
/// Now uses AppShell for unified layout structure
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredGames = ref.watch(filteredGamesProvider);
    final featuredGames = ref.watch(featuredGamesProvider);
    final newGames = ref.watch(newGamesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final hasActiveFilter =
        selectedCategory != GameCategory.all || searchQuery.isNotEmpty;

    return AppShell(
      searchWidget: const HomeSearchBar(),
      headerTrailing: _buildProfileAvatar(),
      collapsibleSidebar: true,
      child: _HomeContent(
        hasActiveFilter: hasActiveFilter,
        filteredGames: filteredGames.cast<GameEntity>(),
        featuredGames: featuredGames.cast<GameEntity>(),
        newGames: newGames.cast<GameEntity>(),
        selectedCategory: selectedCategory,
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white24,
          width: 2,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade400,
            Colors.blue.shade400,
          ],
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// Home content widget - contains the games grid and sections
class _HomeContent extends ConsumerWidget {
  final bool hasActiveFilter;
  final List<GameEntity> filteredGames;
  final List<GameEntity> featuredGames;
  final List<GameEntity> newGames;
  final GameCategory selectedCategory;

  const _HomeContent({
    required this.hasActiveFilter,
    required this.filteredGames,
    required this.featuredGames,
    required this.newGames,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = ScrollController();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1A),
      ),
      child: CustomPaint(
        painter: _BackgroundPatternPainter(),
        child: Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(
                const Color(0xFFFFD700).withValues(alpha: 0.3),
              ),
              trackColor: WidgetStateProperty.all(
                Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            thickness: 8,
            radius: const Radius.circular(4),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // If filtering, show filtered results
                  if (hasActiveFilter) ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: KeyedSubtree(
                        key: ValueKey('${selectedCategory.name}_${filteredGames.length}'),
                        child: _FilteredResults(
                          games: filteredGames,
                          category: selectedCategory,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Featured games carousel
                    if (featuredGames.isNotEmpty) ...[
                      _FeaturedSection(games: featuredGames),
                      const SizedBox(height: 32),
                    ],

                    // New games section
                    if (newGames.isNotEmpty) ...[
                      GamesSection(
                        title: 'Novos Jogos',
                        icon: Icons.fiber_new,
                        games: newGames,
                        isCompact: true,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // All games section
                    GamesSection(
                      title: 'Todos os Jogos',
                      icon: Icons.games,
                      games: filteredGames,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Featured games section
class _FeaturedSection extends StatelessWidget {
  final List<GameEntity> games;

  const _FeaturedSection({required this.games});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'DESTAQUES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            
            // On small screens, show cards vertically
            if (width < 600) {
              return Column(
                children: games.take(3).map((game) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GameCardFeatured(game: game),
                  );
                }).toList(),
              );
            }
            
            // On larger screens, show in grid
            final cardWidth = width < 900
                ? (width - 16) / 2
                : (width - 32) / 3;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: games.take(3).map((game) {
                return SizedBox(
                  width: cardWidth,
                  child: GameCardFeatured(game: game),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Filtered results section
class _FilteredResults extends ConsumerWidget {
  final List<GameEntity> games;
  final GameCategory category;

  const _FilteredResults({
    required this.games,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = category == GameCategory.all
        ? 'Resultados da Busca'
        : category.displayName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${games.length} jogos',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            if (category != GameCategory.all)
              TextButton.icon(
                onPressed: () {
                  ref
                      .read(selectedCategoryProvider.notifier)
                      .select(GameCategory.all);
                },
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Limpar filtro'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white54,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        if (games.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum jogo encontrado',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )
        else
          GamesSection(
            title: '',
            games: games,
          ),
      ],
    );
  }
}

/// Background pattern painter for game portal aesthetic
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw game-related icons pattern
    const spacing = 60.0;
    final icons = ['♠', '♥', '♦', '♣', '★', '●', '▲', '■'];
    var iconIndex = 0;

    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: icons[iconIndex % icons.length],
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.03),
              fontSize: 20,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
        iconIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
