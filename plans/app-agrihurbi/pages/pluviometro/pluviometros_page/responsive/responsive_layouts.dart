// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'responsive_breakpoints.dart';

/// Layout responsivo para a página de pluviômetros
class ResponsivePluviometrosLayout extends StatelessWidget {
  final Widget header;
  final Widget filters;
  final Widget content;
  final Widget? floatingActionButton;
  final Widget? bottomBar;

  const ResponsivePluviometrosLayout({
    super.key,
    required this.header,
    required this.filters,
    required this.content,
    this.floatingActionButton,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        if (info.isMobile) {
          return _buildMobileLayout(info);
        } else if (info.isTablet) {
          return _buildTabletLayout(info);
        } else {
          return _buildDesktopLayout(info);
        }
      },
    );
  }

  Widget _buildMobileLayout(ResponsiveInfo info) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header fixo
            Container(
              padding: EdgeInsets.symmetric(horizontal: info.horizontalPadding),
              child: header,
            ),

            // Filtros colapsáveis em mobile
            _CollapsibleFilters(
              filters: filters,
              isExpanded: false,
              horizontalPadding: info.horizontalPadding,
            ),

            // Conteúdo principal
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: info.horizontalPadding),
                child: content,
              ),
            ),

            // Bottom bar se fornecido
            if (bottomBar != null)
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: info.horizontalPadding),
                child: bottomBar,
              ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildTabletLayout(ResponsiveInfo info) {
    return Scaffold(
      body: SafeArea(
        child: info.isLandscape
            ? _buildTabletLandscape(info)
            : _buildTabletPortrait(info),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildTabletPortrait(ResponsiveInfo info) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: info.horizontalPadding),
          child: header,
        ),

        // Filtros sempre visíveis em tablet portrait
        Container(
          padding: EdgeInsets.symmetric(horizontal: info.horizontalPadding),
          child: filters,
        ),

        // Conteúdo
        Expanded(
          child: Container(
            width: info.maxContentWidth,
            padding: EdgeInsets.symmetric(horizontal: info.horizontalPadding),
            child: content,
          ),
        ),

        if (bottomBar != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: info.horizontalPadding),
            child: bottomBar,
          ),
      ],
    );
  }

  Widget _buildTabletLandscape(ResponsiveInfo info) {
    return Row(
      children: [
        // Sidebar com filtros
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Column(
            children: [
              header,
              const Divider(),
              Expanded(child: filters),
              if (bottomBar != null) bottomBar!,
            ],
          ),
        ),

        // Conteúdo principal
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: info.horizontalPadding),
            child: content,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(ResponsiveInfo info) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar fixa com filtros
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: header,
                ),
                const Divider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: filters,
                  ),
                ),
                if (bottomBar != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: bottomBar,
                  ),
              ],
            ),
          ),

          // Conteúdo principal
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxWidth: info.maxContentWidth),
              padding: EdgeInsets.symmetric(horizontal: info.horizontalPadding),
              child: content,
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Filtros colapsáveis para mobile
class _CollapsibleFilters extends StatefulWidget {
  final Widget filters;
  final bool isExpanded;
  final double horizontalPadding;

  const _CollapsibleFilters({
    required this.filters,
    required this.isExpanded,
    required this.horizontalPadding,
  });

  @override
  State<_CollapsibleFilters> createState() => _CollapsibleFiltersState();
}

class _CollapsibleFiltersState extends State<_CollapsibleFilters>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header do filtro
        InkWell(
          onTap: _toggle,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.horizontalPadding,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Filtros',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.expand_more),
                ),
              ],
            ),
          ),
        ),

        // Conteúdo dos filtros
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: widget.filters,
          ),
        ),
      ],
    );
  }
}

/// Grid responsivo para lista de itens
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? itemHeight;
  final EdgeInsets? padding;
  final double? spacing;
  final double? runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.itemHeight,
    this.padding,
    this.spacing,
    this.runSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        final columns = info.gridColumns;
        final itemSpacing = spacing ?? info.getSpacing();
        final itemRunSpacing = runSpacing ?? info.getSpacing();

        if (columns == 1) {
          // Lista simples para mobile
          return ListView.separated(
            padding: padding ?? EdgeInsets.all(info.horizontalPadding),
            itemCount: children.length,
            separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
            itemBuilder: (context, index) => children[index],
          );
        }

        // Grid para tablets e desktop
        return GridView.builder(
          padding: padding ?? EdgeInsets.all(info.horizontalPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: itemSpacing,
            mainAxisSpacing: itemRunSpacing,
            mainAxisExtent: itemHeight ?? info.getItemHeight(),
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Card responsivo que adapta seu conteúdo baseado no tamanho da tela
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        final cardPadding = padding ?? EdgeInsets.all(info.getSpacing());

        return Card(
          elevation: info.isMobile ? 1 : 2,
          margin: EdgeInsets.zero,
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(info.isMobile ? 8 : 12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(info.isMobile ? 8 : 12),
            child: Padding(
              padding: cardPadding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Container que adapta sua largura máxima baseado na tela
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Alignment? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: info.maxContentWidth),
            padding: padding ??
                EdgeInsets.symmetric(horizontal: info.horizontalPadding),
            margin: margin,
            color: color,
            alignment: alignment,
            child: child,
          ),
        );
      },
    );
  }
}

/// Texto responsivo que adapta o tamanho da fonte
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        final fontSize = info.getFontSize(
          mobile: mobileFontSize ?? 14,
          tablet: tabletFontSize ?? 16,
          desktop: desktopFontSize ?? 18,
        );

        return Text(
          text,
          style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
