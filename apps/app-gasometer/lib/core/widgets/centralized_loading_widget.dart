import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Widget centralizado de loading para consistência em todo o app
class CentralizedLoadingWidget extends StatelessWidget {
  const CentralizedLoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
    this.showMessage = true,
    this.padding,
  });

  /// Mensagem a ser exibida abaixo do indicador (padrão: "Carregando...")
  final String? message;
  
  /// Tamanho do indicador de progresso
  final double? size;
  
  /// Cor do indicador de progresso
  final Color? color;
  
  /// Se deve mostrar a mensagem
  final bool showMessage;
  
  /// Padding customizado
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final effectiveSize = size ?? GasometerDesignTokens.iconSizeFeature;
    final effectiveMessage = message ?? 'Carregando...';
    final effectivePadding = padding ?? GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg);

    return Center(
      child: Padding(
        padding: effectivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: effectiveSize,
              height: effectiveSize,
              child: CircularProgressIndicator(
                color: effectiveColor,
                strokeWidth: 3.0,
              ),
            ),
            if (showMessage) ...[
              const SizedBox(height: GasometerDesignTokens.spacingLg),
              Text(
                effectiveMessage,
                style: TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeBody,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacitySecondary),
                  fontWeight: GasometerDesignTokens.fontWeightMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de loading compacto para usar em cards ou espaços menores
class CompactLoadingWidget extends StatelessWidget {
  const CompactLoadingWidget({
    super.key,
    this.color,
    this.size,
  });

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final effectiveSize = size ?? GasometerDesignTokens.iconSizeMd;

    return Center(
      child: SizedBox(
        width: effectiveSize,
        height: effectiveSize,
        child: CircularProgressIndicator(
          color: effectiveColor,
          strokeWidth: 2.0,
        ),
      ),
    );
  }
}

/// Widget de loading para listas (com shimmer effect simulado)
class ListLoadingWidget extends StatelessWidget {
  const ListLoadingWidget({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 80.0,
    this.showTitle = true,
  });

  final int itemCount;
  final double itemHeight;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Container(
            width: 120,
            height: GasometerDesignTokens.fontSizeHeading,
            margin: GasometerDesignTokens.paddingOnly(
              bottom: GasometerDesignTokens.spacingLg,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacityDivider),
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusSm,
              ),
            ),
          ),
        ],
        ...List.generate(
          itemCount,
          (index) => Container(
            width: double.infinity,
            height: itemHeight,
            margin: GasometerDesignTokens.paddingOnly(
              bottom: GasometerDesignTokens.spacingMd,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacityDivider),
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusLg,
              ),
            ),
            child: Padding(
              padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg),
              child: Row(
                children: [
                  Container(
                    width: GasometerDesignTokens.iconSizeFeature,
                    height: GasometerDesignTokens.iconSizeFeature,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacityDivider * 2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: GasometerDesignTokens.spacingLg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: GasometerDesignTokens.fontSizeBodyLarge,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacityDivider * 2),
                            borderRadius: GasometerDesignTokens.borderRadius(
                              GasometerDesignTokens.radiusXs,
                            ),
                          ),
                        ),
                        const SizedBox(height: GasometerDesignTokens.spacingSm),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: GasometerDesignTokens.fontSizeBody,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacityDivider),
                            borderRadius: GasometerDesignTokens.borderRadius(
                              GasometerDesignTokens.radiusXs,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget de loading para operações em background
class OperationLoadingWidget extends StatelessWidget {
  const OperationLoadingWidget({
    super.key,
    required this.operation,
    this.progress,
    this.showProgress = false,
  });

  final String operation;
  final double? progress;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingXxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showProgress && progress != null) ...[
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: GasometerDesignTokens.opacityDivider),
                      strokeWidth: 8.0,
                    ),
                  ),
                  Text(
                    '${(progress! * 100).round()}%',
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeHeading,
                      fontWeight: GasometerDesignTokens.fontWeightBold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 4.0,
              ),
            ),
          ],
          const SizedBox(height: GasometerDesignTokens.spacingXxl),
          Text(
            operation,
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeBodyLarge,
              fontWeight: GasometerDesignTokens.fontWeightMedium,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: GasometerDesignTokens.spacingSm),
          Text(
            'Por favor, aguarde...',
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeBody,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacitySecondary),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}