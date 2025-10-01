import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'centralized_loading_widget.dart';

/// Tipos padronizados de loading states para consistência em todo o app
enum LoadingType {
  /// Carregamento inicial de dados - loading completo
  initial,
  /// Refresh de dados - indicador mais discreto
  refresh,
  /// Submit de formulário - com overlay
  submit,
  /// Ação específica - loading compacto
  action,
  /// Loading em lista - skeleton screens
  list,
  /// Loading inline - pequeno indicador
  inline,
}

/// Widget padronizado para todos os estados de loading do app
/// Centraliza a lógica de loading states e garante consistência visual
class StandardLoadingView extends StatelessWidget {
  const StandardLoadingView({
    super.key,
    this.type = LoadingType.initial,
    this.message = 'Carregando...',
    this.showProgress = false,
    this.progress,
    this.height,
    this.color,
    this.itemCount = 3,
    this.child,
  });

  /// Factory constructors para uso conveniente

  /// Loading inicial padrão para páginas
  factory StandardLoadingView.initial({
    String message = 'Carregando...',
    double? height,
    Color? color,
  }) {
    return StandardLoadingView(
      type: LoadingType.initial,
      message: message,
      height: height,
      color: color,
    );
  }

  /// Loading para refresh/pull-to-refresh
  factory StandardLoadingView.refresh({
    String message = 'Atualizando...',
    Color? color,
  }) {
    return StandardLoadingView(
      type: LoadingType.refresh,
      message: message,
      color: color,
    );
  }

  /// Loading para submits com overlay
  factory StandardLoadingView.submit({
    String message = 'Salvando...',
    bool showProgress = false,
    double? progress,
    Color? color,
  }) {
    return StandardLoadingView(
      type: LoadingType.submit,
      message: message,
      showProgress: showProgress,
      progress: progress,
      color: color,
    );
  }

  /// Loading para ações específicas
  factory StandardLoadingView.action({
    String message = 'Processando...',
    Widget? child,
    Color? color,
  }) {
    return StandardLoadingView(
      type: LoadingType.action,
      message: message,
      color: color,
      showProgress: child != null,
      child: child, // Show overlay if wrapping a child
    );
  }

  /// Loading skeleton para listas
  factory StandardLoadingView.list({
    int itemCount = 3,
  }) {
    return StandardLoadingView(
      type: LoadingType.list,
      itemCount: itemCount,
    );
  }

  /// Loading inline pequeno
  factory StandardLoadingView.inline({
    Color? color,
  }) {
    return StandardLoadingView(
      type: LoadingType.inline,
      color: color,
    );
  }

  /// Tipo de loading a ser exibido
  final LoadingType type;
  
  /// Mensagem personalizada para o loading
  final String message;
  
  /// Se deve mostrar indicador de progresso
  final bool showProgress;
  
  /// Valor do progresso (0.0 a 1.0) se showProgress for true
  final double? progress;
  
  /// Altura customizada para alguns tipos
  final double? height;
  
  /// Cor customizada para o indicador
  final Color? color;
  
  /// Número de itens skeleton (para LoadingType.list)
  final int itemCount;
  
