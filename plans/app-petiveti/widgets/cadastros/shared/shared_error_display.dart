// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/form_constants.dart';
import '../constants/form_styles.dart';

/// Tipos de display de erro
enum ErrorDisplayType {
  error,
  warning,
  info,
  success,
}

/// Widget de exibição de erro unificado para todos os formulários de cadastro
class SharedErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;
  final bool dismissible;
  final ErrorDisplayType type;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Duration? autoHideDuration;
  final bool showIcon;
  final IconData? customIcon;
  final Color? customColor;

  const SharedErrorDisplay({
    super.key,
    required this.message,
    this.onDismiss,
    this.onRetry,
    this.dismissible = true,
    this.type = ErrorDisplayType.error,
    this.margin,
    this.padding,
    this.autoHideDuration,
    this.showIcon = true,
    this.customIcon,
    this.customColor,
  });

  /// Factory para erro
  factory SharedErrorDisplay.error({
    required String message,
    VoidCallback? onDismiss,
    VoidCallback? onRetry,
    bool dismissible = true,
    Duration? autoHideDuration,
  }) {
    return SharedErrorDisplay(
      message: message,
      onDismiss: onDismiss,
      onRetry: onRetry,
      dismissible: dismissible,
      type: ErrorDisplayType.error,
      autoHideDuration: autoHideDuration,
    );
  }

  /// Factory para aviso
  factory SharedErrorDisplay.warning({
    required String message,
    VoidCallback? onDismiss,
    bool dismissible = true,
    Duration? autoHideDuration,
  }) {
    return SharedErrorDisplay(
      message: message,
      onDismiss: onDismiss,
      dismissible: dismissible,
      type: ErrorDisplayType.warning,
      autoHideDuration: autoHideDuration,
    );
  }

  /// Factory para informação
  factory SharedErrorDisplay.info({
    required String message,
    VoidCallback? onDismiss,
    bool dismissible = true,
    Duration? autoHideDuration,
  }) {
    return SharedErrorDisplay(
      message: message,
      onDismiss: onDismiss,
      dismissible: dismissible,
      type: ErrorDisplayType.info,
      autoHideDuration: autoHideDuration,
    );
  }

  /// Factory para sucesso
  factory SharedErrorDisplay.success({
    required String message,
    VoidCallback? onDismiss,
    bool dismissible = true,
    Duration? autoHideDuration,
  }) {
    return SharedErrorDisplay(
      message: message,
      onDismiss: onDismiss,
      dismissible: dismissible,
      type: ErrorDisplayType.success,
      autoHideDuration: autoHideDuration,
    );
  }

  /// Factory para erro de rede
  factory SharedErrorDisplay.networkError({
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return SharedErrorDisplay(
      message: 'Erro de conexão. Verifique sua internet e tente novamente.',
      onRetry: onRetry,
      onDismiss: onDismiss,
      type: ErrorDisplayType.error,
    );
  }

  /// Factory para timeout
  factory SharedErrorDisplay.timeout({
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return SharedErrorDisplay(
      message: 'Operação expirou. Tente novamente.',
      onRetry: onRetry,
      onDismiss: onDismiss,
      type: ErrorDisplayType.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.only(bottom: FormStyles.mediumSpacing),
      padding: padding ?? FormStyles.defaultPadding,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(FormStyles.borderRadius),
        border: Border.all(
          color: _getBorderColor(),
          width: FormStyles.borderWidth,
        ),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(
              _getIcon(),
              color: _getColor(),
              size: 20,
            ),
            const SizedBox(width: FormStyles.smallSpacing + 4),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _getColor(),
                fontSize: FormStyles.bodyFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: FormStyles.smallSpacing),
            _buildRetryButton(),
          ],
          if (dismissible && onDismiss != null) ...[
            const SizedBox(width: FormStyles.smallSpacing),
            _buildCloseButton(),
          ],
        ],
      ),
    );

    // Auto hide functionality
    if (autoHideDuration != null && onDismiss != null) {
      return _AutoHideWrapper(
        duration: autoHideDuration!,
        onHide: onDismiss!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildRetryButton() {
    return IconButton(
      onPressed: onRetry,
      icon: Icon(
        Icons.refresh,
        color: _getColor(),
        size: 18,
      ),
      tooltip: FormConstants.retryLabel,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
    );
  }

  Widget _buildCloseButton() {
    return IconButton(
      onPressed: onDismiss,
      icon: Icon(
        Icons.close,
        color: _getColor(),
        size: 18,
      ),
      tooltip: FormConstants.closeLabel,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
    );
  }

  IconData _getIcon() {
    if (customIcon != null) return customIcon!;

    switch (type) {
      case ErrorDisplayType.error:
        return Icons.error_outline;
      case ErrorDisplayType.warning:
        return Icons.warning_outlined;
      case ErrorDisplayType.info:
        return Icons.info_outline;
      case ErrorDisplayType.success:
        return Icons.check_circle_outline;
    }
  }

  Color _getColor() {
    if (customColor != null) return customColor!;

    switch (type) {
      case ErrorDisplayType.error:
        return FormStyles.errorColor;
      case ErrorDisplayType.warning:
        return FormStyles.warningColor;
      case ErrorDisplayType.info:
        return FormStyles.primaryColor;
      case ErrorDisplayType.success:
        return FormStyles.successColor;
    }
  }

  Color _getBackgroundColor() {
    return _getColor().withValues(alpha: 0.1);
  }

  Color _getBorderColor() {
    return _getColor().withValues(alpha: 0.3);
  }

  /// Método estático para mostrar como SnackBar
  static void showAsSnackBar(
    BuildContext context, {
    required String message,
    ErrorDisplayType type = ErrorDisplayType.error,
    VoidCallback? onRetry,
    Duration? duration,
  }) {
    final color = _getStaticColor(type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getStaticIcon(type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: FormStyles.smallSpacing),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration ?? FormConstants.mediumAnimation,
        action: onRetry != null
            ? SnackBarAction(
                label: FormConstants.retryLabel,
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static Color _getStaticColor(ErrorDisplayType type) {
    switch (type) {
      case ErrorDisplayType.error:
        return FormStyles.errorColor;
      case ErrorDisplayType.warning:
        return FormStyles.warningColor;
      case ErrorDisplayType.info:
        return FormStyles.primaryColor;
      case ErrorDisplayType.success:
        return FormStyles.successColor;
    }
  }

  static IconData _getStaticIcon(ErrorDisplayType type) {
    switch (type) {
      case ErrorDisplayType.error:
        return Icons.error_outline;
      case ErrorDisplayType.warning:
        return Icons.warning_outlined;
      case ErrorDisplayType.info:
        return Icons.info_outline;
      case ErrorDisplayType.success:
        return Icons.check_circle_outline;
    }
  }
}

/// Widget wrapper para auto-hide
class _AutoHideWrapper extends StatefulWidget {
  final Duration duration;
  final VoidCallback onHide;
  final Widget child;

  const _AutoHideWrapper({
    required this.duration,
    required this.onHide,
    required this.child,
  });

  @override
  State<_AutoHideWrapper> createState() => _AutoHideWrapperState();
}

class _AutoHideWrapperState extends State<_AutoHideWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) {
        widget.onHide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
