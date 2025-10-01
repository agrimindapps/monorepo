import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../providers/home_defensivos_provider.dart';
import 'defensivos_category_button.dart';

/// Statistics grid component for Defensivos home page.
///
/// Features:
/// - Responsive layout (vertical/grid based on screen size)
/// - Category buttons with counts and navigation
/// - Adaptive sizing for different devices
///
/// Performance: Optimized with RepaintBoundary and efficient layout calculations.
class DefensivosStatsGrid extends StatelessWidget {
  const DefensivosStatsGrid({
    super.key,
    required this.provider,
    required this.onCategoryTap,
  });

  final HomeDefensivosProvider provider;
  final void Function(String category) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: ReceitaAgroElevation.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
          side: BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: ReceitaAgroSpacing.sm,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final screenWidth = MediaQuery.of(context).size.width;
              final isSmallDevice =
                  screenWidth < ReceitaAgroBreakpoints.smallDevice;
              final useVerticalLayout = isSmallDevice ||
                  availableWidth <
                      ReceitaAgroBreakpoints.verticalLayoutThreshold;

              if (useVerticalLayout) {
                return _buildVerticalLayout(availableWidth, context);
              } else {
                return _buildGridLayout(availableWidth, context);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(double availableWidth, BuildContext context) {
    final theme = Theme.of(context);
    final buttonWidth = availableWidth;  // Largura total sem padding extra
    final standardColor = theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DefensivosCategoryButton(
          count: provider.getFormattedCount(provider.totalClasseAgronomica),
          title: 'Classe Agronômica',
          width: buttonWidth,
          onTap: () => onCategoryTap('classeAgronomica'),
          icon: FontAwesomeIcons.seedling,
          color: standardColor,
        ),
        const SizedBox(height: 6),
        DefensivosCategoryButton(
          count: provider.getFormattedCount(provider.totalFabricantes),
          title: 'Fabricantes',
          width: buttonWidth,
          onTap: () => onCategoryTap('fabricantes'),
          icon: FontAwesomeIcons.industry,
          color: standardColor,
        ),
        const SizedBox(height: 6),
        DefensivosCategoryButton(
          count: provider.getFormattedCount(provider.totalModoAcao),
          title: 'Modo de Ação',
          width: buttonWidth,
          onTap: () => onCategoryTap('modoAcao'),
          icon: FontAwesomeIcons.bullseye,
          color: standardColor,
        ),
        const SizedBox(height: 6),
        DefensivosCategoryButton(
          count: provider.getFormattedCount(provider.totalIngredienteAtivo),
          title: 'Ingrediente Ativo',
          width: buttonWidth,
          onTap: () => onCategoryTap('ingredienteAtivo'),
          icon: FontAwesomeIcons.flask,
          color: standardColor,
        ),
        const SizedBox(height: 6),
        DefensivosCategoryButton(
          count: provider.getFormattedCount(provider.totalDefensivos),
          title: 'Defensivos',
          width: buttonWidth,
          onTap: () => onCategoryTap('defensivos'),
          icon: FontAwesomeIcons.sprayCan,
          color: standardColor,
        ),
      ],
    );
  }

  Widget _buildGridLayout(double availableWidth, BuildContext context) {
    final theme = Theme.of(context);
    final isMediumDevice =
        MediaQuery.of(context).size.width < ReceitaAgroBreakpoints.mediumDevice;
    final buttonWidth = (availableWidth - 6) / 2;  // Apenas o espaço do gap entre botões
    final standardColor = theme.colorScheme.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefensivosCategoryButton(
              count: provider.getFormattedCount(provider.totalClasseAgronomica),
              title: 'Classe Agronômica',
              width: buttonWidth,
              onTap: () => onCategoryTap('classeAgronomica'),
              icon: FontAwesomeIcons.seedling,
              color: standardColor,
            ),
            const SizedBox(width: 6),
            DefensivosCategoryButton(
              count: provider.getFormattedCount(provider.totalFabricantes),
              title: 'Fabricantes',
              width: buttonWidth,
              onTap: () => onCategoryTap('fabricantes'),
              icon: FontAwesomeIcons.industry,
              color: standardColor,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefensivosCategoryButton(
              count: provider.getFormattedCount(provider.totalModoAcao),
              title: 'Modo de Ação',
              width: buttonWidth,
              onTap: () => onCategoryTap('modoAcao'),
              icon: FontAwesomeIcons.bullseye,
              color: standardColor,
            ),
            const SizedBox(width: 6),
            DefensivosCategoryButton(
              count: provider.getFormattedCount(provider.totalIngredienteAtivo),
              title: 'Ingrediente Ativo',
              width: buttonWidth,
              onTap: () => onCategoryTap('ingredienteAtivo'),
              icon: FontAwesomeIcons.flask,
              color: standardColor,
            ),
          ],
        ),
        const SizedBox(height: 6),
        DefensivosCategoryButton(
          count: provider.getFormattedCount(provider.totalDefensivos),
          title: 'Defensivos',
          width: availableWidth,  // Largura total para o último botão
          onTap: () => onCategoryTap('defensivos'),
          icon: FontAwesomeIcons.sprayCan,
          color: standardColor,
        ),
      ],
    );
  }
}
