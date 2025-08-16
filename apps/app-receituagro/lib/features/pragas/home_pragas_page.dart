import 'package:flutter/material.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'detalhe_praga_page.dart';
import 'lista_pragas_page.dart';
import '../culturas/lista_culturas_page.dart';

class HomePragasPage extends StatefulWidget {
  const HomePragasPage({super.key});

  @override
  State<HomePragasPage> createState() => _HomePragasPageState();
}

class _HomePragasPageState extends State<HomePragasPage> {
  final PageController _pageController = PageController(viewportFraction: 0.6);
  int _currentCarouselIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildModernHeader(context, isDark),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildStatsGrid(context),
                        const SizedBox(height: 24),
                        _buildSuggestionsSection(context),
                        const SizedBox(height: 24),
                        _buildRecentAccessSection(context),
                        const SizedBox(height: 80), // Espaço para bottom navigation
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return ModernHeaderWidget(
      title: 'Pragas e Doenças',
      subtitle: 'Identifique e controle 1139 pragas',
      leftIcon: Icons.pest_control,
      showBackButton: false,
      showActions: true,
      isDark: isDark,
      rightIcon: Icons.search,
      onRightIconPressed: () => _navigateToSearch(context),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallDevice = screenWidth < 360;
            final useVerticalLayout = isSmallDevice || availableWidth < 320;

            if (useVerticalLayout) {
              return _buildVerticalMenuLayout(availableWidth);
            } else {
              return _buildGridMenuLayout(availableWidth, context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildVerticalMenuLayout(double availableWidth) {
    final theme = Theme.of(context);
    final buttonWidth = availableWidth - 16;
    final standardColor = theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCategoryButton(
          count: '389',
          title: 'Insetos',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'insetos'),
          icon: Icons.bug_report,
          color: standardColor,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: '391',
          title: 'Doenças',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'doencas'),
          icon: Icons.coronavirus,
          color: standardColor,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: '359',
          title: 'Plantas',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'plantas'),
          icon: Icons.eco,
          color: standardColor,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: '210',
          title: 'Culturas',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'culturas'),
          icon: Icons.agriculture,
          color: standardColor,
        ),
      ],
    );
  }

  Widget _buildGridMenuLayout(double availableWidth, BuildContext context) {
    final theme = Theme.of(context);
    final isMediumDevice = MediaQuery.of(context).size.width < 600;
    final buttonWidth = isMediumDevice ? (availableWidth - 32) / 3 : (availableWidth - 40) / 3;
    final standardColor = theme.colorScheme.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryButton(
              count: '389',
              title: 'Insetos',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'insetos'),
              icon: Icons.bug_report,
              color: standardColor,
            ),
            const SizedBox(width: 8),
            _buildCategoryButton(
              count: '391',
              title: 'Doenças',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'doencas'),
              icon: Icons.coronavirus,
              color: standardColor,
            ),
            const SizedBox(width: 8),
            _buildCategoryButton(
              count: '359',
              title: 'Plantas',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'plantas'),
              icon: Icons.eco,
              color: standardColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: '210',
          title: 'Culturas',
          width: isMediumDevice ? availableWidth - 16 : availableWidth * 0.75,
          onTap: () => _navigateToCategory(context, 'culturas'),
          icon: Icons.agriculture,
          color: standardColor,
        ),
      ],
    );
  }

  Widget _buildCategoryButton({
    required String count,
    required String title,
    required double width,
    required VoidCallback onTap,
    IconData? icon,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    return SizedBox(
      width: width,
      height: 90,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  buttonColor.withValues(alpha: 0.7),
                  buttonColor.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Icon(
                    icon ?? Icons.circle,
                    size: 70,
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon ?? Icons.circle,
                            color: theme.colorScheme.onPrimary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              count,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onPrimary,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: theme.shadowColor.withValues(alpha: 0.3),
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(
                    Icons.touch_app,
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.5),
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sugestões',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCarousel(),
        const SizedBox(height: 12),
        _buildDotIndicators(),
      ],
    );
  }

  Widget _buildCarousel() {
    final suggestions = _getSuggestionsList();
    
    if (suggestions.isEmpty) {
      return _buildEmptyCarousel();
    }

    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: _pageController,
        itemCount: suggestions.length,
        onPageChanged: (index) {
          setState(() {
            _currentCarouselIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return _buildCarouselItem(suggestion);
        },
      ),
    );
  }

  Widget _buildCarouselItem(Map<String, dynamic> suggestion) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildItemBackground(suggestion),
            _buildGradientOverlay(suggestion),
            _buildItemContent(suggestion),
            _buildTouchLayer(suggestion),
          ],
        ),
      ),
    );
  }

  Widget _buildItemBackground(Map<String, dynamic> suggestion) {
    final theme = Theme.of(context);
    final itemColor = _getColorForType(suggestion['type'] as String, context);
    
    return Container(
      color: itemColor.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Text(
              suggestion['emoji'] as String,
              style: const TextStyle(fontSize: 48),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay(Map<String, dynamic> suggestion) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Theme.of(context).shadowColor.withValues(alpha: 0.8),
              Colors.transparent,
            ],
            stops: const [0.0, 0.9],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion['name'] as String,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              suggestion['scientific'] as String,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            _buildTypeTag(suggestion),
          ],
        ),
      ),
    );
  }

  Widget _buildItemContent(Map<String, dynamic> suggestion) {
    return const SizedBox.shrink();
  }

  Widget _buildTypeTag(Map<String, dynamic> suggestion) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            suggestion['type'] == 'Inseto' ? Icons.bug_report : Icons.coronavirus,
            color: theme.colorScheme.onSurface,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            suggestion['type'] as String,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTouchLayer(Map<String, dynamic> suggestion) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToPragaDetails(
            context, 
            suggestion['name'] as String, 
            suggestion['scientific'] as String
          ),
          splashColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildDotIndicators() {
    final suggestions = _getSuggestionsList();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: suggestions.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => _pageController.animateToPage(
            entry.key,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          child: Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentCarouselIndex == entry.key
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyCarousel() {
    final theme = Theme.of(context);
    
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Nenhuma sugestão disponível',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(String type, BuildContext context) {
    final theme = Theme.of(context);
    switch (type.toLowerCase()) {
      case 'inseto':
        return theme.colorScheme.primary;
      case 'doença':
        return theme.colorScheme.tertiary;
      case 'planta':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }

  List<Map<String, dynamic>> _getSuggestionsList() {
    return [
      {
        'name': 'Cochonilha',
        'scientific': 'Planococcus minor',
        'type': 'Inseto',
        'emoji': '🐛',
      },
      {
        'name': 'Mancha Branca',
        'scientific': 'Pseudomonas syringae',
        'type': 'Doença',
        'emoji': '🟤',
      },
      {
        'name': 'Ferrugem',
        'scientific': 'Phakopsora pachyrhizi',
        'type': 'Doença',
        'emoji': '🟠',
      },
      {
        'name': 'Lagarta',
        'scientific': 'Spodoptera frugiperda',
        'type': 'Inseto',
        'emoji': '🐛',
      },
      {
        'name': 'Oídio',
        'scientific': 'Erysiphe necator',
        'type': 'Doença',
        'emoji': '⚪',
      },
    ];
  }

  Widget _buildRecentAccessSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimos Acessados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.history,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildPragaItem(
              context,
              'Podridão',
              'Phoma exigua var. exigua',
              'Doença',
              _getColorForType('Doença', context),
              '🟤', // Emoji como placeholder para imagem
            ),
            _buildPragaItem(
              context,
              'Broca',
              'Etiella zinckenella',
              'Inseto',
              _getColorForType('Inseto', context),
              '🐛',
            ),
            _buildPragaItem(
              context,
              'Besouro',
              'Cathartus quadricollis',
              'Inseto',
              _getColorForType('Inseto', context),
              '🪲',
            ),
            _buildPragaItem(
              context,
              'Lagarta',
              'Bonagota cranaodes',
              'Inseto',
              _getColorForType('Inseto', context),
              '🐛',
            ),
            _buildPragaItem(
              context,
              'Tripes',
              'Thrips palmi',
              'Inseto',
              _getColorForType('Inseto', context),
              '🦗',
            ),
            _buildPragaItem(
              context,
              'Erva',
              'Polygonum aviculare',
              'Planta',
              _getColorForType('Planta', context),
              '🌿',
            ),
            _buildPragaItem(
              context,
              'Apaga',
              'Alternanthera tenella',
              'Planta',
              _getColorForType('Planta', context),
              '🌱',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPragaItem(BuildContext context, String name, String scientificName, String category, Color categoryColor, String emoji) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _navigateToPragaDetails(context, name, scientificName),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Foto/Imagem circular
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Conteúdo principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome da praga
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Nome científico
                    Text(
                      scientificName,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tag da categoria
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Seta à direita
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPragaDetails(BuildContext context, String pragaName, String scientificName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhePragaPage(
          pragaName: pragaName,
          pragaScientificName: scientificName,
        ),
      ),
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ListaPragasPage(),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    switch (category) {
      case 'culturas':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ListaCulturasPage(),
          ),
        );
        break;
      case 'insetos':
      case 'doencas':
      case 'plantas':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ListaPragasPage(),
          ),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ListaPragasPage(),
          ),
        );
    }
  }
}