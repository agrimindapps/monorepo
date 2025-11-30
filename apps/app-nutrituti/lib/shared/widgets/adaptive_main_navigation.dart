/// Adaptive main navigation component for NutriTuti
/// Provides different navigation layouts based on screen size:
/// - Mobile: Grid-based home page
/// - Tablet: Navigation rail with content
/// - Desktop: Collapsible sidebar with content
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../core/constants/responsive_constants.dart';
import '../../database/feature_item.dart';
import '../../routes.dart';
import 'responsive_sidebar.dart';

/// Main adaptive navigation shell that changes layout based on screen size
class AdaptiveMainNavigation extends ConsumerStatefulWidget {
  const AdaptiveMainNavigation({
    super.key,
    required this.features,
    required this.onFeatureTap,
    required this.categoryColors,
    required this.onExit,
    required this.child,
  });

  final List<FeatureItem> features;
  final Function(FeatureItem) onFeatureTap;
  final Map<String, Color> categoryColors;
  final VoidCallback onExit;
  final Widget child;

  @override
  ConsumerState<AdaptiveMainNavigation> createState() =>
      _AdaptiveMainNavigationState();
}

class _AdaptiveMainNavigationState
    extends ConsumerState<AdaptiveMainNavigation> {
  bool _sidebarCollapsed = false;
  String _selectedRoute = '/';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final navigationType =
            ResponsiveLayout.getNavigationType(constraints.maxWidth);

        switch (navigationType) {
          case NavigationType.sidebar:
            return _buildDesktopSidebarLayout();
          case NavigationType.rail:
            return _buildTabletRailLayout();
          case NavigationType.bottom:
            return widget.child; // Mobile uses grid-based home
        }
      },
    );
  }

  void _navigateToRoute(String routeName) {
    setState(() => _selectedRoute = routeName);
    
    // Find the corresponding feature and navigate
    final feature = widget.features.firstWhere(
      (f) => f.routeName == routeName,
      orElse: () => widget.features.first,
    );
    widget.onFeatureTap(feature);
  }

  /// Desktop layout with collapsible sidebar
  Widget _buildDesktopSidebarLayout() {
    return Scaffold(
      body: Row(
        children: [
          ResponsiveSidebar(
            isCollapsed: _sidebarCollapsed,
            onToggle: () =>
                setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            selectedRoute: _selectedRoute,
            onNavigate: _navigateToRoute,
            onExit: widget.onExit,
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              const Color(0xFF1C1C1E),
                              const Color(0xFF0F0F0F),
                            ]
                          : [
                              const Color(0xFFF0F2F5),
                              const Color(0xFFE8ECEF),
                            ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: _buildContentArea(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Tablet layout with navigation rail
  Widget _buildTabletRailLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _getCurrentNavigationIndex(),
            onDestinationSelected: _onNavigationSelected,
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Theme.of(context).colorScheme.surface,
            indicatorColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            unselectedIconTheme: IconThemeData(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    onPressed: widget.onExit,
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: 'Sair do Módulo',
                  ),
                ),
              ),
            ),
            destinations: _getNavigationRailDestinations(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              const Color(0xFF1C1C1E),
                              const Color(0xFF0F0F0F),
                            ]
                          : [
                              const Color(0xFFF0F2F5),
                              const Color(0xFFE8ECEF),
                            ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: _buildContentArea(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Content area with feature grid
  Widget _buildContentArea() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.teal.shade500,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.health_and_safety,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sua saúde em primeiro lugar',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Escolha uma ferramenta na barra lateral ou clique abaixo',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Ferramentas Disponíveis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(32),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final feature = widget.features[index];
                    return _FeatureGridCard(
                      feature: feature,
                      color: widget.categoryColors[feature.title] ??
                          Theme.of(context).colorScheme.primary,
                      onTap: () => widget.onFeatureTap(feature),
                    );
                  },
                  childCount: widget.features.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCurrentNavigationIndex() {
    final routeIndexMap = {
      AppRoutes.beberAgua: 0,
      AppRoutes.calculos: 1,
      AppRoutes.exercicios: 2,
      AppRoutes.meditacao: 3,
      AppRoutes.peso: 4,
      AppRoutes.pratos: 5,
      AppRoutes.receitas: 6,
      AppRoutes.alimentos: 7,
      AppRoutes.asmr: 8,
    };
    return routeIndexMap[_selectedRoute] ?? 0;
  }

  void _onNavigationSelected(int index) {
    final routes = [
      AppRoutes.beberAgua,
      AppRoutes.calculos,
      AppRoutes.exercicios,
      AppRoutes.meditacao,
      AppRoutes.peso,
      AppRoutes.pratos,
      AppRoutes.receitas,
      AppRoutes.alimentos,
      AppRoutes.asmr,
    ];
    if (index < routes.length) {
      _navigateToRoute(routes[index]);
    }
  }

  List<NavigationRailDestination> _getNavigationRailDestinations() {
    return const [
      NavigationRailDestination(
        icon: Icon(FontAwesome.glass_water_solid),
        label: Text('Água'),
      ),
      NavigationRailDestination(
        icon: Icon(FontAwesome.calculator_solid),
        label: Text('Cálculos'),
      ),
      NavigationRailDestination(
        icon: Icon(FontAwesome.dumbbell_solid),
        label: Text('Exercícios'),
      ),
      NavigationRailDestination(
        icon: Icon(FontAwesome.spa_solid),
        label: Text('Meditação'),
      ),
      NavigationRailDestination(
        icon: Icon(FontAwesome.weight_scale_solid),
        label: Text('Peso'),
      ),
      NavigationRailDestination(
        icon: Icon(FontAwesome.utensils_solid),
        label: Text('Pratos'),
      ),
      NavigationRailDestination(
        icon: Icon(FontAwesome.bowl_food_solid),
        label: Text('Receitas'),
      ),
      NavigationRailDestination(
        icon: Icon(FontAwesome.apple_whole_solid),
        label: Text('Alimentos'),
      ),
      NavigationRailDestination(
        icon: Icon(FontAwesome.headphones_simple_solid),
        label: Text('ASMR'),
      ),
    ];
  }
}

/// Feature grid card for desktop/tablet view
class _FeatureGridCard extends StatefulWidget {
  const _FeatureGridCard({
    required this.feature,
    required this.color,
    required this.onTap,
  });

  final FeatureItem feature;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_FeatureGridCard> createState() => _FeatureGridCardState();
}

class _FeatureGridCardState extends State<_FeatureGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: _isHovered ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color.withValues(alpha: _isHovered ? 0.15 : 0.1),
                    widget.color.withValues(alpha: _isHovered ? 0.08 : 0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.feature.icon,
                      color: widget.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.feature.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.feature.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
