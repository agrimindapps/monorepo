import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../providers/home_defensivos_notifier.dart';
import 'defensivos_category_button.dart';

/// Statistics grid component for Defensivos home page.
///
/// Features:
/// - Responsive layout (vertical/grid based on screen size)
/// - Category buttons with counts and navigation
/// - Adaptive sizing for different devices
///
/// Performance: Optimized with RepaintBoundary and efficient layout calculations.
/// Migrated to Riverpod - uses ConsumerWidget.
class DefensivosStatsGrid extends ConsumerWidget {
  const DefensivosStatsGrid({super.key, required this.onCategoryTap});

  final void Function(String category) onCategoryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDefensivosNotifierProvider);

    return state.when(
      data:
          (data) => RepaintBoundary(
            child: Card(
              elevation: ReceitaAgroElevation.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ReceitaAgroBorderRadius.card,
                ),
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
                    final useVerticalLayout =
                        isSmallDevice ||
                        availableWidth <
                            ReceitaAgroBreakpoints.verticalLayoutThreshold;

                    if (useVerticalLayout) {
                      return _buildVerticalLayout(
                        availableWidth,
                        context,
                        data,
                      );
                    } else {
                      return _buildGridLayout(availableWidth, context, data);
                    }
                  },
                ),
              ),
            ),
          ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildVerticalLayout(
    double availableWidth,
    BuildContext context,
    HomeDefensivosState data,
  ) {
    final theme = Theme.of(context);
    final buttonWidth = availableWidth; // Largura total sem padding extra
    final standardColor = theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DefensivosCategoryButton(
          count: data.getFormattedCount(data.totalClasseAgronomica),
          title: 'Classe Agronômica',
          width: buttonWidth,
          onTap: () => onCategoryTap('classeAgronomica'),
          icon: FontAwesomeIcons.seedling,
          color: standardColor,
        ),
        const SizedBox(height: 6),
        DefensivosCategoryButton(
          count: data.getFormattedCount(data.totalFabricantes),
          title: 'Fabricantes',
          width: buttonWidth,
          onTap: () => onCategoryTap('fabricantes'),
          icon: FontAwesomeIcons.industry,
          color: standardColor,
        ),
        const SizedBox(height: 6),
        DefensivosCategoryButton(
          count: data.getFormattedCount(data.totalModoAcao),
          title: 'Modo de Ação',
          width: buttonWidth,
          onTap: () => onCategoryTap('modoAcao'),
          icon: FontAwesomeIcons.bullseye,
          color: standardColor,
        ),
        const SizedBox(height: 6),
        DefensivosCategoryButton(
          count: data.getFormattedCount(data.totalIngredienteAtivo),
          title: 'Ingrediente Ativo',
          width: buttonWidth,
          onTap: () => onCategoryTap('ingredienteAtivo'),
          icon: FontAwesomeIcons.flask,
          color: standardColor,
        ),
        const SizedBox(height: 6),
        DefensivosCategoryButton(
          count: data.getFormattedCount(data.totalDefensivos),
          title: 'Defensivos',
          width: buttonWidth,
          onTap: () => onCategoryTap('defensivos'),
          icon: FontAwesomeIcons.sprayCan,
          color: standardColor,
        ),
      ],
    );
  }

  Widget _buildGridLayout(
    double availableWidth,
    BuildContext context,
    HomeDefensivosState data,
  ) {
    final theme = Theme.of(context);
    final buttonWidth =
        (availableWidth - 6) / 2; // Apenas o espaço do gap entre botões
    final standardColor = theme.colorScheme.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefensivosCategoryButton(
              count: data.getFormattedCount(data.totalClasseAgronomica),
              title: 'Classe Agronômica',
              width: buttonWidth,
              onTap: () => onCategoryTap('classeAgronomica'),
              icon: FontAwesomeIcons.seedling,
              color: standardColor,
            ),
            const SizedBox(width: 6),
            DefensivosCategoryButton(
              count: data.getFormattedCount(data.totalFabricantes),
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
              count: data.getFormattedCount(data.totalModoAcao),
              title: 'Modo de Ação',
              width: buttonWidth,
              onTap: () => onCategoryTap('modoAcao'),
              icon: FontAwesomeIcons.bullseye,
              color: standardColor,
            ),
            const SizedBox(width: 6),
            DefensivosCategoryButton(
              count: data.getFormattedCount(data.totalIngredienteAtivo),
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
          count: data.getFormattedCount(data.totalDefensivos),
          title: 'Defensivos',
          width: availableWidth, // Largura total para o último botão
          onTap: () => onCategoryTap('defensivos'),
          icon: FontAwesomeIcons.sprayCan,
          color: standardColor,
        ),
      ],
    );
  }
}
