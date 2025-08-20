import 'package:flutter/material.dart';

/// Overlay de carregamento que pode ser sobreposto a qualquer widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final Color? overlayColor;
  final Color? indicatorColor;
  final double? indicatorSize;
  final Widget? customLoadingWidget;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.overlayColor,
    this.indicatorColor,
    this.indicatorSize,
    this.customLoadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) _buildOverlay(context),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: overlayColor ?? Colors.black.withOpacity(0.3),
        child: Center(
          child: customLoadingWidget ?? _buildDefaultLoading(context),
        ),
      ),
    );
  }

  Widget _buildDefaultLoading(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: indicatorSize ?? 32,
            height: indicatorSize ?? 32,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                indicatorColor ?? Theme.of(context).primaryColor,
              ),
              strokeWidth: 3,
            ),
          ),
          if (loadingText != null) ...[
            const SizedBox(height: 16),
            Text(
              loadingText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Factory constructor para overlay simples
  factory LoadingOverlay.simple({
    required bool isLoading,
    required Widget child,
    String? text,
  }) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: child,
      loadingText: text,
    );
  }

  /// Factory constructor para overlay transparente
  factory LoadingOverlay.transparent({
    required bool isLoading,
    required Widget child,
    Color? indicatorColor,
  }) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: child,
      overlayColor: Colors.transparent,
      indicatorColor: indicatorColor,
      customLoadingWidget: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            indicatorColor ?? Colors.blue,
          ),
        ),
      ),
    );
  }

  /// Factory constructor para overlay com texto personalizado
  factory LoadingOverlay.withText({
    required bool isLoading,
    required Widget child,
    required String text,
    Color? backgroundColor,
  }) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: child,
      loadingText: text,
      overlayColor: backgroundColor ?? Colors.black.withOpacity(0.5),
    );
  }

  /// Factory constructor para overlay de tela cheia
  factory LoadingOverlay.fullScreen({
    required bool isLoading,
    required Widget child,
    String? text,
    Widget? customWidget,
  }) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: child,
      loadingText: text,
      overlayColor: Colors.black.withOpacity(0.7),
      customLoadingWidget: customWidget,
    );
  }
}