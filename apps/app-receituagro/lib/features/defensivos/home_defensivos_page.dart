import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'lista_defensivos_page.dart';
import '../DetalheDefensivos/detalhe_defensivo_page.dart';
import 'lista_defensivos_agrupados_page.dart';

class HomeDefensivosPage extends StatelessWidget {
  const HomeDefensivosPage({super.key});

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
                        _buildRecentAccessSection(context),
                        const SizedBox(height: 24),
                        _buildNewItemsSection(context),
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
      title: 'Defensivos',
      subtitle: '3148 Registros Disponíveis',
      leftIcon: Icons.shield_outlined,
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
              return _buildVerticalMenuLayout(availableWidth, context);
            } else {
              return _buildGridMenuLayout(availableWidth, context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildVerticalMenuLayout(double availableWidth, BuildContext context) {
    final theme = Theme.of(context);
    final buttonWidth = availableWidth - 16;
    final standardColor = theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCategoryButton(
          count: '3148',
          title: 'Defensivos',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'defensivos'),
          icon: FontAwesomeIcons.sprayCan,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: '233',
          title: 'Fabricantes',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'fabricantes'),
          icon: FontAwesomeIcons.industry,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: '98',
          title: 'Modo de Ação',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'modoAcao'),
          icon: FontAwesomeIcons.bullseye,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: '671',
          title: 'Ingrediente Ativo',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'ingredienteAtivo'),
          icon: FontAwesomeIcons.flask,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: '43',
          title: 'Classe Agronômica',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'classeAgronomica'),
          icon: FontAwesomeIcons.seedling,
          color: standardColor,
          context: context,
        ),
      ],
    );
  }

  Widget _buildGridMenuLayout(double availableWidth, BuildContext context) {
    final theme = Theme.of(context);
    final isMediumDevice = MediaQuery.of(context).size.width < 600;
    final buttonWidth = isMediumDevice ? (availableWidth - 32) / 2 : (availableWidth - 40) / 2;
    final standardColor = theme.colorScheme.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryButton(
              count: '3148',
              title: 'Defensivos',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'defensivos'),
              icon: FontAwesomeIcons.sprayCan,
              color: standardColor,
              context: context,
            ),
            const SizedBox(width: 8),
            _buildCategoryButton(
              count: '233',
              title: 'Fabricantes',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'fabricantes'),
              icon: FontAwesomeIcons.industry,
              color: standardColor,
              context: context,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryButton(
              count: '98',
              title: 'Modo de Ação',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'modoAcao'),
              icon: FontAwesomeIcons.bullseye,
              color: standardColor,
              context: context,
            ),
            const SizedBox(width: 8),
            _buildCategoryButton(
              count: '671',
              title: 'Ingrediente Ativo',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'ingredienteAtivo'),
              icon: FontAwesomeIcons.flask,
              color: standardColor,
              context: context,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: '43',
          title: 'Classe Agronômica',
          width: isMediumDevice ? availableWidth - 16 : availableWidth * 0.75,
          onTap: () => _navigateToCategory(context, 'classeAgronomica'),
          icon: FontAwesomeIcons.seedling,
          color: standardColor,
          context: context,
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
    required BuildContext context,
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
                  child: FaIcon(
                    icon ?? FontAwesomeIcons.circle,
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
                          FaIcon(
                            icon ?? FontAwesomeIcons.circle,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final items = [
                    {
                      'title': 'Alion',
                      'subtitle': 'Indaziflam',
                      'category': 'Herbicida',
                      'icon': FontAwesomeIcons.leaf,
                      'fabricante': 'Bayer',
                    },
                    {
                      'title': 'Mojiave',
                      'subtitle': 'Glifosato - Sal de Potássio + Glifos...',
                      'category': 'Herbicida',
                      'icon': FontAwesomeIcons.leaf,
                      'fabricante': 'Syngenta',
                    },
                    {
                      'title': '2,4-D Crop 806 SL',
                      'subtitle': '2,4-D + Equivalente ácido de 2,4-D',
                      'category': 'Herbicida',
                      'icon': FontAwesomeIcons.leaf,
                      'fabricante': 'Crop',
                    },
                  ];
                  
                  final item = items[index];
                  return _buildListItem(
                    context,
                    item['title'] as String,
                    item['subtitle'] as String,
                    item['category'] as String,
                    item['icon'] as IconData,
                    fabricante: item['fabricante'] as String,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewItemsSection(BuildContext context) {
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
                'Novos Defensivos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.settings,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final items = [
                    {
                      'title': 'Lungo',
                      'subtitle': 'Baculovírus Spodoptera frugiperda...',
                      'category': 'Inseticida microbiológico',
                      'icon': FontAwesomeIcons.bug,
                      'fabricante': 'FMC',
                    },
                    {
                      'title': 'BT-Turbo Max',
                      'subtitle': 'Bacillus thuringiensis var. kurstaki ...',
                      'category': 'Inseticida microbiológico',
                      'icon': FontAwesomeIcons.bug,
                      'fabricante': 'Sumitomo',
                    },
                    {
                      'title': 'BLOWOUT, CLEANOVER',
                      'subtitle': 'Dibrometo de diquate',
                      'category': 'Herbicida',
                      'icon': FontAwesomeIcons.leaf,
                      'fabricante': 'Syngenta',
                    },
                    {
                      'title': 'Biagro Solo',
                      'subtitle': 'Mix de microrganismos',
                      'category': 'Fungicida biológico',
                      'icon': FontAwesomeIcons.seedling,
                      'fabricante': 'Biagro',
                    },
                  ];
                  
                  final item = items[index];
                  return _buildListItem(
                    context,
                    item['title'] as String,
                    item['subtitle'] as String,
                    item['category'] as String,
                    item['icon'] as IconData,
                    fabricante: item['fabricante'] as String,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(BuildContext context, String title, String subtitle, String category, IconData icon, {String fabricante = 'Fabricante'}) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _navigateToDefensivoDetails(context, title, fabricante),
      borderRadius: BorderRadius.circular(12),
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              icon,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
          ),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
          ),
        ),
    );
  }

  void _navigateToDefensivoDetails(BuildContext context, String defensivoName, String fabricante) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalheDefensivoPage(
          defensivoName: defensivoName,
          fabricante: fabricante,
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    if (category == 'defensivos') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ListaDefensivosPage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListaDefensivosAgrupadosPage(
            tipoAgrupamento: category,
          ),
        ),
      );
    }
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ListaDefensivosPage(),
      ),
    );
  }
}