import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/user_preferences_providers.dart';
import '../../../../widgets/theme_toggle_button.dart';

// Modern dark theme colors matching calculator pages
const _backgroundColor = Color(0xFF0F0F1A);
const _surfaceColor = Color(0xFF1A1A2E);
const _sidebarColor = Color(0xFF16162A);
const _primaryAccent = Color(0xFF4CAF50);

class HomePage extends ConsumerStatefulWidget {
  final String? initialCategory;

  const HomePage({super.key, this.initialCategory});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      case 'todos':
      default:
        return 'Todos';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<_CalculatorItem> _getFilteredCalculators(
    List<_CalculatorItem> allCalculators,
    List<String> favorites,
    List<String> recents,
  ) {
    var items = <_CalculatorItem>[];

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
          items = _financialCalculators;
          break;
        case 'Construção':
          items = _constructionCalculators;
          break;
        case 'Saúde':
          items = _healthCalculators;
          break;
        case 'Pet':
          items = _petCalculators;
          break;
        case 'Agricultura':
          items = _agricultureCalculators;
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final favoritesAsync = ref.watch(favoriteCalculatorsProvider);
    final recentsAsync = ref.watch(recentCalculatorsProvider);

    final favorites = favoritesAsync.value ?? [];
    final recents = recentsAsync.value ?? [];

    final allCalculators = [
      ..._financialCalculators,
      ..._constructionCalculators,
      ..._healthCalculators,
      ..._petCalculators,
      ..._agricultureCalculators,
    ];

    final filteredCalculators =
        _getFilteredCalculators(allCalculators, favorites, recents);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: isMobile ? _buildDrawer(favorites.length, recents.length) : null,
      body: Row(
        children: [
          // Sidebar (desktop only)
          if (!isMobile) _buildSidebar(favorites.length, recents.length),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Top header with search
                _buildTopHeader(isMobile),

                // Content
                Expanded(
                  child: _buildMainContent(
                    filteredCalculators,
                    allCalculators,
                    favorites,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(int favoritesCount, int recentsCount) {
    return Drawer(
      backgroundColor: _sidebarColor,
      child: _buildSidebarContent(favoritesCount, recentsCount),
    );
  }

  Widget _buildSidebar(int favoritesCount, int recentsCount) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: _sidebarColor,
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: _buildSidebarContent(favoritesCount, recentsCount),
    );
  }

  Widget _buildSidebarContent(int favoritesCount, int recentsCount) {
    final popularCount =
        [..._financialCalculators, ..._constructionCalculators, ..._healthCalculators, ..._petCalculators, ..._agricultureCalculators]
            .where((c) => c.isPopular)
            .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo header
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryAccent, _primaryAccent.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Calculei',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const Divider(color: Colors.white10, height: 1),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick filters section
                _buildSidebarSection('FILTROS RÁPIDOS'),
                _buildFilterItem(
                  'Favoritos',
                  Icons.favorite,
                  Colors.red,
                  favoritesCount,
                  isFilter: true,
                ),
                _buildFilterItem(
                  'Recentes',
                  Icons.history,
                  Colors.purple,
                  recentsCount,
                  isFilter: true,
                ),
                _buildFilterItem(
                  'Popular',
                  Icons.star,
                  Colors.amber,
                  popularCount,
                  isFilter: true,
                ),

                const SizedBox(height: 24),

                // Categories section
                _buildSidebarSection('CATEGORIAS'),
                _buildCategoryItem(
                  'Todos',
                  Icons.apps,
                  null,
                  _financialCalculators.length +
                      _constructionCalculators.length +
                      _healthCalculators.length +
                      _petCalculators.length +
                      _agricultureCalculators.length,
                ),
                _buildCategoryItem(
                  'Financeiro',
                  Icons.account_balance_wallet,
                  Colors.blue,
                  _financialCalculators.length,
                ),
                _buildCategoryItem(
                  'Construção',
                  Icons.construction,
                  Colors.orange,
                  _constructionCalculators.length,
                ),
                _buildCategoryItem(
                  'Saúde',
                  Icons.favorite_border,
                  Colors.pink,
                  _healthCalculators.length,
                ),
                _buildCategoryItem(
                  'Pet',
                  Icons.pets,
                  Colors.brown,
                  _petCalculators.length,
                ),
                _buildCategoryItem(
                  'Agricultura',
                  Icons.agriculture,
                  Colors.teal,
                  _agricultureCalculators.length,
                ),
                
                // Theme toggle at the bottom
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ThemeToggleButton(color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFilterItem(
    String label,
    IconData icon,
    Color color,
    int count, {
    bool isFilter = false,
  }) {
    final isSelected = _selectedFilter == label;

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedFilter = '';
          } else {
            _selectedFilter = label;
            _selectedCategory = 'Todos';
          }
        });
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    String label,
    IconData icon,
    Color? color,
    int count,
  ) {
    final isSelected = _selectedCategory == label && _selectedFilter.isEmpty;
    final itemColor = color ?? _primaryAccent;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          _selectedFilter = '';
        });
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? itemColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: itemColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? itemColor : Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? itemColor.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected
                      ? itemColor
                      : Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: _surfaceColor.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Row(
            children: [
              // Menu button (mobile only)
              if (isMobile) ...[
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 8),
              ],

              // Search bar
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'O que vamos calcular hoje?',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // View toggle
              Container(
                decoration: BoxDecoration(
                  color: _backgroundColor,
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
              ),
            ],
          ),
        ),
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
          color: isSelected ? _primaryAccent.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? _primaryAccent : Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    List<_CalculatorItem> filteredCalculators,
    List<_CalculatorItem> allCalculators,
    List<String> favorites,
  ) {
    final viewMode = ref.watch(viewModeProvider).value;
    final isGridView = viewMode == 'grid';

    // Get section title
    var sectionTitle = 'TODAS AS CALCULADORAS';
    var sectionIcon = Icons.apps;
    var sectionColor = _primaryAccent;

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
          sectionIcon = Icons.agriculture;
          sectionColor = Colors.teal;
          break;
      }
    }

    return Stack(
      children: [
        // Background pattern
        CustomPaint(
          painter: _HomeBackgroundPainter(),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${filteredCalculators.length}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
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
              decoration: const BoxDecoration(
                color: _surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<_CalculatorItem> items, List<String> favorites) {
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

  Widget _buildListView(List<_CalculatorItem> items, List<String> favorites) {
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
      title: 'Concreto',
      description: 'Calcule volume e materiais para concreto',
      icon: Icons.layers,
      color: Colors.grey,
      route: '/calculators/construction/concrete',
      tags: ['Cimento', 'Areia', 'Brita'],
      isPopular: true,
    ),
    _CalculatorItem(
      title: 'Tinta',
      description: 'Quantidade de tinta para pintura',
      icon: Icons.format_paint,
      color: Colors.orange,
      route: '/calculators/construction/paint',
      tags: ['Parede', 'Litros'],
    ),
    _CalculatorItem(
      title: 'Piso e Revestimento',
      description: 'Peças, caixas e rejunte necessários',
      icon: Icons.grid_on,
      color: Colors.brown,
      route: '/calculators/construction/flooring',
      tags: ['Cerâmica', 'Porcelanato'],
    ),
    _CalculatorItem(
      title: 'Tijolos e Blocos',
      description: 'Tijolos e argamassa para alvenaria',
      icon: Icons.crop_square,
      color: Colors.red,
      route: '/calculators/construction/brick',
      tags: ['Alvenaria', 'Parede'],
    ),
  ];

  final List<_CalculatorItem> _healthCalculators = [
    _CalculatorItem(
      title: 'IMC',
      description: 'Índice de Massa Corporal',
      icon: Icons.monitor_weight_outlined,
      color: Colors.green,
      route: '/calculators/health/bmi',
      tags: ['Peso', 'Altura', 'Saúde'],
      isPopular: true,
    ),
    _CalculatorItem(
      title: 'Taxa Metabólica',
      description: 'Calorias diárias necessárias',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      route: '/calculators/health/bmr',
      tags: ['Calorias', 'Metabolismo'],
      isPopular: true,
    ),
    _CalculatorItem(
      title: 'Necessidade Hídrica',
      description: 'Quantidade ideal de água por dia',
      icon: Icons.water_drop,
      color: Colors.blue,
      route: '/calculators/health/water',
      tags: ['Água', 'Hidratação'],
    ),
    _CalculatorItem(
      title: 'Peso Ideal',
      description: '4 fórmulas científicas',
      icon: Icons.accessibility_new,
      color: Colors.teal,
      route: '/calculators/health/ideal-weight',
      tags: ['Peso', 'Altura'],
    ),
    _CalculatorItem(
      title: 'Gordura Corporal',
      description: 'Percentual de gordura (US Navy)',
      icon: Icons.pie_chart,
      color: Colors.purple,
      route: '/calculators/health/body-fat',
      tags: ['Composição', 'Medidas'],
    ),
    _CalculatorItem(
      title: 'Macronutrientes',
      description: 'Carboidratos, proteínas e gorduras',
      icon: Icons.pie_chart_outline,
      color: Colors.amber,
      route: '/calculators/health/macros',
      tags: ['Dieta', 'Nutrição'],
    ),
    _CalculatorItem(
      title: 'Proteínas Diárias',
      description: 'Necessidade proteica por peso',
      icon: Icons.restaurant,
      color: Colors.red,
      route: '/calculators/health/protein',
      tags: ['Proteína', 'Dieta', 'Músculo'],
    ),
    _CalculatorItem(
      title: 'Calorias Exercício',
      description: 'Gasto calórico por atividade',
      icon: Icons.directions_run,
      color: Colors.deepOrange,
      route: '/calculators/health/exercise-calories',
      tags: ['Exercício', 'Calorias', 'Treino'],
      isPopular: true,
    ),
    _CalculatorItem(
      title: 'Cintura-Quadril',
      description: 'Risco cardiovascular (RCQ)',
      icon: Icons.straighten,
      color: Colors.pink,
      route: '/calculators/health/waist-hip',
      tags: ['Medidas', 'Risco', 'Saúde'],
    ),
    _CalculatorItem(
      title: 'Álcool no Sangue',
      description: 'Concentração alcoólica (BAC)',
      icon: Icons.local_bar,
      color: Colors.brown,
      route: '/calculators/health/blood-alcohol',
      tags: ['Álcool', 'BAC', 'Segurança'],
    ),
    _CalculatorItem(
      title: 'Volume Sanguíneo',
      description: 'Estimativa por peso e altura',
      icon: Icons.bloodtype,
      color: Colors.red,
      route: '/calculators/health/blood-volume',
      tags: ['Sangue', 'Volume', 'Corpo'],
    ),
    _CalculatorItem(
      title: 'Déficit Calórico',
      description: 'Meta para perda ou ganho de peso',
      icon: Icons.trending_down,
      color: Colors.indigo,
      route: '/calculators/health/caloric-deficit',
      tags: ['Dieta', 'Emagrecimento', 'Meta'],
    ),
  ];

  final List<_CalculatorItem> _petCalculators = [
    _CalculatorItem(
      title: 'Idade do Pet',
      description: 'Idade em anos humanos',
      icon: Icons.pets,
      color: Colors.blue,
      route: '/calculators/pet/age',
      tags: ['Cachorro', 'Gato', 'Idade'],
      isPopular: true,
    ),
    _CalculatorItem(
      title: 'Gestação Pet',
      description: 'Acompanhe a gravidez',
      icon: Icons.child_friendly,
      color: Colors.pink,
      route: '/calculators/pet/pregnancy',
      tags: ['Gravidez', 'Parto', 'Filhotes'],
    ),
    _CalculatorItem(
      title: 'Condição Corporal',
      description: 'BCS - Escore de condição física',
      icon: Icons.fitness_center,
      color: Colors.orange,
      route: '/calculators/pet/body-condition',
      tags: ['BCS', 'Peso', 'Nutrição'],
      isPopular: true,
    ),
    _CalculatorItem(
      title: 'Calorias Pet',
      description: 'Necessidade calórica diária',
      icon: Icons.restaurant,
      color: Colors.green,
      route: '/calculators/pet/caloric-needs',
      tags: ['Ração', 'Alimentação', 'Calorias'],
    ),
    _CalculatorItem(
      title: 'Dosagem Medicamento',
      description: 'Dose por peso do animal',
      icon: Icons.medication,
      color: Colors.red,
      route: '/calculators/pet/medication',
      tags: ['Remédio', 'Veterinário', 'Dose'],
    ),
    _CalculatorItem(
      title: 'Fluidoterapia',
      description: 'Volume de fluidos IV',
      icon: Icons.water_drop,
      color: Colors.cyan,
      route: '/calculators/pet/fluid-therapy',
      tags: ['Soro', 'Desidratação', 'IV'],
    ),
    _CalculatorItem(
      title: 'Peso Ideal Pet',
      description: 'Meta de peso saudável',
      icon: Icons.monitor_weight,
      color: Colors.purple,
      route: '/calculators/pet/ideal-weight',
      tags: ['Peso', 'Obesidade', 'Dieta'],
    ),
    _CalculatorItem(
      title: 'Conversão Unidades',
      description: 'kg↔lb, °C↔°F e mais',
      icon: Icons.swap_horiz,
      color: Colors.grey,
      route: '/calculators/pet/unit-conversion',
      tags: ['Converter', 'Medidas', 'Unidades'],
    ),
  ];

  final List<_CalculatorItem> _agricultureCalculators = [
    _CalculatorItem(
      title: 'Adubação NPK',
      description: 'Calcule a necessidade de nutrientes',
      icon: Icons.grass,
      color: Colors.green,
      route: '/calculators/agriculture/npk',
      tags: ['Fertilizante', 'Nutrientes', 'Solo'],
      isPopular: true,
    ),
    _CalculatorItem(
      title: 'Taxa de Semeadura',
      description: 'Quantidade de sementes por hectare',
      icon: Icons.agriculture,
      color: Colors.amber,
      route: '/calculators/agriculture/seed-rate',
      tags: ['Sementes', 'Plantio', 'Lavoura'],
    ),
    _CalculatorItem(
      title: 'Irrigação',
      description: 'Volume de água e tempo de irrigação',
      icon: Icons.water,
      color: Colors.blue,
      route: '/calculators/agriculture/irrigation',
      tags: ['Água', 'Pivô', 'Gotejo'],
    ),
    _CalculatorItem(
      title: 'Dosagem Fertilizante',
      description: 'Quantidade de adubo por área',
      icon: Icons.science,
      color: Colors.purple,
      route: '/calculators/agriculture/fertilizer-dosing',
      tags: ['Adubo', 'Dosagem', 'Aplicação'],
    ),
    _CalculatorItem(
      title: 'Correção pH Solo',
      description: 'Calcário necessário para correção',
      icon: Icons.landscape,
      color: Colors.brown,
      route: '/calculators/agriculture/soil-ph',
      tags: ['Calcário', 'pH', 'Acidez'],
    ),
    _CalculatorItem(
      title: 'Densidade Plantio',
      description: 'Plantas por hectare',
      icon: Icons.grid_on,
      color: Colors.lightGreen,
      route: '/calculators/agriculture/planting-density',
      tags: ['Espaçamento', 'Plantas', 'Estande'],
    ),
    _CalculatorItem(
      title: 'Previsão Produtividade',
      description: 'Estimativa de colheita',
      icon: Icons.trending_up,
      color: Colors.orange,
      route: '/calculators/agriculture/yield-prediction',
      tags: ['Colheita', 'Produção', 'Safra'],
      isPopular: true,
    ),
    _CalculatorItem(
      title: 'Ração Animal',
      description: 'Consumo diário de ração',
      icon: Icons.pets,
      color: Colors.red,
      route: '/calculators/agriculture/feed',
      tags: ['Gado', 'Suíno', 'Frango', 'Alimentação'],
    ),
    _CalculatorItem(
      title: 'Ganho de Peso',
      description: 'Tempo para atingir peso meta',
      icon: Icons.monitor_weight,
      color: Colors.teal,
      route: '/calculators/agriculture/weight-gain',
      tags: ['Engorda', 'Gado', 'Pecuária'],
    ),
    _CalculatorItem(
      title: 'Ciclo Reprodutivo',
      description: 'Gestação e parto de animais',
      icon: Icons.child_friendly,
      color: Colors.pink,
      route: '/calculators/agriculture/breeding-cycle',
      tags: ['Gestação', 'Parto', 'Reprodução'],
    ),
    _CalculatorItem(
      title: 'Evapotranspiração',
      description: 'ETo e necessidade hídrica',
      icon: Icons.wb_sunny,
      color: Colors.cyan,
      route: '/calculators/agriculture/evapotranspiration',
      tags: ['ETo', 'Clima', 'Água'],
    ),
  ];
}

// Data model
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

// Background painter
class _HomeBackgroundPainter extends CustomPainter {
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
              color: Colors.white.withValues(alpha: 0.015),
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Modern Calculator Card
class _ModernCalculatorCard extends ConsumerStatefulWidget {
  final _CalculatorItem item;
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
                  : Colors.white.withValues(alpha: 0.08),
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
                                  : Colors.white.withValues(alpha: 0.7),
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
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.item.icon,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Title
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        color: Colors.white,
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
                        color: Colors.white.withValues(alpha: 0.7),
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
  final _CalculatorItem item;
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
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                          style: const TextStyle(
                            color: Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.5),
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
                color: isFavorite ? Colors.red : Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
