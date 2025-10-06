import 'package:flutter/material.dart';
import '../../../core/theme/loading_design_tokens.dart';

/// Widget para skeleton loading que simula o conteúdo da página
/// Usado para dar preview do que está sendo carregado
class SkeletonLoading extends StatefulWidget {

  const SkeletonLoading({
    super.key,
    this.itemCount = 3,
    this.padding,
    this.animate = true,
    this.baseColor,
    this.highlightColor,
    required this.type,
  });
  final SkeletonType type;
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final bool animate;
  final Color? baseColor;
  final Color? highlightColor;

  /// Factory para skeleton de veículos
  static SkeletonLoading vehicles({
    Key? key,
    int itemCount = 3,
    EdgeInsetsGeometry? padding,
  }) {
    return SkeletonLoading(
      key: key,
      itemCount: itemCount,
      padding: padding,
      type: SkeletonType.vehicles,
    );
  }

  /// Factory para skeleton de lista simples
  static SkeletonLoading list({
    Key? key,
    int itemCount = 5,
    EdgeInsetsGeometry? padding,
  }) {
    return SkeletonLoading(
      key: key,
      itemCount: itemCount,
      padding: padding,
      type: SkeletonType.list,
    );
  }

  /// Factory para skeleton de cartões
  static SkeletonLoading cards({
    Key? key,
    int itemCount = 2,
    EdgeInsetsGeometry? padding,
  }) {
    return SkeletonLoading(
      key: key,
      type: SkeletonType.cards,
      itemCount: itemCount,
      padding: padding,
    );
  }

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _setupAnimation();
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = LoadingDesignTokens.getColorScheme(context);
    
    Widget content;
    
    switch (widget.type) {
      case SkeletonType.vehicles:
        content = _buildVehiclesSkeleton(colors);
        break;
      case SkeletonType.list:
        content = _buildListSkeleton(colors);
        break;
      case SkeletonType.cards:
        content = _buildCardsSkeleton(colors);
        break;
      case SkeletonType.profile:
        content = _buildProfileSkeleton(colors);
        break;
      case SkeletonType.dashboard:
        content = _buildDashboardSkeleton(colors);
        break;
    }

