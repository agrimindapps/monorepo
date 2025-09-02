import 'package:flutter/material.dart';

/// **COMENTARIOS ERROR WIDGET**
/// 
/// Displays error states with retry functionality.
/// Provides user-friendly error messages and recovery options.
/// 
/// ## Features:
/// 
/// - **Error Classification**: Different UI for different error types
/// - **Retry Functionality**: Clear retry button for recoverable errors
/// - **User-Friendly Messages**: Translated and contextual error messages
/// - **Visual Consistency**: Matches app-receituagro error design patterns

class ComentariosErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final bool isRetryable;

  const ComentariosErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.isRetryable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 12),
            _buildMessage(),
            const SizedBox(height: 32),
            if (isRetryable && onRetry != null) _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getErrorIcon(),
        size: 48,
        color: Colors.red.shade600,
      ),
    );
  }

  IconData _getErrorIcon() {
    if (_isNetworkError()) {
      return Icons.cloud_off_outlined;
    } else if (_isPermissionError()) {
      return Icons.lock_outline;
    } else if (_isValidationError()) {
      return Icons.warning_outlined;
    } else {
      return Icons.error_outline;
    }
  }

  Widget _buildTitle() {
    return Text(
      _getErrorTitle(),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.red,
      ),
      textAlign: TextAlign.center,
    );
  }

  String _getErrorTitle() {
    if (_isNetworkError()) {
      return 'Problema de Conexão';
    } else if (_isPermissionError()) {
      return 'Acesso Negado';
    } else if (_isValidationError()) {
      return 'Dados Inválidos';
    } else {
      return 'Erro Inesperado';
    }
  }

  Widget _buildMessage() {
    return Text(
      _getFormattedMessage(),
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade700,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  String _getFormattedMessage() {
    // Clean up technical error prefixes
    String cleanError = error
        .replaceAll(RegExp(r'^[A-Za-z]+Exception:\s*'), '')
        .replaceAll(RegExp(r'^Exception:\s*'), '')
        .replaceAll(RegExp(r'^Error:\s*'), '');

    // Provide user-friendly fallback messages
    if (cleanError.isEmpty || cleanError.length < 10) {
      return _getDefaultMessage();
    }

    return cleanError;
  }

  String _getDefaultMessage() {
    if (_isNetworkError()) {
      return 'Verifique sua conexão com a internet e tente novamente.';
    } else if (_isPermissionError()) {
      return 'Você não tem permissão para acessar este recurso.';
    } else if (_isValidationError()) {
      return 'Os dados fornecidos não são válidos. Verifique e tente novamente.';
    } else {
      return 'Algo deu errado. Tente novamente em alguns instantes.';
    }
  }

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(
        Icons.refresh,
        size: 20,
      ),
      label: const Text(
        'Tentar Novamente',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  // Helper methods to classify errors
  bool _isNetworkError() {
    final lowerError = error.toLowerCase();
    return lowerError.contains('network') ||
           lowerError.contains('conexão') ||
           lowerError.contains('internet') ||
           lowerError.contains('timeout') ||
           lowerError.contains('socket');
  }

  bool _isPermissionError() {
    final lowerError = error.toLowerCase();
    return lowerError.contains('permission') ||
           lowerError.contains('unauthorized') ||
           lowerError.contains('forbidden') ||
           lowerError.contains('acesso') ||
           lowerError.contains('permissão');
  }

  bool _isValidationError() {
    final lowerError = error.toLowerCase();
    return lowerError.contains('validation') ||
           lowerError.contains('invalid') ||
           lowerError.contains('inválid') ||
           lowerError.contains('duplicat') ||
           lowerError.contains('limit') ||
           lowerError.contains('excede');
  }

  /// Factory constructor for network errors
  static ComentariosErrorWidget network({
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    return ComentariosErrorWidget(
      error: customMessage ?? 'Erro de conexão com a internet',
      onRetry: onRetry,
      isRetryable: true,
    );
  }

  /// Factory constructor for validation errors
  static ComentariosErrorWidget validation({
    required String message,
    VoidCallback? onRetry,
  }) {
    return ComentariosErrorWidget(
      error: message,
      onRetry: onRetry,
      isRetryable: false,
    );
  }

  /// Factory constructor for permission errors
  static ComentariosErrorWidget permission({
    String? customMessage,
  }) {
    return ComentariosErrorWidget(
      error: customMessage ?? 'Você não tem permissão para acessar este recurso',
      isRetryable: false,
    );
  }

  /// Factory constructor for generic errors
  static ComentariosErrorWidget generic({
    required String error,
    VoidCallback? onRetry,
  }) {
    return ComentariosErrorWidget(
      error: error,
      onRetry: onRetry,
      isRetryable: true,
    );
  }
}