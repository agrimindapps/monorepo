// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../styles/vacina_colors.dart';
import '../styles/vacina_constants.dart';

/// A reusable widget for displaying error states in the vaccine module.
/// 
/// This widget provides a consistent and user-friendly way to display
/// error states throughout the vaccine management interface. It includes
/// an error icon, customizable message, and retry functionality.
/// 
/// Features:
/// - Customizable error message and icon
/// - Retry functionality with callback
/// - Responsive design with proper spacing
/// - Theme-aware styling
/// - Accessibility support
/// - Different error types (network, validation, generic)
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;
  final EdgeInsets? padding;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryLabel,
    this.iconColor,
    this.textColor,
    this.iconSize,
    this.padding,
  });

  /// Creates an error widget for network-related errors.
  factory ErrorStateWidget.network({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      icon: Icons.wifi_off,
      title: 'Erro de Conexão',
      message: message ?? 'Verifique sua conexão com a internet e tente novamente.',
      onRetry: onRetry,
      retryLabel: 'Tentar Novamente',
    );
  }

  /// Creates an error widget for validation errors.
  factory ErrorStateWidget.validation({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      icon: Icons.error_outline,
      title: 'Erro de Validação',
      message: message ?? 'Os dados inseridos não são válidos.',
      onRetry: onRetry,
      retryLabel: 'Corrigir',
    );
  }

  /// Creates an error widget for generic errors.
  factory ErrorStateWidget.generic({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      icon: Icons.error_outline,
      title: 'Erro Inesperado',
      message: message ?? 'Ocorreu um erro inesperado. Tente novamente.',
      onRetry: onRetry,
      retryLabel: 'Tentar Novamente',
    );
  }

  /// Creates an error widget for data loading errors.
  factory ErrorStateWidget.loadingData({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      icon: Icons.refresh,
      title: 'Erro ao Carregar',
      message: message ?? 'Não foi possível carregar os dados das vacinas.',
      onRetry: onRetry,
      retryLabel: 'Recarregar',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(VacinaConstants.espacamentoPadrao * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: iconSize ?? VacinaConstants.tamanhoIconeStatus,
              color: iconColor ?? VacinaColors.erro(context),
            ),
            if (title != null) ...[
              const SizedBox(height: VacinaConstants.espacamentoPadrao),
              Text(
                title!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? VacinaColors.erroTexto(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: VacinaConstants.espacamentoPadrao),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VacinaConstants.espacamentoPadrao,
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? VacinaColors.erroTexto(context),
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: VacinaConstants.espacamentoPadrao * 2),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? 'Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VacinaConstants.espacamentoPadrao * 2,
                    vertical: VacinaConstants.espacamentoPadrao,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A specialized error widget for API-related errors.
class ApiErrorWidget extends StatelessWidget {
  final String errorMessage;
  final int? statusCode;
  final VoidCallback? onRetry;

  const ApiErrorWidget({
    super.key,
    required this.errorMessage,
    this.statusCode,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    String title = 'Erro de Comunicação';
    String message = errorMessage;
    IconData icon = Icons.cloud_off;

    // Customize based on status code
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          title = 'Dados Inválidos';
          icon = Icons.error_outline;
          break;
        case 401:
          title = 'Acesso Negado';
          icon = Icons.lock_outline;
          break;
        case 403:
          title = 'Sem Permissão';
          icon = Icons.block;
          break;
        case 404:
          title = 'Não Encontrado';
          icon = Icons.search_off;
          break;
        case 500:
          title = 'Erro do Servidor';
          icon = Icons.dns;
          break;
        default:
          title = 'Erro de Rede';
          icon = Icons.cloud_off;
      }
    }

    return ErrorStateWidget(
      icon: icon,
      title: title,
      message: message,
      onRetry: onRetry,
      retryLabel: 'Tentar Novamente',
    );
  }
}
