import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/game_entity.dart';
import '../../domain/enums/game_category.dart';
import '../providers/home_providers.dart';
import '../widgets/game_card_featured.dart';
import '../widgets/games_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_sidebar.dart';

/// HomePage - Modern game portal design
/// Displays games in a portal-style layout with sidebar and sections
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final isTablet = screenWidth >= 800 && screenWidth < 1200;

    final filteredGames = ref.watch(filteredGamesProvider);
    final featuredGames = ref.watch(featuredGamesProvider);
    final newGames = ref.watch(newGamesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final hasActiveFilter =
        selectedCategory != GameCategory.all || searchQuery.isNotEmpty;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0F0F1A),
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xFF1A1A2E),
              child: HomeSidebar(
                isCollapsed: false,
                onToggleCollapse: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar (desktop/tablet)
          if (!isMobile)
            HomeSidebar(
              isCollapsed: isTablet ? _sidebarCollapsed : false,
              onToggleCollapse: isTablet
                  ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                  : null,
            ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                HomeHeader(
                  onMenuTap: isMobile
                      ? () => _scaffoldKey.currentState?.openDrawer()
                      : null,
                ),

                // Content
                Expanded(
                  child: _buildContent(
                    context,
                    hasActiveFilter: hasActiveFilter,
                    filteredGames: filteredGames,
                    featuredGames: featuredGames,
                    newGames: newGames,
                    selectedCategory: selectedCategory,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required bool hasActiveFilter,
    required List filteredGames,
    required List featuredGames,
    required List newGames,
    required GameCategory selectedCategory,
  }) {
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
                        child: _buildFilteredResults(
                          filteredGames.cast(),
                          selectedCategory,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Featured games carousel
                    if (featuredGames.isNotEmpty) ...[
                      _buildFeaturedSection(featuredGames.cast()),
                      const SizedBox(height: 32),
                    ],

                    // New games section
                    if (newGames.isNotEmpty) ...[
                      GamesSection(
                        title: 'Novos Jogos',
                        icon: Icons.fiber_new,
                        games: newGames.cast(),
                        isCompact: true,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // All games section
                    GamesSection(
                      title: 'Todos os Jogos',
                      icon: Icons.games,
                      games: filteredGames.cast(),
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

  Widget _buildFeaturedSection(List games) {
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
            final cardWidth = width < 600
                ? width
                : width < 900
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

  Widget _buildFilteredResults(List games, GameCategory category) {
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
            games: games.cast<GameEntity>(),
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
