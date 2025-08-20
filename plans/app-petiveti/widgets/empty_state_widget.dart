// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/design_tokens.dart';
import '../utils/animation_utils.dart';

/// A reusable widget for displaying empty states
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool animate;
  final double iconSize;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.animate = true,
    this.iconSize = DesignTokens.iconXXL,
    this.iconColor,
  });

  /// Predefined empty state for animals
  factory EmptyStateWidget.noAnimals({
    VoidCallback? onAddPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.pets_outlined,
      title: 'Nenhum animal cadastrado',
      subtitle: 'Comece adicionando seu primeiro animal de estimação',
      action: onAddPressed != null
          ? ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Animal'),
            )
          : null,
    );
  }

  /// Predefined empty state for search results
  factory EmptyStateWidget.noSearchResults({
    String? searchQuery,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: 'Nenhum resultado encontrado',
      subtitle: searchQuery != null 
          ? 'Nenhum animal encontrado para "$searchQuery"'
          : 'Tente ajustar sua pesquisa',
    );
  }

  /// Predefined empty state for network errors
  factory EmptyStateWidget.networkError({
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_outlined,
      title: 'Problema de conexão',
      subtitle: 'Verifique sua conexão com a internet',
      action: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            )
          : null,
    );
  }

  /// Predefined empty state for general errors
  factory EmptyStateWidget.error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Algo deu errado',
      subtitle: message ?? 'Ocorreu um erro inesperado',
      iconColor: DesignTokens.colorError,
      action: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget content = SizedBox(
      width: Get.width,
      height: Get.height * 0.6,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: DesignTokens.pagePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(theme),
                Spacing.v24,
                _buildTitle(theme),
                if (subtitle != null) ...[
                  Spacing.v12,
                  _buildSubtitle(theme),
                ],
                if (action != null) ...[
                  Spacing.v32,
                  _buildAction(),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (animate) {
      content = AnimationUtils.fadeIn(
        duration: DesignTokens.animationNormal,
        child: content,
      );
    }

    return content;
  }

  Widget _buildIcon(ThemeData theme) {
    Widget iconWidget = Icon(
      icon,
      size: iconSize,
      color: iconColor ?? theme.textTheme.bodyLarge?.color?.withValues(alpha: DesignTokens.opacityMedium),
    );

    if (animate) {
      iconWidget = AnimationUtils.scaleIn(
        duration: DesignTokens.animationSlow,
        curve: DesignTokens.curveBounce,
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: TypographyTokens.weightSemiBold,
        color: theme.textTheme.headlineSmall?.color?.withValues(alpha: DesignTokens.opacityHigh),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    return Text(
      subtitle!,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.textTheme.bodyLarge?.color?.withValues(alpha: DesignTokens.opacityMedium),
        height: TypographyTokens.lineHeightRelaxed,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAction() {
    if (animate) {
      return AnimationUtils.slideInFromBottom(
        duration: DesignTokens.animationSlow,
        child: action!,
      );
    }
    return action!;
  }
}

/// Animated empty state with custom loading animation
class AnimatedEmptyState extends StatefulWidget {
  final EmptyStateWidget emptyState;
  final Duration delay;

  const AnimatedEmptyState({
    super.key,
    required this.emptyState,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.animationSlower,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: DesignTokens.curveStandard),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: DesignTokens.curveDecelerate),
    ));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: widget.emptyState,
          ),
        );
      },
    );
  }
}
