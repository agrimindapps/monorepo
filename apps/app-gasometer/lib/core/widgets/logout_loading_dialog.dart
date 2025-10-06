import 'package:flutter/material.dart';
import '../theme/loading_design_tokens.dart';

/// Dialog profissional de loading para operação de logout
/// 
/// Exibe um indicador de loading não-cancelável com mensagem
/// personalizada e design consistente com o app
class LogoutLoadingDialog extends StatefulWidget {

  const LogoutLoadingDialog({
    super.key,
    this.message = 'Saindo...',
    this.minDuration = const Duration(seconds: 2),
    this.onCompleted,
  });
  /// Mensagem a ser exibida no dialog
  final String message;

  /// Duração mínima de exibição do dialog (padrão: 2 segundos)
  final Duration minDuration;

  /// Callback executado quando o dialog deve ser fechado
  final VoidCallback? onCompleted;

  @override
  State<LogoutLoadingDialog> createState() => _LogoutLoadingDialogState();

  /// Mostra o dialog de logout loading
  /// 
  /// Retorna um Future que completa quando o dialog é fechado
  static Future<void> show(
    BuildContext context, {
    String message = 'Saindo...',
    Duration minDuration = const Duration(seconds: 2),
    VoidCallback? onCompleted,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Não permite fechar clicando fora
      builder: (context) => LogoutLoadingDialog(
        message: message,
        minDuration: minDuration,
        onCompleted: onCompleted,
      ),
    );
  }
}

class _LogoutLoadingDialogState extends State<LogoutLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: LoadingDesignTokens.fastDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: LoadingDesignTokens.enterCurve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: LoadingDesignTokens.enterCurve,
    ));
    _startLoadingProcess();
  }

  Future<void> _startLoadingProcess() async {
    await _animationController.forward();
    await Future<void>.delayed(widget.minDuration);
    widget.onCompleted?.call();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = LoadingDesignTokens.getColorScheme(context);
    
    return PopScope(
      canPop: false, // Impede que o usuário feche o dialog
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusMd),
                ),
                backgroundColor: colorScheme.surface,
                elevation: 8.0,
                child: Padding(
                  padding: const EdgeInsets.all(LoadingDesignTokens.spacingXl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(LoadingDesignTokens.spacingMd),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout_outlined,
                          size: LoadingDesignTokens.largeIconSize,
                          color: colorScheme.primary,
                        ),
                      ),
                      
                      const SizedBox(height: LoadingDesignTokens.spacingLg),
                      SizedBox(
                        width: LoadingDesignTokens.loadingIndicatorSize,
                        height: LoadingDesignTokens.loadingIndicatorSize,
                        child: CircularProgressIndicator(
                          strokeWidth: LoadingDesignTokens.loadingIndicatorStrokeWidth,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                      
                      const SizedBox(height: LoadingDesignTokens.spacingLg),
                      Text(
                        widget.message,
                        style: LoadingDesignTokens.titleTextStyle.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: LoadingDesignTokens.spacingSm),
                      Text(
                        'Aguarde um momento...',
                        style: LoadingDesignTokens.bodyTextStyle.copyWith(
                          color: colorScheme.onSurfaceLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Helper para mostrar rapidamente o dialog de logout loading
/// 
/// Uso básico:
/// ```dart
/// await showLogoutLoading(context);
/// ```
/// 
/// Uso com personalização:
/// ```dart
/// await showLogoutLoading(
///   context,
///   message: 'Fazendo logout...',
///   duration: Duration(seconds: 3),
/// );
/// ```
Future<void> showLogoutLoading(
  BuildContext context, {
  String message = 'Saindo...',
  Duration duration = const Duration(seconds: 2),
}) async {
  return LogoutLoadingDialog.show(
    context,
    message: message,
    minDuration: duration,
  );
}