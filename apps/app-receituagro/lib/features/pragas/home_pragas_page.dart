import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../core/repositories/cultura_hive_repository.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/praga_image_widget.dart';
import '../culturas/lista_culturas_page.dart';
import 'detalhe_praga_page.dart';
import 'lista_pragas_page.dart';
import 'presentation/providers/pragas_provider.dart';

class HomePragasPage extends StatefulWidget {
  const HomePragasPage({super.key});

  @override
  State<HomePragasPage> createState() => _HomePragasPageState();
}

class _HomePragasPageState extends State<HomePragasPage> {
  final PageController _pageController = PageController(viewportFraction: 0.6);
  final CulturaHiveRepository _culturaRepository = GetIt.instance<CulturaHiveRepository>();
  
  int _currentCarouselIndex = 0;
  
  // Contador de culturas (ainda usa repository legacy)
  int _totalCulturas = 0;

  @override
  void initState() {
    super.initState();
    _loadCulturaData();
    
    // Inicializa pragas usando Provider após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PragasProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCulturaData() async {
    try {
      final culturas = _culturaRepository.getAll();
      
      if (mounted) {
        setState(() {
          _totalCulturas = culturas.length;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _totalCulturas = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return ChangeNotifierProvider.value(
      value: GetIt.instance<PragasProvider>(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Consumer<PragasProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  _buildModernHeader(context, isDark, provider),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildStatsGrid(context, provider),
                              const SizedBox(height: 24),
                              _buildSuggestionsSection(context, provider),
                              const SizedBox(height: 24),
                              _buildRecentAccessSection(context, provider),
                              const SizedBox(height: 80), // Espaço para bottom navigation
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark, PragasProvider provider) {
    String subtitle = 'Carregando pragas...';
    if (!provider.isLoading && provider.stats != null) {
      final stats = provider.stats!;
      final total = stats.insetos + stats.doencas + stats.plantas;
      subtitle = 'Identifique e controle $total pragas';
    }
    
    return ModernHeaderWidget(
      title: 'Pragas e Doenças',
      subtitle: subtitle,
      leftIcon: Icons.pest_control,
      showBackButton: false,
      showActions: false,
      isDark: isDark,
    );
  }

  Widget _buildStatsGrid(BuildContext context, PragasProvider provider) {
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
              return _buildVerticalMenuLayout(availableWidth, provider);
            } else {
              return _buildGridMenuLayout(availableWidth, context, provider);
            }
          },
        ),
      ),
    );
  }

  Widget _buildVerticalMenuLayout(double availableWidth, PragasProvider provider) {
    final theme = Theme.of(context);
    final buttonWidth = availableWidth - 16;
    final standardColor = theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCategoryButton(
          count: provider.isLoading ? '...' : '${provider.stats?.insetos ?? 0}',
          title: 'Insetos',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'insetos'),
          icon: Icons.bug_report,
          color: standardColor,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: provider.isLoading ? '...' : '${provider.stats?.doencas ?? 0}',
          title: 'Doenças',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'doencas'),
          icon: Icons.coronavirus,
          color: standardColor,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: provider.isLoading ? '...' : '${provider.stats?.plantas ?? 0}',
          title: 'Plantas',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'plantas'),
          icon: Icons.eco,
          color: standardColor,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: '$_totalCulturas',
          title: 'Culturas',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'culturas'),
          icon: Icons.agriculture,
          color: standardColor,
        ),
      ],
    );
  }

  Widget _buildGridMenuLayout(double availableWidth, BuildContext context, PragasProvider provider) {
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
              count: provider.isLoading ? '...' : '${provider.stats?.insetos ?? 0}',
              title: 'Insetos',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'insetos'),
              icon: Icons.bug_report,
              color: standardColor,
            ),
            const SizedBox(width: 8),
            _buildCategoryButton(
              count: provider.isLoading ? '...' : '${provider.stats?.doencas ?? 0}',
              title: 'Doenças',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'doencas'),
              icon: Icons.coronavirus,
              color: standardColor,
            ),
            const SizedBox(width: 8),
            _buildCategoryButton(
              count: provider.isLoading ? '...' : '${provider.stats?.plantas ?? 0}',
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
          count: '$_totalCulturas',
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

  Widget _buildSuggestionsSection(BuildContext context, PragasProvider provider) {
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
        _buildCarousel(provider),
        const SizedBox(height: 12),
        _buildDotIndicators(provider),
      ],
    );
  }

  Widget _buildCarousel(PragasProvider provider) {
    final suggestions = _getSuggestionsList(provider);
    
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
    
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: PragaImageWidget(
        nomeCientifico: suggestion['scientific'] as String,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(12),
        errorWidget: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: _getColorForType(suggestion['type'] as String, context).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
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
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.3),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion['name'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              suggestion['scientific'] as String,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontStyle: FontStyle.italic,
                shadows: const [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black,
                    offset: Offset(0, 1),
                  ),
                ],
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
    IconData icon;
    Color backgroundColor;
    
    switch (suggestion['type'] as String) {
      case 'Inseto':
        icon = Icons.bug_report;
        backgroundColor = Colors.red.withValues(alpha: 0.9);
        break;
      case 'Doença':
        icon = Icons.coronavirus;
        backgroundColor = Colors.orange.withValues(alpha: 0.9);
        break;
      case 'Planta':
        icon = Icons.grass;
        backgroundColor = Colors.green.withValues(alpha: 0.9);
        break;
      default:
        icon = Icons.help;
        backgroundColor = Colors.grey.withValues(alpha: 0.9);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            suggestion['type'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 1.0,
                  color: Colors.black,
                  offset: Offset(0, 0.5),
                ),
              ],
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

  Widget _buildDotIndicators(PragasProvider provider) {
    final suggestions = _getSuggestionsList(provider);
    
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

  List<Map<String, dynamic>> _getSuggestionsList(PragasProvider provider) {
    if (provider.isLoading || provider.suggestedPragas.isEmpty) {
      return [];
    }
    
    return provider.suggestedPragas.map((praga) {
      String emoji = '🐛';
      String type = 'Inseto';
      
      switch (praga.tipoPraga) {
        case '1':
          emoji = '🐛';
          type = 'Inseto';
          break;
        case '2':
          emoji = '🦠';
          type = 'Doença';
          break;
        case '3':
          emoji = '🌿';
          type = 'Planta';
          break;
      }
      
      return {
        'name': praga.nomeComum,
        'scientific': praga.nomeCientifico,
        'type': type,
        'emoji': emoji,
      };
    }).toList();
  }

  Widget _buildRecentAccessSection(BuildContext context, PragasProvider provider) {
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
        provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.recentPragas.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma praga acessada recentemente',
                      style: TextStyle(fontSize: 14),
                    ),
                  )
                : Column(
                    children: provider.recentPragas.map((praga) {
                      String emoji = '🐛';
                      String type = 'Inseto';
                      
                      switch (praga.tipoPraga) {
                        case '1':
                          emoji = '🐛';
                          type = 'Inseto';
                          break;
                        case '2':
                          emoji = '🦠';
                          type = 'Doença';
                          break;
                        case '3':
                          emoji = '🌿';
                          type = 'Planta';
                          break;
                      }
                      
                      return _buildPragaItem(
                        context,
                        praga.nomeComum,
                        praga.nomeCientifico,
                        type,
                        _getColorForType(type, context),
                        emoji,
                      );
                    }).toList(),
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
              PragaImageWidget(
                nomeCientifico: scientificName,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(24),
                errorWidget: Container(
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
      MaterialPageRoute<void>(
        builder: (context) => DetalhePragaPage(
          pragaName: pragaName,
          pragaScientificName: scientificName,
        ),
      ),
    );
  }


  void _navigateToCategory(BuildContext context, String category) {
    switch (category) {
      case 'culturas':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const ListaCulturasPage(),
          ),
        );
        break;
      case 'insetos':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const ListaPragasPage(pragaType: '1'), // Tipo 1 = Insetos
          ),
        );
        break;
      case 'doencas':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const ListaPragasPage(pragaType: '2'), // Tipo 2 = Doenças
          ),
        );
        break;
      case 'plantas':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const ListaPragasPage(pragaType: '3'), // Tipo 3 = Plantas Daninhas
          ),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const ListaPragasPage(),
          ),
        );
    }
  }
}