import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/user_preferences_providers.dart';
import '../../../../core/theme/theme_providers.dart';
import '../../../../shared/widgets/intro_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    // Show intro dialog on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      IntroDialog.showIfNeeded(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleViewMode() {
    ref.read(viewModeProvider.notifier).toggle();
  }

  bool _shouldShowSection(String sectionTitle, List<_CalculatorItem> items) {
    // Filter by category first
    if (_selectedCategory != 'Todos' && sectionTitle != _selectedCategory) {
      return false;
    }

    // Then filter by search
    if (_searchQuery.isEmpty) return true;
    if (sectionTitle.toLowerCase().contains(_searchQuery)) return true;
    return items.any((item) => item.title.toLowerCase().contains(_searchQuery));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(currentThemeModeProvider) == ThemeMode.dark;
    final favoritesAsync = ref.watch(favoriteCalculatorsProvider);
    final recentsAsync = ref.watch(recentCalculatorsProvider);

    final favorites = favoritesAsync.value ?? [];
    final recents = recentsAsync.value ?? [];

    // Build dynamic sections based on selected category
    final allCalculators = [
      ..._financialCalculators,
      ..._constructionCalculators
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverToBoxAdapter(
            child: _HeroSection(isDark: isDark),
          ),

          // Category Filter Bar
          SliverToBoxAdapter(
            child: _CategoryFilterBar(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          ),

          // Search Bar with suggestions
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              isDark: isDark,
              onToggleView: _toggleViewMode,
              isGridView: ref.watch(viewModeProvider).value == 'grid',
              allCalculators: allCalculators,
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Favoritos Section
                if (_selectedCategory == 'Favoritos') ...[
                  _buildSectionTitle(context, 'Favoritos'),
                  _buildGrid(
                    context,
                    allCalculators
                        .where((item) => favorites.contains(item.route))
                        .toList(),
                    sectionTitle: 'Favoritos',
                  ),
                  if (favorites.isEmpty)
                    _buildEmptyState('Nenhuma calculadora favoritada ainda',
                        Icons.favorite_border),
                ],

                // Recentes Section
                if (_selectedCategory == 'Recentes') ...[
                  _buildSectionTitle(context, 'Recentes'),
                  _buildGrid(
                    context,
                    recents.map((route) {
                      return allCalculators.firstWhere(
                        (item) => item.route == route,
                        orElse: () => allCalculators.first,
                      );
                    }).toList(),
                    sectionTitle: 'Recentes',
                  ),
                  if (recents.isEmpty)
                    _buildEmptyState('Nenhuma calculadora usada recentemente',
                        Icons.history),
                ],

                // Regular Sections
                if (_selectedCategory != 'Favoritos' &&
                    _selectedCategory != 'Recentes') ...[
                  if (_shouldShowSection('Financeiro', _financialCalculators))
                    _buildSectionTitle(context, 'Financeiro'),
                  if (_shouldShowSection('Financeiro', _financialCalculators))
                    _buildGrid(context, _financialCalculators,
                        sectionTitle: 'Financeiro'),
                  if (_searchQuery.isEmpty) const SizedBox(height: 32),
                  if (_shouldShowSection(
                      'Construção', _constructionCalculators))
                    _buildSectionTitle(context, 'Construção'),
                  if (_shouldShowSection(
                      'Construção', _constructionCalculators))
                    _buildGrid(context, _constructionCalculators,
                        sectionTitle: 'Construção'),
                ],
              ]),
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    Color color = Colors.grey;
    if (title == 'Financeiro') color = Colors.blue;
    if (title == 'Construção') color = Colors.deepOrange;
    if (title == 'Favoritos') color = Colors.red;
    if (title == 'Recentes') color = Colors.purple;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<_CalculatorItem> items,
      {String? sectionTitle}) {
    final filteredItems = items.where((item) {
      return _searchQuery.isEmpty ||
          (sectionTitle != null &&
              sectionTitle.toLowerCase().contains(_searchQuery)) ||
          item.title.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredItems.isEmpty) return const SizedBox.shrink();

    final viewModeAsync = ref.watch(viewModeProvider);
    final isGridView = viewModeAsync.value == 'grid';

    if (!isGridView) {
      // List view with stagger animation
      return Column(
        children: filteredItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CalculatorListTile(item: item),
            ),
          );
        }).toList(),
      );
    }

    // Grid view
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600
            ? 2
            : constraints.maxWidth < 900
                ? 3
                : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _CalculatorCard(item: filteredItems[index]),
            );
          },
        );
      },
    );
  }

  // Calculator Data
  final List<_CalculatorItem> _financialCalculators = [
    _CalculatorItem(
      title: '13º Salário',
      description: 'Calcule seu 13º salário líquido e bruto',
      icon: Icons.card_giftcard,
      color: Colors.green,
      route: '/calculators/financial/thirteenth-salary',
      tags: ['CLT', 'Trabalhista'],
      isPopular: true,
    ),
    _CalculatorItem(
      title: 'Férias',
      description: 'Descubra quanto você vai receber de férias',
      icon: Icons.beach_access,
      color: Colors.blue,
      route: '/calculators/financial/vacation',
      tags: ['CLT', 'Trabalhista'],
      isPopular: true,
    ),
    _CalculatorItem(
      title: 'Salário Líquido',
      description: 'Descubra seu salário após descontos',
      icon: Icons.monetization_on,
      color: Colors.orange,
      route: '/calculators/financial/net-salary',
      tags: ['CLT', 'INSS', 'IR'],
      isPopular: true,
    ),
    _CalculatorItem(
      title: 'Horas Extras',
      description: 'Calcule o valor das suas horas extras',
      icon: Icons.access_time,
      color: Colors.purple,
      route: '/calculators/financial/overtime',
      tags: ['CLT', 'Trabalhista'],
    ),
    _CalculatorItem(
      title: 'Reserva de Emergência',
      description: 'Planeje sua reserva financeira ideal',
      icon: Icons.savings,
      color: Colors.teal,
      route: '/calculators/financial/emergency-reserve',
      tags: ['Investimento', 'Planejamento'],
    ),
    _CalculatorItem(
      title: 'À vista ou Parcelado',
      description: 'Compare e decida a melhor forma de pagamento',
      icon: Icons.payment,
      color: Colors.indigo,
      route: '/calculators/financial/cash-vs-installment',
      tags: ['Compras', 'Juros'],
    ),
    _CalculatorItem(
      title: 'Seguro Desemprego',
      description: 'Calcule o valor do seu seguro desemprego',
      icon: Icons.work_off,
      color: Colors.red,
      route: '/calculators/financial/unemployment-insurance',
      tags: ['CLT', 'Trabalhista'],
    ),
  ];

  final List<_CalculatorItem> _constructionCalculators = [
    _CalculatorItem(
      title: 'Cálculos de Construção',
      description: 'Diversos cálculos para sua obra',
      icon: Icons.construction,
      color: Colors.deepOrange,
      route: '/calculators/construction/selection',
      tags: ['Materiais', 'Medidas'],
    ),
    // Add more construction calculators here as they are implemented/routed
  ];
}

