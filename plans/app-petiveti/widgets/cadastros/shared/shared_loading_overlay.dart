// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/form_constants.dart';
import '../constants/form_styles.dart';

/// Widget de overlay de carregamento unificado para todos os formulários de cadastro
class SharedLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool dismissible;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final VoidCallback? onDismiss;
  final Widget? customIndicator;
  final double opacity;
  final bool showCard;

  const SharedLoadingOverlay({
    super.key,
    this.message,
    this.dismissible = false,
    this.backgroundColor,
    this.indicatorColor,
    this.onDismiss,
    this.customIndicator,
    this.opacity = FormConstants.overlayOpacity,
    this.showCard = true,
  });

  /// Factory para consulta
  factory SharedLoadingOverlay.consulta({
    String? message,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return SharedLoadingOverlay(
      message: message ?? 'Salvando consulta...',
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  /// Factory para despesa
  factory SharedLoadingOverlay.despesa({
    String? message,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return SharedLoadingOverlay(
      message: message ?? 'Salvando despesa...',
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  /// Factory para lembrete
  factory SharedLoadingOverlay.lembrete({
    String? message,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return SharedLoadingOverlay(
      message: message ?? 'Salvando lembrete...',
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  /// Factory para medicamento
  factory SharedLoadingOverlay.medicamento({
    String? message,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return SharedLoadingOverlay(
      message: message ?? 'Salvando medicamento...',
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  /// Factory para peso
  factory SharedLoadingOverlay.peso({
    String? message,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return SharedLoadingOverlay(
      message: message ?? 'Salvando peso...',
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  /// Factory para vacina
  factory SharedLoadingOverlay.vacina({
    String? message,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return SharedLoadingOverlay(
      message: message ?? 'Salvando vacina...',
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  /// Factory para animal
  factory SharedLoadingOverlay.animal({
    String? message,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return SharedLoadingOverlay(
      message: message ?? 'Salvando animal...',
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  /// Factory genérico
  factory SharedLoadingOverlay.generic({
    String? message,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return SharedLoadingOverlay(
      message: message ?? FormConstants.loadingMessage,
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  /// Factory simples sem card
  factory SharedLoadingOverlay.simple({
    String? message,
    Color? indicatorColor,
  }) {
    return SharedLoadingOverlay(
      message: message,
      showCard: false,
      indicatorColor: indicatorColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (dismissible && onDismiss != null) {
          onDismiss!();
          return true;
        }
        return dismissible;
      },
      child: GestureDetector(
        onTap: dismissible ? onDismiss : null,
        child: Container(
          color: (backgroundColor ?? Colors.black).withValues(alpha: opacity),
          child: Center(
            child: _buildLoadingContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        customIndicator ?? _buildProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: FormStyles.mediumSpacing),
          _buildMessage(context),
        ],
      ],
    );

    if (!showCard) return content;

    return Card(
      elevation: FormStyles.highElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FormStyles.largeBorderRadius),
      ),
      child: Padding(
        padding: FormStyles.largePadding,
        child: content,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        indicatorColor ?? FormStyles.primaryColor,
      ),
      strokeWidth: 3,
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Text(
      message!,
      style: FormStyles.bodyTextStyle.copyWith(
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Método estático para mostrar overlay em uma stack
  static Widget wrapWithOverlay({
    required Widget child,
    required bool isLoading,
    String? message,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: SharedLoadingOverlay(
              message: message,
              dismissible: dismissible,
              onDismiss: onDismiss,
            ),
          ),
      ],
    );
  }

  /// Método estático para mostrar como dialog
  static Future<void> showAsDialog(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => SharedLoadingOverlay(
        message: message,
        dismissible: barrierDismissible,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Método estático para dismissar dialog
  static void dismissDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