  /// Widget child para wrapping (usado em LoadingType.action)
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    
    switch (type) {
      case LoadingType.initial:
        return _buildInitialLoading(context, effectiveColor);
      case LoadingType.refresh:
        return _buildRefreshLoading(context, effectiveColor);
      case LoadingType.submit:
        return _buildSubmitLoading(context, effectiveColor);
      case LoadingType.action:
        return _buildActionLoading(context, effectiveColor);
      case LoadingType.list:
        return _buildListLoading(context);
      case LoadingType.inline:
        return _buildInlineLoading(context, effectiveColor);
    }
  }

  /// Loading para carregamento inicial de páginas
  Widget _buildInitialLoading(BuildContext context, Color color) {
    return SizedBox(
      height: height ?? 300,
      child: CentralizedLoadingWidget(
        message: message,
        color: color,
        showMessage: true,
        size: GasometerDesignTokens.iconSizeFeature,
      ),
    );
  }

  /// Loading discreto para refresh (pull-to-refresh style)
  Widget _buildRefreshLoading(BuildContext context, Color color) {
    return Container(
      padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: GasometerDesignTokens.iconSizeLg,
              height: GasometerDesignTokens.iconSizeLg,
              child: CircularProgressIndicator(
                color: color,
                strokeWidth: 2.0,
              ),
            ),
            const SizedBox(height: GasometerDesignTokens.spacingMd),
            Text(
              message,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeBody,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacitySecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Loading com overlay para submits de formulário
  Widget _buildSubmitLoading(BuildContext context, Color color) {
    return Container(
      constraints: BoxConstraints(
        minHeight: height ?? 120,
      ),
      child: Center(
        child: Container(
          padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingXxl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress && progress != null) ...[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.2),
                        strokeWidth: 4.0,
                      ),
                      Text(
                        '${(progress! * 100).round()}%',
                        style: TextStyle(
                          fontSize: GasometerDesignTokens.fontSizeMd,
                          fontWeight: GasometerDesignTokens.fontWeightBold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: GasometerDesignTokens.iconSizeFeature,
                  height: GasometerDesignTokens.iconSizeFeature,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 3.0,
                  ),
                ),
              ],
              const SizedBox(height: GasometerDesignTokens.spacingLg),
              Text(
                message,
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
        ),
      ),
    );
  }

  /// Loading compacto para ações específicas
  Widget _buildActionLoading(BuildContext context, Color color) {
    if (child != null) {
      // Wrap existing widget with loading overlay
      return Stack(
        children: [
          child!,
          if (showProgress) ...[
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Container(
                    padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: GasometerDesignTokens.iconSizeLg,
                          height: GasometerDesignTokens.iconSizeLg,
                          child: CircularProgressIndicator(
                            color: color,
                            strokeWidth: 3.0,
                          ),
                        ),
                        const SizedBox(height: GasometerDesignTokens.spacingMd),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: GasometerDesignTokens.fontSizeBody,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    }
    
    // Standalone action loading
    return SizedBox(
      height: height ?? 60,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: GasometerDesignTokens.iconSizeMd,
              height: GasometerDesignTokens.iconSizeMd,
              child: CircularProgressIndicator(
                color: color,
                strokeWidth: 2.0,
              ),
            ),
            const SizedBox(width: GasometerDesignTokens.spacingMd),
            Text(
              message,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeBody,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacitySecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Loading com skeleton screens para listas
  Widget _buildListLoading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skeleton para título
        Container(
          width: 120,
          height: 24,
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
        // Skeleton para itens da lista
        ...List.generate(
          itemCount,
          (index) => Container(
            width: double.infinity,
            height: 80,
            margin: GasometerDesignTokens.paddingOnly(
              bottom: GasometerDesignTokens.spacingMd,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacityDivider),
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusCard,
              ),
            ),
            child: Padding(
              padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg),
              child: Row(
                children: [
                  // Skeleton para ícone
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacityDivider * 1.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: GasometerDesignTokens.spacingLg),
                  // Skeleton para texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacityDivider * 1.5),
                            borderRadius: GasometerDesignTokens.borderRadius(
                              GasometerDesignTokens.radiusXs,
                            ),
                          ),
                        ),
                        const SizedBox(height: GasometerDesignTokens.spacingSm),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 14,
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

  /// Loading inline pequeno para uso em botões ou espaços pequenos
  Widget _buildInlineLoading(BuildContext context, Color color) {
    return SizedBox(
      width: GasometerDesignTokens.iconSizeButton,
      height: GasometerDesignTokens.iconSizeButton,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 2.0,
      ),
    );
  }
}

/// Widget para overlay de loading que pode ser usado com qualquer widget
class StandardLoadingOverlay extends StatelessWidget {
  const StandardLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message = 'Carregando...',
    this.type = LoadingType.action,
    this.showProgress = false,
    this.progress,
    this.color,
  });

  /// Factory para overlay simples
  factory StandardLoadingOverlay.simple({
    required bool isLoading,
    required Widget child,
    String message = 'Carregando...',
  }) {
    return StandardLoadingOverlay(
      isLoading: isLoading,
      message: message,
      type: LoadingType.action,
      child: child,
    );
  }

  /// Factory para overlay de submit
  factory StandardLoadingOverlay.submit({
    required bool isLoading,
    required Widget child,
    String message = 'Salvando...',
    bool showProgress = false,
    double? progress,
  }) {
    return StandardLoadingOverlay(
      isLoading: isLoading,
      message: message,
      type: LoadingType.submit,
      showProgress: showProgress,
      progress: progress,
      child: child,
    );
  }

  /// Se deve mostrar o loading overlay
  final bool isLoading;
  
  /// Widget filho que será coberto pelo overlay quando loading
  final Widget child;
  
  /// Mensagem do loading
  final String message;
  
  /// Tipo de loading
  final LoadingType type;
  
  /// Se deve mostrar progresso
  final bool showProgress;
  
  /// Valor do progresso
  final double? progress;
  
  /// Cor do indicador
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;
    
    return StandardLoadingView(
      type: type,
      message: message,
      showProgress: showProgress,
      progress: progress,
      color: color,
      child: child,
    );
  }
}

/// Extensão para RefreshIndicator padronizado
class StandardRefreshIndicator extends StatelessWidget {
  const StandardRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
  });

  final RefreshCallback onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? Theme.of(context).colorScheme.primary,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      strokeWidth: 3.0,
      displacement: 60.0,
      child: child,
    );
  }
}