class _CalculatorItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final List<String> tags;
  final bool isPopular;

  _CalculatorItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    this.tags = const [],
    this.isPopular = false,
  });
}

class _HeroSection extends StatelessWidget {
  final bool isDark;

  const _HeroSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.indigo.shade900, Colors.blue.shade900]
              : [Colors.blue.shade600, Colors.indigo.shade600],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bem-vindo ao Calculei',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '8+ calculadoras disponíveis',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _CategoryFilterBar({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Todos', Icons.apps, null),
      ('Favoritos', Icons.favorite, Colors.red),
      ('Recentes', Icons.history, Colors.purple),
      ('Financeiro', Icons.account_balance_wallet, Colors.blue),
      ('Construção', Icons.construction, Colors.deepOrange),
    ];

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final (name, icon, color) = categories[index];
          final isSelected = selectedCategory == name;

          return _CategoryChip(
            label: name,
            icon: icon,
            color: color,
            isSelected: isSelected,
            onTap: () => onCategorySelected(name),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withOpacity(0.15)
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? chipColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? chipColor : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? chipColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final VoidCallback onToggleView;
  final bool isGridView;
  final List<_CalculatorItem> allCalculators;

  _SearchBarDelegate({
    required this.controller,
    required this.onChanged,
    required this.isDark,
    required this.onToggleView,
    required this.isGridView,
    required this.allCalculators,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Buscar calculadora...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onToggleView,
            icon: Icon(
              isGridView ? Icons.view_list : Icons.grid_view,
              color: isDark ? Colors.white : Colors.black87,
            ),
            tooltip:
                isGridView ? 'Visualização em lista' : 'Visualização em grade',
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.isGridView != isGridView;
  }
}

// List Tile version of Calculator Card
class _CalculatorListTile extends ConsumerWidget {
  final _CalculatorItem item;

  const _CalculatorListTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favoritesAsync = ref.watch(favoriteCalculatorsProvider);
    final favorites = favoritesAsync.value ?? [];
    final isFavorite = favorites.contains(item.route);

    return InkWell(
      onTap: () {
        ref.read(recentCalculatorsProvider.notifier).addRecent(item.route);
        context.go(item.route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                size: 32,
                color: item.color,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            color: item.isPopular
                                ? Colors.red.withOpacity(0.1)
                                : Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.isPopular ? 'Popular' : 'Novo',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item.isPopular
                                  ? Colors.red
                                  : Colors.amber.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: item.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: item.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Favorite Button
            IconButton(
              onPressed: () {
                ref
                    .read(favoriteCalculatorsProvider.notifier)
                    .toggle(item.route);
              },
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatorCard extends ConsumerStatefulWidget {
  final _CalculatorItem item;

  const _CalculatorCard({required this.item});

  @override
  ConsumerState<_CalculatorCard> createState() => _CalculatorCardState();
}

class _CalculatorCardState extends ConsumerState<_CalculatorCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favoritesAsync = ref.watch(favoriteCalculatorsProvider);
    final favorites = favoritesAsync.value ?? [];
    final isFavorite = favorites.contains(widget.item.route);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          // Track as recent
          ref
              .read(recentCalculatorsProvider.notifier)
              .addRecent(widget.item.route);
          // Navigate
          context.go(widget.item.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovering ? 1.02 : 1.0),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.item.color.withOpacity(_isHovering ? 0.3 : 0.1),
                blurRadius: _isHovering ? 16 : 8,
                offset: Offset(0, _isHovering ? 4 : 2),
              ),
            ],
            border: Border.all(
              color: _isHovering
                  ? widget.item.color.withOpacity(0.5)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon, Badge, and Favorite Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.item.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.item.icon,
                        size: 28,
                        color: widget.item.color,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.item.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.item.isPopular
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.item.isPopular ? 'Popular' : 'Novo',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: widget.item.isPopular
                                    ? Colors.red
                                    : Colors.amber.shade700,
                              ),
                            ),
                          ),
                        if (widget.item.isPopular) const SizedBox(width: 4),
                        // Favorite Button
                        InkWell(
                          onTap: () {
                            ref
                                .read(favoriteCalculatorsProvider.notifier)
                                .toggle(widget.item.route);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),

                // Title
                Text(
                  widget.item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  widget.item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Tags
                if (widget.item.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: widget.item.tags.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.item.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.item.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
