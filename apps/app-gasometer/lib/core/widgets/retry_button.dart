import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../widgets/semantic_widgets.dart';

/// Retry button component with built-in loading state and accessibility
class RetryButton extends StatefulWidget {
  const RetryButton({
    super.key,
    required this.onRetry,
    this.label,
    this.semanticLabel,
    this.semanticHint,
    this.icon,
    this.style,
    this.type = RetryButtonType.elevated,
    this.enabled = true,
    this.cooldownDuration,
  });

  /// Factory for network retry
  factory RetryButton.network({
    required VoidCallback onRetry,
    String? customLabel,
    bool enabled = true,
  }) {
    return RetryButton(
      onRetry: onRetry,
      label: customLabel ?? 'Tentar Conectar',
      semanticLabel: 'Tentar conectar novamente',
      semanticHint: 'Tenta estabelecer conexão com o servidor novamente',
      icon: Icons.wifi_protected_setup,
      type: RetryButtonType.elevated,
      enabled: enabled,
      cooldownDuration: const Duration(seconds: 2),
    );
  }

  /// Factory for data reload retry
  factory RetryButton.reload({
    required VoidCallback onRetry,
    String? customLabel,
    bool enabled = true,
  }) {
    return RetryButton(
      onRetry: onRetry,
      label: customLabel ?? 'Recarregar',
      semanticLabel: 'Recarregar dados',
      semanticHint: 'Recarrega os dados da tela atual',
      icon: Icons.refresh,
      type: RetryButtonType.outlined,
      enabled: enabled,
      cooldownDuration: const Duration(seconds: 1),
    );
  }

  /// Factory for form retry
  factory RetryButton.form({
    required VoidCallback onRetry,
    String? customLabel,
    bool enabled = true,
  }) {
    return RetryButton(
      onRetry: onRetry,
      label: customLabel ?? 'Tentar Novamente',
      semanticLabel: 'Tentar enviar formulário novamente',
      semanticHint: 'Tenta enviar os dados do formulário novamente',
      icon: Icons.send,
      type: RetryButtonType.filled,
      enabled: enabled,
      cooldownDuration: const Duration(seconds: 3),
    );
  }

  /// Factory for sync retry
  factory RetryButton.sync({
    required VoidCallback onRetry,
    String? customLabel,
    bool enabled = true,
  }) {
    return RetryButton(
      onRetry: onRetry,
      label: customLabel ?? 'Sincronizar',
      semanticLabel: 'Tentar sincronizar novamente',
      semanticHint: 'Tenta sincronizar os dados com o servidor',
      icon: Icons.sync,
      type: RetryButtonType.elevated,
      enabled: enabled,
      cooldownDuration: const Duration(seconds: 5),
    );
  }

  /// Compact retry button for inline errors
  factory RetryButton.compact({
    required VoidCallback onRetry,
    String? customLabel,
    bool enabled = true,
  }) {
    return RetryButton(
      onRetry: onRetry,
      label: customLabel ?? 'Retry',
      semanticLabel: 'Tentar novamente',
      semanticHint: 'Executa a operação novamente',
      icon: Icons.refresh,
      type: RetryButtonType.text,
      enabled: enabled,
    );
  }
  final VoidCallback onRetry;
  final String? label;
  final String? semanticLabel;
  final String? semanticHint;
  final IconData? icon;
  final ButtonStyle? style;
  final RetryButtonType type;
  final bool enabled;
  final Duration? cooldownDuration;

  @override
  State<RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _inCooldown = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (!widget.enabled || _isLoading || _inCooldown) return;

    setState(() {
      _isLoading = true;
    });

    await _animationController.repeat();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      widget.onRetry();

