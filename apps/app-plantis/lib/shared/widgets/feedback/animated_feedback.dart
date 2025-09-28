import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'feedback_system.dart';

/// Componentes de animação específicos para feedback visual
class AnimatedFeedback {
  /// Animação de checkmark para sucesso
  static Widget checkmarkAnimation({
    required AnimationController controller,
    Color color = Colors.white,
    double size = 60,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: CheckmarkPainter(progress: controller.value, color: color),
        );
      },
    );
  }

  /// Animação de confetti para sucesso
  static Widget confettiAnimation({
    required AnimationController controller,
    double size = 100,
    int particleCount = 20,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: ConfettiPainter(
            progress: controller.value,
            particleCount: particleCount,
          ),
        );
      },
    );
  }

  /// Animação de shake para erro
  static Widget shakeAnimation({
    required AnimationController controller,
    required Widget child,
    double intensity = 8.0,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final offset = math.sin(controller.value * math.pi * 4) * intensity;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
    );
  }

  /// Animação de pulse para erro
  static Widget pulseAnimation({
    required AnimationController controller,
    required Widget child,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final scale =
            minScale +
            (maxScale - minScale) *
                (math.sin(controller.value * math.pi * 2) * 0.5 + 0.5);
        return Transform.scale(scale: scale, child: child);
      },
    );
  }

  /// Animação de bounce para sucesso
  static Widget bounceAnimation({
    required AnimationController controller,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final bounce = math.sin(controller.value * math.pi);
        return Transform.scale(scale: 1.0 + (bounce * 0.2), child: child);
      },
    );
  }
}

/// Widget que combina feedback visual com animações específicas
class AnimatedFeedbackWidget extends StatefulWidget {
  final FeedbackController controller;
  final VoidCallback? onDismiss;

  const AnimatedFeedbackWidget({
    super.key,
    required this.controller,
    this.onDismiss,
  });

  @override
  State<AnimatedFeedbackWidget> createState() => _AnimatedFeedbackWidgetState();
}

