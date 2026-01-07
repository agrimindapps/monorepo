import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/user_preferences_providers.dart';
import '../../../../core/theme/theme_providers.dart';

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
      ..._constructionCalculators,
      ..._healthCalculators,
      ..._petCalculators,
      ..._agricultureCalculators,
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // New Modern AppBar - Fixed logo and app name
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 1,
            backgroundColor: isDark ? const Color(0xFF1a1a1a) : Colors.white,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calculate_rounded,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Calculei',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      // Theme toggle
                      IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () {
                          ref.read(themeModeProvider.notifier).toggleTheme();
                        },
                        tooltip: isDark ? 'Modo Claro' : 'Modo Escuro',
                      ),
                      // Calculators Dropdown - using the new component
                      _HomeCalculatorsDropdown(isDark: isDark),
                    ],
                  ),
                ),
              ),
            ),
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
              delegate: SliverChildListDelegate(
                [
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
                          _buildEmptyState(
                            'Nenhuma calculadora favoritada ainda',
                            Icons.favorite_border,
                          ),
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
                          _buildEmptyState(
                            'Nenhuma calculadora usada recentemente',
                            Icons.history,
                          ),
                      ],

                      // Regular Sections
                      if (_selectedCategory != 'Favoritos' &&
                          _selectedCategory != 'Recentes') ...[
                        if (_shouldShowSection(
                          'Financeiro',
                          _financialCalculators,
                        ))
                          _buildSectionTitle(context, 'Financeiro'),
                        if (_shouldShowSection(
                          'Financeiro',
                          _financialCalculators,
                        ))
                          _buildGrid(
                            context,
                            _financialCalculators,
                            sectionTitle: 'Financeiro',
                          ),
                        if (_searchQuery.isEmpty) const SizedBox(height: 32),
                        if (_shouldShowSection(
                          'Construção',
                          _constructionCalculators,
                        ))
                          _buildSectionTitle(context, 'Construção'),
                        if (_shouldShowSection(
                          'Construção',
                          _constructionCalculators,
                        ))
                          _buildGrid(
                            context,
                            _constructionCalculators,
                            sectionTitle: 'Construção',
                          ),
                        if (_searchQuery.isEmpty) const SizedBox(height: 32),
                        if (_shouldShowSection(
                          'Saúde',
                          _healthCalculators,
                        ))
                          _buildSectionTitle(context, 'Saúde'),
                        if (_shouldShowSection(
                          'Saúde',
                          _healthCalculators,
                        ))
                          _buildGrid(
                            context,
                            _healthCalculators,
                            sectionTitle: 'Saúde',
                          ),
                        if (_searchQuery.isEmpty) const SizedBox(height: 32),
                        if (_shouldShowSection(
                          'Pet',
                          _petCalculators,
                        ))
                          _buildSectionTitle(context, 'Pet'),
                        if (_shouldShowSection(
                          'Pet',
                          _petCalculators,
                        ))
                          _buildGrid(
                            context,
                            _petCalculators,
                            sectionTitle: 'Pet',
                          ),
                        if (_searchQuery.isEmpty) const SizedBox(height: 32),
                        if (_shouldShowSection(
                          'Agricultura',
                          _agricultureCalculators,
                        ))
                          _buildSectionTitle(context, 'Agricultura'),
                        if (_shouldShowSection(
                          'Agricultura',
                          _agricultureCalculators,
                        ))
                          _buildGrid(
                            context,
                            _agricultureCalculators,
                            sectionTitle: 'Agricultura',
                          ),
                      ],
                    ]
                    .map(
                      (w) => Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: w,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
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
    if (title == 'Saúde') color = Colors.green;
    if (title == 'Pet') color = Colors.brown;
    if (title == 'Agricultura') color = Colors.teal;
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<_CalculatorItem> items, {
    String? sectionTitle,
  }) {
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
                child: Opacity(opacity: value, child: child),
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
                  child: Opacity(opacity: value, child: child),
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
      ('Saúde', Icons.favorite_border, Colors.green),
      ('Pet', Icons.pets, Colors.brown),
      ('Agricultura', Icons.agriculture, Colors.teal),
    ];

    return Container(
      height: 64,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
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
              ? chipColor.withValues(alpha: 0.15)
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
              color: isSelected
                  ? chipColor
                  : (isDark ? Colors.grey[400] : Colors.grey),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? chipColor
                    : (isDark ? Colors.grey[400] : Colors.grey),
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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
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
              tooltip: isGridView
                  ? 'Visualização em lista'
                  : 'Visualização em grade',
            ),
          ],
        ),
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
              color: item.color.withValues(alpha: 0.1),
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
                color: item.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 32, color: item.color),
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.amber.withValues(alpha: 0.1),
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
                      color: isDark ? Colors.grey[400] : Colors.grey,
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
                            color: item.color.withValues(alpha: 0.1),
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
                color: isFavorite
                    ? Colors.red
                    : (isDark ? Colors.grey[400] : Colors.grey),
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
                color: widget.item.color.withValues(
                  alpha: _isHovering ? 0.3 : 0.1,
                ),
                blurRadius: _isHovering ? 16 : 8,
                offset: Offset(0, _isHovering ? 4 : 2),
              ),
            ],
            border: Border.all(
              color: _isHovering
                  ? widget.item.color.withValues(alpha: 0.5)
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
                        color: widget.item.color.withValues(alpha: 0.15),
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
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.amber.withValues(alpha: 0.1),
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
                              color: isFavorite
                                  ? Colors.red
                                  : (isDark ? Colors.grey[400] : Colors.grey),
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
                    color: isDark ? Colors.grey[400] : Colors.grey,
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
                          color: widget.item.color.withValues(alpha: 0.1),
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

/// Calculators dropdown for home page
class _HomeCalculatorsDropdown extends StatefulWidget {
  final bool isDark;

  const _HomeCalculatorsDropdown({required this.isDark});

  @override
  State<_HomeCalculatorsDropdown> createState() =>
      _HomeCalculatorsDropdownState();
}

class _HomeCalculatorsDropdownState extends State<_HomeCalculatorsDropdown> {
  final _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return MenuAnchor(
      controller: _menuController,
      menuChildren: [
        // Trabalhista Category
        _buildCategoryHeader('Trabalhista', Icons.work_outline, Colors.blue),
        _buildMenuItem(
          'Salário Líquido',
          '/calculators/financial/net-salary',
          Icons.monetization_on,
          Colors.orange,
        ),
        _buildMenuItem(
          '13º Salário',
          '/calculators/financial/thirteenth-salary',
          Icons.card_giftcard,
          Colors.green,
        ),
        _buildMenuItem(
          'Férias',
          '/calculators/financial/vacation',
          Icons.beach_access,
          Colors.blue,
        ),
        _buildMenuItem(
          'Horas Extras',
          '/calculators/financial/overtime',
          Icons.access_time,
          Colors.purple,
        ),
        _buildMenuItem(
          'Seguro Desemprego',
          '/calculators/financial/unemployment-insurance',
          Icons.work_off,
          Colors.red,
        ),
        const Divider(height: 8),
        // Financeiro Category
        _buildCategoryHeader(
          'Financeiro',
          Icons.account_balance_wallet,
          Colors.green,
        ),
        _buildMenuItem(
          'Reserva de Emergência',
          '/calculators/financial/emergency-reserve',
          Icons.savings,
          Colors.teal,
        ),
        _buildMenuItem(
          'À Vista vs Parcelado',
          '/calculators/financial/cash-vs-installment',
          Icons.payment,
          Colors.indigo,
        ),
      ],
      style: MenuStyle(
        elevation: WidgetStateProperty.all(8),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      child: isDesktop
          ? _buildDesktopButton(theme)
          : IconButton(
              icon: Icon(
                Icons.calculate,
                color: widget.isDark ? Colors.white70 : Colors.black54,
              ),
              onPressed: () {
                if (_menuController.isOpen) {
                  _menuController.close();
                } else {
                  _menuController.open();
                }
              },
              tooltip: 'Calculadoras',
            ),
    );
  }

  Widget _buildCategoryHeader(String name, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    String route,
    IconData icon,
    Color color,
  ) {
    return MenuItemButton(
      onPressed: () {
        _menuController.close();
        context.go(route);
      },
      leadingIcon: Icon(icon, size: 20, color: color),
      child: Text(title),
    );
  }

  Widget _buildDesktopButton(ThemeData theme) {
    return MouseRegion(
      child: GestureDetector(
        onTap: () {
          if (_menuController.isOpen) {
            _menuController.close();
          } else {
            _menuController.open();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Calculadoras',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
