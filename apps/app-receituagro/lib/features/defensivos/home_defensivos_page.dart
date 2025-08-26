import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/design/design_tokens.dart';
import '../../core/di/injection_container.dart';
import '../../core/extensions/fitossanitario_hive_extension.dart';
import '../../core/models/fitossanitario_hive.dart';
import '../../core/repositories/fitossanitario_hive_repository.dart';
import '../../core/widgets/content_section_widget.dart';
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

  @override
  void dispose() {
    super.dispose();
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
                        SizedBox(height: ReceitaAgroSpacing.sm),
                        _buildStatsGrid(context),
                        SizedBox(height: ReceitaAgroSpacing.lg),
                        _buildRecentAccessSection(context),
                        SizedBox(height: ReceitaAgroSpacing.lg),
                        _buildNewItemsSection(context),
                        SizedBox(height: ReceitaAgroSpacing.bottomSafeArea),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.horizontalPadding,
      ),
      child: Card(
        elevation: ReceitaAgroElevation.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
          side: BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ReceitaAgroSpacing.sm, 
            vertical: ReceitaAgroSpacing.sm,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final screenWidth = MediaQuery.of(context).size.width;
              final isSmallDevice = screenWidth < ReceitaAgroBreakpoints.smallDevice;
              final useVerticalLayout = isSmallDevice || availableWidth < ReceitaAgroBreakpoints.verticalLayoutThreshold;

              if (useVerticalLayout) {
                return _buildVerticalMenuLayout(availableWidth, context);
              } else {
                return _buildGridMenuLayout(availableWidth, context);
              }
            },
          ),
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
        const SizedBox(height: 6),
        _buildCategoryButton(
          count: _isLoading ? '...' : '$_totalFabricantes',
          title: 'Fabricantes',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'fabricantes'),
          icon: FontAwesomeIcons.industry,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 6),
        _buildCategoryButton(
          count: _isLoading ? '...' : '$_totalModoAcao',
          title: 'Modo de Ação',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'modoAcao'),
          icon: FontAwesomeIcons.bullseye,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 6),
        _buildCategoryButton(
          count: _isLoading ? '...' : '$_totalIngredienteAtivo',
          title: 'Ingrediente Ativo',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'ingredienteAtivo'),
          icon: FontAwesomeIcons.flask,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 6),
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
    final isMediumDevice = MediaQuery.of(context).size.width < ReceitaAgroBreakpoints.mediumDevice;
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
            const SizedBox(width: 6),
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
        const SizedBox(height: 6),
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
            const SizedBox(width: 6),
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
        const SizedBox(height: 6),
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
      height: ReceitaAgroDimensions.buttonHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.button),
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
              borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.button),
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
                  padding: const EdgeInsets.all(ReceitaAgroSpacing.sm),
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
                          const SizedBox(width: 6),
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
                      const SizedBox(height: 6),
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
    return ContentSectionWidget(
      title: 'Últimos Acessados',
      actionIcon: Icons.history,
      onActionPressed: () {},
      isLoading: _isLoading,
      emptyMessage: 'Nenhum defensivo acessado recentemente',
      child: _recentDefensivos.isEmpty
          ? const SizedBox.shrink()
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentDefensivos.length,
              separatorBuilder: (context, index) => SizedBox(height: ReceitaAgroSpacing.xs),
              itemBuilder: (context, index) {
                final defensivo = _recentDefensivos[index];
                return ContentListItemWidget(
                  title: defensivo.displayName,
                  subtitle: defensivo.displayIngredient,
                  category: defensivo.displayClass,
                  icon: FontAwesomeIcons.leaf,
                  iconColor: const Color(0xFF4CAF50),
                  onTap: () => _navigateToDefensivoDetails(
                    context, 
                    defensivo.displayName, 
                    defensivo.displayFabricante,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildNewItemsSection(BuildContext context) {
    return ContentSectionWidget(
      title: 'Novos Defensivos',
      actionIcon: Icons.settings,
      onActionPressed: () {},
      isLoading: _isLoading,
      emptyMessage: 'Nenhum novo defensivo disponível',
      child: _newDefensivos.isEmpty
          ? const SizedBox.shrink()
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _newDefensivos.length,
              separatorBuilder: (context, index) => SizedBox(height: ReceitaAgroSpacing.xs),
              itemBuilder: (context, index) {
                final defensivo = _newDefensivos[index];
                return ContentListItemWidget(
                  title: defensivo.displayName,
                  subtitle: defensivo.displayIngredient,
                  category: defensivo.displayClass,
                  icon: FontAwesomeIcons.seedling,
                  iconColor: const Color(0xFF4CAF50),
                  onTap: () => _navigateToDefensivoDetails(
                    context, 
                    defensivo.displayName, 
                    defensivo.displayFabricante,
                  ),
                );
              },
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