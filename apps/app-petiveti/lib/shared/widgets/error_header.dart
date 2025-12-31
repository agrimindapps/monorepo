import 'package:flutter/material.dart';

/// Widget para exibir erros no header de formulários
///
/// Exibe uma mensagem de erro em vermelho com animação suave de entrada e saída.
/// Baseado no padrão do app-gasometer.
class ErrorHeader extends StatefulWidget {
  const ErrorHeader({
    super.key,
    required this.errorMessage,
    this.onDismiss,
    this.showDismissButton = true,
    this.errorStyle,
    this.errorIcon = Icons.error_outline,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// Mensagem de erro a ser exibida. Se null, o widget não será exibido.
  final String? errorMessage;

  /// Callback chamado quando o usuário toca no ícone de fechar
  final VoidCallback? onDismiss;

  /// Se deve mostrar ícone de fechar
  final bool showDismissButton;

  /// Estilo do texto do erro (opcional)
  final TextStyle? errorStyle;

  /// Ícone do erro (padrão: Icons.error_outline)
  final IconData errorIcon;

  /// Cor do fundo do erro (padrão: vermelho translúcido)
  final Color? backgroundColor;

  /// Padding interno do container de erro
  final EdgeInsets padding;

  /// Duração da animação de entrada/saída
  final Duration animationDuration;

  @override
  State<ErrorHeader> createState() => _ErrorHeaderState();
}

class _ErrorHeaderState extends State<ErrorHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    if (widget.errorMessage != null) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ErrorHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.errorMessage == null && widget.errorMessage != null) {
      _animationController.forward();
    } else if (oldWidget.errorMessage != null && widget.errorMessage == null) {
      _animationController.reverse();
    } else if (oldWidget.errorMessage != widget.errorMessage &&
        widget.errorMessage != null) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    if (widget.onDismiss != null) {
      _animationController.reverse().then((_) {
        if (mounted) {
          widget.onDismiss!();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(top: 8),
              padding: widget.padding,
              child: Row(
                children: [
                  Icon(
                    widget.errorIcon,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.errorMessage!,
                      style: widget.errorStyle ??
                          TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                    ),
                  ),
                  if (widget.showDismissButton) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _handleDismiss,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.error,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget especializado para erros de validação de formulário
///
/// Variação do ErrorHeader otimizada para uso em cabeçalhos de formulários
/// com estilos pré-configurados para consistência visual.
class FormValidationErrorHeader extends StatelessWidget {
  const FormValidationErrorHeader({
    super.key,
    required this.errorMessage,
    this.onClear,
    this.showClearButton = true,
  });

  /// Mensagem de erro de validação
  final String? errorMessage;

  /// Callback para limpar o erro
  final VoidCallback? onClear;

  /// Se deve mostrar botão para limpar o erro
  final bool showClearButton;

  @override
  Widget build(BuildContext context) {
    return ErrorHeader(
      errorMessage: errorMessage,
      onDismiss: onClear,
      showDismissButton: showClearButton,
      errorIcon: Icons.warning_amber_rounded,
      backgroundColor: Colors.red.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      errorStyle: TextStyle(
        color: Colors.red.shade700,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
    );
  }
}

/// Mixin para facilitar gerenciamento de erros em páginas de formulário
mixin FormErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  String? _formErrorMessage;

  /// Mensagem de erro atual do formulário
  String? get formErrorMessage => _formErrorMessage;

  /// Define uma mensagem de erro e atualiza a UI
  void setFormError(String? message) {
    setState(() {
      _formErrorMessage = message;
    });
  }

  /// Limpa a mensagem de erro
  void clearFormError() {
    setState(() {
      _formErrorMessage = null;
    });
  }

  /// Exibe um erro temporário que se remove automaticamente
  void showTemporaryError(String message,
      {Duration duration = const Duration(seconds: 5)}) {
    setFormError(message);

    Future.delayed(duration, () {
      if (mounted && _formErrorMessage == message) {
        clearFormError();
      }
    });
  }

  /// Widget ErrorHeader pronto para uso
  Widget buildFormErrorHeader() {
    return FormValidationErrorHeader(
      errorMessage: _formErrorMessage,
      onClear: clearFormError,
    );
  }
}