    if (widget.animate) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: content,
          );
        },
      );
    }

    return content;
  }

  Widget _buildVehiclesSkeleton(LoadingColorScheme colors) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(LoadingDesignTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonBox(
            width: 120,
            height: LoadingDesignTokens.skeletonHeightLg,
            colors: colors,
          ),
          const SizedBox(height: LoadingDesignTokens.spacingLg),
          ...List.generate(widget.itemCount, (index) => 
            _buildVehicleCard(colors, index)
          ),

          const SizedBox(height: LoadingDesignTokens.spacingLg),
          _buildSkeletonBox(
            width: double.infinity,
            height: 48,
            colors: colors,
            borderRadius: LoadingDesignTokens.borderRadiusMd,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(LoadingColorScheme colors, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: LoadingDesignTokens.spacingMd),
      child: Card(
        color: colors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusMd),
        ),
        child: Padding(
          padding: const EdgeInsets.all(LoadingDesignTokens.spacingMd),
          child: Row(
            children: [
              _buildSkeletonBox(
                width: LoadingDesignTokens.skeletonAvatarSize,
                height: LoadingDesignTokens.skeletonAvatarSize,
                colors: colors,
                isCircular: true,
              ),
              
              const SizedBox(width: LoadingDesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonBox(
                      width: 140 + (index * 20.0),
                      height: LoadingDesignTokens.skeletonHeight,
                      colors: colors,
                    ),
                    
                    const SizedBox(height: LoadingDesignTokens.spacingSm),
                    _buildSkeletonBox(
                      width: 100,
                      height: LoadingDesignTokens.skeletonHeightSm,
                      colors: colors,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildSkeletonBox(
                    width: 60,
                    height: LoadingDesignTokens.skeletonHeightSm,
                    colors: colors,
                  ),
                  const SizedBox(height: LoadingDesignTokens.spacingXs),
                  _buildSkeletonBox(
                    width: 80,
                    height: LoadingDesignTokens.skeletonHeightSm,
                    colors: colors,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListSkeleton(LoadingColorScheme colors) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(LoadingDesignTokens.spacingMd),
      child: Column(
        children: List.generate(widget.itemCount, (index) => 
          Container(
            margin: const EdgeInsets.only(bottom: LoadingDesignTokens.spacingMd),
            child: Row(
              children: [
                _buildSkeletonBox(
                  width: 40,
                  height: 40,
                  colors: colors,
                  isCircular: true,
                ),
                
                const SizedBox(width: LoadingDesignTokens.spacingMd),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonBox(
                        width: double.infinity,
                        height: LoadingDesignTokens.skeletonHeight,
                        colors: colors,
                      ),
                      
                      const SizedBox(height: LoadingDesignTokens.spacingXs),
                      
                      _buildSkeletonBox(
                        width: 200,
                        height: LoadingDesignTokens.skeletonHeightSm,
                        colors: colors,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  Widget _buildCardsSkeleton(LoadingColorScheme colors) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(LoadingDesignTokens.spacingMd),
      child: Column(
        children: List.generate(widget.itemCount, (index) => 
          Container(
            margin: const EdgeInsets.only(bottom: LoadingDesignTokens.spacingMd),
            child: Card(
              color: colors.surface,
              child: Padding(
                padding: const EdgeInsets.all(LoadingDesignTokens.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonBox(
                      width: double.infinity,
                      height: LoadingDesignTokens.skeletonCardHeight,
                      colors: colors,
                    ),
                    
                    const SizedBox(height: LoadingDesignTokens.spacingMd),
                    
                    _buildSkeletonBox(
                      width: 150,
                      height: LoadingDesignTokens.skeletonHeight,
                      colors: colors,
                    ),
                    
                    const SizedBox(height: LoadingDesignTokens.spacingSm),
                    
                    _buildSkeletonBox(
                      width: double.infinity,
                      height: LoadingDesignTokens.skeletonHeightSm,
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ),
          )
        ),
      ),
    );
  }

  Widget _buildProfileSkeleton(LoadingColorScheme colors) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(LoadingDesignTokens.spacingMd),
      child: Column(
        children: [
          _buildSkeletonBox(
            width: 80,
            height: 80,
            colors: colors,
            isCircular: true,
          ),
          
          const SizedBox(height: LoadingDesignTokens.spacingMd),
          _buildSkeletonBox(
            width: 160,
            height: LoadingDesignTokens.skeletonHeightLg,
            colors: colors,
          ),
          
          const SizedBox(height: LoadingDesignTokens.spacingSm),
          _buildSkeletonBox(
            width: 200,
            height: LoadingDesignTokens.skeletonHeight,
            colors: colors,
          ),
          
          const SizedBox(height: LoadingDesignTokens.spacingLg),
          ...List.generate(3, (index) => 
            Container(
              margin: const EdgeInsets.only(bottom: LoadingDesignTokens.spacingMd),
              child: Row(
                children: [
                  _buildSkeletonBox(
                    width: 24,
                    height: 24,
                    colors: colors,
                    isCircular: true,
                  ),
                  
                  const SizedBox(width: LoadingDesignTokens.spacingMd),
                  
                  _buildSkeletonBox(
                    width: 180,
                    height: LoadingDesignTokens.skeletonHeight,
                    colors: colors,
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSkeleton(LoadingColorScheme colors) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(LoadingDesignTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(colors),
              ),
              const SizedBox(width: LoadingDesignTokens.spacingMd),
              Expanded(
                child: _buildStatCard(colors),
              ),
            ],
          ),
          
          const SizedBox(height: LoadingDesignTokens.spacingLg),
          _buildSkeletonBox(
            width: 140,
            height: LoadingDesignTokens.skeletonHeightLg,
            colors: colors,
          ),
          
          const SizedBox(height: LoadingDesignTokens.spacingMd),
          ...List.generate(widget.itemCount, (index) => 
            Container(
              margin: const EdgeInsets.only(bottom: LoadingDesignTokens.spacingMd),
              child: _buildSkeletonBox(
                width: double.infinity,
                height: 60,
                colors: colors,
                borderRadius: LoadingDesignTokens.borderRadiusSm,
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(LoadingColorScheme colors) {
    return Card(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LoadingDesignTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSkeletonBox(
              width: 60,
              height: LoadingDesignTokens.skeletonHeightSm,
              colors: colors,
            ),
            
            const SizedBox(height: LoadingDesignTokens.spacingSm),
            
            _buildSkeletonBox(
              width: 80,
              height: LoadingDesignTokens.skeletonHeightLg + 4,
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    required LoadingColorScheme colors,
    double? borderRadius,
    bool isCircular = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: widget.baseColor ?? colors.onSurface.withValues(alpha: 0.1),
        borderRadius: isCircular 
          ? null 
          : BorderRadius.circular(borderRadius ?? LoadingDesignTokens.borderRadiusSm),
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

/// Widget especializado para skeleton da página de veículos
class VehiclesSkeleton extends StatelessWidget {

  const VehiclesSkeleton({
    super.key,
    this.vehicleCount = 3,
    this.showStats = true,
    this.padding,
  });
  final int vehicleCount;
  final bool showStats;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = LoadingDesignTokens.getColorScheme(context);
    
    return Container(
      padding: padding ?? const EdgeInsets.all(LoadingDesignTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colors),
          
          const SizedBox(height: LoadingDesignTokens.spacingLg),
          if (showStats) ...[
            _buildStatsSection(colors),
            const SizedBox(height: LoadingDesignTokens.spacingLg),
          ],
          _buildVehiclesList(colors),
        ],
      ),
    );
  }

  Widget _buildHeader(LoadingColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 24,
              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusSm),
              ),
            ),
            const SizedBox(height: LoadingDesignTokens.spacingSm),
            Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusSm),
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.onSurface.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(LoadingColorScheme colors) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(colors, 'Total')),
        const SizedBox(width: LoadingDesignTokens.spacingMd),
        Expanded(child: _buildStatCard(colors, 'Ativo')),
        const SizedBox(width: LoadingDesignTokens.spacingMd),
        Expanded(child: _buildStatCard(colors, 'Km/mês')),
      ],
    );
  }

  Widget _buildStatCard(LoadingColorScheme colors, String label) {
    return Container(
      padding: const EdgeInsets.all(LoadingDesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusMd),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 12,
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusSm),
            ),
          ),
          const SizedBox(height: LoadingDesignTokens.spacingSm),
          Container(
            width: 60,
            height: 20,
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusSm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesList(LoadingColorScheme colors) {
    return Column(
      children: List.generate(vehicleCount, (index) => 
        Container(
          margin: const EdgeInsets.only(bottom: LoadingDesignTokens.spacingMd),
          padding: const EdgeInsets.all(LoadingDesignTokens.spacingMd),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusMd),
            border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
              
              const SizedBox(width: LoadingDesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120 + (index * 20.0),
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors.onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusSm),
                      ),
                    ),
                    const SizedBox(height: LoadingDesignTokens.spacingXs),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusSm),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 50,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusSm),
                    ),
                  ),
                  const SizedBox(height: LoadingDesignTokens.spacingXs),
                  Container(
                    width: 70,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusSm),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}

/// Tipos de skeleton disponíveis
enum SkeletonType {
  vehicles,
  list,
  cards,
  profile,
  dashboard,
}
