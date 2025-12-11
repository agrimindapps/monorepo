import 'package:flutter/material.dart';

/// Widget para tratamento de erros com funcionalidades de retry
/// Resolve problemas identificados na análise UX de falta de recovery em estados de erro
class ErrorRecovery extends StatefulWidget {
  final Exception? error;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final Widget? child;
  final ErrorRecoveryStyle style;
  final bool showRetryButton;
  final bool showDismissButton;
  final String? retryText;
  final String? dismissText;
  final Duration autoRetryDelay;
  final int maxAutoRetries;
  final Widget? customErrorWidget;

  const ErrorRecovery({
    super.key,
    this.error,
    this.errorMessage,
    this.onRetry,
    this.onDismiss,
    this.child,
    this.style = ErrorRecoveryStyle.card,
    this.showRetryButton = true,
    this.showDismissButton = false,
    this.retryText,
    this.dismissText,
    this.autoRetryDelay = const Duration(seconds: 3),
    this.maxAutoRetries = 0,
    this.customErrorWidget,
  });

  @override
  State<ErrorRecovery> createState() => _ErrorRecoveryState();
}

class _ErrorRecoveryState extends State<ErrorRecovery>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _shakeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  int _retryCount = 0;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    if (widget.error != null || widget.errorMessage != null) {
      _slideController.forward();
      _scheduleAutoRetry();
    }
  }

  @override
  void didUpdateWidget(ErrorRecovery oldWidget) {
    super.didUpdateWidget(oldWidget);

    final hadError = oldWidget.error != null || oldWidget.errorMessage != null;
    final hasError = widget.error != null || widget.errorMessage != null;

    if (!hadError && hasError) {
      _slideController.forward();
      _scheduleAutoRetry();
    } else if (hadError && !hasError) {
      _slideController.reverse();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _scheduleAutoRetry() {
    if (widget.maxAutoRetries > 0 && _retryCount < widget.maxAutoRetries) {
      Future.delayed(widget.autoRetryDelay, () {
        if (mounted && (widget.error != null || widget.errorMessage != null)) {
          _handleRetry(isAutoRetry: true);
        }
      });
    }
  }

  Future<void> _handleRetry({bool isAutoRetry = false}) async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
      if (!isAutoRetry) _retryCount++;
    });
    if (!isAutoRetry) {
      await _shakeController.forward();
      _shakeController.reset();
    }

    try {
      widget.onRetry?.call();
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);

        if (isAutoRetry) {
          _retryCount++;
          _scheduleAutoRetry();
        }
      }
    }
  }

  void _handleDismiss() {
    _slideController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null || widget.errorMessage != null;

    if (!hasError) {
      return widget.child ?? const SizedBox.shrink();
    }

    return Stack(
      children: [if (widget.child != null) widget.child!, _buildErrorOverlay()],
    );
  }

  Widget _buildErrorOverlay() {
    switch (widget.style) {
      case ErrorRecoveryStyle.card:
        return _buildCardStyle();
      case ErrorRecoveryStyle.banner:
        return _buildBannerStyle();
      case ErrorRecoveryStyle.modal:
        return _buildModalStyle();
      case ErrorRecoveryStyle.snackbar:
        return _buildSnackbarStyle();
      case ErrorRecoveryStyle.inline:
        return _buildInlineStyle();
    }
  }

  Widget _buildCardStyle() {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value * 10, 0),
            child: Card(
              margin: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildErrorContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerStyle() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.errorContainer,
        padding: const EdgeInsets.all(16),
        child: _buildErrorContent(),
      ),
    );
  }

  Widget _buildModalStyle() {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: Card(
            margin: const EdgeInsets.all(32),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildErrorContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSnackbarStyle() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildErrorContent(compact: true),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineStyle() {
    return _buildErrorContent();
  }

  Widget _buildErrorContent({bool compact = false}) {
    final theme = Theme.of(context);

    if (widget.customErrorWidget != null) {
      return widget.customErrorWidget!;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: compact ? 20 : 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ops! Algo deu errado',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: compact ? 14 : null,
                ),
              ),
            ),
            if (widget.showDismissButton)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _handleDismiss,
                iconSize: compact ? 20 : 24,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _getErrorMessage(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onErrorContainer,
            fontSize: compact ? 12 : null,
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 16),
          _buildActionButtons(),
        ] else if (widget.showRetryButton) ...[
          const SizedBox(height: 8),
          _buildCompactActionButtons(),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_retryCount > 0) ...[
          Text(
            'Tentativa ${_retryCount + 1}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onErrorContainer.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 16),
        ],
        if (widget.showDismissButton)
          TextButton(
            onPressed: _handleDismiss,
            child: Text(widget.dismissText ?? 'Dispensar'),
          ),
        if (widget.showRetryButton) ...[
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _isRetrying ? null : () => _handleRetry(),
            icon: _isRetrying
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.refresh, size: 18),
            label: Text(
              _isRetrying
                  ? 'Tentando...'
                  : (widget.retryText ?? 'Tentar Novamente'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_retryCount > 0)
          Text(
            'Tentativa ${_retryCount + 1}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onErrorContainer.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        TextButton.icon(
          onPressed: _isRetrying ? null : () => _handleRetry(),
          icon: _isRetrying
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                )
              : const Icon(Icons.refresh, size: 14),
          label: Text(
            _isRetrying ? 'Tentando...' : 'Tentar',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  String _getErrorMessage() {
    if (widget.errorMessage != null) {
      return widget.errorMessage!;
    }

    if (widget.error != null) {
      return _parseErrorMessage(widget.error!);
    }

    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }

  String _parseErrorMessage(Exception error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network') || message.contains('connection')) {
      return 'Problema de conexão com a internet. Verifique sua conexão e tente novamente.';
    }

    if (message.contains('timeout')) {
      return 'A operação demorou mais que o esperado. Tente novamente.';
    }

    if (message.contains('permission') || message.contains('unauthorized')) {
      return 'Você não tem permissão para realizar esta operação.';
    }

    if (message.contains('not found') || message.contains('404')) {
      return 'Recurso não encontrado. Pode ter sido removido ou movido.';
    }

    if (message.contains('server') || message.contains('500')) {
      return 'Erro interno do servidor. Nossa equipe foi notificada.';
    }

    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }
}

/// Estilos disponíveis para o ErrorRecovery
enum ErrorRecoveryStyle { card, banner, modal, snackbar, inline }

/// Widget específico para erros de rede
class NetworkErrorRecovery extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onOfflineMode;
  final bool isOffline;

  const NetworkErrorRecovery({
    super.key,
    this.onRetry,
    this.onOfflineMode,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorRecovery(
      errorMessage: isOffline
          ? 'Você está offline. Algumas funcionalidades podem estar limitadas.'
          : 'Problema de conexão com a internet.',
      onRetry: onRetry,
      style: ErrorRecoveryStyle.banner,
      customErrorWidget: _buildNetworkErrorWidget(context),
    );
  }

  Widget _buildNetworkErrorWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOffline
            ? Colors.orange.withValues(alpha: 0.1)
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOffline
                ? Icons.wifi_off
                : Icons.signal_wifi_connected_no_internet_4,
            color: isOffline ? Colors.orange : theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOffline ? 'Modo Offline' : 'Sem Conexão',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isOffline
                        ? Colors.orange
                        : theme.colorScheme.onErrorContainer,
                  ),
                ),
                Text(
                  isOffline
                      ? 'Trabalhando com dados locais'
                      : 'Verifique sua conexão com a internet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOffline
                        ? Colors.orange
                        : theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          if (!isOffline && onRetry != null)
            IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh)),
          if (isOffline && onOfflineMode != null)
            TextButton(
              onPressed: onOfflineMode,
              child: const Text('Ver Offline'),
            ),
        ],
      ),
    );
  }
}

/// Widget para erros de validação de formulário
class FormErrorRecovery extends StatelessWidget {
  final Map<String, String> fieldErrors;
  final VoidCallback? onFixErrors;

  const FormErrorRecovery({
    super.key,
    required this.fieldErrors,
    this.onFixErrors,
  });

  @override
  Widget build(BuildContext context) {
    if (fieldErrors.isEmpty) {
      return const SizedBox.shrink();
    }

    return ErrorRecovery(
      style: ErrorRecoveryStyle.card,
      showRetryButton: false,
      customErrorWidget: _buildFormErrorWidget(context),
    );
  }

  Widget _buildFormErrorWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Text(
              'Corrija os erros abaixo:',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...fieldErrors.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.arrow_right,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      children: [
                        TextSpan(
                          text: '${entry.key}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: entry.value),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onFixErrors != null) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onFixErrors,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Corrigir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
          ),
        ],
      ],
    );
  }
}
