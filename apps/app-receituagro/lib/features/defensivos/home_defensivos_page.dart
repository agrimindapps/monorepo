import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/di/injection_container.dart';
import '../../core/extensions/fitossanitario_hive_extension.dart';
import '../../core/models/fitossanitario_hive.dart';
import '../../core/repositories/fitossanitario_hive_repository.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../DetalheDefensivos/detalhe_defensivo_page.dart';
import 'lista_defensivos_agrupados_page.dart';
import 'lista_defensivos_page.dart';

class HomeDefensivosPage extends StatefulWidget {
  const HomeDefensivosPage({super.key});

  @override
  State<HomeDefensivosPage> createState() => _HomeDefensivosPageState();
}

class _HomeDefensivosPageState extends State<HomeDefensivosPage> {
  final FitossanitarioHiveRepository _repository = sl<FitossanitarioHiveRepository>();
  bool _isLoading = true;
  
  // Contadores reais
  int _totalDefensivos = 0;
  int _totalFabricantes = 0;
  int _totalModoAcao = 0;
  int _totalIngredienteAtivo = 0;
  int _totalClasseAgronomica = 0;
  
  // Listas para dados reais
  List<FitossanitarioHive> _recentDefensivos = [];
  List<FitossanitarioHive> _newDefensivos = [];

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final defensivos = _repository.getActiveDefensivos();
      
      // Calcular totais reais
      _totalDefensivos = defensivos.length;
      _totalFabricantes = defensivos.map((d) => d.displayFabricante).toSet().length;
      _totalModoAcao = defensivos.map((d) => d.displayModoAcao).where((m) => m.isNotEmpty).toSet().length;
      _totalIngredienteAtivo = defensivos.map((d) => d.displayIngredient).where((i) => i.isNotEmpty).toSet().length;
      _totalClasseAgronomica = defensivos.map((d) => d.displayClass).where((c) => c.isNotEmpty).toSet().length;
      
      // Últimos acessados (simulação com defensivos aleatórios)
      _recentDefensivos = defensivos.take(3).toList();
      
      // Novos defensivos (últimos por data de registro)
      _newDefensivos = defensivos.take(4).toList();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Em caso de erro, manter valores padrão
          _totalDefensivos = 0;
          _totalFabricantes = 0;
          _totalModoAcao = 0;
          _totalIngredienteAtivo = 0;
          _totalClasseAgronomica = 0;
        });
      }
    }
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
    String subtitle = 'Carregando defensivos...';
    if (!_isLoading) {
      subtitle = '$_totalDefensivos Registros Disponíveis';
    }
    
    return ModernHeaderWidget(
      title: 'Defensivos',
      subtitle: subtitle,
      leftIcon: Icons.shield_outlined,
      showBackButton: false,
      showActions: false,
      isDark: isDark,
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
          count: _isLoading ? '...' : '$_totalDefensivos',
          title: 'Defensivos',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'defensivos'),
          icon: FontAwesomeIcons.sprayCan,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: _isLoading ? '...' : '$_totalFabricantes',
          title: 'Fabricantes',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'fabricantes'),
          icon: FontAwesomeIcons.industry,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: _isLoading ? '...' : '$_totalModoAcao',
          title: 'Modo de Ação',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'modoAcao'),
          icon: FontAwesomeIcons.bullseye,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: _isLoading ? '...' : '$_totalIngredienteAtivo',
          title: 'Ingrediente Ativo',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'ingredienteAtivo'),
          icon: FontAwesomeIcons.flask,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 8),
        _buildCategoryButton(
          count: _isLoading ? '...' : '$_totalClasseAgronomica',
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
              count: _isLoading ? '...' : '$_totalDefensivos',
              title: 'Defensivos',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'defensivos'),
              icon: FontAwesomeIcons.sprayCan,
              color: standardColor,
              context: context,
            ),
            const SizedBox(width: 8),
            _buildCategoryButton(
              count: _isLoading ? '...' : '$_totalFabricantes',
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
              count: _isLoading ? '...' : '$_totalModoAcao',
              title: 'Modo de Ação',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'modoAcao'),
              icon: FontAwesomeIcons.bullseye,
              color: standardColor,
              context: context,
            ),
            const SizedBox(width: 8),
            _buildCategoryButton(
              count: _isLoading ? '...' : '$_totalIngredienteAtivo',
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
          count: _isLoading ? '...' : '$_totalClasseAgronomica',
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recentDefensivos.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum defensivo acessado recentemente',
                            style: TextStyle(fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentDefensivos.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final defensivo = _recentDefensivos[index];
                            return _buildListItem(
                              context,
                              defensivo.displayName,
                              defensivo.displayIngredient,
                              defensivo.displayClass,
                              FontAwesomeIcons.leaf,
                              fabricante: defensivo.displayFabricante,
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _newDefensivos.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum novo defensivo disponível',
                            style: TextStyle(fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _newDefensivos.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final defensivo = _newDefensivos[index];
                            return _buildListItem(
                              context,
                              defensivo.displayName,
                              defensivo.displayIngredient,
                              defensivo.displayClass,
                              FontAwesomeIcons.seedling,
                              fabricante: defensivo.displayFabricante,
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

}