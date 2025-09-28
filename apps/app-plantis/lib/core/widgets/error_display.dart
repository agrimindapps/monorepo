import 'package:flutter/material.dart';
import '../theme/plantis_colors.dart';

/// Enhanced error display widget with contextual messaging and retry actions
class ErrorDisplay extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String retryText;
  final String dismissText;
  final IconData icon;
  final Color iconColor;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.onDismiss,
    this.retryText = 'Tentar Novamente',
    this.dismissText = 'Fechar',
    this.icon = Icons.error_outline,
    this.iconColor = PlantisColors.error,
    this.showIcon = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: PlantisColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PlantisColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              if (showIcon) ...[
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          color: PlantisColors.error,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      message,
                      style: const TextStyle(
                        color: PlantisColors.error,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action buttons
          if (onRetry != null || onDismiss != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDismiss != null) ...[
                  TextButton(
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: PlantisColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(dismissText),
                  ),
                  if (onRetry != null) const SizedBox(width: 8),
                ],
                if (onRetry != null)
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlantisColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(retryText),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Specific error display for authentication errors
class AuthErrorDisplay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const AuthErrorDisplay({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getAuthErrorInfo(errorMessage);

    return ErrorDisplay(
      title: errorInfo['title'] as String?,
      message: errorInfo['message'] as String,
      onRetry: (errorInfo['canRetry'] as bool? ?? false) ? onRetry : null,
      onDismiss: onDismiss,
      retryText: (errorInfo['retryText'] as String?) ?? 'Tentar Novamente',
    );
  }

  Map<String, dynamic> _getAuthErrorInfo(String error) {
    final lowercaseError = error.toLowerCase();

    if (lowercaseError.contains('network') ||
        lowercaseError.contains('connection')) {
      return {
        'title': 'Erro de Conexão',
        'message': 'Verifique sua conexão com a internet e tente novamente.',
        'canRetry': true,
        'retryText': 'Tentar Novamente',
      };
    }

    if (lowercaseError.contains('invalid-email')) {
      return {
        'title': 'Email Inválido',
        'message': 'Por favor, verifique o formato do seu email.',
        'canRetry': false,
      };
    }

    if (lowercaseError.contains('user-not-found')) {
      return {
        'title': 'Usuário Não Encontrado',
        'message':
            'Não existe uma conta com este email. Verifique o email ou crie uma nova conta.',
        'canRetry': false,
      };
    }

    if (lowercaseError.contains('wrong-password') ||
        lowercaseError.contains('invalid-credential')) {
      return {
        'title': 'Senha Incorreta',
        'message':
            'A senha informada está incorreta. Tente novamente ou recupere sua senha.',
        'canRetry': true,
        'retryText': 'Tentar Novamente',
      };
    }

    if (lowercaseError.contains('email-already-in-use')) {
      return {
        'title': 'Email já Cadastrado',
        'message':
            'Já existe uma conta com este email. Tente fazer login ou use outro email.',
        'canRetry': false,
      };
    }

    if (lowercaseError.contains('weak-password')) {
      return {
        'title': 'Senha Muito Fraca',
        'message': 'Escolha uma senha mais forte com pelo menos 8 caracteres.',
        'canRetry': false,
      };
    }

    if (lowercaseError.contains('too-many-requests')) {
      return {
        'title': 'Muitas Tentativas',
        'message':
            'Muitas tentativas de login. Tente novamente em alguns minutos.',
        'canRetry': true,
        'retryText': 'Tentar Novamente',
      };
    }

    // Generic error
    return {
      'title': 'Erro de Autenticação',
      'message':
          error.isNotEmpty
              ? error
              : 'Ocorreu um erro inesperado. Tente novamente.',
      'canRetry': true,
      'retryText': 'Tentar Novamente',
    };
  }
}

/// Specific error display for purchase errors
class PurchaseErrorDisplay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final VoidCallback? onContactSupport;

  const PurchaseErrorDisplay({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.onDismiss,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getPurchaseErrorInfo(errorMessage);

    return ErrorDisplay(
      title: errorInfo['title'] as String?,
      message: errorInfo['message'] as String,
      onRetry: (errorInfo['canRetry'] as bool? ?? false) ? onRetry : null,
      onDismiss: onDismiss,
      retryText: (errorInfo['retryText'] as String?) ?? 'Tentar Novamente',
    );
  }

  Map<String, dynamic> _getPurchaseErrorInfo(String error) {
    final lowercaseError = error.toLowerCase();

    if (lowercaseError.contains('user_cancelled') ||
        lowercaseError.contains('cancelled')) {
      return {
        'title': null, // Don't show error for user cancellation
        'message': '',
        'canRetry': false,
      };
    }

    if (lowercaseError.contains('network') ||
        lowercaseError.contains('connection')) {
      return {
        'title': 'Erro de Conexão',
        'message':
            'Problema de conexão durante a compra. Verifique sua internet e tente novamente.',
        'canRetry': true,
        'retryText': 'Tentar Novamente',
      };
    }

    if (lowercaseError.contains('payment_invalid') ||
        lowercaseError.contains('payment')) {
      return {
        'title': 'Erro de Pagamento',
        'message':
            'Não foi possível processar o pagamento. Verifique seus dados de pagamento.',
        'canRetry': true,
        'retryText': 'Tentar Novamente',
      };
    }

    if (lowercaseError.contains('product_not_available')) {
      return {
        'title': 'Produto Indisponível',
        'message':
            'Este produto não está disponível no momento. Tente novamente mais tarde.',
        'canRetry': true,
        'retryText': 'Tentar Novamente',
      };
    }

    if (lowercaseError.contains('store_problem') ||
        lowercaseError.contains('billing_unavailable')) {
      return {
        'title': 'Erro na Loja',
        'message':
            'Problema temporário na loja de aplicativos. Tente novamente em alguns minutos.',
        'canRetry': true,
        'retryText': 'Tentar Novamente',
      };
    }

    if (lowercaseError.contains('already_owned')) {
      return {
        'title': 'Produto já Possui',
        'message': 'Você já possui este produto. Tente restaurar suas compras.',
        'canRetry': false,
      };
    }

    // Generic purchase error
    return {
      'title': 'Erro na Compra',
      'message':
          'Não foi possível completar a compra. Entre em contato com o suporte se o problema persistir.',
      'canRetry': true,
      'retryText': 'Tentar Novamente',
    };
  }
}

/// Success display widget for positive feedback
class SuccessDisplay extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onDismiss;
  final String dismissText;
  final IconData icon;
  final Color iconColor;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;

  const SuccessDisplay({
    super.key,
    required this.message,
    this.title,
    this.onDismiss,
    this.dismissText = 'OK',
    this.icon = Icons.check_circle_outline,
    this.iconColor = PlantisColors.success,
    this.showIcon = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: PlantisColors.successLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PlantisColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              if (showIcon) ...[
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          color: PlantisColors.success,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      message,
                      style: const TextStyle(
                        color: PlantisColors.success,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Dismiss button
          if (onDismiss != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PlantisColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(dismissText),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
