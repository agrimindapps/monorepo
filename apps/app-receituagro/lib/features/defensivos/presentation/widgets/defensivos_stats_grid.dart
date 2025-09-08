import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/design/design_tokens.dart';
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
            horizontal: ReceitaAgroSpacing.sm,
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
    final buttonWidth = availableWidth - 16;
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
    final buttonWidth =
        isMediumDevice ? (availableWidth - 32) / 2 : (availableWidth - 40) / 2;
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
          width: isMediumDevice ? availableWidth - 16 : availableWidth * 0.75,
          onTap: () => onCategoryTap('defensivos'),
          icon: FontAwesomeIcons.sprayCan,
          color: standardColor,
        ),
      ],
    );
  }
}
