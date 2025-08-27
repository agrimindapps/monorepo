import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

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
import 'presentation/providers/home_defensivos_provider.dart';


/// Página Home de Defensivos refatorada seguindo Clean Architecture
/// 
/// Performance optimizations implemented:
/// - Uses Provider pattern instead of direct repository access
/// - Heavy calculations moved to background isolate via compute()
/// - Consolidated state management with single notifyListeners()
/// - Proper separation of concerns between UI and business logic
class HomeDefensivosPage extends StatelessWidget {
  const HomeDefensivosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeDefensivosProvider>(
      create: (_) => HomeDefensivosProvider(
        repository: sl<FitossanitarioHiveRepository>(),
      )..loadData(),
      child: const _HomeDefensivosView(),
    );
  }
}

class _HomeDefensivosView extends StatefulWidget {
  const _HomeDefensivosView();

  @override
  State<_HomeDefensivosView> createState() => _HomeDefensivosViewState();
}

class _HomeDefensivosViewState extends State<_HomeDefensivosView> {
  @override
  void initState() {
    super.initState();
    // No manual data loading needed - Provider handles initialization
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
            Consumer<HomeDefensivosProvider>(
              builder: (context, provider, _) => _buildModernHeader(context, isDark, provider),
            ),
            Expanded(
              child: Consumer<HomeDefensivosProvider>(
                builder: (context, provider, _) {
                  // Handle error state
                  if (provider.errorMessage != null) {
                    return _buildErrorState(context, provider);
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () => provider.refreshData(),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: ReceitaAgroSpacing.sm),
                              _buildStatsGrid(context, provider),
                              const SizedBox(height: 24),
                              _buildRecentAccessSection(context, provider),
                              const SizedBox(height: 32),
                              _buildNewItemsSection(context, provider),
                              const SizedBox(height: ReceitaAgroSpacing.bottomSafeArea),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark, HomeDefensivosProvider provider) {
    return ModernHeaderWidget(
      title: 'Defensivos',
      subtitle: provider.headerSubtitle,
      leftIcon: Icons.shield_outlined,
      showBackButton: false,
      showActions: false,
      isDark: isDark,
    );
  }
  
  Widget _buildErrorState(BuildContext context, HomeDefensivosProvider provider) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReceitaAgroSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: ReceitaAgroSpacing.md),
            Text(
              provider.errorMessage ?? 'Erro desconhecido',
              style: ReceitaAgroTypography.sectionTitle.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ReceitaAgroSpacing.lg),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.loadData();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, HomeDefensivosProvider provider) {
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
                return _buildVerticalMenuLayout(availableWidth, context, provider);
              } else {
                return _buildGridMenuLayout(availableWidth, context, provider);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalMenuLayout(double availableWidth, BuildContext context, HomeDefensivosProvider provider) {
    final theme = Theme.of(context);
    final buttonWidth = availableWidth - 16;
    final standardColor = theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCategoryButton(
          count: provider.getFormattedCount(provider.totalDefensivos),
          title: 'Defensivos',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'defensivos'),
          icon: FontAwesomeIcons.sprayCan,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 6),
        _buildCategoryButton(
          count: provider.getFormattedCount(provider.totalFabricantes),
          title: 'Fabricantes',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'fabricantes'),
          icon: FontAwesomeIcons.industry,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 6),
        _buildCategoryButton(
          count: provider.getFormattedCount(provider.totalModoAcao),
          title: 'Modo de Ação',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'modoAcao'),
          icon: FontAwesomeIcons.bullseye,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 6),
        _buildCategoryButton(
          count: provider.getFormattedCount(provider.totalIngredienteAtivo),
          title: 'Ingrediente Ativo',
          width: buttonWidth,
          onTap: () => _navigateToCategory(context, 'ingredienteAtivo'),
          icon: FontAwesomeIcons.flask,
          color: standardColor,
          context: context,
        ),
        const SizedBox(height: 6),
        _buildCategoryButton(
          count: provider.getFormattedCount(provider.totalClasseAgronomica),
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

  Widget _buildGridMenuLayout(double availableWidth, BuildContext context, HomeDefensivosProvider provider) {
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
              count: provider.getFormattedCount(provider.totalDefensivos),
              title: 'Defensivos',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'defensivos'),
              icon: FontAwesomeIcons.sprayCan,
              color: standardColor,
              context: context,
            ),
            const SizedBox(width: 6),
            _buildCategoryButton(
              count: provider.getFormattedCount(provider.totalFabricantes),
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
              count: provider.getFormattedCount(provider.totalModoAcao),
              title: 'Modo de Ação',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'modoAcao'),
              icon: FontAwesomeIcons.bullseye,
              color: standardColor,
              context: context,
            ),
            const SizedBox(width: 6),
            _buildCategoryButton(
              count: provider.getFormattedCount(provider.totalIngredienteAtivo),
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
          count: provider.getFormattedCount(provider.totalClasseAgronomica),
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

  Widget _buildRecentAccessSection(BuildContext context, HomeDefensivosProvider provider) {
    return ContentSectionWidget(
      title: 'Últimos Acessados',
      actionIcon: Icons.history,
      onActionPressed: () {},
      isLoading: provider.isLoading,
      emptyMessage: 'Nenhum defensivo acessado recentemente',
      isEmpty: provider.recentDefensivos.isEmpty,
      showCard: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.recentDefensivos.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 0.5,
          indent: 80, // Alinhado com o texto (ícone + espaço)
          endIndent: 16,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final defensivo = provider.recentDefensivos[index];
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
              defensivo,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewItemsSection(BuildContext context, HomeDefensivosProvider provider) {
    return ContentSectionWidget(
      title: 'Novos Defensivos',
      actionIcon: Icons.settings,
      onActionPressed: () {},
      isLoading: provider.isLoading,
      emptyMessage: 'Nenhum novo defensivo disponível',
      isEmpty: provider.newDefensivos.isEmpty,
      showCard: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.newDefensivos.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 0.5,
          indent: 80, // Alinhado com o texto (ícone + espaço)
          endIndent: 16,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final defensivo = provider.newDefensivos[index];
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
              defensivo,
            ),
          );
        },
      ),
    );
  }


  void _navigateToDefensivoDetails(BuildContext context, String defensivoName, String fabricante, [FitossanitarioHive? defensivo]) {
    // Registra o acesso se o defensivo foi fornecido (em background)
    if (defensivo != null) {
      final provider = context.read<HomeDefensivosProvider>();
      provider.recordDefensivoAccess(defensivo);
    }
    
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetalheDefensivoPage(
          defensivoName: defensivoName,
          fabricante: fabricante,
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    if (category == 'defensivos') {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const ListaDefensivosPage(),
        ),
      );
    } else {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => ListaDefensivosAgrupadosPage(
            tipoAgrupamento: category,
          ),
        ),
      );
    }
  }

}