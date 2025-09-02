import 'package:flutter/material.dart';
import 'responsive_layout.dart';

/// Grid layout adaptativo que ajusta o número de colunas baseado no tamanho da tela
class AdaptiveGridLayout extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  
  /// Número de colunas para cada breakpoint
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  const AdaptiveGridLayout({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.physics,
    this.shrinkWrap = false,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    int columns = mobileColumns;
    
    if (ResponsiveBreakpoints.isDesktop(context)) {
      columns = desktopColumns;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      columns = tabletColumns;
    }

    return GridView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Grid builder adaptativo para grandes coleções
class AdaptiveGridBuilder extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  
  /// Número de colunas para cada breakpoint
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  const AdaptiveGridBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.physics,
    this.shrinkWrap = false,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    int columns = mobileColumns;
    
    if (ResponsiveBreakpoints.isDesktop(context)) {
      columns = desktopColumns;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      columns = tabletColumns;
    }

    return GridView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Grid layout específico para plantas com configurações otimizadas
class AdaptivePlantGrid extends StatelessWidget {
  final List<Widget> plants;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsets padding;

  const AdaptivePlantGrid({
    super.key,
    required this.plants,
    this.physics,
    this.shrinkWrap = false,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveGridLayout(
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      childAspectRatio: 0.85, // Proporção otimizada para cards de plantas
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 3,
      children: plants,
    );
  }
}

/// Sliver version do grid adaptativo
class SliverAdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  
  /// Número de colunas para cada breakpoint
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  const SliverAdaptiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    int columns = mobileColumns;
    
    if (ResponsiveBreakpoints.isDesktop(context)) {
      columns = desktopColumns;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      columns = tabletColumns;
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => children[index],
        childCount: children.length,
      ),
    );
  }
}

/// Helper extension para facilitar uso
extension AdaptiveGridExtension on List<Widget> {
  /// Converte lista de widgets em grid adaptativo
  Widget toAdaptiveGrid({
    double childAspectRatio = 1.0,
    double crossAxisSpacing = 16.0,
    double mainAxisSpacing = 16.0,
    EdgeInsets padding = const EdgeInsets.all(16.0),
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    return AdaptiveGridLayout(
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
      children: this,
    );
  }

  /// Converte lista de widgets em grid específico para plantas
  Widget toPlantGrid({
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsets padding = const EdgeInsets.all(16.0),
  }) {
    return AdaptivePlantGrid(
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      plants: this,
    );
  }
}