      // Start cooldown if specified
      if (widget.cooldownDuration != null) {
        setState(() {
          _inCooldown = true;
        });

        await Future<void>.delayed(widget.cooldownDuration!);

        if (mounted) {
          setState(() {
            _inCooldown = false;
          });
        }
      }
    } finally {
      if (mounted) {
        _animationController.stop();
        _animationController.reset();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.enabled || _isLoading || _inCooldown;
    final label = widget.label ?? 'Tentar Novamente';
    final icon = widget.icon ?? Icons.refresh;

    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isLoading)
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Icon(Icons.refresh, size: _getIconSize()),
              );
            },
          )
        else
          Icon(icon, size: _getIconSize()),
        if (widget.type != RetryButtonType.iconOnly) ...[
          const SizedBox(width: GasometerDesignTokens.spacingSm),
          Text(
            _inCooldown ? 'Aguarde...' : label,
            style: _getTextStyle(context),
          ),
        ],
      ],
    );

    return SemanticButton(
      semanticLabel: widget.semanticLabel ?? 'Tentar novamente',
      semanticHint: widget.semanticHint ?? 'Executa a operação novamente',
      onPressed: isDisabled ? null : _handleRetry,
      style: _getButtonStyle(context, isDisabled),
      child: child,
    );
  }

  double _getIconSize() {
    switch (widget.type) {
      case RetryButtonType.iconOnly:
      case RetryButtonType.compact:
        return 20.0;
      case RetryButtonType.text:
        return 16.0;
      default:
        return 18.0;
    }
  }

  TextStyle? _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);

    switch (widget.type) {
      case RetryButtonType.text:
        return theme.textTheme.labelMedium;
      case RetryButtonType.compact:
        return theme.textTheme.labelSmall;
      default:
        return theme.textTheme.labelLarge;
    }
  }

  ButtonStyle? _getButtonStyle(BuildContext context, bool isDisabled) {
    final theme = Theme.of(context);

    ButtonStyle baseStyle = widget.style ?? const ButtonStyle();

    if (widget.type == RetryButtonType.compact) {
      baseStyle = baseStyle.copyWith(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        minimumSize: WidgetStateProperty.all(const Size(80, 32)),
      );
    }

    if (_inCooldown) {
      baseStyle = baseStyle.copyWith(
        foregroundColor: WidgetStateProperty.all(
          theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      );
    }

    return baseStyle;
  }
}

/// Types of retry buttons
enum RetryButtonType { elevated, filled, outlined, text, compact, iconOnly }

/// Retry button with countdown timer
class RetryButtonWithCountdown extends StatefulWidget {
  const RetryButtonWithCountdown({
    super.key,
    required this.onRetry,
    required this.countdownDuration,
    this.label,
    this.icon,
    this.type = RetryButtonType.elevated,
  });
  final VoidCallback onRetry;
  final Duration countdownDuration;
  final String? label;
  final IconData? icon;
  final RetryButtonType type;

  @override
  State<RetryButtonWithCountdown> createState() =>
      _RetryButtonWithCountdownState();
}

class _RetryButtonWithCountdownState extends State<RetryButtonWithCountdown> {
  int? _remainingSeconds;
  Timer? _timer;

  void _startCountdown() {
    setState(() {
      _remainingSeconds = widget.countdownDuration.inSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds = _remainingSeconds! - 1;
      });

      if (_remainingSeconds! <= 0) {
        timer.cancel();
        setState(() {
          _remainingSeconds = null;
        });
      }
    });
  }

  void _handleRetry() {
    widget.onRetry();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCountingDown = _remainingSeconds != null && _remainingSeconds! > 0;

    return RetryButton(
      onRetry: _handleRetry,
      enabled: !isCountingDown,
      label:
          isCountingDown
              ? '${widget.label ?? 'Tentar Novamente'} (${_remainingSeconds}s)'
              : widget.label,
      icon: widget.icon,
      type: widget.type,
    );
  }
}

/// Retry button with attempt counter
class RetryButtonWithCounter extends StatefulWidget {
  const RetryButtonWithCounter({
    super.key,
    required this.onRetry,
    this.maxAttempts = 3,
    this.label,
    this.icon,
    this.type = RetryButtonType.elevated,
    this.onMaxAttemptsReached,
  });
  final VoidCallback onRetry;
  final int maxAttempts;
  final String? label;
  final IconData? icon;
  final RetryButtonType type;
  final VoidCallback? onMaxAttemptsReached;

  @override
  State<RetryButtonWithCounter> createState() => _RetryButtonWithCounterState();
}

class _RetryButtonWithCounterState extends State<RetryButtonWithCounter> {
  int _attemptCount = 0;

  void _handleRetry() {
    _attemptCount++;

    if (_attemptCount >= widget.maxAttempts) {
      widget.onMaxAttemptsReached?.call();
      return;
    }

    widget.onRetry();
  }

  void reset() {
    setState(() {
      _attemptCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasReachedMax = _attemptCount >= widget.maxAttempts;

    String label = widget.label ?? 'Tentar Novamente';
    if (_attemptCount > 0 && !hasReachedMax) {
      label += ' ($_attemptCount/${widget.maxAttempts})';
    }

    return RetryButton(
      onRetry: _handleRetry,
      enabled: !hasReachedMax,
      label: hasReachedMax ? 'Máx. tentativas atingido' : label,
      icon: widget.icon,
      type: widget.type,
      semanticHint:
          hasReachedMax
              ? 'Número máximo de tentativas atingido'
              : 'Tentativa ${_attemptCount + 1} de ${widget.maxAttempts}',
    );
  }
}
