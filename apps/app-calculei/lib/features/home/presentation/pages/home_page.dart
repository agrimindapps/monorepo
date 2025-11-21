import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _shouldShowSection(String sectionTitle, List<_CalculatorItem> items) {
    if (_searchQuery.isEmpty) return true;
    if (sectionTitle.toLowerCase().contains(_searchQuery)) return true;
    return items.any((item) => item.title.toLowerCase().contains(_searchQuery));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(currentThemeModeProvider) == ThemeMode.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverToBoxAdapter(
            child: _HeroSection(isDark: isDark),
          ),

          // Search Bar
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
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_shouldShowSection('Financeiro', _financialCalculators))
                  _buildSectionTitle(context, 'Financeiro'),
                if (_shouldShowSection('Financeiro', _financialCalculators))
                  _buildGrid(context, _financialCalculators,
                      sectionTitle: 'Financeiro'),
                if (_searchQuery.isEmpty) const SizedBox(height: 24),
                if (_shouldShowSection('Construção', _constructionCalculators))
                  _buildSectionTitle(context, 'Construção'),
                if (_shouldShowSection('Construção', _constructionCalculators))
                  _buildGrid(context, _constructionCalculators,
                      sectionTitle: 'Construção'),
              ]),
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
            childAspectRatio: 1.1,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            return _CalculatorCard(item: filteredItems[index]);
          },
        );
      },
    );
  }

  // Calculator Data
  final List<_CalculatorItem> _financialCalculators = [
    _CalculatorItem(
      title: '13º Salário',
      icon: Icons.card_giftcard,
      color: Colors.green,
      route: '/calculators/financial/thirteenth-salary',
    ),
    _CalculatorItem(
      title: 'Férias',
      icon: Icons.beach_access,
      color: Colors.blue,
      route: '/calculators/financial/vacation',
    ),
    _CalculatorItem(
      title: 'Salário Líquido',
      icon: Icons.monetization_on,
      color: Colors.orange,
      route: '/calculators/financial/net-salary',
    ),
    _CalculatorItem(
      title: 'Horas Extras',
      icon: Icons.access_time,
      color: Colors.purple,
      route: '/calculators/financial/overtime',
    ),
    _CalculatorItem(
      title: 'Reserva de Emergência',
      icon: Icons.savings,
      color: Colors.teal,
      route: '/calculators/financial/emergency-reserve',
    ),
    _CalculatorItem(
      title: 'À vista ou Parcelado',
      icon: Icons.payment,
      color: Colors.indigo,
      route: '/calculators/financial/cash-vs-installment',
    ),
    _CalculatorItem(
      title: 'Seguro Desemprego',
      icon: Icons.work_off,
      color: Colors.red,
      route: '/calculators/financial/unemployment-insurance',
    ),
  ];

  final List<_CalculatorItem> _constructionCalculators = [
    _CalculatorItem(
      title: 'Cálculos de Construção',
      icon: Icons.construction,
      color: Colors.deepOrange,
      route: '/calculators/construction/selection',
    ),
    // Add more construction calculators here as they are implemented/routed
  ];
}

class _CalculatorItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  _CalculatorItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _HeroSection extends StatelessWidget {
  final bool isDark;

  const _HeroSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.indigo.shade900, Colors.blue.shade900]
              : [Colors.blue.shade600, Colors.indigo.shade600],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bem-vindo ao Calculei',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Simplifique sua vida com nossas calculadoras.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;

  _SearchBarDelegate({
    required this.controller,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).scaffoldBackgroundColor,
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
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class _CalculatorCard extends StatefulWidget {
  final _CalculatorItem item;

  const _CalculatorCard({required this.item});

  @override
  State<_CalculatorCard> createState() => _CalculatorCardState();
}

class _CalculatorCardState extends State<_CalculatorCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => context.go(widget.item.route),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.item.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.item.icon,
                  size: 32,
                  color: widget.item.color,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.item.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
