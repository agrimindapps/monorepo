import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/calculator_registry.dart';
import '../../../../core/providers/user_preferences_providers.dart';
import '../../../../core/theme/adaptive_colors.dart';
import '../../../../core/widgets/app_shell.dart';

class HomePage extends ConsumerStatefulWidget {
  final String? initialCategory;
  final String? initialFilter;

  const HomePage({super.key, this.initialCategory, this.initialFilter});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  String _selectedFilter = '';

  @override
  void initState() {
    super.initState();
    // Set initial category from widget parameter if provided
    if (widget.initialCategory != null) {
      _selectedCategory = _mapCategoryParam(widget.initialCategory!);
    }
    // Set initial filter from widget parameter if provided
    if (widget.initialFilter != null) {
      _selectedFilter = _mapFilterParam(widget.initialFilter!);
      _selectedCategory = 'Todos'; // Reset category when filter is set
    }
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // React to route parameter changes
    if (oldWidget.initialCategory != widget.initialCategory) {
      setState(() {
        if (widget.initialCategory != null) {
          _selectedCategory = _mapCategoryParam(widget.initialCategory!);
          _selectedFilter = ''; // Clear filter when category changes
        } else {
          _selectedCategory = 'Todos';
        }
      });
    }
    
    if (oldWidget.initialFilter != widget.initialFilter) {
      setState(() {
        if (widget.initialFilter != null) {
          _selectedFilter = _mapFilterParam(widget.initialFilter!);
          _selectedCategory = 'Todos'; // Reset category when filter is set
        } else {
          _selectedFilter = '';
        }
      });
    }
  }

  // Map category parameter to display name
  String _mapCategoryParam(String param) {
    switch (param.toLowerCase()) {
      case 'financeiro':
        return 'Financeiro';
      case 'construcao':
      case 'construção':
        return 'Construção';
      case 'saude':
      case 'saúde':
        return 'Saúde';
      case 'pet':
        return 'Pet';
      case 'agricultura':
        return 'Agricultura';
      case 'pecuaria':
      case 'pecuária':
        return 'Pecuária';
      case 'todos':
      default:
        return 'Todos';
    }
  }

  // Map filter parameter to display name
  String _mapFilterParam(String param) {
    switch (param.toLowerCase()) {
      case 'favoritos':
        return 'Favoritos';
      case 'recentes':
        return 'Recentes';
      case 'popular':
        return 'Popular';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<CalculatorItem> _getFilteredCalculators(
    List<CalculatorItem> allCalculators,
    List<String> favorites,
    List<String> recents,
  ) {
    var items = <CalculatorItem>[];

    // Apply filter first
    if (_selectedFilter == 'Favoritos') {
      items = allCalculators.where((c) => favorites.contains(c.route)).toList();
    } else if (_selectedFilter == 'Recentes') {
      items = recents
          .map((route) => allCalculators.firstWhere(
                (c) => c.route == route,
                orElse: () => allCalculators.first,
              ))
          .toList();
    } else if (_selectedFilter == 'Popular') {
      items = allCalculators.where((c) => c.isPopular).toList();
    } else if (_selectedCategory != 'Todos') {
      // Filter by category
      switch (_selectedCategory) {
        case 'Financeiro':
          items = CalculatorRegistry.financial;
          break;
        case 'Construção':
          items = CalculatorRegistry.construction;
          break;
        case 'Saúde':
          items = CalculatorRegistry.health;
          break;
        case 'Pet':
          items = CalculatorRegistry.pet;
          break;
        case 'Agricultura':
          items = CalculatorRegistry.agriculture;
          break;
        case 'Pecuária':
          items = CalculatorRegistry.livestock;
          break;
        default:
          items = allCalculators;
      }
    } else {
      items = allCalculators;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.title.toLowerCase().contains(_searchQuery) ||
            item.description.toLowerCase().contains(_searchQuery) ||
            item.tags.any((t) => t.toLowerCase().contains(_searchQuery));
      }).toList();
    }

    return items;
  }

