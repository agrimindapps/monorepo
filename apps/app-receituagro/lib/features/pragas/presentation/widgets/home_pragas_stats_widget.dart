import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/design_tokens.dart';
import '../../../../core/navigation/app_navigation_provider.dart';
import '../providers/home_pragas_provider.dart';

/// Widget para exibir grid de estatísticas/categorias na home de pragas
/// 
/// Responsabilidades:
/// - Exibir botões para cada categoria (Insetos, Doenças, Plantas, Culturas)
/// - Layout responsivo (vertical em dispositivos pequenos)
/// - Navegação para páginas específicas de cada categoria
/// - Estados de loading com shimmer
class HomePragasStatsWidget extends StatelessWidget {
  final HomePragasProvider provider;

  const HomePragasStatsWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 0,
      ),
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
          child: provider.errorMessage != null
              ? _buildErrorState(context)
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isSmallDevice = screenWidth < ReceitaAgroBreakpoints.smallDevice;
                    final useVerticalLayout = isSmallDevice || 
                        availableWidth < ReceitaAgroBreakpoints.verticalLayoutThreshold;

                    if (useVerticalLayout) {
                      return _buildVerticalLayout(context, availableWidth);
                    } else {
                      return _buildGridLayout(context, availableWidth);
                    }
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(ReceitaAgroSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Erro ao carregar dados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Toque para tentar novamente',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.refreshPragasData,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context, double availableWidth) {
    final buttonWidth = (availableWidth - 16) / 3; // Três botões por linha com espaçamento reduzido
    final cultureButtonWidth = availableWidth - 8; // Botão cultura ocupa linha inteira

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primeira row: Insetos, Doenças e Plantas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCategoryButton(
              context: context,
              count: provider.isLoading ? '...' : '${provider.stats?.insetos ?? 0}',
              title: 'Insetos',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'insetos'),
              icon: Icons.bug_report,
            ),
            const SizedBox(width: 4),
            _buildCategoryButton(
              context: context,
              count: provider.isLoading ? '...' : '${provider.stats?.doencas ?? 0}',
              title: 'Doenças',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'doencas'),
              icon: Icons.coronavirus,
            ),
            const SizedBox(width: 4),
            _buildCategoryButton(
              context: context,
              count: provider.isLoading ? '...' : '${provider.stats?.plantas ?? 0}',
              title: 'Plantas',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'plantas'),
              icon: Icons.eco,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Segunda row: Culturas
        _buildCategoryButton(
          context: context,
          count: '${provider.totalCulturas}',
          title: 'Culturas',
          width: cultureButtonWidth,
          onTap: () => _navigateToCategory(context, 'culturas'),
          icon: Icons.agriculture,
        ),
      ],
    );
  }

  Widget _buildGridLayout(BuildContext context, double availableWidth) {
    final buttonWidth = (availableWidth - 16) / 3; // Três botões por linha com espaçamento reduzido
    final cultureButtonWidth = availableWidth - 8; // Botão cultura ocupa linha inteira

    return Column(
      children: [
        // Primeira row: Insetos, Doenças e Plantas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCategoryButton(
              context: context,
              count: provider.isLoading ? '...' : '${provider.stats?.insetos ?? 0}',
              title: 'Insetos',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'insetos'),
              icon: Icons.bug_report,
            ),
            const SizedBox(width: 4),
            _buildCategoryButton(
              context: context,
              count: provider.isLoading ? '...' : '${provider.stats?.doencas ?? 0}',
              title: 'Doenças',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'doencas'),
              icon: Icons.coronavirus,
            ),
            const SizedBox(width: 4),
            _buildCategoryButton(
              context: context,
              count: provider.isLoading ? '...' : '${provider.stats?.plantas ?? 0}',
              title: 'Plantas',
              width: buttonWidth,
              onTap: () => _navigateToCategory(context, 'plantas'),
              icon: Icons.eco,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Segunda row: Culturas
        _buildCategoryButton(
          context: context,
          count: '${provider.totalCulturas}',
          title: 'Culturas',
          width: cultureButtonWidth,
          onTap: () => _navigateToCategory(context, 'culturas'),
          icon: Icons.agriculture,
        ),
      ],
    );
  }

  Widget _buildCategoryButton({
    required BuildContext context,
    required String count,
    required String title,
    required double width,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final buttonColor = theme.colorScheme.primary;
    
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
                // Ícone de fundo decorativo
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Icon(
                    icon ?? Icons.circle,
                    size: 70,
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                  ),
                ),
                // Conteúdo principal
                Padding(
                  padding: const EdgeInsets.all(ReceitaAgroSpacing.sm),
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
                          const SizedBox(width: 4),
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
                // Indicador de toque
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

  void _navigateToCategory(BuildContext context, String category) {
    switch (category) {
      case 'culturas':
        context.read<AppNavigationProvider>().navigateToListaCulturas();
        break;
      case 'insetos':
        context.read<AppNavigationProvider>().navigateToListaPragas(pragaType: '1');
        break;
      case 'doencas':
        context.read<AppNavigationProvider>().navigateToListaPragas(pragaType: '2');
        break;
      case 'plantas':
        context.read<AppNavigationProvider>().navigateToListaPragas(pragaType: '3');
        break;
      default:
        context.read<AppNavigationProvider>().navigateToListaPragas();
    }
  }
}