class _AnimatedFeedbackWidgetState extends State<AnimatedFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _specificController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _specificController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _mainController.forward();
    _specificController.forward();

    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _mainController.dispose();
    _specificController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.controller.state == FeedbackState.dismissed) {
      _animateOut();
    } else {
      setState(() {});
    }
  }

  void _animateOut() {
    _mainController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: _buildAnimatedContent(theme),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedContent(ThemeData theme) {
    Widget baseWidget = _buildBaseFeedbackCard(theme);

    // Aplicar animação específica baseada no tipo e animação
    switch (widget.controller.type) {
      case FeedbackType.success:
        return _buildSuccessAnimation(baseWidget);
      case FeedbackType.error:
        return _buildErrorAnimation(baseWidget);
      case FeedbackType.progress:
        return baseWidget; // Progress não precisa de animação específica
    }
  }

  Widget _buildSuccessAnimation(Widget child) {
    final animation = widget.controller.animation as SuccessAnimationType?;

    switch (animation) {
      case SuccessAnimationType.bounce:
        return AnimatedFeedback.bounceAnimation(
          controller: _specificController,
          child: child,
        );
      case SuccessAnimationType.fade:
        return child; // Já tem fade no main controller
      case SuccessAnimationType.confetti:
        return Stack(
          alignment: Alignment.center,
          children: [
            child,
            AnimatedFeedback.confettiAnimation(
              controller: _specificController,
              size: 120,
            ),
          ],
        );
      case SuccessAnimationType.checkmark:
      case null:
      default:
        return child; // Checkmark será no ícone
    }
  }

  Widget _buildErrorAnimation(Widget child) {
    final animation = widget.controller.animation as ErrorAnimationType?;

    switch (animation) {
      case ErrorAnimationType.shake:
        return AnimatedFeedback.shakeAnimation(
          controller: _specificController,
          child: child,
        );
      case ErrorAnimationType.pulse:
        return AnimatedFeedback.pulseAnimation(
          controller: _specificController,
          child: child,
        );
      case ErrorAnimationType.fade:
      case null:
      default:
        return child;
    }
  }

  Widget _buildBaseFeedbackCard(ThemeData theme) {
    Color backgroundColor;
    Color textColor;
    Color iconColor;

    switch (widget.controller.type) {
      case FeedbackType.success:
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        iconColor = Colors.white;
        break;
      case FeedbackType.error:
        backgroundColor = Colors.red.shade600;
        textColor = Colors.white;
        iconColor = Colors.white;
        break;
      case FeedbackType.progress:
        backgroundColor = theme.colorScheme.surface;
        textColor = theme.colorScheme.onSurface;
        iconColor = theme.colorScheme.primary;
        break;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 12,
      shadowColor: backgroundColor.withValues(alpha: 0.4),
      child: Container(
        constraints: const BoxConstraints(minHeight: 70, maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimatedIcon(iconColor),
            const SizedBox(width: 16),
            Expanded(child: _buildContent(textColor)),
            if (widget.controller.actionLabel != null) ...[
              const SizedBox(width: 12),
              _buildAction(textColor),
            ],
            if (widget.controller.type != FeedbackType.progress) ...[
              const SizedBox(width: 12),
              _buildDismissButton(textColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(Color color) {
    if (widget.controller.type == FeedbackType.success &&
        widget.controller.animation == SuccessAnimationType.checkmark) {
      return SizedBox(
        width: 28,
        height: 28,
        child: AnimatedFeedback.checkmarkAnimation(
          controller: _specificController,
          color: color,
          size: 28,
        ),
      );
    }

    if (widget.controller.type == FeedbackType.progress) {
      return SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          value:
              widget.controller.progressType == ProgressType.determinate
                  ? widget.controller.progress
                  : null,
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Icon(widget.controller.icon, color: color, size: 28);
  }

  Widget _buildContent(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.controller.message,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.controller.type == FeedbackType.progress &&
            widget.controller.progressType == ProgressType.determinate) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: widget.controller.progress,
              backgroundColor: textColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(widget.controller.progress * 100).round()}%',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAction(Color textColor) {
    return TextButton(
      onPressed: widget.controller.onAction,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: textColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Text(
        widget.controller.actionLabel!,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildDismissButton(Color textColor) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, color: textColor, size: 16),
      ),
    );
  }
}

/// Painter para animação de checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;

    // Desenhar círculo de fundo
    if (progress > 0.1) {
      final circleProgress = ((progress - 0.1) / 0.3).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(centerX, centerY),
        (size.width * 0.4) * circleProgress,
        paint..style = PaintingStyle.stroke,
      );
    }

    // Desenhar checkmark
    if (progress > 0.4) {
      final checkProgress = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);

      final startX = centerX - size.width * 0.15;
      final startY = centerY;
      final midX = centerX - size.width * 0.05;
      final midY = centerY + size.height * 0.1;
      final endX = centerX + size.width * 0.2;
      final endY = centerY - size.height * 0.15;

      path.moveTo(startX, startY);

      if (checkProgress < 0.5) {
        final t = checkProgress * 2;
        final currentX = startX + (midX - startX) * t;
        final currentY = startY + (midY - startY) * t;
        path.lineTo(currentX, currentY);
      } else {
        path.lineTo(midX, midY);
        final t = (checkProgress - 0.5) * 2;
        final currentX = midX + (endX - midX) * t;
        final currentY = midY + (endY - midY) * t;
        path.lineTo(currentX, currentY);
      }

      canvas.drawPath(path, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Painter para animação de confetti
class ConfettiPainter extends CustomPainter {
  final double progress;
  final int particleCount;

  ConfettiPainter({required this.progress, required this.particleCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = math.Random(42); // Seed fixo para consistência
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance =
          progress * size.width * 0.5 * (0.5 + random.nextDouble() * 0.5);
      final particleSize = 3 + random.nextDouble() * 4;

      final x = size.width * 0.5 + math.cos(angle) * distance;
      final y =
          size.height * 0.5 +
          math.sin(angle) * distance +
          progress * progress * 50; // Gravidade

      paint.color = colors[i % colors.length].withValues(
        alpha: (1.0 - progress * 0.7),
      );

      // Rotação da partícula
      final rotation = progress * math.pi * 2 * (1 + i % 3);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particleSize,
            height: particleSize * 0.6,
          ),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
