import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Serviço centralizado para efeitos shimmer
/// Fornece builders padronizados para diferentes tipos de loading states
class ShimmerService {
  
  /// Cores padrão do shimmer baseadas no tema
  static Color _getBaseColor(BuildContext context, Color? customBaseColor) {
    if (customBaseColor != null) return customBaseColor;
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? theme.colorScheme.surface.withOpacity(0.1)
        : Colors.grey.shade300;
  }
  
  static Color _getHighlightColor(BuildContext context, Color? customHighlightColor) {
    if (customHighlightColor != null) return customHighlightColor;
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? theme.colorScheme.surface.withOpacity(0.05)
        : Colors.grey.shade100;
  }

  /// Shimmer básico com cores adaptáveis ao tema
  static Widget fromColors({
    required BuildContext context,
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration period = const Duration(milliseconds: 1500),
  }) {
    return Shimmer.fromColors(
      baseColor: _getBaseColor(context, baseColor),
      highlightColor: _getHighlightColor(context, highlightColor),
      period: period,
      child: child,
    );
  }

  /// Shimmer específico para imagens
  static Widget imageShimmer({
    required BuildContext context,
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return fromColors(
      context: context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shimmer para texto/conteúdo
  static Widget textShimmer({
    required BuildContext context,
    double width = double.infinity,
    double height = 16,
    BorderRadiusGeometry? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return fromColors(
      context: context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Shimmer para cards com estrutura padrão
  static Widget cardShimmer({
    required BuildContext context,
    double height = 120,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    bool showShadow = true,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return fromColors(
      context: context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          boxShadow: showShadow ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone/Avatar skeleton
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              
              // Conteúdo skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Título
                    Container(
                      height: 18,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtítulo
                    Container(
                      height: 14,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Metadata
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shimmer para lista de cards
  static Widget listShimmer({
    required BuildContext context,
    int itemCount = 5,
    double itemHeight = 120,
    EdgeInsetsGeometry? itemMargin,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => cardShimmer(
        context: context,
        height: itemHeight,
        margin: itemMargin,
        baseColor: baseColor,
        highlightColor: highlightColor,
      ),
    );
  }

  /// Shimmer para barras/headers
  static Widget headerShimmer({
    required BuildContext context,
    double height = 48,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return fromColors(
      context: context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Ícone/título principal
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              // Ação/botão
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shimmer circular para avatars
  static Widget circularShimmer({
    required BuildContext context,
    double size = 48,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return fromColors(
      context: context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Builder para shimmer customizado
  static Widget customShimmer({
    required BuildContext context,
    required Widget Function(BuildContext context, Color baseColor, Color highlightColor) builder,
    Color? baseColor,
    Color? highlightColor,
    Duration period = const Duration(milliseconds: 1500),
  }) {
    final effectiveBaseColor = _getBaseColor(context, baseColor);
    final effectiveHighlightColor = _getHighlightColor(context, highlightColor);
    
    return fromColors(
      context: context,
      baseColor: effectiveBaseColor,
      highlightColor: effectiveHighlightColor,
      period: period,
      child: builder(context, effectiveBaseColor, effectiveHighlightColor),
    );
  }
}