  /// Mapeia o filtro selecionado para o parâmetro de rota
  String? _getFilterParam() {
    switch (_selectedFilter) {
      case 'Favoritos':
        return 'favoritos';
      case 'Recentes':
        return 'recentes';
      case 'Popular':
        return 'popular';
      default:
        return null;
    }
  }

  /// Mapeia a categoria selecionada para o parâmetro de rota
  String? _getCategoryParam() {
    if (_selectedCategory == 'Todos') return null;
    return _selectedCategory.toLowerCase()
        .replaceAll('ú', 'u')
        .replaceAll('ã', 'a')
        .replaceAll('ç', 'c');
  }

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoriteCalculatorsProvider);
    final recentsAsync = ref.watch(recentCalculatorsProvider);

    final favorites = favoritesAsync.value ?? [];
    final recents = recentsAsync.value ?? [];

    // Use CalculatorRegistry as single source of truth
    const allCalculators = CalculatorRegistry.all;

    final filteredCalculators =
        _getFilteredCalculators(allCalculators, favorites, recents);

    return AppShell(
      // Home page - no title shows search bar
      searchController: _searchController,
      onSearchChanged: (value) {
        setState(() => _searchQuery = value.toLowerCase());
      },
      searchHint: 'O que vamos calcular hoje?',
      headerTrailing: _buildViewToggle(),
      currentCategory: _getCategoryParam(),
      currentFilter: _getFilterParam(),
      showBackgroundPattern: true,
      child: _buildMainContent(
        filteredCalculators,
        allCalculators,
        favorites,
      ),
    );
  }

  Widget _buildViewToggle() {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewToggleButton(
            Icons.grid_view,
            ref.watch(viewModeProvider).value == 'grid',
            () => ref.read(viewModeProvider.notifier).setMode('grid'),
          ),
          _buildViewToggleButton(
            Icons.view_list,
            ref.watch(viewModeProvider).value != 'grid',
            () => ref.read(viewModeProvider.notifier).setMode('list'),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? context.colors.primary : context.colors.textMuted,
        ),
      ),
    );
  }
  Widget _buildMainContent(
    List<CalculatorItem> filteredCalculators,
    List<CalculatorItem> allCalculators,
    List<String> favorites,
  ) {
    final viewMode = ref.watch(viewModeProvider).value;
    final isGridView = viewMode == 'grid';

    // Get section title
    var sectionTitle = 'TODAS AS CALCULADORAS';
    var sectionIcon = Icons.apps;
    var sectionColor = context.colors.primary;

    if (_selectedFilter == 'Favoritos') {
      sectionTitle = 'FAVORITOS';
      sectionIcon = Icons.favorite;
      sectionColor = Colors.red;
    } else if (_selectedFilter == 'Recentes') {
      sectionTitle = 'RECENTES';
      sectionIcon = Icons.history;
      sectionColor = Colors.purple;
    } else if (_selectedFilter == 'Popular') {
      sectionTitle = 'POPULARES';
      sectionIcon = Icons.star;
      sectionColor = Colors.amber;
    } else if (_selectedCategory != 'Todos') {
      sectionTitle = _selectedCategory.toUpperCase();
      switch (_selectedCategory) {
        case 'Financeiro':
          sectionIcon = Icons.account_balance_wallet;
          sectionColor = Colors.blue;
          break;
        case 'Construção':
          sectionIcon = Icons.construction;
          sectionColor = Colors.orange;
          break;
        case 'Saúde':
          sectionIcon = Icons.favorite_border;
          sectionColor = Colors.pink;
          break;
        case 'Pet':
          sectionIcon = Icons.pets;
          sectionColor = Colors.brown;
          break;
        case 'Agricultura':
          sectionIcon = Icons.grass;
          sectionColor = const Color(0xFF8BC34A);
          break;
        case 'Pecuária':
          sectionIcon = Icons.agriculture;
          sectionColor = const Color(0xFFFF5722);
          break;
      }
    }

    return Stack(
      children: [
        // Background pattern
        CustomPaint(
          painter: _HomeBackgroundPainter(symbolColor: context.colors.textPrimary.withValues(alpha: 0.015)),
          size: Size.infinite,
        ),

        // Content with max width constraint
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: sectionColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(sectionIcon, color: sectionColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          sectionTitle,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colors.textPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${filteredCalculators.length}',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Empty state
                if (filteredCalculators.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(),
                  ),

                // Grid/List content
                if (filteredCalculators.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                    sliver: isGridView
                        ? _buildGridView(filteredCalculators, favorites)
                        : _buildListView(filteredCalculators, favorites),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    var message = 'Nenhuma calculadora encontrada';
    var subtitle = 'Tente ajustar os filtros ou busca';
    var icon = Icons.search_off;

    if (_selectedFilter == 'Favoritos') {
      message = 'Nenhum favorito ainda';
      subtitle = 'Toque no ❤️ em qualquer calculadora';
      icon = Icons.favorite_border;
    } else if (_selectedFilter == 'Recentes') {
      message = 'Nenhuma calculadora recente';
      subtitle = 'Use uma calculadora para aparecer aqui';
      icon = Icons.history;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: context.colors.textDisabled,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                color: context.colors.textPrimary.withValues(alpha: 0.8),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: context.colors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<CalculatorItem> items, List<String> favorites) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final crossAxisCount = width < 500
            ? 2
            : width < 800
                ? 3
                : width < 1100
                    ? 4
                    : 5;

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              return _ModernCalculatorCard(
                item: item,
                isFavorite: favorites.contains(item.route),
              );
            },
            childCount: items.length,
          ),
        );
      },
    );
  }

  Widget _buildListView(List<CalculatorItem> items, List<String> favorites) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ModernCalculatorListTile(
              item: item,
              isFavorite: favorites.contains(item.route),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

// Background painter
class _HomeBackgroundPainter extends CustomPainter {
  final Color symbolColor;

  _HomeBackgroundPainter({required this.symbolColor});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 80.0;
    final symbols = ['+', '−', '×', '÷', '%', '=', '√', 'π'];
    var symbolIndex = 0;

    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        TextPainter(
          text: TextSpan(
            text: symbols[symbolIndex % symbols.length],
            style: TextStyle(
              color: symbolColor,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          textDirection: TextDirection.ltr,
        )
          ..layout()
          ..paint(canvas, Offset(x, y));
        symbolIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HomeBackgroundPainter oldDelegate) => 
      oldDelegate.symbolColor != symbolColor;
}

// Modern Calculator Card
class _ModernCalculatorCard extends ConsumerStatefulWidget {
  final CalculatorItem item;
  final bool isFavorite;

  const _ModernCalculatorCard({
    required this.item,
    required this.isFavorite,
  });

  @override
  ConsumerState<_ModernCalculatorCard> createState() =>
      _ModernCalculatorCardState();
}

class _ModernCalculatorCardState extends ConsumerState<_ModernCalculatorCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          ref.read(recentCalculatorsProvider.notifier).addRecent(widget.item.route);
          context.go(widget.item.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.item.color.withValues(alpha: _isHovering ? 0.3 : 0.2),
                widget.item.color.withValues(alpha: _isHovering ? 0.15 : 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovering
                  ? widget.item.color.withValues(alpha: 0.5)
                  : colors.border.withValues(alpha: 0.08),
              width: _isHovering ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with badges
                    Row(
                      children: [
                        if (widget.item.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'POPULAR',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const Spacer(),
                        // Favorite button
                        InkWell(
                          onTap: () {
                            ref
                                .read(favoriteCalculatorsProvider.notifier)
                                .toggle(widget.item.route);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: widget.isFavorite
                                  ? Colors.red
                                  : colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Center icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.textPrimary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.item.icon,
                          color: colors.textPrimary,
                          size: 32,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Title
                    Text(
                      widget.item.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      widget.item.description,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modern List Tile
class _ModernCalculatorListTile extends ConsumerWidget {
  final CalculatorItem item;
  final bool isFavorite;

  const _ModernCalculatorListTile({
    required this.item,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(recentCalculatorsProvider.notifier).addRecent(item.route);
        context.go(item.route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (item.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Popular',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: context.colors.textMuted,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {
                ref.read(favoriteCalculatorsProvider.notifier).toggle(item.route);
              },
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : context.colors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
